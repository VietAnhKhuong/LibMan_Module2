package model;

import java.util.Date;

/** Thống kê một nhà cung cấp theo số lượng tài liệu nhập trong khoảng thời gian startDate đến endDate. */
public class SupplierStatistic3 extends Supplier3 {
    private Date startDate;
    private Date endDate;
    private int totalQuantityImported;

    public SupplierStatistic3() {
        super();
    }

    public Date getStartDate() { return startDate; }
    public void setStartDate(Date startDate) { this.startDate = startDate; }

    public Date getEndDate() { return endDate; }
    public void setEndDate(Date endDate) { this.endDate = endDate; }

    public int getTotalQuantityImported() { return totalQuantityImported; }
    public void setTotalQuantityImported(int totalQuantityImported) { this.totalQuantityImported = totalQuantityImported; }
}
