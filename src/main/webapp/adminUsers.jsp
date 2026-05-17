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
    String deleted = request.getParameter("deleted");
    List<String[]> users = new ArrayList<>();
    File uf = new File(dataDir + "users.txt");
    if (uf.exists()) {
        BufferedReader br = new BufferedReader(new FileReader(uf));
        String line;
        while ((line = br.readLine()) != null) {
            line = line.trim();
            if (line.isEmpty()) continue;
            users.add(line.split(",", 6));
        }
        br.close();
    }

    int customers = 0, admins = 0;
    for (String[] u : users) {
        if (u.length >= 5) {
            if ("Customer".equalsIgnoreCase(u[4].trim())) customers++;
            else if ("Admin".equalsIgnoreCase(u[4].trim())) admins++;
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Users - CeylonFresh Admin</title>
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
        .panel { background: white; border-radius: 20px; box-shadow: 0 18px 40px rgba(15,23,42,0.06); border: 1px solid rgba(148,163,184,0.12); overflow: hidden; }
        .panel-header { padding: 24px 28px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; }
        .panel-header h3 { margin: 0; font-size: 20px; color: #0f172a; }
        .panel-header span { color: #64748b; font-size: 14px; }
        .panel-body { padding: 24px 28px 28px; }
        .table-wrap { overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; min-width: 720px; }
        th, td { text-align: left; padding: 16px 18px; border-bottom: 1px solid #e2e8f0; }
        thead th { color: #334155; font-size: 14px; text-transform: uppercase; letter-spacing: 0.08em; border-bottom: 2px solid #e2e8f0; }
        tbody tr:hover { background: #f8fafc; }
        .user-name { font-weight: 700; color: #0f172a; }
        .badge { display: inline-flex; align-items: center; gap: 6px; padding: 6px 12px; border-radius: 999px; font-size: 12px; font-weight: 700; color: #0f172a; background: #f8fafc; }
        .badge.admin { color: #dc2626; background: #fee2e2; }
        .badge.customer { color: #16a34a; background: #dcfce7; }
        .empty-state { padding: 40px; color: #64748b; text-align: center; }
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
    <a href="adminUsers.jsp" class="active"><i class="fa-solid fa-users"></i> Users</a>
    <a href="adminOrders.jsp"><i class="fa-solid fa-shopping-cart"></i> Orders</a>
    <a href="adminPayments.jsp"><i class="fa-solid fa-credit-card"></i> Payments</a>
    <a href="inventory.jsp"><i class="fa-solid fa-warehouse"></i> Inventory</a>
    <div class="nav-section">Content</div>
    <a href="adminReviews.jsp"><i class="fa-solid fa-star"></i> Reviews</a>
    <a href="adminNotifications.jsp"><i class="fa-solid fa-bell"></i> Notifications</a>
    <div class="sidebar-footer">
        <a href="LogoutServlet" class="logout-btn">Logout</a>
    </div>
</div>
<div class="main">
    <div class="topbar">
        <div class="topbar-left">
            <h2>Manage Users</h2>
            <div class="breadcrumb">Admin / Users</div>
        </div>
        <div class="topbar-right">
            <div class="topbar-date">📅 <%= new java.util.Date().toString().substring(0, 10) %></div>
            <button class="notif-btn"><i class="fa-solid fa-plus"></i> Add New</button>
        </div>
    </div>
    <div class="content">
        <div class="stat-grid">
            <div class="stat-card">
                <div class="stat-top">
                    <div class="stat-icon blue"><i class="fa-solid fa-users"></i></div>
                </div>
                <div class="stat-num"><%= users.size() %></div>
                <div class="stat-label">Total Users</div>
            </div>
            <div class="stat-card">
                <div class="stat-top">
                    <div class="stat-icon green"><i class="fa-solid fa-user"></i></div>
                </div>
                <div class="stat-num"><%= customers %></div>
                <div class="stat-label">Customers</div>
            </div>
            <div class="stat-card">
                <div class="stat-top">
                    <div class="stat-icon purple"><i class="fa-solid fa-user-shield"></i></div>
                </div>
                <div class="stat-num"><%= admins %></div>
                <div class="stat-label">Admins</div>
            </div>
        </div>
        <div class="panel">
            <div class="panel-header">
                <h3>User Directory</h3>
                <span>Manage registered accounts</span>
            </div>
            <div class="panel-body">
                <% if ("ok".equals(deleted)) { %>
                <div class="success-message" style="margin-bottom:20px; padding:16px; background:#dcfce7; color:#166534; border-radius:12px; border:1px solid #bbf7d0;">
                    <i class="fa-solid fa-check-circle"></i> User removed successfully.
                </div>
                <% } %>
                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>User</th>
                                <th>Email</th>
                                <th>User ID</th>
                                <th>Role</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (users.isEmpty()) { %>
                            <tr><td colspan="5" class="empty-state">No users found. New registrations will appear here.</td></tr>
                            <% } else {
                                int index = 1;
                                for (String[] u : users) {
                                    String uid = u.length > 0 ? u[0].trim() : "—";
                                    String uname = u.length > 1 ? u[1].trim() : "—";
                                    String uemail = u.length > 2 ? u[2].trim() : "—";
                                    String urole = u.length > 4 ? u[4].trim() : "Customer";
                            %>
                            <tr>
                                <td><%= index++ %></td>
                                <td><div class="user-name"><%= uname %></div></td>
                                <td><%= uemail %></td>
                                <td><%= uid.length() > 12 ? uid.substring(0, 12) + "…" : uid %></td>
                                <td><span class="badge <%= urole.toLowerCase() %>"><%= urole %></span></td>
                                <td>
                                    <% if (!"Admin".equalsIgnoreCase(urole)) { %>
                                    <form action="UserServlet" method="post" style="display:inline;">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="id" value="<%= uid %>">
                                        <button type="submit" class="btn btn-delete" onclick="return confirm('Remove this user?')">Delete</button>
                                    </form>
                                    <% } else { %>
                                    <span class="badge admin">Protected</span>
                                    <% } %>
                                </td>
                            </tr>
                            <% }
                            } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>


