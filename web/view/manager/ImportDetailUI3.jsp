<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.text.SimpleDateFormat, java.util.Date, dao.ImportInvoiceDetailDAO3, model.ImportInvoice3, model.ImportInvoiceDetail3, model.Manager3, model.Supplier3" %>
<%
    Manager3 manager = (Manager3) session.getAttribute("manager");
    if (manager == null) {
        response.sendRedirect(request.getContextPath() + "/view/member/LoginUI3.jsp?err=timeout");
        return;
    }

    // Nhà cung cấp, khoảng thời gian và danh sách hóa đơn do các trang trước lưu vào session
    Date startDate = (Date) session.getAttribute("startDate");
    Date endDate = (Date) session.getAttribute("endDate");
    Supplier3 supplier = (Supplier3) session.getAttribute("supplier");
    if (startDate == null || endDate == null || supplier == null || session.getAttribute("listInvoice") == null) {
        response.sendRedirect(request.getContextPath() + "/view/manager/StatPeriodUI3.jsp");
        return;
    }

    // Lần nhập được chọn: idImportInvoice gửi từ ImportListUI3, hoặc đã lưu trong session khi tải lại trang
    ImportInvoice3 invoice = null;
    if (request.getParameter("idImportInvoice") != null) {
        try {
            for (ImportInvoice3 i : (ImportInvoice3[]) session.getAttribute("listInvoice")) {
                if (i.getId() == Integer.parseInt(request.getParameter("idImportInvoice").trim())) {
                    invoice = i;
                }
            }
        } catch (NumberFormatException e) {
            invoice = null;
        }
    } else {
        invoice = (ImportInvoice3) session.getAttribute("invoice");
    }
    if (invoice == null) {
        response.sendRedirect(request.getContextPath() + "/view/manager/ImportListUI3.jsp");
        return;
    }
    session.setAttribute("invoice", invoice);

    // Lấy chi tiết hóa đơn (listDetail = null nghĩa là lỗi CSDL)
    ImportInvoiceDetail3[] listDetail = null;
    try {
        listDetail = (new ImportInvoiceDetailDAO3()).getImportInvoiceDetail(invoice.getId());
    } catch (IllegalStateException e) {
        application.log("ImportDetailUI3: lỗi CSDL", e);
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Chi tiết hóa đơn nhập - LibMan</title>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700&display=swap">
    <style>
        :root {
            --ink: #17212b;
            --muted: #5d6b78;
            --paper: #ffffff;
            --desk: #e9eef0;
            --pine: #1d5c4c;
            --pine-dark: #134234;
            --line: #c9d3d8;
            --alert-bg: #fdecea;
            --alert-ink: #8a1f17;
            --ok-bg: #e4f4ec;
            --ok-ink: #14583c;
        }

        * { box-sizing: border-box; }

        body {
            margin: 0;
            min-height: 100vh;
            background: var(--desk);
            color: var(--ink);
            font-family: "Be Vietnam Pro", "Segoe UI", system-ui, -apple-system, sans-serif;
            font-size: 16px;
            line-height: 1.5;
        }

        .page {
            max-width: 640px;
            margin: 0 auto;
            padding: 40px 20px 64px;
        }

        .brand {
            font-size: 1.1rem;
            font-weight: 700;
            color: var(--pine-dark);
            margin: 0 0 28px;
        }

        .card {
            background: var(--paper);
            border: 1px solid var(--line);
            border-radius: 6px;
            overflow: hidden;
        }

        .card-head {
            background: var(--pine);
            color: #fff;
            padding: 18px 24px;
        }

        .card-head h1 { margin: 0; font-size: 1.35rem; font-weight: 600; }

        .card-head p { margin: 4px 0 0; font-size: .92rem; opacity: .9; }

        .card-body { padding: 8px 24px 24px; }

        .btn:focus-visible {
            outline: 3px solid #7fb8a8;
            outline-offset: 1px;
        }

        .actions { margin-top: 24px; display: flex; gap: 12px; align-items: center; }

        .btn {
            display: inline-block;
            padding: 10px 22px;
            font: inherit;
            font-weight: 600;
            color: #fff;
            background: var(--pine);
            border: 0;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
        }

        .btn:hover { background: var(--pine-dark); }

        .btn-quiet {
            background: transparent;
            color: var(--pine-dark);
            border: 1px solid var(--line);
        }

        .btn-quiet:hover { background: var(--desk); }

        .notice {
            margin: 16px 0 0;
            padding: 12px 14px;
            border-radius: 4px;
            font-size: .95rem;
        }

        .notice-error { background: var(--alert-bg); color: var(--alert-ink); }

        .page-wide { max-width: 860px; }

        .btn[disabled] { background: var(--line); color: var(--muted); cursor: not-allowed; }

        .btn[disabled]:hover { background: var(--line); }

        .data-table { width: 100%; border-collapse: collapse; margin: 16px 0 4px; }

        .data-table caption { text-align: left; font-weight: 600; padding-bottom: 8px; }

        .data-table th,
        .data-table td { padding: 10px 12px; text-align: left; border-bottom: 1px solid var(--line); }

        .data-table th { font-size: .9rem; color: var(--muted); font-weight: 500; border-bottom: 2px solid var(--ink); }

        .data-table .num { text-align: right; font-variant-numeric: tabular-nums; }

        .data-table tfoot td { font-weight: 700; border-bottom: 0; border-top: 2px solid var(--ink); }

        .empty { margin: 16px 0 4px; color: var(--muted); }
    </style>
</head>
<body>
<main class="page page-wide">
    <p class="brand">LibMan</p>

    <section class="card">
        <div class="card-head">
            <h1>Chi tiết hóa đơn của NCC <%= supplier.getName().replace("&", "&amp;").replace("<", "&lt;") %> ngày <%= new SimpleDateFormat("dd/MM/yyyy").format(invoice.getImportDate()) %></h1>
        </div>
        <div class="card-body">
            <% if (listDetail == null) { %>
            <div class="notice notice-error" role="alert">Hệ thống đang gặp sự cố, vui lòng thử lại sau.</div>
            <% } else if (listDetail.length == 0) { %>
            <p class="empty">Hóa đơn này chưa có tài liệu nào.</p>
            <% } else { %>
            <table class="data-table" id="outImportInvoiceDetailList">
                <caption>Chi tiết hóa đơn</caption>
                <thead>
                    <tr><th>TT</th><th>Mã tài liệu</th><th>Tên tài liệu</th><th class="num">Số lượng</th></tr>
                </thead>
                <tbody>
                    <% for (int i = 0; i < listDetail.length; i++) { %>
                    <tr>
                        <td><%= i + 1 %></td>
                        <td><%= listDetail[i].getDocument().getId() %></td>
                        <td><%= listDetail[i].getDocument().getName().replace("&", "&amp;").replace("<", "&lt;") %></td>
                        <td class="num"><%= listDetail[i].getQuantity() %></td>
                    </tr>
                    <% } %>
                </tbody>
                <tfoot>
                    <tr><td></td><td></td><td>Tổng</td><td class="num"><%= java.util.Arrays.stream(listDetail).mapToInt(ImportInvoiceDetail3::getQuantity).sum() %></td></tr>
                </tfoot>
            </table>
            <% } %>
        </div>
    </section>

    <form method="get" action="<%= request.getContextPath() %>/view/manager/ImportListUI3.jsp" class="actions">
        <button type="submit" class="btn btn-quiet" id="subBack" name="subBack">Quay lại</button>
    </form>
</main>
</body>
</html>
