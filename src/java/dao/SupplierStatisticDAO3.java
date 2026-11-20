package dao;

import model.SupplierStatistic3;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;

public class SupplierStatisticDAO3 extends DAO3 {

    public SupplierStatisticDAO3() {
        super();
    }

    /**
     * Thống kê các nhà cung cấp có nhập tài liệu trong khoảng từ startDate đến endDate (gồm cả hai đầu),
     * sắp xếp theo số lượng tài liệu nhập giảm dần. Không có nhà cung cấp nào thì trả về mảng rỗng.
     */
    public SupplierStatistic3[] getSupplierStatistic(Date startDate, Date endDate) {
        String sql = "SELECT s.id, s.name, s.address, s.phoneNumber, s.description, SUM(d.quantity) AS total "
                + "FROM tblSupplier3 s "
                + "JOIN tblImportInvoice3 i ON i.tblSupplier3id = s.id "
                + "JOIN tblImportInvoiceDetail3 d ON d.tblImportInvoice3id = i.id "
                + "WHERE i.importDate BETWEEN ? AND ? "
                + "GROUP BY s.id, s.name, s.address, s.phoneNumber, s.description "
                + "ORDER BY total DESC, s.name";
        ArrayList<SupplierStatistic3> kq = new ArrayList<SupplierStatistic3>();
        synchronized (DAO3.class) { // kết nối dùng chung nên mỗi lần truy cập CSDL xếp hàng lần lượt
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setDate(1, new java.sql.Date(startDate.getTime()));
                ps.setDate(2, new java.sql.Date(endDate.getTime()));
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        SupplierStatistic3 ss = new SupplierStatistic3();
                        ss.setId(rs.getInt("id"));
                        ss.setName(rs.getString("name"));
                        ss.setAddress(rs.getString("address"));
                        ss.setPhoneNumber(rs.getString("phoneNumber"));
                        ss.setDescription(rs.getString("description"));
                        ss.setStartDate(startDate);
                        ss.setEndDate(endDate);
                        ss.setTotalQuantityImported(rs.getInt("total"));
                        kq.add(ss);
                    }
                }
            } catch (SQLException e) {
                throw new IllegalStateException("Lỗi khi thống kê nhà cung cấp: " + e.getMessage(), e);
            }
        }
        return kq.toArray(new SupplierStatistic3[0]);
    }
}
