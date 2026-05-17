<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.io.*, java.util.*, java.text.SimpleDateFormat" %>
<%
    String adminName = (String) session.getAttribute("username");
    String adminRole = (String) session.getAttribute("role");
    if (adminName == null || !"Admin".equalsIgnoreCase(adminRole)) {
        response.sendRedirect("adminLogin.jsp");
        return;
    }

    String dataDir = application.getRealPath("/") + "data" + File.separator;

    // 1. Read Products (Product Stock & Low Stock)
    List<String[]> allProducts = new ArrayList<>();
    List<String[]> lowStockProducts = new ArrayList<>();
    File pf = new File(dataDir + "products.txt");
    if (pf.exists()) {
        try(BufferedReader br = new BufferedReader(new FileReader(pf))) {
            String line;
            while((line = br.readLine()) != null) {
                line = line.trim();
                if(line.isEmpty()) continue;
                String[] p = line.split(",", -1);
                if(p.length >= 6) {
                    allProducts.add(p);
                    try {
                        int stock = Integer.parseInt(p[4].trim());
                        if (stock < 20) lowStockProducts.add(p);
                    } catch (Exception ignored) {}
                }
            }
        }
    }

    // 2. Read Orders (Daily Sales & Order History)
    List<String[]> allOrders = new ArrayList<>();
    double todayRevenue = 0.0;
    int todayOrderCount = 0;

    // Simulate simple date check for "today" (Since orders.txt doesn't have a date field, we assume latest orders are recent. But let's check payments for date if possible, or just sum all for demo, or assume last 24hrs if we had dates. Since we lack dates in orders.txt, we will just sum "Confirmed" as today for demo purposes).
    File of = new File(dataDir + "orders.txt");
    if (of.exists()) {
        try(BufferedReader br = new BufferedReader(new FileReader(of))) {
            String line;
            while((line = br.readLine()) != null) {
                line = line.trim();
                if(line.isEmpty()) continue;
                String[] o = line.split(",", -1);
                if(o.length >= 8) {
                    allOrders.add(o);
                    if("Confirmed".equalsIgnoreCase(o[7].trim()) || "Delivered".equalsIgnoreCase(o[7].trim())) {
                        try {
                            double amt = Double.parseDouble(o[3].trim());
                            todayRevenue += amt;
                            todayOrderCount++;
                        } catch (Exception ignored) {}
                    }
                }
            }
        }
    }
    Collections.reverse(allOrders); // Newest first

    // 3. Read Inventory (Restock History)
    List<String[]> restockHistory = new ArrayList<>();
    File invf = new File(dataDir + "inventory.txt");
    if (invf.exists()) {
        try(BufferedReader br = new BufferedReader(new FileReader(invf))) {
            String line;
            while((line = br.readLine()) != null) {
                line = line.trim();
                if(line.isEmpty()) continue;
                restockHistory.add(line.split(",", -1));
            }
        }
    }
    Collections.reverse(restockHistory);
