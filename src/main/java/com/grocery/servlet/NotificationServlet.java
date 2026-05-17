package com.grocery.servlet;

import com.grocery.dao.NotificationDAO;
import com.grocery.model.Notification;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.UUID;

@WebServlet("/NotificationServlet")
public class NotificationServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        String appPath = getServletContext().getRealPath("/");
        NotificationDAO dao = new NotificationDAO(appPath);

        if ("markRead".equals(action) || "markAllRead".equals(action)) {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("role") == null) {
                response.sendRedirect("login.jsp");
                return;
            }
            if ("markRead".equals(action)) {
                String id = request.getParameter("id");
                if (id != null) {
                    Notification notification = dao.getNotificationById(id);
                    if (notification != null) {
                        notification.setRead(true);
                        dao.updateNotification(notification);
                    }
                }
                String userRole = (String) session.getAttribute("role");
                if ("Delivery".equalsIgnoreCase(userRole)) {
                    response.sendRedirect("deliveryDashboard.jsp?marked=ok");
                } else {
                    response.sendRedirect("notifications.jsp?marked=ok");
                }
                return;
            }
            if ("markAllRead".equals(action)) {
                dao.markAllRead();
                response.sendRedirect("notifications.jsp?markedAll=ok");
                return;
            }
        }

        String adminRole = (String) request.getSession().getAttribute("role");

        if ("delete".equals(action)) {
            String id = request.getParameter("id");
            if (id != null) {
                dao.deleteNotification(id);
            }
            if ("Customer".equalsIgnoreCase(adminRole)) {
                response.sendRedirect("notifications.jsp?deleted=ok");
            } else {
                response.sendRedirect("adminNotifications.jsp?deleted=ok");
            }
            return;
        }

        if (!"Admin".equalsIgnoreCase(adminRole)) {
            response.sendRedirect("adminLogin.jsp");
            return;
        }

        if ("send".equals(action)) {
            String title = request.getParameter("title");
            String message = request.getParameter("message");
            String recipient = request.getParameter("recipient");
            if (recipient == null || recipient.trim().isEmpty()) {
                recipient = "All";
            }

            if (title != null && !title.trim().isEmpty() && message != null && !message.trim().isEmpty()) {
                String id = UUID.randomUUID().toString().substring(0, 8);
                String timestamp = new java.util.Date().toString();
                Notification notification = new Notification(id, recipient.trim(), title.trim(), message.trim(), timestamp, false);
                dao.addNotification(notification);
            }
            response.sendRedirect("adminNotifications.jsp?sent=ok");

        } else if ("edit".equals(action)) {
            String id = request.getParameter("id");
            String title = request.getParameter("title");
            String message = request.getParameter("message");
            String recipient = request.getParameter("recipient");
            if (recipient == null || recipient.trim().isEmpty()) {
                recipient = "All";
            }

            if (id != null && title != null && message != null) {
                String timestamp = new java.util.Date().toString();
                Notification existing = dao.getNotificationById(id);
                boolean currentRead = existing != null && existing.isRead();
                Notification updated = new Notification(id, recipient.trim(), title.trim(), message.trim(), timestamp, currentRead);
                dao.updateNotification(updated);
            }
            response.sendRedirect("adminNotifications.jsp?updated=ok");

        } else {
            response.sendRedirect("adminNotifications.jsp");
        }
    }
}
