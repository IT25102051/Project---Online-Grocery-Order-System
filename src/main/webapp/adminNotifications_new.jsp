<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.io.*, java.util.*" %>
<%
    String adminName = (String) session.getAttribute("username");
    String adminRole = (String) session.getAttribute("role");
    if (adminName == null || !"Admin".equalsIgnoreCase(adminRole)) {
        response.sendRedirect("adminLogin.jsp");
        return;
    }

    String dataDir = application.getRealPath("/") + "data/";
    String sent = request.getParameter("sent");
    String editId = request.getParameter("edit");

    // Load existing notifications: id,title,message,timestamp
    List<String[]> notifs = new ArrayList<>();
    File nf = new File(dataDir + "notifications.txt");
    if (nf.exists()) {
        BufferedReader br = new BufferedReader(new FileReader(nf));
        String line;
        while ((line = br.readLine()) != null) {
            line = line.trim();
            if (line.isEmpty()) continue;
            notifs.add(line.split(",", 4));
        }
        br.close();
    }
    Collections.reverse(notifs);

    // Find notification to edit
    String[] editNotif = null;
    if (editId != null) {
        for (String[] n : notifs) {
            if (n.length >= 4 && n[0].equals(editId)) {
                editNotif = n;
                break;
            }
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Notifications - CeylonFresh Admin</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f3f6fb; display: flex; min-height: 100vh; color: #334155; }
        .sidebar { width: 260px; background: linear-gradient(135deg,#0f766e 0%,#16a34a 100%); color: white; padding: 20px 0; position: fixed; height: 100vh; overflow-y: auto; box-shadow: 2px 0 18px rgba(15,23,42,0.12); }
        .sidebar-brand { text-align: center; padding: 24px 20px; border-bottom: 1px solid rgba(255,255,255,0.18); margin-bottom: 20px; }
        .logo-text { font-size: 26px; font-weight: 800; color: white; letter-spacing: 1px; }
        .logo-text span { color: #fbbf24; }
        .logo-sub { font-size: 12px; color: rgba(255,255,255,0.72); margin-top: 6px; letter-spacing: 0.5px; }
        .sidebar-admin { display: flex; align-items: center; gap: 12px; padding: 18px 20px; border-bottom: 1px solid rgba(255,255,255,0.18); margin-bottom: 18px; }
        .sa-avatar { width: 44px; height: 44px; background: #fde047; color: #0f172a; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 18px; }
        .sa-info strong { display: block; font-size: 14px; line-height: 1.2; }
        .sa-info span { font-size: 12px; color: rgba(255,255,255,0.78); }
        .nav-section { padding: 14px 20px 6px; font-size: 11px; text-transform: uppercase; color: rgba(255,255,255,0.65); letter-spacing: 1px; }
        .sidebar a { display: block; color: white; text-decoration: none; padding: 13px 20px; transition: all 0.25s ease-in-out; border-left: 3px solid transparent; font-size: 14px; }
        .sidebar a:hover, .sidebar a.active { background: rgba(255,255,255,0.12); border-left-color: #fbbf24; }
        .sidebar a i { width: 20px; margin-right: 12px; }
        .sidebar-footer { position: absolute; bottom: 0; width: 100%; padding: 20px; }
        .logout-btn { display: block; background: rgba(255,255,255,0.12); border: 1px solid rgba(255,255,255,0.22); border-radius: 10px; padding: 12px 14px; text-align: center; color: white; font-weight: 600; }
        .logout-btn:hover { background: rgba(255,255,255,0.18); }
        .main { margin-left: 260px; flex: 1; }
        .topbar { background: white; padding: 24px 30px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #e2e8f0; }
        .topbar-left h2 { margin: 0; color: #0f172a; font-size: 26px; letter-spacing: -0.02em; }
        .breadcrumb { color: #64748b; font-size: 13px; margin-top: 8px; }
        .topbar-right { display: flex; align-items: center; gap: 14px; }
        .topbar-date { color: #475569; font-size: 14px; padding: 10px 14px; background: #f8fafc; border-radius: 10px; }
        .notif-btn { background: #16a34a; color: white; border: none; padding: 11px 16px; border-radius: 10px; cursor: pointer; font-weight: 600; }
        .content { padding: 30px; }
        .stat-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 20px; margin-bottom: 28px; }
        .stat-card { background: white; padding: 24px; border-radius: 18px; box-shadow: 0 18px 40px rgba(15,23,42,0.06); border: 1px solid rgba(148,163,184,0.12); }
        .stat-top { display: flex; align-items: center; justify-content: space-between; margin-bottom: 18px; }
        .stat-icon { width: 52px; height: 52px; border-radius: 14px; display: flex; align-items: center; justify-content: center; color: white; font-size: 20px; }
        .stat-icon.blue { background: #2563eb; }
        .stat-icon.green { background: #16a34a; }
        .stat-icon.purple { background: #8b5cf6; }
        .stat-num { font-size: 32px; font-weight: 800; color: #0f172a; margin-bottom: 6px; }
        .stat-label { color: #64748b; font-size: 14px; }
        .layout-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; }
        .panel { background: white; border-radius: 20px; box-shadow: 0 18px 40px rgba(15,23,42,0.06); border: 1px solid rgba(148,163,184,0.12); overflow: hidden; }
        .panel-header { padding: 24px 28px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; }
        .panel-header h3 { margin: 0; font-size: 20px; color: #0f172a; }
        .panel-header span { color: #64748b; font-size: 14px; }
        .panel-body { padding: 24px 28px 28px; }
        .form-group { margin-bottom: 18px; }
        .form-group label { display: block; font-weight: 700; margin-bottom: 8px; color: #0f172a; }
        .form-group input, .form-group textarea { width: 100%; padding: 14px 16px; border-radius: 14px; border: 1px solid #cbd5e1; font-size: 14px; color: #0f172a; background: #f8fafc; }
        .form-group input:focus, .form-group textarea:focus { outline: none; border-color: #16a34a; background: white; }
        .form-group textarea { height: 120px; resize: vertical; }
        .form-actions { display: flex; gap: 14px; flex-wrap: wrap; margin-top: 10px; }
        .btn { display: inline-flex; align-items: center; justify-content: center; gap: 10px; border: none; border-radius: 14px; padding: 14px 18px; background: #16a34a; color: white; font-weight: 700; cursor: pointer; transition: background 0.25s ease; }
        .btn:hover { background: #15803d; }
        .btn-secondary { background: #475569; }
        .btn-secondary:hover { background: #334155; }
        .success-message { background: #dcfce7; color: #166534; padding: 12px 16px; border-radius: 12px; margin-bottom: 20px; border: 1px solid #bbf7d0; }
        .notification-list { margin-top: 24px; }
        .notification-item { display: flex; align-items: flex-start; gap: 16px; padding: 20px; border: 1px solid #e2e8f0; border-radius: 12px; margin-bottom: 16px; background: #fafbfc; }
        .notification-icon { width: 40px; height: 40px; background: #16a34a; color: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 16px; flex-shrink: 0; }
        .notification-content { flex: 1; }
        .notification-title { font-weight: 700; color: #0f172a; margin-bottom: 6px; }
        .notification-message { color: #64748b; line-height: 1.5; }
        .notification-meta { font-size: 12px; color: #94a3b8; margin-top: 8px; }
        .action-buttons { display: flex; gap: 10px; flex-wrap: wrap; }
        .btn-edit { background: #3b82f6; color: white; }
        .btn-delete { background: #ef4444; color: white; }
        .empty-state { padding: 40px; color: #64748b; text-align: center; }
        @media (max-width: 1024px) { .layout-grid { grid-template-columns: 1fr; } }
    </style>
</head>
<body>
<div class="sidebar">
    <div class="sidebar-brand">
        <div class="logo-text">Fresh<span>Cart</span></div>
        <div class="logo-sub">Admin Panel</div>
    </div>
    <div class="sidebar-admin">
        <div class="sa-avatar"><%= adminName.substring(0,1).toUpperCase() %></div>
        <div class="sa-info">
            <strong><%= adminName %></strong>
            <span>Administrator</span>
        </div>
    </div>
    <div class="nav-section">Main</div>
    <a href="adminDashboard.jsp"><i class="fa-solid fa-gauge"></i> Dashboard</a>
    <div class="nav-section">Manage</div>
    <a href="adminProducts.jsp"><i class="fa-solid fa-box"></i> Products</a>
    <a href="adminUsers.jsp"><i class="fa-solid fa-users"></i> Users</a>
    <a href="adminOrders.jsp"><i class="fa-solid fa-shopping-cart"></i> Orders</a>
    <a href="adminPayments.jsp"><i class="fa-solid fa-credit-card"></i> Payments</a>
    <a href="inventory.jsp"><i class="fa-solid fa-warehouse"></i> Inventory</a>
    <div class="nav-section">Content</div>
    <a href="adminReviews.jsp"><i class="fa-solid fa-star"></i> Reviews</a>
    <a href="adminNotifications.jsp" class="active"><i class="fa-solid fa-bell"></i> Notifications</a>
    <div class="sidebar-footer">
        <a href="LogoutServlet" class="logout-btn">Logout</a>
    </div>
</div>
<div class="main">
    <div class="topbar">
        <div class="topbar-left">
            <h2>Manage Notifications</h2>
            <div class="breadcrumb">Admin / Notifications</div>
        </div>
        <div class="topbar-right">
            <div class="topbar-date">Today: <%= new java.util.Date().toString().substring(0,10) %></div>
        </div>
    </div>
    <div class="content">
        <div class="stat-grid">
            <div class="stat-card">
                <div class="stat-top">
                    <div class="stat-icon blue"><i class="fa-solid fa-bell"></i></div>
                </div>
                <div class="stat-num"><%= notifs.size() %></div>
                <div class="stat-label">Total Notifications</div>
            </div>
        </div>
        <div class="layout-grid">
            <div class="panel">
                <div class="panel-header">
                    <h3><%= editNotif != null ? "Edit Notification" : "Send New Notification" %></h3>
                    <span><%= editNotif != null ? "Update existing notification" : "Broadcast to all customers" %></span>
                </div>
                <div class="panel-body">
                    <% if ("ok".equals(sent)) { %>
                    <div class="success-message">
                        <i class="fa-solid fa-check-circle"></i> Notification sent successfully to all customers!
                    </div>
                    <% } %>
                    <form action="NotificationServlet" method="post">
                        <input type="hidden" name="action" value="<%= editNotif != null ? "edit" : "send" %>">
                        <% if (editNotif != null) { %>
                        <input type="hidden" name="id" value="<%= editNotif[0] %>">
                        <% } %>
                        <div class="form-group">
                            <label>Notification Title</label>
                            <input type="text" name="title" placeholder="e.g. Weekend Sale Alert!" value="<%= editNotif != null ? editNotif[1].replace(";", ",") : "" %>" required>
                        </div>
                        <div class="form-group">
                            <label>Message Content</label>
                            <textarea name="message" placeholder="Enter your notification message here..." required><%= editNotif != null ? editNotif[2].replace(";", ",") : "" %></textarea>
                        </div>
                        <div class="form-actions">
                            <button type="submit" class="btn">
                                <i class="fa-solid fa-paper-plane"></i> <%= editNotif != null ? "Update Notification" : "Send to All Customers" %>
                            </button>
                            <% if (editNotif != null) { %>
                            <a href="adminNotifications.jsp" class="btn btn-secondary">
                                <i class="fa-solid fa-times"></i> Cancel
                            </a>
                            <% } %>
                        </div>
                    </form>
                </div>
            </div>
            <div class="panel">
                <div class="panel-header">
                    <h3>Notification History</h3>
                    <span><%= notifs.size() %> notifications sent</span>
                </div>
                <div class="panel-body">
                    <% if (notifs.isEmpty()) { %>
                    <div class="empty-state">No notifications have been sent yet. Create your first notification above.</div>
                    <% } else { %>
                    <div class="notification-list">
                        <% for (String[] n : notifs) {
                            String nid = n.length > 0 ? n[0] : "";
                            String ntitle = n.length > 1 ? n[1].replace(";", ",") : "—";
                            String nmsg = n.length > 2 ? n[2].replace(";", ",") : "—";
                            String ntime = n.length > 3 ? n[3] : "—";
                        %>
                        <div class="notification-item">
                            <div class="notification-icon">
                                <i class="fa-solid fa-bell"></i>
                            </div>
                            <div class="notification-content">
                                <div class="notification-title"><%= ntitle %></div>
                                <div class="notification-message"><%= nmsg.length() > 100 ? nmsg.substring(0, 100) + "…" : nmsg %></div>
                                <div class="notification-meta">Sent: <%= ntime %></div>
                            </div>
                            <div class="action-buttons">
                                <a href="adminNotifications.jsp?edit=<%= nid %>" class="btn btn-edit">
                                    <i class="fa-solid fa-pen"></i> Edit
                                </a>
                                <form action="NotificationServlet" method="post" style="display:inline;">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id" value="<%= nid %>">
                                    <button type="submit" class="btn btn-delete" onclick="return confirm('Are you sure you want to delete this notification?')">
                                        <i class="fa-solid fa-trash"></i> Delete
                                    </button>
                                </form>
                            </div>
                        </div>
                        <% } %>
                    </div>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
