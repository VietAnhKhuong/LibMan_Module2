<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.text.SimpleDateFormat, java.util.Date, dao.ImportInvoiceDAO3, model.ImportInvoice3, model.ImportInvoiceDetail3, model.Manager3, model.Supplier3, model.SupplierStatistic3" %>
<%
    Manager3 manager = (Manager3) session.getAttribute("manager");
    if (manager == null) {
        response.sendRedirect(request.getContextPath() + "/view/member/LoginUI3.jsp?err=timeout");
        return;
    }

    // Khoảng thời gian thống kê và danh sách thống kê do SupplierStatUI3 lưu vào session
    Date startDate = (Date) session.getAttribute("startDate");
    Date endDate = (Date) session.getAttribute("endDate");
    if (startDate == null || endDate == null || session.getAttribute("listStat") == null) {
        response.sendRedirect(request.getContextPath() + "/view/manager/StatPeriodUI3.jsp");
        return;
    }

    // Nhà cung cấp được chọn: idSupplier gửi từ SupplierStatUI3, hoặc đã lưu trong session khi quay lại từ ImportDetailUI3
    Supplier3 supplier = null;
    if (request.getParameter("idSupplier") != null) {
        try {
            for (SupplierStatistic3 s : (SupplierStatistic3[]) session.getAttribute("listStat")) {
                if (s.getId() == Integer.parseInt(request.getParameter("idSupplier").trim())) {
                    supplier = s;
                }
            }
        } catch (NumberFormatException e) {
            supplier = null;
        }
    } else {
        supplier = (Supplier3) session.getAttribute("supplier");
    }
    if (supplier == null) {
        response.sendRedirect(request.getContextPath() + "/view/manager/SupplierStatUI3.jsp");
        return;
    }
    session.setAttribute("supplier", supplier);

    // Lấy các lần nhập của nhà cung cấp trong khoảng thời gian thống kê (listInvoice = null nghĩa là lỗi CSDL)
    ImportInvoice3[] listInvoice = null;
    try {
        listInvoice = (new ImportInvoiceDAO3()).getImportInvoiceBySupplier(supplier.getId(), startDate, endDate);
        session.setAttribute("listInvoice", listInvoice);
    } catch (IllegalStateException e) {
        application.log("ImportListUI3: lỗi CSDL", e);
    }
    // Xử lý sự kiện khi bấm nút Đăng xuất (subLogout)
    if (request.getParameter("subLogout") != null) {
        session.invalidate();
        response.sendRedirect(request.getContextPath() + "/view/member/LoginUI3.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Các hóa đơn của NCC - LibMan</title>
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

        .btn-link {
            padding: 0;
            font: inherit;
            font-weight: 600;
            color: var(--pine-dark);
            background: none;
            border: 0;
            border-bottom: 1px solid var(--pine);
            cursor: pointer;
        }

        .btn-link:hover { color: var(--pine); }

        .btn-link:focus-visible { outline: 3px solid #7fb8a8; outline-offset: 2px; }

        .empty { margin: 16px 0 4px; color: var(--muted); }
        
                .btn-logout {
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
            white-space: nowrap;
        }

        .btn-logout:hover { 
            background: var(--pine-dark); 
        }
    </style>
</head>
<body>
<main class="page page-wide">
    <p class="brand">LibMan</p>

    <section class="card">
        <div class="card-head">
            <h1>Các hóa đơn của NCC <%= supplier.getName().replace("&", "&amp;").replace("<", "&lt;") %></h1>
            <p>Tên: <%= manager.getName().replace("&", "&amp;").replace("<", "&lt;") %> &middot; Chức vụ: <%= manager.getPosition().replace("&", "&amp;").replace("<", "&lt;") %></p>
            <p>Từ ngày <%= new SimpleDateFormat("dd/MM/yyyy").format(startDate) %> đến ngày <%= new SimpleDateFormat("dd/MM/yyyy").format(endDate) %></p>
        </div>
        <div class="card-body">
            <% if (listInvoice == null) { %>
            <div class="notice notice-error" role="alert">Hệ thống đang gặp sự cố, vui lòng thử lại sau.</div>
            <% } else if (listInvoice.length == 0) { %>
            <p class="empty">Nhà cung cấp này không có lần nhập nào trong khoảng thời gian đã chọn.</p>
            <% } else { %>
            <%-- Bấm vào ngày nhập để xem chi tiết hóa đơn của lần nhập đó --%>
            <form method="post" action="<%= request.getContextPath() %>/view/manager/ImportDetailUI3.jsp" id="outsubImportInvoiceList">
                <table class="data-table">
                    <caption>Danh sách hóa đơn</caption>
                    <thead>
                        <tr><th>TT</th><th>Ngày nhập tài liệu</th><th class="num">Số lượng nhập</th></tr>
                    </thead>
                    <tbody>
                        <% for (int i = 0; i < listInvoice.length; i++) { %>
                        <tr>
                            <td><%= i + 1 %></td>
                            <td><button type="submit" class="btn-link" name="idImportInvoice" value="<%= listInvoice[i].getId() %>"><%= new SimpleDateFormat("dd/MM/yyyy").format(listInvoice[i].getImportDate()) %></button></td>
                            <td class="num"><%= java.util.Arrays.stream(listInvoice[i].getImportInvoiceDetail()).mapToInt(ImportInvoiceDetail3::getQuantity).sum() %></td>
                        </tr>
                        <% } %>
                    </tbody>
                    <tfoot>
                        <tr><td></td><td>Tổng</td><td class="num"><%= java.util.Arrays.stream(listInvoice).flatMap(inv -> java.util.Arrays.stream(inv.getImportInvoiceDetail())).mapToInt(ImportInvoiceDetail3::getQuantity).sum() %></td></tr>
                    </tfoot>
                </table>
            </form>
            <% } %>
        </div>
    </section>

    <form method="get" action="<%= request.getContextPath() %>/view/manager/SupplierStatUI3.jsp" class="actions">
        <button type="submit" class="btn btn-quiet" id="subBack" name="subBack">Quay lại</button>
    </form>
    <form method="post" class="actions">
                <button type="submit" class="btn btn-quiet" id="subLogout" name="subLogout">Đăng xuất</button>
            </form>
</main>
</body>
</html>