%>
<!DOCTYPE html>
<html>
<head>
    <title>Reports - CeylonFresh Admin</title>
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

        .main { margin-left: 260px; flex: 1; padding-bottom: 50px; }
        .topbar { background: white; padding: 24px 30px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #e2e8f0; }
        .topbar-left h2 { margin: 0; color: #0f172a; font-size: 26px; letter-spacing: -0.02em; font-weight: 800; }
        .breadcrumb { color: #64748b; font-size: 13px; margin-top: 8px; font-weight: 500; }

        .content { padding: 30px; }

        /* Dashboard Stats */
        .stat-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 24px; margin-bottom: 30px; }
        .stat-card { background: white; padding: 24px; border-radius: 20px; box-shadow: 0 10px 30px rgba(0,0,0,0.03); border: 1px solid #f1f5f9; display: flex; flex-direction: column; }
        .stat-top { display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px; }
        .stat-icon { width: 48px; height: 48px; border-radius: 12px; display: flex; align-items: center; justify-content: center; color: white; font-size: 20px; }
        .stat-icon.green { background: linear-gradient(135deg, #10b981, #059669); }
        .stat-icon.red { background: linear-gradient(135deg, #ef4444, #dc2626); }
        .stat-icon.blue { background: linear-gradient(135deg, #3b82f6, #2563eb); }
        .stat-num { font-size: 32px; font-weight: 800; color: #0f172a; margin-bottom: 4px; }
        .stat-label { color: #64748b; font-size: 14px; font-weight: 600; }

        /* Panels */
        .reports-container { display: grid; grid-template-columns: 1fr; gap: 30px; }
        .panel { background: white; border-radius: 20px; box-shadow: 0 10px 30px rgba(0,0,0,0.03); border: 1px solid #f1f5f9; overflow: hidden; }
        .panel-header { padding: 20px 24px; border-bottom: 1px solid #f1f5f9; background: #fafafa; display: flex; justify-content: space-between; align-items: center; }
        .panel-header h3 { font-size: 18px; font-weight: 700; color: #0f172a; display: flex; align-items: center; gap: 10px; }

        .table-wrap { overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; }
        th, td { text-align: left; padding: 16px 24px; border-bottom: 1px solid #f1f5f9; }
        thead th { background: #f8fafc; color: #64748b; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; }
        tbody tr:hover { background: #f8fafc; }
        .td-id { font-family: monospace; color: #64748b; }
        .td-amount { font-weight: 700; color: #10b981; }

        .badge { display: inline-flex; align-items: center; padding: 4px 10px; border-radius: 8px; font-size: 12px; font-weight: 700; }
        .badge.low { background: #fee2e2; color: #dc2626; }
        .badge.ok { background: #d1fae5; color: #059669; }

        .empty-state { padding: 40px; text-align: center; color: #94a3b8; font-weight: 500; }
    </style>
</head>
<body>

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
    <a href="adminDashboard.jsp"><i class="fa-solid fa-gauge"></i> Dashboard</a>

    <div class="nav-section">Manage</div>
    <a href="adminProducts.jsp"><i class="fa-solid fa-box"></i> Products</a>
    <a href="adminUsers.jsp"><i class="fa-solid fa-users"></i> Users</a>
    <a href="adminOrders.jsp"><i class="fa-solid fa-shopping-cart"></i> Orders</a>
    <a href="adminPayments.jsp"><i class="fa-solid fa-credit-card"></i> Payments</a>
    <a href="inventory.jsp"><i class="fa-solid fa-warehouse"></i> Inventory</a>

    <div class="nav-section">Content</div>
    <a href="adminReviews.jsp"><i class="fa-solid fa-star"></i> Reviews</a>
    <a href="adminNotifications.jsp"><i class="fa-solid fa-bell"></i> Notifications</a>
    <a href="adminReports.jsp" class="active"><i class="fa-solid fa-chart-pie"></i> Reports</a>

    <div class="sidebar-footer">
        <a href="LogoutServlet" class="logout-btn">Logout</a>
    </div>
</div>

<div class="main">
    <div class="topbar">
        <div class="topbar-left">
            <h2>Business Reports</h2>
            <div class="breadcrumb">Admin / Reports</div>
        </div>
    </div>

    <div class="content">
        <!-- High Level Stats -->
        <div class="stat-grid">
            <div class="stat-card">
                <div class="stat-top">
                    <div class="stat-icon green"><i class="fa-solid fa-sack-dollar"></i></div>
                </div>
                <div class="stat-num">Rs. <%= String.format("%.2f", todayRevenue) %></div>
                <div class="stat-label">Total Revenue</div>
            </div>
            <div class="stat-card">
                <div class="stat-top">
                    <div class="stat-icon blue"><i class="fa-solid fa-cart-shopping"></i></div>
                </div>
                <div class="stat-num"><%= todayOrderCount %></div>
                <div class="stat-label">Total Orders</div>
            </div>
            <div class="stat-card">
                <div class="stat-top">
                    <div class="stat-icon red"><i class="fa-solid fa-triangle-exclamation"></i></div>
                </div>
                <div class="stat-num"><%= lowStockProducts.size() %></div>
                <div class="stat-label">Low Stock Items</div>
            </div>
        </div>

        <div class="reports-container">
            <!-- 1. Low Stock Report -->
            <div class="panel">
                <div class="panel-header">
                    <h3><i class="fa-solid fa-circle-exclamation" style="color:#ef4444;"></i> Low Stock Report</h3>
                </div>
                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>Product ID</th>
                                <th>Name</th>
                                <th>Category</th>
                                <th>Price</th>
                                <th>Current Stock</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if(lowStockProducts.isEmpty()) { %>
                                <tr><td colspan="6" class="empty-state">No low stock items! Inventory is healthy.</td></tr>
                            <% } else {
                                for(String[] p : lowStockProducts) { %>
                                <tr>
                                    <td class="td-id"><%= p[0] %></td>
                                    <td style="font-weight:600;"><%= p[1] %></td>
                                    <td><%= p[2] %></td>
                                    <td>Rs. <%= p[3] %></td>
                                    <td style="font-weight:800; color:#ef4444;"><%= p[4] %></td>
                                    <td><span class="badge low">Restock Needed</span></td>
                                </tr>
                            <%  } } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- 2. Product Stock Report -->
            <div class="panel">
                <div class="panel-header">
                    <h3><i class="fa-solid fa-boxes-stacked" style="color:#3b82f6;"></i> Full Product Stock Report</h3>
                </div>
                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>Product ID</th>
                                <th>Name</th>
                                <th>Category</th>
                                <th>Stock</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if(allProducts.isEmpty()) { %>
                                <tr><td colspan="5" class="empty-state">No products found.</td></tr>
                            <% } else {
                                for(String[] p : allProducts) {
                                    int stock = 0; try { stock = Integer.parseInt(p[4].trim()); } catch(Exception e){}
                                %>
                                <tr>
                                    <td class="td-id"><%= p[0] %></td>
                                    <td style="font-weight:600;"><%= p[1] %></td>
                                    <td><%= p[2] %></td>
                                    <td style="font-weight:700;"><%= stock %></td>
                                    <td><span class="badge <%= stock < 20 ? "low" : "ok" %>"><%= stock < 20 ? "Low Stock" : "Available" %></span></td>
                                </tr>
                            <%  } } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- 3. Order History Report -->
            <div class="panel">
                <div class="panel-header">
                    <h3><i class="fa-solid fa-clock-rotate-left" style="color:#10b981;"></i> Order History Report</h3>
                </div>
                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>Order ID</th>
                                <th>Customer</th>
                                <th>Address</th>
                                <th>Amount</th>
                                <th>Payment Method</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if(allOrders.isEmpty()) { %>
                                <tr><td colspan="6" class="empty-state">No orders have been placed yet.</td></tr>
                            <% } else {
                                for(String[] o : allOrders) { %>
                                <tr>
                                    <td class="td-id"><%= o[0] %></td>
                                    <td style="font-weight:600;"><%= o[2] %></td>
                                    <td><div style="max-width:200px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;" title="<%= o[5] %>"><%= o[5] %></div></td>
                                    <td class="td-amount">Rs. <%= o[3] %></td>
                                    <td><%= o[4] %></td>
                                    <td><span class="badge <%= "Delivered".equals(o[7].trim()) ? "ok" : "low" %>" style="background:#f1f5f9; color:#0f172a;"><%= o[7] %></span></td>
                                </tr>
                            <%  } } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- 4. Restock History Report -->
            <div class="panel">
                <div class="panel-header">
                    <h3><i class="fa-solid fa-truck-ramp-box" style="color:#f59e0b;"></i> Inventory Restock Report</h3>
                </div>
                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>Inventory ID</th>
                                <th>Product Name</th>
                                <th>Quantity Added</th>
                                <th>Supplier</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if(restockHistory.isEmpty()) { %>
                                <tr><td colspan="5" class="empty-state">No restock records found.</td></tr>
                            <% } else {
                                for(String[] row : restockHistory) {
                                    if (row.length < 6) continue;
                                %>
                                <tr>
                                    <td class="td-id"><%= row[0] %></td>
                                    <td style="font-weight:600;"><%= row[2] %></td>
                                    <td style="font-weight:800; color:#10b981;">+ <%= row[3] %></td>
                                    <td><%= row[4] %></td>
                                    <td>
                                        <span class="badge <%= "Restocked".equals(row[5].trim()) ? "ok" : "low" %>" style="font-size:10px;">
                                            <%= row[5] %>
                                        </span>
                                    </td>
                                </tr>
                            <%  } } %>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>
    </div>
</div>

</body>
</html>
