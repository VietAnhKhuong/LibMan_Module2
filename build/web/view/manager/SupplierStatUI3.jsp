<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.text.SimpleDateFormat, java.time.LocalDate, java.time.format.DateTimeParseException, java.util.Date, dao.SupplierStatisticDAO3, model.Manager3, model.Supplier3, model.SupplierStatistic3" %>
<%
    Manager3 manager = (Manager3) session.getAttribute("manager");
    if (manager == null) {
        response.sendRedirect(request.getContextPath() + "/view/member/LoginUI3.jsp?err=timeout");
        return;
    }

    // Khoảng thời gian thống kê: vừa nhập ở StatPeriodUI3 (nút subView) hoặc đã lưu trong session khi quay lại từ trang sau
    Date startDate = null;
    Date endDate = null;
    if ("POST".equals(request.getMethod()) && request.getParameter("subView") != null) {
        try {
            startDate = java.sql.Date.valueOf(LocalDate.parse(request.getParameter("inStartDate").trim()));
            endDate = java.sql.Date.valueOf(LocalDate.parse(request.getParameter("inEndDate").trim()));
        } catch (DateTimeParseException | NullPointerException e) {
            startDate = null;
            endDate = null;
        }
        if (startDate == null || endDate == null || startDate.after(endDate)) {
            response.sendRedirect(request.getContextPath() + "/view/manager/StatPeriodUI3.jsp?err=date");
            return;
        }
        session.setAttribute("startDate", startDate);
        session.setAttribute("endDate", endDate);
        session.removeAttribute("supplier"); // khoảng thời gian mới thì bỏ lựa chọn nhà cung cấp cũ
    } else {
        startDate = (Date) session.getAttribute("startDate");
        endDate = (Date) session.getAttribute("endDate");
        if (startDate == null || endDate == null) {
            response.sendRedirect(request.getContextPath() + "/view/manager/StatPeriodUI3.jsp");
            return;
        }
    }

    // Nhà cung cấp đã chọn lần trước (khi quay lại từ ImportListUI3) được tô sáng trong bảng
    Supplier3 supplier = (Supplier3) session.getAttribute("supplier");

    // Lấy thống kê các nhà cung cấp trong khoảng thời gian đó (listStat = null nghĩa là lỗi CSDL)
    SupplierStatistic3[] listStat = null;
    try {
        listStat = (new SupplierStatisticDAO3()).getSupplierStatistic(startDate, endDate);
        session.setAttribute("listStat", listStat);
    } catch (IllegalStateException e) {
        application.log("SupplierStatUI3: lỗi CSDL", e);
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Thống kê NCC theo số lượng nhập - LibMan</title>
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

        .data-table tr.selected td { background: var(--ok-bg); }

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
    </style>
</head>
<body>
<main class="page page-wide">
    <p class="brand">LibMan</p>

    <section class="card">
        <div class="card-head">
            <h1>Thống kê NCC theo số lượng nhập</h1>
            <p>Từ ngày <%= new SimpleDateFormat("dd/MM/yyyy").format(startDate) %> đến ngày <%= new SimpleDateFormat("dd/MM/yyyy").format(endDate) %></p>
        </div>
        <div class="card-body">
            <% if (listStat == null) { %>
            <div class="notice notice-error" role="alert">Hệ thống đang gặp sự cố, vui lòng thử lại sau.</div>
            <% } else if (listStat.length == 0) { %>
            <p class="empty">Không có nhà cung cấp nào nhập tài liệu trong khoảng thời gian này.</p>
            <% } else { %>
            <%-- Bấm vào tên một nhà cung cấp để xem các lần nhập của nhà cung cấp đó --%>
            <form method="post" action="<%= request.getContextPath() %>/view/manager/ImportListUI3.jsp" id="outsubSupplierStatList">
                <table class="data-table">
                    <caption>Danh sách NCC</caption>
                    <thead>
                        <tr><th>TT</th><th>Tên NCC</th><th class="num">Số lượng tài liệu nhập</th></tr>
                    </thead>
                    <tbody>
                        <% for (int i = 0; i < listStat.length; i++) { %>
                        <tr<%= supplier != null && supplier.getId() == listStat[i].getId() ? " class=\"selected\"" : "" %>>
                            <td><%= i + 1 %></td>
                            <td><button type="submit" class="btn-link" name="idSupplier" value="<%= listStat[i].getId() %>"><%= listStat[i].getName().replace("&", "&amp;").replace("<", "&lt;") %></button></td>
                            <td class="num"><%= listStat[i].getTotalQuantityImported() %></td>
                        </tr>
                        <% } %>
                    </tbody>
                    <tfoot>
                        <tr><td></td><td>Tổng</td><td class="num"><%= java.util.Arrays.stream(listStat).mapToInt(SupplierStatistic3::getTotalQuantityImported).sum() %></td></tr>
                    </tfoot>
                </table>
            </form>
            <% } %>
        </div>
    </section>

    <form method="get" action="<%= request.getContextPath() %>/view/manager/StatPeriodUI3.jsp" class="actions">
        <button type="submit" class="btn btn-quiet" id="subBack" name="subBack">Quay lại</button>
    </form>
</main>
</body>
</html>
