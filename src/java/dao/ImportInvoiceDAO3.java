package dao;

import model.ImportInvoice3;
import model.ImportInvoiceDetail3;
import model.Librarian3;
import model.Supplier3;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;

public class ImportInvoiceDAO3 extends DAO3 {

    public ImportInvoiceDAO3() {
        super();
    }

    /**
     * Lấy các lần nhập (hóa đơn nhập) của nhà cung cấp idSupplier trong khoảng từ startDate đến endDate
     * (gồm cả hai đầu), sắp xếp theo ngày nhập. Mỗi hóa đơn kèm danh sách chi tiết (id, số lượng, đơn giá)
     * để trang giao diện cộng được số lượng nhập. Không có hóa đơn nào thì trả về mảng rỗng.
     */
    public ImportInvoice3[] getImportInvoiceBySupplier(int idSupplier, Date startDate, Date endDate) {
        String sql = "SELECT i.id, i.importDate, i.tblLibrarian3tblStaff3tblMember3id AS idLibrarian, "
                + "s.id AS idSupplier, s.name, s.address, s.phoneNumber, s.description, "
                + "d.id AS idDetail, d.quantity, d.unitPrice "
                + "FROM tblImportInvoice3 i "
                + "JOIN tblSupplier3 s ON s.id = i.tblSupplier3id "
                + "LEFT JOIN tblImportInvoiceDetail3 d ON d.tblImportInvoice3id = i.id "
                + "WHERE i.tblSupplier3id = ? AND i.importDate BETWEEN ? AND ? "
                + "ORDER BY i.importDate, i.id, d.id";
        ArrayList<ImportInvoice3> kq = new ArrayList<ImportInvoice3>();
        ArrayList<ImportInvoiceDetail3> details = null;
        synchronized (DAO3.class) {
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, idSupplier);
                ps.setDate(2, new java.sql.Date(startDate.getTime()));
                ps.setDate(3, new java.sql.Date(endDate.getTime()));
                try (ResultSet rs = ps.executeQuery()) {
                    ImportInvoice3 current = null;
                    while (rs.next()) {
                        if (current == null || current.getId() != rs.getInt("id")) {
                            if (current != null) {
                                current.setImportInvoiceDetail(details.toArray(new ImportInvoiceDetail3[0]));
                            }
                            current = new ImportInvoice3();
                            current.setId(rs.getInt("id"));
                            current.setImportDate(rs.getDate("importDate"));
                            Supplier3 supplier = new Supplier3();
                            supplier.setId(rs.getInt("idSupplier"));
                            supplier.setName(rs.getString("name"));
                            supplier.setAddress(rs.getString("address"));
                            supplier.setPhoneNumber(rs.getString("phoneNumber"));
                            supplier.setDescription(rs.getString("description"));
                            current.setSupplier(supplier);
                            Librarian3 librarian = new Librarian3();
                            librarian.setId(rs.getInt("idLibrarian"));
                            current.setLibrarian(librarian);
                            details = new ArrayList<ImportInvoiceDetail3>();
                            kq.add(current);
                        }
                        int idDetail = rs.getInt("idDetail");
                        if (!rs.wasNull()) { // hóa đơn chưa có chi tiết thì LEFT JOIN trả về NULL
                            ImportInvoiceDetail3 detail = new ImportInvoiceDetail3();
                            detail.setId(idDetail);
                            detail.setQuantity(rs.getInt("quantity"));
                            detail.setUnitPrice(rs.getFloat("unitPrice"));
                            details.add(detail);
                        }
                    }
                    if (current != null) {
                        current.setImportInvoiceDetail(details.toArray(new ImportInvoiceDetail3[0]));
                    }
                }
            } catch (SQLException e) {
                throw new IllegalStateException("Lỗi khi lấy các lần nhập của nhà cung cấp: " + e.getMessage(), e);
            }
        }
        return kq.toArray(new ImportInvoice3[0]);
    }
}
