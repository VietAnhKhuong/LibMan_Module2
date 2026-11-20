<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.ManagerDAO3, model.Manager3" %>
<%
    request.setCharacterEncoding("UTF-8");

    // Chỉ nhận dữ liệu do nút Đăng nhập (subLogin) của LoginUI3 gửi lên
    if (!"POST".equals(request.getMethod()) || request.getParameter("subLogin") == null) {
        response.sendRedirect(request.getContextPath() + "/view/member/LoginUI3.jsp");
        return;
    }

    // Đóng gói tên đăng nhập và mật khẩu vào Manager3
    Manager3 manager = new Manager3();
    manager.setUsername(request.getParameter("inUsername").trim());
    manager.setPassword(request.getParameter("inPassword"));

    if (manager.getUsername().isEmpty() || manager.getPassword().isEmpty()) {
        request.setAttribute("outNotification", "Vui lòng nhập tên đăng nhập và mật khẩu.");
    } else {
        try {
            if ((new ManagerDAO3()).checkLogin(manager)) {
                // Đăng nhập đúng: cấp mã phiên mới (chống session fixation), lưu Manager3 vào session
                request.changeSessionId();
                session.setAttribute("manager", manager);
                response.sendRedirect(request.getContextPath() + "/view/manager/ManagerMainUI3.jsp");
                return;
            }
            // Không nói rõ sai tên đăng nhập hay sai mật khẩu
            request.setAttribute("outNotification", "Tên đăng nhập hoặc mật khẩu không đúng.");
        } catch (IllegalStateException e) {
            application.log("doLogin3: lỗi CSDL", e);
            request.setAttribute("outNotification", "Hệ thống đang gặp sự cố, vui lòng thử lại sau.");
        }
    }

    // Không đăng nhập được: quay lại form kèm thông báo và tên đăng nhập đã nhập (không kèm mật khẩu)
    manager.setPassword(null);
    request.setAttribute("manager", manager);
    request.getRequestDispatcher("/view/member/LoginUI3.jsp").forward(request, response);
%>
