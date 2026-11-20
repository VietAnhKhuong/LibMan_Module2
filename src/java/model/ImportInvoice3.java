package model;

import java.util.Date;

public class ImportInvoice3 {
    private Date importDate;
    private int id;
    private ImportInvoiceDetail3[] importInvoiceDetail;
    private Supplier3 supplier;
    private Librarian3 librarian;

    public ImportInvoice3() {
    }

    public Date getImportDate() { return importDate; }
    public void setImportDate(Date importDate) { this.importDate = importDate; }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public ImportInvoiceDetail3[] getImportInvoiceDetail() { return importInvoiceDetail; }
    public void setImportInvoiceDetail(ImportInvoiceDetail3[] importInvoiceDetail) { this.importInvoiceDetail = importInvoiceDetail; }

    public Supplier3 getSupplier() { return supplier; }
    public void setSupplier(Supplier3 supplier) { this.supplier = supplier; }

    public Librarian3 getLibrarian() { return librarian; }
    public void setLibrarian(Librarian3 librarian) { this.librarian = librarian; }
}
