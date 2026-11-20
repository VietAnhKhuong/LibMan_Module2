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
    <title>Chọn loại thống kê - LibMan</title>
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

        .toolbar { display: flex; flex-wrap: wrap; gap: 12px; margin: 20px 0 4px; }

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
        
                .btn-quiet {
            background: transparent;
            color: var(--pine-dark);
            border: 1px solid var(--line);
        }

        .btn-quiet:hover { background: var(--desk); }
    </style>
</head>
<body>
<main class="page">
    <p class="brand">LibMan</p>

    <section class="card">
        <div class="card-head">
            <h1>Chọn loại thống kê</h1>
            <p>Tên: <%= manager.getName().replace("&", "&amp;").replace("<", "&lt;") %> &middot; Chức vụ: <%= manager.getPosition().replace("&", "&amp;").replace("<", "&lt;") %></p>
        </div>
        <div class="card-body">
            <div id="outsubStatTypeList" class="toolbar">
                <form method="get" action="<%= request.getContextPath() %>/view/manager/StatPeriodUI3.jsp">
                    <button type="submit" class="btn" name="statType" value="supplier">Thống kê NCC theo số lượng</button>
                </form>
                <%-- Loại thống kê này thuộc modul khác, chưa có trang xử lí --%>
                <button type="button" class="btn" disabled title="Chưa triển khai">Thống kê các tài liệu theo số lần mượn</button>
            </div>
        </div>
    </section>
                <form method="post" class="actions">
        <button type="submit" class="btn btn-quiet" id="subLogout" name="subLogout">Đăng xuất</button>
    </form>
</main>
</body>
</html>
