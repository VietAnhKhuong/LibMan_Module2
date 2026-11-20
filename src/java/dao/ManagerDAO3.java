package dao;

import model.Manager3;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import java.security.GeneralSecurityException;
import java.security.MessageDigest;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Base64;

public class ManagerDAO3 extends DAO3 {

    public ManagerDAO3() {
        super();
    }

    /**
     * Kiểm tra đăng nhập của nhân viên quản lí theo manager.username và manager.password (mật khẩu gốc).
     * Đúng thì điền đầy đủ thông tin của nhân viên quản lí vào manager (mật khẩu được xóa khỏi đối tượng)
     * và trả về true. Sai tên đăng nhập, sai mật khẩu hoặc tài khoản không phải quản lí đều trả về false.
     */
    public boolean checkLogin(Manager3 manager) {
        String sql = "SELECT m.id, m.name, m.password, m.birthday, m.address, m.email, m.phoneNumber, "
                + "s.position, s.salary "
                + "FROM tblMember3 m "
                + "JOIN tblStaff3 s ON s.tblMember3id = m.id "
                + "JOIN tblManager3 g ON g.tblStaff3tblMember3id = s.tblMember3id "
                + "WHERE m.username = ?";
        synchronized (DAO3.class) { // kết nối dùng chung nên mỗi lần truy cập CSDL xếp hàng lần lượt
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, manager.getUsername());
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        return false;
                    }
                    // Mật khẩu trong CSDL có dạng iterations:salt:hash (Base64), băm bằng PBKDF2 khi đăng kí
                    String[] stored = rs.getString("password").split(":");
                    if (stored.length != 3) {
                        return false;
                    }
                    try {
                        byte[] salt = Base64.getDecoder().decode(stored[1]);
                        byte[] expected = Base64.getDecoder().decode(stored[2]);
                        byte[] actual = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256")
                                .generateSecret(new PBEKeySpec(manager.getPassword().toCharArray(), salt,
                                        Integer.parseInt(stored[0]), expected.length * 8))
                                .getEncoded();
                        if (!MessageDigest.isEqual(expected, actual)) {
                            return false;
                        }
                    } catch (IllegalArgumentException | GeneralSecurityException e) {
                        return false; // chuỗi mật khẩu trong CSDL sai định dạng
                    }
                    manager.setId(rs.getInt("id"));
                    manager.setName(rs.getString("name"));
                    manager.setBirthday(rs.getDate("birthday"));
                    manager.setAddress(rs.getString("address"));
                    manager.setEmail(rs.getString("email"));
                    manager.setPhoneNumber(rs.getString("phoneNumber"));
                    manager.setPosition(rs.getString("position"));
                    manager.setSalary(rs.getFloat("salary"));
                    manager.setPassword(null);
                    return true;
                }
            } catch (SQLException e) {
                throw new IllegalStateException("Lỗi khi kiểm tra đăng nhập: " + e.getMessage(), e);
            }
        }
    }
}
