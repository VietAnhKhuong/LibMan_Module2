package dao;

import model.Document3;
import model.ImportInvoiceDetail3;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

public class ImportInvoiceDetailDAO3 extends DAO3 {

    public ImportInvoiceDetailDAO3() {
        super();
    }

    /** Lấy chi tiết hóa đơn nhập idImportInvoice, mỗi dòng kèm tài liệu đã nhập. */
    public ImportInvoiceDetail3[] getImportInvoiceDetail(int idImportInvoice) {
        String sql = "SELECT d.id, d.quantity, d.unitPrice, "
                + "doc.id AS idDocument, doc.name, doc.author, doc.description, doc.stockQuantity "
                + "FROM tblImportInvoiceDetail3 d "
                + "JOIN tblDocument3 doc ON doc.id = d.tblDocument3id "
                + "WHERE d.tblImportInvoice3id = ? ORDER BY d.id";
        ArrayList<ImportInvoiceDetail3> kq = new ArrayList<ImportInvoiceDetail3>();
        synchronized (DAO3.class) {
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, idImportInvoice);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        ImportInvoiceDetail3 detail = new ImportInvoiceDetail3();
                        detail.setId(rs.getInt("id"));
                        detail.setQuantity(rs.getInt("quantity"));
                        detail.setUnitPrice(rs.getFloat("unitPrice"));
                        Document3 document = new Document3();
                        document.setId(rs.getInt("idDocument"));
                        document.setName(rs.getString("name"));
                        document.setAuthor(rs.getString("author"));
                        document.setDescription(rs.getString("description"));
                        document.setStockQuantity(rs.getInt("stockQuantity"));
                        detail.setDocument(document);
                        kq.add(detail);
                    }
                }
            } catch (SQLException e) {
                throw new IllegalStateException("Lỗi khi lấy chi tiết hóa đơn nhập: " + e.getMessage(), e);
            }
        }
        return kq.toArray(new ImportInvoiceDetail3[0]);
    }
}
