<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.grocery.dao.InventoryDAO" %>
<%@ page import="java.io.*, java.util.*" %>
<%
    String adminName = (String) session.getAttribute("username");
    String adminRole = (String) session.getAttribute("role");
    if (adminName == null || !"Admin".equalsIgnoreCase(adminRole)) {
        response.sendRedirect("adminLogin.jsp");
        return;
    }

    String dataDir = application.getRealPath("/") + "data" + File.separator;
    InventoryDAO dao = new InventoryDAO(dataDir);
    List<String> inventoryRows = dao.getAllInventory();

    int totalItems = 0;
    int totalStock = 0;
    int lowStockCount = 0;
    List<String[]> inventory = new ArrayList<>();
    for (String row : inventoryRows) {
        row = row.trim();
        if (row.isEmpty()) continue;
        String[] data = row.split(",", -1);
        inventory.add(data);
        totalItems++;
        if (data.length >= 6) {
            String status = data[5].trim();
            if ("Pending".equals(status)) lowStockCount++;
            if (!"Completed".equals(status)) {
                try {
                    totalStock += Integer.parseInt(data[3].trim());
                } catch (Exception ignored) {}
            }
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Inventory - CeylonFresh Admin</title>
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
        .stat-icon.orange { background: #f59e0b; }
        .stat-num { font-size: 32px; font-weight: 800; color: #0f172a; margin-bottom: 6px; }
        .stat-label { color: #64748b; font-size: 14px; }
        .layout-grid { display: grid; grid-template-columns: 1.2fr .8fr; gap: 24px; }
        .panel { background: white; border-radius: 20px; box-shadow: 0 18px 40px rgba(15,23,42,0.06); border: 1px solid rgba(148,163,184,0.12); overflow: hidden; }
        .panel-header { padding: 24px 28px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; }
        .panel-header h3 { margin: 0; font-size: 20px; color: #0f172a; }
        .panel-header span { color: #64748b; font-size: 14px; }
        .panel-body { padding: 24px 28px 28px; }
        .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 18px; margin-bottom: 24px; }
        .form-group { display: flex; flex-direction: column; }
        .form-group label { font-size: 14px; font-weight: 600; color: #374151; margin-bottom: 8px; }
        .form-group input { padding: 12px 16px; border: 1px solid #d1d5db; border-radius: 12px; font-size: 14px; transition: border-color 0.2s; }
        .form-group input:focus { outline: none; border-color: #16a34a; }
        .btn { background: #16a34a; color: white; border: none; padding: 14px 20px; border-radius: 12px; cursor: pointer; font-weight: 600; transition: all 0.2s; }
        .btn:hover { background: #15803d; transform: translateY(-1px); }
        .btn-danger { background: #dc2626; }
        .btn-danger:hover { background: #b91c1c; }
        .table-wrap { overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; min-width: 720px; }
        th, td { text-align: left; padding: 16px 18px; border-bottom: 1px solid #e2e8f0; }
        thead th { color: #334155; font-size: 14px; text-transform: uppercase; letter-spacing: 0.08em; border-bottom: 2px solid #e2e8f0; }
        tbody tr:hover { background: #f8fafc; }
        .product-name { font-weight: 700; color: #0f172a; }
        .stock-count { font-weight: 600; }
        .stock-low { color: #dc2626; }
        .stock-normal { color: #16a34a; }
        .badge { display: inline-flex; align-items: center; gap: 6px; padding: 6px 12px; border-radius: 999px; font-size: 12px; font-weight: 700; color: #0f172a; background: #f8fafc; }
        .badge.low { color: #dc2626; background: #fee2e2; }
        .badge.orange { color: #9a3412; background: #ffedd5; }
        .badge.blue { color: #1e40af; background: #dbeafe; }
        .badge.ok { color: #166534; background: #dcfce7; }
        .empty-state { padding: 40px; color: #64748b; text-align: center; }
        .btn-pulse { animation: pulse-blue 2s infinite; }
        @keyframes pulse-blue { 0% { box-shadow: 0 0 0 0 rgba(37, 99, 235, 0.7); } 70% { box-shadow: 0 0 0 10px rgba(37, 99, 235, 0); } 100% { box-shadow: 0 0 0 0 rgba(37, 99, 235, 0); } }
        .arrived-badge { background: #ef4444; color: white; font-size: 10px; padding: 2px 6px; border-radius: 999px; margin-left: 8px; vertical-align: middle; }
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
    <a href="inventory.jsp" class="active"><i class="fa-solid fa-warehouse"></i> Inventory</a>
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
            <h2>Manage Inventory</h2>
            <div class="breadcrumb">Admin / Inventory</div>
        </div>
        <div class="topbar-right">
            <div class="topbar-date">📅 <%= new java.util.Date().toString().substring(0, 10) %></div>
            <%
                int arrivedCount = 0;
                for (String[] row : inventory) {
                    if (row.length >= 6 && "Delivered".equals(row[5].trim())) arrivedCount++;
                }
            %>
            <button class="notif-btn <%= arrivedCount > 0 ? "btn-pulse" : "" %>"
                    onclick="<%= arrivedCount > 0 ? "document.querySelector('.btn-pulse').scrollIntoView({behavior: 'smooth'});" : "document.getElementById('stock-form-panel').scrollIntoView({behavior: 'smooth'}); document.getElementsByName('productId')[0].focus();" %>">
                <i class="fa-solid fa-plus"></i>
                <%= arrivedCount > 0 ? "Pending Completion" : "Add Stock" %>
                <% if (arrivedCount > 0) { %>
                <span class="arrived-badge"><%= arrivedCount %></span>
                <% } %>
            </button>
        </div>
    </div>
    <div class="content">
        <!-- ... existing stat-grid ... -->
        <div class="stat-grid">
            <div class="stat-card">
                <div class="stat-top">
                    <div class="stat-icon blue"><i class="fa-solid fa-box"></i></div>
                </div>
                <div class="stat-num"><%= totalItems %></div>
                <div class="stat-label">Total Products</div>
            </div>
            <div class="stat-card">
                <div class="stat-top">
                    <div class="stat-icon green"><i class="fa-solid fa-cubes"></i></div>
                </div>
                <div class="stat-num"><%= totalStock %></div>
                <div class="stat-label">Total Stock</div>
            </div>
            <div class="stat-card">
                <div class="stat-top">
                    <div class="stat-icon orange"><i class="fa-solid fa-triangle-exclamation"></i></div>
                </div>
                <div class="stat-num"><%= lowStockCount %></div>
                <div class="stat-label">Low Stock Alerts</div>
            </div>
        </div>
        <div class="layout-grid">
            <div class="panel" id="stock-form-panel">
                <div class="panel-header">
                    <h3>Quick Stock Update</h3>
                    <span>Add new inventory items</span>
                </div>
                <div class="panel-body">
                    <form action="InventoryServlet" method="post">
                        <input type="hidden" name="action" value="add">
                        <div class="form-grid">
                            <div class="form-group">
                                <label>Inventory ID</label>
                                <input type="text" name="inventoryId" value="INV-<%= System.currentTimeMillis() %>" readonly>
                            </div>
                            <div class="form-group">
                                <label>Select Product</label>
                                <select name="productId" required style="padding: 12px 16px; border: 1px solid #d1d5db; border-radius: 12px; font-size: 14px;">
                                    <option value="" disabled selected>Select a product to restock</option>
                                    <%
                                        String pPath = application.getRealPath("/") + "data/products.txt";
                                        File pfObj = new File(pPath);
                                        if (pfObj.exists()) {
                                            try (BufferedReader pbr = new BufferedReader(new FileReader(pfObj))) {
                                                String pLine;
                                                while ((pLine = pbr.readLine()) != null) {
                                                    pLine = pLine.trim();
                                                    if (pLine.isEmpty()) continue;
                                                    String[] pParts = pLine.split(",");
                                                    if (pParts.length >= 2) {
                                                        out.println("<option value=\"" + pParts[0].trim() + "\">" + pParts[1].trim() + " (" + pParts[0].trim() + ")</option>");
                                                    }
                                                }
                                            }
                                        }
                                    %>
                                </select>
                            </div>
                            <div class="form-group">
                                <label>Stock Quantity</label>
                                <input type="number" name="stock" placeholder="Enter quantity" min="1" required>
                            </div>
                            <div class="form-group">
                                <label>Delivered By (Supplier)</label>
                                <select name="supplier" required style="padding: 12px 16px; border: 1px solid #d1d5db; border-radius: 12px; font-size: 14px;">
                                    <option value="" disabled selected>Select delivery person</option>
                                    <%
                                        String uPath = application.getRealPath("/") + "data/users.txt";
                                        File ufObj = new File(uPath);
                                        if (ufObj.exists()) {
                                            try (BufferedReader ubr = new BufferedReader(new FileReader(ufObj))) {
                                                String uLine;
                                                while ((uLine = ubr.readLine()) != null) {
                                                    uLine = uLine.trim();
                                                    if (uLine.isEmpty()) continue;
                                                    String[] uParts = uLine.split(",");
                                                    if (uParts.length >= 5 && "Delivery".equalsIgnoreCase(uParts[4].trim())) {
                                                        out.println("<option value=\"" + uParts[1].trim() + "\">" + uParts[1].trim() + "</option>");
                                                    }
                                                }
                                            }
                                        }
                                    %>
                                </select>
                            </div>
                        </div>
                        <button type="submit" class="btn"><i class="fa-solid fa-plus"></i> Add to Inventory</button>
                    </form>
                </div>
            </div>
            <div class="panel">
                <div class="panel-header">
                    <h3>Current Stock</h3>
                    <span><%= inventory.size() %> items tracked</span>
                </div>
                <div class="panel-body">
                    <div class="table-wrap">
                        <table>
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Product</th>
                                    <th>Stock</th>
                                    <th>Supplier</th>
                                    <th>Status</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (inventory.isEmpty()) { %>
                                <tr><td colspan="6" class="empty-state">No inventory requests found. Create one above to notify the delivery team.</td></tr>
                                <% } else {
                                    for (String[] row : inventory) {
                                        String invId = "";
                                        String pName = "";
                                        String qty = "0";
                                        String supplier = "";
                                        String status = "Pending";

                                        if (row.length >= 6) {
                                            invId = row[0].trim();
                                            pName = row[2].trim();
                                            qty = row[3].trim();
                                            supplier = row[4].trim();
                                            status = row[5].trim();
                                        } else if (row.length >= 4) {
                                            invId = row[0].trim();
                                            pName = row[1].trim();
                                            qty = row[2].trim();
                                            supplier = row[3].trim();
                                        }

                                        String statusClass = "badge";
                                        if ("Pending".equals(status)) statusClass += " low";
                                        else if ("Approved".equals(status)) statusClass += " orange";
                                        else if ("Delivered".equals(status)) statusClass += " blue";
                                        else if ("Completed".equals(status)) statusClass += " ok";
                                %>
                                <tr>
                                    <td><%= invId %></td>
                                    <td><div class="product-name"><%= pName %></div></td>
                                    <td><span class="stock-count"><%= qty %></span></td>
                                    <td><%= supplier %></td>
                                    <td>
                                        <span class="<%= statusClass %>">
                                            <% if ("Pending".equals(status)) { %><i class="fa-solid fa-clock-rotate-left"></i> Pending<% } %>
                                            <% if ("Approved".equals(status)) { %><i class="fa-solid fa-truck-fast"></i> Stock Available<% } %>
                                            <% if ("Delivered".equals(status)) { %><i class="fa-solid fa-circle-check"></i> Delivered<% } %>
                                            <% if ("Completed".equals(status)) { %><i class="fa-solid fa-boxes-stacked"></i> Completed<% } %>
                                        </span>
                                    </td>
                                    <td>
                                        <% if ("Delivered".equals(status)) { %>
                                        <form action="InventoryServlet" method="post" style="display:inline;">
                                            <input type="hidden" name="action" value="updateStatus">
                                            <input type="hidden" name="inventoryId" value="<%= invId %>">
                                            <input type="hidden" name="status" value="Completed">
                                            <button type="submit" class="btn btn-pulse" style="background:#2563eb; padding:8px 12px; font-size:12px;">
                                                <i class="fa-solid fa-check"></i> Verify & Complete
                                            </button>
                                        </form>
                                        <% } else if ("Completed".equals(status)) { %>
                                        <span style="color:#16a34a; font-weight:700; font-size:12px;"><i class="fa-solid fa-check-double"></i> Verified</span>
                                        <% } else { %>
                                        <form action="InventoryServlet" method="post" style="display:inline;">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="inventoryId" value="<%= invId %>">
                                            <button type="submit" class="btn btn-danger" title="Cancel request" style="padding:8px 12px; font-size:12px;"><i class="fa-solid fa-times"></i></button>
                                        </form>
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
</div>
</body>
</html>
