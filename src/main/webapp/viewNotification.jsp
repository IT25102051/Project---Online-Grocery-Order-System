<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.grocery.dao.NotificationDAO, com.grocery.model.Notification, java.io.*" %>
<%
    String role = (String) session.getAttribute("role");
    if (role == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String id = request.getParameter("id");
    if (id == null || id.trim().isEmpty()) {
        response.sendRedirect("notifications.jsp");
        return;
    }
    NotificationDAO dao = new NotificationDAO(application.getRealPath("/"));
    Notification notif = null;
    try {
        notif = dao.getNotificationById(id);
    } catch (IOException e) {
        // ignore, show not found below
    }
    boolean allowed = false;
    if (notif != null) {
        String recip = notif.getRecipient();
        if (recip == null || recip.trim().isEmpty()) recip = "All";
        if ("All".equalsIgnoreCase(recip) || recip.equalsIgnoreCase(role) || "Admin".equalsIgnoreCase(role)) {
            allowed = true;
            if (!notif.isRead()) {
                notif.setRead(true);
                try { dao.updateNotification(notif); } catch (IOException ignored) {}
            }
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>View Notification</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background:#f3f6fb; color:#0f172a; padding:36px; }
        .card { max-width:900px; margin:40px auto; background:white; border-radius:12px; padding:22px; box-shadow:0 18px 40px rgba(15,23,42,0.06); }
        .title { font-size:22px; font-weight:800; margin-bottom:10px; }
        .meta { color:#64748b; font-size:13px; margin-bottom:16px; }
        .message { color:#334155; line-height:1.6; white-space:pre-wrap; }
        .back { margin-top:18px; display:inline-block; background:#475569; color:white; padding:10px 14px; border-radius:10px; text-decoration:none; }
        .notfound { text-align:center; padding:40px; color:#64748b; }
    </style>
</head>
<body>
<div class="card">
    <% if (notif == null) { %>
        <div class="notfound">Notification not found.</div>
    <% } else if (!allowed) { %>
        <div class="notfound">You are not authorized to view this notification.</div>
    <% } else { %>
        <div class="title"><%= notif.getTitle() %></div>
        <div class="meta">Recipient: <%= notif.getRecipient() %> · Sent: <%= notif.getTimestamp() %></div>
        <div class="message"><%= notif.getMessage() %></div>
        <a href="notifications.jsp" class="back"><i class="fa-solid fa-arrow-left"></i> Back to Notifications</a>
    <% } %>
</div>
</body>
</html>
