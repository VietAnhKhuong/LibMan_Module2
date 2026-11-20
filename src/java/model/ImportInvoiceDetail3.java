package model;

public class ImportInvoiceDetail3 {
    private int id;
    private int quantity;
    private float unitPrice;
    private Document3 document;

    public ImportInvoiceDetail3() {
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public float getUnitPrice() { return unitPrice; }
    public void setUnitPrice(float unitPrice) { this.unitPrice = unitPrice; }

    public Document3 getDocument() { return document; }
    public void setDocument(Document3 document) { this.document = document; }
}
