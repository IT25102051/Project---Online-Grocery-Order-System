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

    int totalProducts = 0;
    File pf = new File(dataDir + "products.txt");
    if (pf.exists()) {
        BufferedReader br = new BufferedReader(new FileReader(pf));
        while (br.readLine() != null) totalProducts++;
        br.close();
    }

    int totalUsers = 0;
    File uf = new File(dataDir + "users.txt");
    if (uf.exists()) {
        BufferedReader br = new BufferedReader(new FileReader(uf));
        String line;
        while ((line = br.readLine()) != null) {
            String[] p = line.split(",");
            if (p.length >= 5 && "Customer".equalsIgnoreCase(p[4].trim())) totalUsers++;
        }
        br.close();
    }

    int totalOrders = 0;
    double totalRevenue = 0;
    int newOrdersCount = 0;
    File of = new File(dataDir + "orders.txt");
    if (of.exists()) {
        BufferedReader br = new BufferedReader(new FileReader(of));
        String line;
        while ((line = br.readLine()) != null) {
            line = line.trim(); if (line.isEmpty()) continue;
            totalOrders++;
            String[] p = line.split(",");
            if (p.length >= 8 && "Confirmed".equalsIgnoreCase(p[7].trim())) {
                newOrdersCount++;
            }
            if (p.length >= 4) {
                try { totalRevenue += Double.parseDouble(p[3].trim()); } catch (Exception e) {}
            }
        }
        br.close();
    }

    List<String[]> recentOrders = new ArrayList<>();
    if (of.exists()) {
        BufferedReader br = new BufferedReader(new FileReader(of));
        String line;
        while ((line = br.readLine()) != null) {
            line = line.trim(); if (line.isEmpty()) continue;
            recentOrders.add(line.split(",", 9));
        }
        br.close();
    }
    Collections.reverse(recentOrders);
    if (recentOrders.size() > 5) recentOrders = recentOrders.subList(0, 5);

    List<String[]> lowStock = new ArrayList<>();
    if (pf.exists()) {
        BufferedReader br = new BufferedReader(new FileReader(pf));
        String line;
        while ((line = br.readLine()) != null) {
            line = line.trim(); if (line.isEmpty()) continue;
            String[] p = line.split(",", 6);
            if (p.length >= 5) {
                try {
                    int stock = Integer.parseInt(p[4].trim());
                    if (stock < 20) lowStock.add(p);
                } catch (Exception e) {}
            }
        }
        br.close();
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - CeylonFresh</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Outfit', sans-serif; }
        body { background: #f8fafc; display: flex; min-height: 100vh; color: #0f172a; }
        .sidebar { width: 260px; background: linear-gradient(135deg, #064e3b 0%, #10b981 100%); color: white; padding: 20px 0; position: fixed; height: 100vh; overflow-y: auto; box-shadow: 2px 0 20px rgba(0,0,0,0.1); }
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
        .topbar-date { color: #475569; font-size: 14px; padding: 10px 14px; background: #f8fafc; border-radius: 10px; display: flex; align-items: center; gap: 8px; }
        .logout-link { color: #ef4444; text-decoration: none; font-size: 14px; font-weight: 700; padding: 10px 16px; background: #fef2f2; border: 1px solid #fee2e2; border-radius: 10px; display: flex; align-items: center; gap: 8px; transition: all 0.2s; }
        .logout-link:hover { background: #fee2e2; transform: translateY(-1px); }
        .notif-btn { background: #16a34a; color: white; border: none; padding: 11px 16px; border-radius: 10px; cursor: pointer; font-weight: 600; }
        .content { padding: 30px; }
        .stat-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 20px; margin-bottom: 28px; }
        .stat-card { background: white; padding: 24px; border-radius: 18px; box-shadow: 0 18px 40px rgba(15,23,42,0.06); border: 1px solid rgba(148,163,184,0.12); transition: all 0.3s ease; }
        .stat-card:hover { transform: translateY(-4px); box-shadow: 0 24px 48px rgba(15,23,42,0.12); }
        .stat-top { display: flex; align-items: center; justify-content: space-between; margin-bottom: 18px; }
        .stat-icon { width: 52px; height: 52px; border-radius: 14px; display: flex; align-items: center; justify-content: center; color: white; font-size: 22px; }
        .stat-icon.blue { background: #2563eb; }
        .stat-icon.green { background: #16a34a; }
        .stat-icon.orange { background: #f97316; }
        .stat-icon.purple { background: #8b5cf6; }
        .stat-trend { font-size: 12px; color: #16a34a; font-weight: 700; }
        .stat-num { font-size: 32px; font-weight: 800; color: #0f172a; margin-bottom: 6px; }
        .stat-label { color: #64748b; font-size: 14px; }
        .actions-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(160px, 1fr)); gap: 16px; margin-bottom: 32px; }
        .action-card { background: white; padding: 20px; border-radius: 16px; text-decoration: none; color: #0f172a; box-shadow: 0 18px 40px rgba(15,23,42,0.06); border: 1px solid rgba(148,163,184,0.12); transition: all 0.3s ease; text-align: center; display: flex; flex-direction: column; align-items: center; gap: 10px; }
        .action-card:hover { transform: translateY(-6px); box-shadow: 0 24px 48px rgba(15,23,42,0.12); }
        .action-card i { font-size: 28px; color: #16a34a; }
        .action-card h4 { margin: 0; font-size: 14px; font-weight: 700; }
        .action-card p { margin: 0; color: #64748b; font-size: 12px; }
        .two-col { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; }
        .card { background: white; border-radius: 20px; box-shadow: 0 18px 40px rgba(15,23,42,0.06); border: 1px solid rgba(148,163,184,0.12); overflow: hidden; }
        .card-header { padding: 24px 28px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; }
        .card-header h3 { margin: 0; font-size: 18px; font-weight: 700; color: #0f172a; display: flex; align-items: center; gap: 10px; }
        .view-all { color: #16a34a; text-decoration: none; font-size: 13px; font-weight: 700; }
        .view-all:hover { text-decoration: underline; }
        table { width: 100%; border-collapse: collapse; }
        th, td { text-align: left; padding: 16px 28px; border-bottom: 1px solid #e2e8f0; }
        thead th { color: #334155; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.08em; }
        tbody tr:hover { background: #f8fafc; }
        .td-id { font-family: 'Courier New', monospace; font-size: 12px; color: #64748b; }
        .td-amount { font-weight: 700; color: #0f172a; }
        .badge { display: inline-flex; align-items: center; gap: 6px; padding: 6px 12px; border-radius: 999px; font-size: 12px; font-weight: 700; }
        .badge.delivered { background: #d1fae5; color: #166534; }
        .badge.processing { background: #fef3c7; color: #b45309; }
        .badge.pending { background: #fecaca; color: #991b1b; }
        .badge.confirmed { background: #bfdbfe; color: #1e40af; }
        .stock-item { display: flex; justify-content: space-between; align-items: center; padding: 16px 28px; border-bottom: 1px solid #e2e8f0; }
        .stock-name { font-weight: 700; color: #0f172a; margin-bottom: 4px; }
        .stock-cat { font-size: 12px; color: #64748b; }
        .stock-bar-wrap { width: 80px; height: 6px; background: #e2e8f0; border-radius: 3px; overflow: hidden; }
        .stock-bar { height: 100%; background: #16a34a; border-radius: 3px; }
        .stock-bar.low { background: #ef4444; }
        .stock-num { font-weight: 700; color: #0f172a; font-size: 14px; min-width: 32px; }
        .empty-state { padding: 40px 28px; text-align: center; color: #64748b; font-size: 14px; }
        @media (max-width: 1200px) { .two-col { grid-template-columns: 1fr; } }
        @media (max-width: 768px) { .actions-grid { grid-template-columns: repeat(auto-fit, minmax(120px, 1fr)); } }
    </style>
</head>
<body>

<!-- SIDEBAR -->
<div class="sidebar">
    <div class="sidebar-brand">
        <div class="logo-text"><i class="fa-solid fa-leaf" style="color:#10b981;"></i> Ceylon<span>Fresh</span></div>
        <div class="logo-sub">Admin Dashboard</div>
    </div>
    <div class="sidebar-admin">
        <div class="sa-avatar"><%= adminName.substring(0,1).toUpperCase() %></div>
        <div class="sa-info">
            <strong><%= adminName %></strong>
            <span>Administrator</span>
        </div>
    </div>

    <div class="nav-section">Main</div>
    <a href="adminDashboard.jsp" class="active"><i class="fa-solid fa-gauge"></i> Dashboard</a>

    <div class="nav-section">Manage</div>
    <a href="adminProducts.jsp"><i class="fa-solid fa-box"></i> Products</a>
    <a href="adminUsers.jsp"><i class="fa-solid fa-users"></i> Users</a>
    <a href="adminOrders.jsp"><i class="fa-solid fa-shopping-cart"></i> Orders<% if (newOrdersCount > 0) { %><span style="color: #ef4444; margin-left: 6px;" title="<%= newOrdersCount %> New Order(s)"><i class="fa-solid fa-circle-check"></i></span><% } %></a>
    <a href="adminPayments.jsp"><i class="fa-solid fa-credit-card"></i> Payments</a>
    <a href="inventory.jsp"><i class="fa-solid fa-warehouse"></i> Inventory</a>

    <div class="nav-section">Content</div>
    <a href="adminReviews.jsp"><i class="fa-solid fa-star"></i> Reviews</a>
    <a href="adminNotifications.jsp"><i class="fa-solid fa-bell"></i> Notifications</a>
    <a href="adminReports.jsp"><i class="fa-solid fa-chart-pie"></i> Reports</a>

    <div class="sidebar-footer">
        <div style="font-size: 11px; color: rgba(255,255,255,0.5); text-align: center;">&copy; 2026 CeylonFresh Admin</div>
    </div>
</div>

<!-- MAIN -->
<div class="main">

    <!-- TOPBAR -->
    <div class="topbar">
        <div class="topbar-left">
            <h2>Dashboard Overview</h2>
            <div class="breadcrumb">Admin / Dashboard</div>
        </div>
        <div class="topbar-right">
            <div class="topbar-date"><i class="fa-solid fa-calendar-days"></i> Today: <%= new java.util.Date().toString().substring(0,10) %></div>
            <a href="LogoutServlet" class="logout-link" title="Sign Out">
                <i class="fa-solid fa-right-from-bracket"></i> Logout
            </a>
            <a href="adminNotifications.jsp"><button class="notif-btn"><i class="fa-solid fa-bell"></i></button></a>
        </div>
    </div>

    <div class="content">

        <!-- STAT CARDS -->
        <div class="stat-grid">
            <div class="stat-card">
                <div class="stat-top">
                    <div class="stat-icon blue"><i class="fa-solid fa-box-open"></i></div>
                    <span class="stat-trend">In Stock</span>
                </div>
                <div class="stat-num"><%= totalProducts %></div>
                <div class="stat-label">Total Products</div>
            </div>
            <div class="stat-card">
                <div class="stat-top">
                    <div class="stat-icon green"><i class="fa-solid fa-user-group"></i></div>
                    <span class="stat-trend">Active</span>
                </div>
                <div class="stat-num"><%= totalUsers %></div>
                <div class="stat-label">Customers</div>
            </div>
            <div class="stat-card">
                <div class="stat-top">
                    <div class="stat-icon orange"><i class="fa-solid fa-cart-shopping"></i></div>
                    <span class="stat-trend">Pending</span>
                </div>
                <div class="stat-num"><%= totalOrders %></div>
                <div class="stat-label">Total Orders</div>
            </div>
            <div class="stat-card">
                <div class="stat-top">
                    <div class="stat-icon purple"><i class="fa-solid fa-coins"></i></div>
                    <span class="stat-trend">Growth</span>
                </div>
                <div class="stat-num">Rs. <%= String.format("%.0f", totalRevenue) %></div>
                <div class="stat-label">Total Revenue</div>
            </div>
        </div>

        <!-- QUICK ACTIONS -->
        <div class="actions-grid">
            <a href="adminProducts.jsp" class="action-card">
                <i class="fa-solid fa-box"></i>
                <h4>Products</h4>
                <p>Manage items</p>
            </a>
            <a href="adminUsers.jsp" class="action-card">
                <i class="fa-solid fa-users"></i>
                <h4>Users</h4>
                <p>Accounts</p>
            </a>
            <a href="adminOrders.jsp" class="action-card">
                <i class="fa-solid fa-cart-shopping"></i>
                <h4>Orders</h4>
                <p>Track</p>
            </a>
            <a href="adminPayments.jsp" class="action-card">
                <i class="fa-solid fa-credit-card"></i>
                <h4>Payments</h4>
                <p>Transactions</p>
            </a>
            <a href="inventory.jsp" class="action-card">
                <i class="fa-solid fa-warehouse"></i>
                <h4>Inventory</h4>
                <p>Stock</p>
            </a>
            <a href="adminReviews.jsp" class="action-card">
                <i class="fa-solid fa-star"></i>
                <h4>Reviews</h4>
                <p>Feedback</p>
            </a>
            <a href="adminNotifications.jsp" class="action-card">
                <i class="fa-solid fa-bell"></i>
                <h4>Notifications</h4>
                <p>Alerts</p>
            </a>
            <a href="adminReports.jsp" class="action-card">
                <i class="fa-solid fa-chart-pie"></i>
                <h4>Reports</h4>
                <p>Analytics</p>
            </a>
            <a href="LogoutServlet" class="action-card">
                <h4>Logout</h4>
                <p>Sign out</p>
            </a>
        </div>

        <!-- RECENT ORDERS + LOW STOCK -->
        <div class="two-col">

            <!-- Recent Orders Table -->
            <div class="card">
                <div class="card-header">
                    <h3><i class="fa-solid fa-list"></i> Recent Orders</h3>
                    <a href="adminOrders.jsp" class="view-all">View All</a>
                </div>
                <% if (recentOrders.isEmpty()) { %>
                <div class="empty-state">No orders yet. Orders will appear here.</div>
                <% } else { %>
                <table>
                    <thead>
                        <tr>
                            <th>Order ID</th>
                            <th>Customer</th>
                            <th>Amount</th>
                            <th>Payment</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        String[] badges = {"delivered","processing","pending","confirmed"};
                        String[] bLabels = {"Delivered","Processing","Pending","Confirmed"};
                        int bi = 0;
                        for (String[] o : recentOrders) {
                            String oId   = o.length > 0 ? o[0].trim() : "-";
                            String oName = o.length > 2 ? o[2].trim() : "-";
                            String oAmt  = o.length > 3 ? o[3].trim() : "0";
                            String oPay  = o.length > 4 ? o[4].trim() : "-";
                            String bClass = badges[bi % badges.length];
                            String bLabel = bLabels[bi % bLabels.length];
                            bi++;
                            try { oAmt = "Rs. " + String.format("%.2f", Double.parseDouble(oAmt)); } catch(Exception e){}
                    %>
                    <tr>
                        <td class="td-id"><%= oId.length() > 14 ? oId.substring(0,14)+"..." : oId %></td>
                        <td><%= oName %></td>
                        <td class="td-amount"><%= oAmt %></td>
                        <td><%= oPay %></td>
                        <td><span class="badge <%= bClass %>"><%= bLabel %></span></td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
                <% } %>
            </div>

            <!-- Low Stock Alert -->
            <div class="card">
                <div class="card-header">
                    <h3><i class="fa-solid fa-triangle-exclamation"></i> Low Stock Alert</h3>
                    <a href="inventory.jsp" class="view-all">Manage</a>
                </div>
                <% if (lowStock.isEmpty()) { %>
                <div class="empty-state"><i class="fa-solid fa-check-circle"></i> All items well-stocked</div>
                <% } else {
                    for (String[] p : lowStock) {
                        String pName  = p.length > 1 ? p[1].trim() : "-";
                        String pCat   = p.length > 2 ? p[2].trim() : "-";
                        int    pStock = 0;
                        try { pStock = Integer.parseInt(p[4].trim()); } catch(Exception e){}
                        int barWidth = Math.min(pStock * 5, 100);
                        String barClass = pStock < 20 ? "low" : "";
                %>
                <div class="stock-item">
                    <div>
                        <div class="stock-name"><%= pName %></div>
                        <div class="stock-cat"><%= pCat %></div>
                    </div>
                    <div style="display:flex;align-items:center;gap:12px;">
                        <div class="stock-bar-wrap"><div class="stock-bar <%= barClass %>" style="width:<%= barWidth %>%"></div></div>
                        <div class="stock-num"><%= pStock %></div>
                    </div>
                </div>
                <% } } %>
            </div>

        </div>

    </div>
</div>

</body>
</html>
