package dao;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Lớp cha (trừu tượng) của mọi lớp DAO. Kết nối con được dùng chung cho toàn hệ thống (static)
 * và chỉ được mở lại khi chưa có hoặc đã bị mất.
 */
public abstract class DAO3 {
    protected static Connection con;

    public DAO3() {
        synchronized (DAO3.class) {
            try {
                if (con == null || con.isClosed() || !con.isValid(2)) {
                    Properties p = new Properties();
                    try (InputStream in = DAO3.class.getClassLoader().getResourceAsStream("db.properties")) {
                        if (in == null) {
                            throw new IllegalStateException("Không tìm thấy db.properties");
                        }
                        p.load(in);
                    }
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    con = DriverManager.getConnection(
                            p.getProperty("db.url"), p.getProperty("db.user"), p.getProperty("db.password"));
                }
            } catch (IOException | ClassNotFoundException | SQLException e) {
                throw new IllegalStateException("Không kết nối được CSDL: " + e.getMessage(), e);
            }
        }
    }
}
