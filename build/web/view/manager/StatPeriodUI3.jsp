<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.Manager3" %>
<%
    Manager3 manager = (Manager3) session.getAttribute("manager");
    if (manager == null) {
        response.sendRedirect(request.getContextPath() + "/view/member/LoginUI3.jsp?err=timeout");
        return;
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

        .field {
            display: grid;
            grid-template-columns: 170px 1fr;
            gap: 4px 16px;
            align-items: center;
            padding: 12px 0;
            border-bottom: 1px solid var(--line);
        }

        .field label { font-weight: 500; }

        input[type="text"],
        input[type="email"],
        input[type="password"],
        input[type="date"] {
            width: 100%;
            padding: 8px 10px;
            font: inherit;
            color: var(--ink);
            background: #fff;
            border: 1px solid var(--line);
            border-radius: 4px;
        }

        input:focus-visible,
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

        @media (max-width: 560px) {    .field { grid-template-columns: 1fr; }
        }

        .btn[disabled] { background: var(--line); color: var(--muted); cursor: not-allowed; }

        .btn[disabled]:hover { background: var(--line); }
        
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
<main class="page">
    <p class="brand">LibMan</p>

    <form class="card" method="post" action="<%= request.getContextPath() %>/view/manager/SupplierStatUI3.jsp" novalidate>
        <div class="card-head">
            <h1>Thống kê NCC theo số lượng nhập</h1>
            <p>Tên: <%= manager.getName().replace("&", "&amp;").replace("<", "&lt;") %> &middot; Chức vụ: <%= manager.getPosition().replace("&", "&amp;").replace("<", "&lt;") %></p>
            <p>Chọn khoảng thời gian thống kê</p>
        </div>
        <div class="card-body">
            <%-- SupplierStatUI3 chuyển về đây kèm err=date khi ngày nhập sai --%>
            <% if ("date".equals(request.getParameter("err"))) { %>
            <div class="notice notice-error" role="alert">Vui lòng chọn ngày bắt đầu và ngày kết thúc hợp lệ, ngày bắt đầu không được sau ngày kết thúc.</div>
            <% } %>

            <div class="field">
                <label for="inStartDate">Ngày bắt đầu</label>
                <input type="date" id="inStartDate" name="inStartDate"
                       value="<%= session.getAttribute("startDate") == null ? "" : session.getAttribute("startDate") %>">
            </div>
            <div class="field">
                <label for="inEndDate">Ngày kết thúc</label>
                <input type="date" id="inEndDate" name="inEndDate"
                       value="<%= session.getAttribute("endDate") == null ? "" : session.getAttribute("endDate") %>">
            </div>

            <div class="actions">
                <button type="submit" class="btn" id="subView" name="subView">Xem TK</button>
            </div>
        </div>
    </form>

    <form method="get" action="<%= request.getContextPath() %>/view/manager/StatTypeUI3.jsp" class="actions">
        <button type="submit" class="btn btn-quiet" id="subBack" name="subBack">Quay lại</button>
    </form>
        <form method="post" class="actions">
                <button type="submit" class="btn btn-quiet" id="subLogout" name="subLogout">Đăng xuất</button>
            </form>
</main>
</body>
</html>
