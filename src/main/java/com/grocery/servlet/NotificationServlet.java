package com.grocery.servlet;

import com.grocery.dao.NotificationDAO;
import com.grocery.model.Notification;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.UUID; //used to generate unique IDs

@WebServlet("/NotificationServlet")
public class NotificationServlet extends HttpServlet { //inherits HttpServlets features

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) // handle POST requests from forms
            throws ServletException, IOException { //handles servlet and file errors

        String action = request.getParameter("action");//gets action from form(send,edit,delete,markRead)
        String appPath = getServletContext().getRealPath("/"); // get project real path
        NotificationDAO dao = new NotificationDAO(appPath); // create DAO object

        if ("markRead".equals(action) || "markAllRead".equals(action)) {// check if action is markRead or markAllRead
            HttpSession session = request.getSession(false); //get existing session,does not create new session
            if (session == null || session.getAttribute("role") == null) { //check user login
                response.sendRedirect("login.jsp"); //redirect to login page
                return;
            }
            if ("markRead".equals(action)) { //check single read action
                String id = request.getParameter("id"); //get notification ID
                if (id != null) {
                    Notification notification = dao.getNotificationById(id); // finds notification
                    if (notification != null) {
                        notification.setRead(true); //change read status
                        dao.updateNotification(notification); //update file data
                    }
                }
                String userRole = (String) session.getAttribute("role"); //gets logged user role
                if ("Delivery".equalsIgnoreCase(userRole)) { //check if user is delivery person
                    response.sendRedirect("deliveryDashboard.jsp?marked=ok"); //redirects delivery dashboard
                } else {
                    response.sendRedirect("notifications.jsp?marked=ok");//redirect customer notification dashboard
                }
                return;
            }
            if ("markAllRead".equals(action)) { //check mark all read action
                dao.markAllRead(); //marl all notifications read
                response.sendRedirect("notifications.jsp?markedAll=ok"); //redirects page
                return;
            }
        }

        String adminRole = (String) request.getSession().getAttribute("role"); //gets current user role

        if ("delete".equals(action)) { //check delete action
            String id = request.getParameter("id"); //get notification ID
            if (id != null) {
                dao.deleteNotification(id); //delete notification
            }
            if ("Customer".equalsIgnoreCase(adminRole)) { //check if customer
                response.sendRedirect("notifications.jsp?deleted=ok");
            } else {
                response.sendRedirect("adminNotifications.jsp?deleted=ok");
            }
            return;
        }

        if (!"Admin".equalsIgnoreCase(adminRole)) { // check admin access
            response.sendRedirect("adminLogin.jsp"); //redirects unauthorized users
            return;
        }

        if ("send".equals(action)) { //check send action
            String title = request.getParameter("title");
            String message = request.getParameter("message");
            String recipient = request.getParameter("recipient");
            if (recipient == null || recipient.trim().isEmpty()) {
                recipient = "All";
            }

            if (title != null && !title.trim().isEmpty() && message != null && !message.trim().isEmpty()) {
                String id = UUID.randomUUID().toString().substring(0, 8); //generate random unique ID
                String timestamp = new java.util.Date().toString(); //get current date and time
                Notification notification = new Notification(id, recipient.trim(), title.trim(), message.trim(), timestamp, false);
                dao.addNotification(notification);
            }
            response.sendRedirect("adminNotifications.jsp?sent=ok");

        } else if ("edit".equals(action)) { //check edit action
            String id = request.getParameter("id");
            String title = request.getParameter("title");
            String message = request.getParameter("message");
            String recipient = request.getParameter("recipient");
            if (recipient == null || recipient.trim().isEmpty()) {
                recipient = "All";
            }

            if (id != null && title != null && message != null) {
                String timestamp = new java.util.Date().toString();
                Notification existing = dao.getNotificationById(id); // keeps old read/unread state
                boolean currentRead = existing != null && existing.isRead();
                Notification updated = new Notification(id, recipient.trim(), title.trim(), message.trim(), timestamp, currentRead);
                dao.updateNotification(updated); //save update notification
            }
            response.sendRedirect("adminNotifications.jsp?updated=ok");// redirect admin page

        } else {
            response.sendRedirect("adminNotifications.jsp");// redirects if no valid action
        }
    }
}
