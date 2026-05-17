<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.io.*, java.util.*" %>
<%
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
    String userId = (String) session.getAttribute("userId");

    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String notificationsPath = application.getRealPath("/") + "data/notifications.txt";
    List<String[]> notifications = new ArrayList<>();
    File notifFile = new File(notificationsPath);
    int unreadCount = 0;
    if (notifFile.exists()) {
        try (BufferedReader br = new BufferedReader(new FileReader(notifFile))) {
            String line;
            while ((line = br.readLine()) != null) {
                line = line.trim();
                if (line.isEmpty()) continue;
                String[] raw = line.split(",", 6);
                String recipient = "All";
                String title = "";
                String message = "";
                String time = "";
                String readFlag = "unread";
                if (raw.length == 6) {
                    recipient = raw[1].trim();
                    title = raw[2];
                    message = raw[3];
                    time = raw[4];
                    readFlag = raw[5].trim();
                } else if (raw.length == 5) {
                    recipient = raw[1].trim();
                    title = raw[2];
                    message = raw[3];
                    time = raw[4];
                    readFlag = "unread";
                }
                boolean allowed = "All".equalsIgnoreCase(recipient)
                        || (role != null && recipient.equalsIgnoreCase(role))
                        || (userId != null && recipient.equalsIgnoreCase(userId));
                if (allowed) {
                    notifications.add(new String[]{raw[0], recipient, title, message, time, readFlag});
                    if (!"read".equalsIgnoreCase(readFlag)) {
                        unreadCount++;
                    }
                }
            }
        }
    }
    Collections.reverse(notifications);
    int totalNotifications = notifications.size();
