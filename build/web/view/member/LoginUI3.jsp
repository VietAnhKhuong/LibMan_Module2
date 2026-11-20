<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.Manager3" %>
<%
    // Do doLogin3.jsp chuyển lại khi đăng nhập không thành công: thông báo lỗi (outNotification) và
    // tên đăng nhập đã nhập (manager). Các trang quản lí chuyển về đây kèm err=timeout khi chưa đăng nhập.
    String outNotification = (String) request.getAttribute("outNotification");
    if (outNotification == null && "timeout".equals(request.getParameter("err"))) {
        outNotification = "Bạn chưa đăng nhập hoặc phiên làm việc đã hết hạn, vui lòng đăng nhập.";
    }
    Manager3 manager = (Manager3) request.getAttribute("manager");
    if (manager == null) {
        manager = new Manager3();
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Đăng nhập - LibMan</title>
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
    </style>
</head>
<body>
<main class="page">
    <p class="brand">LibMan</p>

    <form class="card" method="post" action="<%= request.getContextPath() %>/view/member/doLogin3.jsp" novalidate>
        <div class="card-head">
            <h1>Đăng nhập</h1>
            <p>Đăng nhập để sử dụng hệ thống thư viện.</p>
        </div>

        <div class="card-body">
            <% if (outNotification != null) { %>
            <div class="notice notice-error" id="outNotification" role="alert"><%= outNotification %></div>
            <% } %>

            <div class="field">
                <label for="inUsername">Tên đăng nhập</label>
                <input type="text" id="inUsername" name="inUsername" maxlength="30" autocomplete="username"
                       value="<%= java.util.Objects.toString(manager.getUsername(), "").replace("&", "&amp;").replace("<", "&lt;").replace("\"", "&quot;") %>">
            </div>
            <div class="field">
                <label for="inPassword">Mật khẩu</label>
                <input type="password" id="inPassword" name="inPassword" maxlength="72" autocomplete="current-password">
            </div>

            <div class="actions">
                <button type="submit" class="btn" id="subLogin" name="subLogin">Đăng nhập</button>
            </div>
        </div>
    </form>
</main>
</body>
</html>