%>
<!DOCTYPE html>
<html>
<head>
    <title>Notifications - CeylonFresh</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        :root {
            --primary: #064e3b;
            --primary-light: #10b981;
            --bg-color: #f8fafc;
            --text-main: #0f172a;
        }
        *{margin:0;padding:0;box-sizing:border-box;font-family:'Outfit',sans-serif;}
        body{background:var(--bg-color); color:var(--text-main); display: flex; min-height: 100vh;}

        /* SIDEBAR */
        .sidebar{position:fixed;left:0;top:0;width:280px;height:100vh;background:linear-gradient(180deg,var(--primary),#065f46);padding:35px 25px;color:white;box-shadow:5px 0 20px rgba(0,0,0,0.08);z-index:100;}
        .logo{font-size:28px;font-weight:800;margin-bottom:50px;display:flex;align-items:center;gap:10px;color:white;text-decoration:none;}
        .logo i {color:var(--primary-light);}
        .menu a{display:flex;align-items:center;gap:15px;padding:16px 18px;margin-bottom:12px;text-decoration:none;color:rgba(255,255,255,0.8);border-radius:16px;transition:0.3s;font-weight:600;font-size:16px;}
        .menu a:hover{background:rgba(255,255,255,0.1);color:white;transform:translateX(5px);}
        .menu a.active{background:white;color:var(--primary);box-shadow:0 10px 20px rgba(0,0,0,0.1);}
        .menu a.logout{margin-top:50px;color:#fca5a5;}
        .menu a.logout:hover{background:rgba(239,68,68,0.1);color:#ef4444;}

        /* MAIN CONTENT */
        .main{margin-left:280px;flex:1;padding:40px;}
        .header{margin-bottom:40px;display:flex;justify-content:space-between;align-items:center;}
        .header h1{font-size:36px;font-weight:800;color:var(--primary);}

        /* STATS */
        .stats{display:grid;grid-template-columns:repeat(3,1fr);gap:24px;margin-bottom:40px;}
        .stat-card{background:white;padding:30px;border-radius:24px;box-shadow:0 10px 30px rgba(0,0,0,0.03);text-align:center;}
        .stat-card h2{font-size:32px;color:var(--primary);margin-bottom:8px;}
        .stat-card p{color:#64748b;font-weight:600;font-size:14px;}

        /* NOTIFICATION LIST */
        .notif-section{background:white;padding:40px;border-radius:30px;box-shadow:0 10px 30px rgba(0,0,0,0.03);}
        .section-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:30px;}
        .mark-btn{padding:12px 24px;background:var(--primary-light);color:white;border:none;border-radius:12px;font-weight:700;cursor:pointer;transition:0.3s;}
        .mark-btn:hover{background:var(--primary);transform:translateY(-2px);}

        .notif-card{display:flex;gap:20px;padding:24px;border-radius:20px;background:#f8fafc;margin-bottom:20px;border:1px solid #e2e8f0;transition:0.3s;position:relative;}
        .notif-card:hover{border-color:var(--primary-light);background:white;transform:translateX(5px);}
        .notif-card.unread{border-left:5px solid var(--primary-light);background:rgba(16,185,129,0.02);}

        .icon-box{width:60px;height:60px;border-radius:16px;display:flex;justify-content:center;align-items:center;font-size:24px;flex-shrink:0;}
        .icon-order{background:#dcfce7;color:#166534;}
        .icon-promo{background:#fef3c7;color:#92400e;}
        .icon-alert{background:#fee2e2;color:#991b1b;}
        .icon-payment{background:#dbeafe;color:#1e40af;}

        .notif-content{flex:1;}
        .notif-content h3{font-size:18px;color:var(--primary);margin-bottom:6px;}
        .notif-content p{color:#475569;line-height:1.6;font-size:15px;}
        .notif-time{margin-top:10px;font-size:12px;color:#94a3b8;font-weight:600;}

        .notif-actions{display:flex;flex-direction:column;gap:10px;justify-content:center;}
        .action-btn{padding:8px 16px;border-radius:8px;font-size:12px;font-weight:700;cursor:pointer;border:none;transition:0.2s;}
        .btn-read{background:#e2e8f0;color:#475569;}
        .btn-read:hover{background:var(--primary-light);color:white;}
        .btn-del{background:none;color:#ef4444;}
        .btn-del:hover{background:#fee2e2;}

        @media(max-width:1100px){
            .sidebar{display:none;}
            .main{margin-left:0;}
            .stats{grid-template-columns:1fr;}
        }
    </style>
</head>
<body>

<div class="sidebar">
    <a href="customerDashboard.jsp" class="logo"><i class="fa-solid fa-leaf"></i> CeylonFresh</a>
    <div class="menu">
        <a href="customerDashboard.jsp"><i class="fa-solid fa-gauge"></i> Dashboard</a>
        <a href="products.jsp"><i class="fa-solid fa-store"></i> Products</a>
        <a href="OrderHistoryServlet"><i class="fa-solid fa-box"></i> Orders</a>
        <a href="notifications.jsp" class="active"><i class="fa-solid fa-bell"></i> Notifications</a>
        <a href="reviews.jsp"><i class="fa-solid fa-star"></i> Reviews</a>
        <a href="profile.jsp"><i class="fa-solid fa-user"></i> Profile</a>
        <a href="LogoutServlet" class="logout"><i class="fa-solid fa-right-from-bracket"></i> Logout</a>
    </div>
</div>

<div class="main">
    <div class="header">
        <h1>Notifications</h1>
    </div>

    <div class="stats">
        <div class="stat-card">
            <h2><%= totalNotifications %></h2>
            <p>Total Messages</p>
        </div>
        <div class="stat-card">
            <h2><%= unreadCount %></h2>
            <p>Unread Alerts</p>
        </div>
        <div class="stat-card">
            <h2><%= totalNotifications > 0 ? "Active" : "None" %></h2>
            <p>System Status</p>
        </div>
    </div>

    <div class="notif-section">
        <div class="section-header">
            <h2 style="color:var(--primary);">Recent Updates</h2>
            <% if (unreadCount > 0) { %>
            <form action="NotificationServlet" method="post">
                <input type="hidden" name="action" value="markAllRead">
                <button type="submit" class="mark-btn">Mark All Read</button>
            </form>
            <% } %>
        </div>

        <% if (notifications.isEmpty()) { %>
            <div style="text-align:center;padding:60px;color:#94a3b8;">
                <i class="fa-solid fa-bell-slash" style="font-size:48px;margin-bottom:20px;opacity:0.3;"></i>
                <p>No notifications at the moment.</p>
            </div>
        <% } else {
            for (String[] n : notifications) {
                String id = n[0];
                String title = n[2];
                String msg = n[3];
                String time = n[4];
                boolean isRead = "read".equalsIgnoreCase(n[5]);

                String iconClass = "icon-order";
                String icon = "fa-bell";
                if (title.toLowerCase().contains("order")) { iconClass="icon-order"; icon="fa-cart-shopping"; }
                else if (title.toLowerCase().contains("promo") || title.toLowerCase().contains("offer")) { iconClass="icon-promo"; icon="fa-gift"; }
                else if (title.toLowerCase().contains("payment")) { iconClass="icon-payment"; icon="fa-credit-card"; }
                else if (title.toLowerCase().contains("alert")) { iconClass="icon-alert"; icon="fa-circle-exclamation"; }
        %>
        <div class="notif-card <%= isRead ? "" : "unread" %>">
            <div class="icon-box <%= iconClass %>">
                <i class="fa-solid <%= icon %>"></i>
            </div>
            <div class="notif-content">
                <h3><%= title %></h3>
                <p><%= msg %></p>
                <div class="notif-time"><i class="fa-regular fa-clock"></i> <%= time %></div>
            </div>
            <div class="notif-actions">
                <% if (!isRead) { %>
                <form action="NotificationServlet" method="post">
                    <input type="hidden" name="action" value="markRead">
                    <input type="hidden" name="id" value="<%= id %>">
                    <button type="submit" class="action-btn btn-read">Mark Read</button>
                </form>
                <% } %>
                <form action="NotificationServlet" method="post" onsubmit="return confirm('Delete this notification?')">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="id" value="<%= id %>">
                    <button type="submit" class="action-btn btn-del"><i class="fa-solid fa-trash-can"></i></button>
                </form>
            </div>
        </div>
        <% } } %>
    </div>
</div>

</body>
</html>
