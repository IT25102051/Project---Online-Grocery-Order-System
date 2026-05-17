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

    // Load orders: orderId,userId,userName,total,paymentMethod,address,phone,status,deliveryId
    List<String[]> orders = new ArrayList<>();
    File of = new File(dataDir + "orders.txt");
    if (of.exists()) {
        BufferedReader br = new BufferedReader(new FileReader(of));
        String line;
        while ((line = br.readLine()) != null) {
            line = line.trim();
            if (line.isEmpty()) continue;
            orders.add(line.split(",", 9));
        }
        br.close();
    }
    Collections.reverse(orders);

    // Calculate statistics
    double totalRevenue = 0;
    int pendingOrders = 0;
    int completedOrders = 0;
    int newOrdersCount = 0;
    for (String[] o : orders) {
        if (o.length >= 8 && "Confirmed".equalsIgnoreCase(o[7].trim())) newOrdersCount++;
        try {
            totalRevenue += Double.parseDouble(o[3].trim());
        } catch (Exception e) {}
        // For demo purposes, alternate between pending and completed
        if (orders.indexOf(o) % 3 == 0) {
            pendingOrders++;
        } else {
            completedOrders++;
        }
    }

    // Load order items for detailed view
    Map<String, List<String[]>> orderItems = new HashMap<>();
    File oif = new File(dataDir + "order_items.txt");
    if (oif.exists()) {
        BufferedReader br = new BufferedReader(new FileReader(oif));
        String line;
        while ((line = br.readLine()) != null) {
            line = line.trim();
            if (line.isEmpty()) continue;
            String[] parts = line.split(",", 5); // orderId,productId,productName,quantity,price
            if (parts.length >= 5) {
                String orderId = parts[0];
                orderItems.computeIfAbsent(orderId, k -> new ArrayList<>()).add(parts);
            }
        }
        br.close();
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Order Management - CeylonFresh Admin</title>
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
        .topbar-date { color: #475569; font-size: 14px; padding: 10px 14px; background: #f8fafc; border-radius: 10px; display: flex; align-items: center; gap: 8px; }
        .logout-link { color: #ef4444; text-decoration: none; font-size: 14px; font-weight: 700; padding: 10px 16px; background: #fef2f2; border: 1px solid #fee2e2; border-radius: 10px; display: flex; align-items: center; gap: 8px; transition: all 0.2s; }
        .logout-link:hover { background: #fee2e2; transform: translateY(-1px); }
        .content { padding: 30px; }
        .stat-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 20px; margin-bottom: 28px; }
        .stat-card { background: white; padding: 24px; border-radius: 18px; box-shadow: 0 18px 40px rgba(15,23,42,0.06); border: 1px solid rgba(148,163,184,0.12); }
        .stat-top { display: flex; align-items: center; justify-content: space-between; margin-bottom: 18px; }
        .stat-icon { width: 52px; height: 52px; border-radius: 14px; display: flex; align-items: center; justify-content: center; color: white; font-size: 20px; }
        .stat-icon.blue { background: #2563eb; }
        .stat-icon.green { background: #16a34a; }
        .stat-icon.orange { background: #f59e0b; }
        .stat-icon.purple { background: #8b5cf6; }
        .stat-num { font-size: 32px; font-weight: 800; color: #0f172a; margin-bottom: 6px; }
        .stat-label { color: #64748b; font-size: 14px; }
        .layout-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; }
        .panel { background: white; border-radius: 20px; box-shadow: 0 18px 40px rgba(15,23,42,0.06); border: 1px solid rgba(148,163,184,0.12); overflow: hidden; }
        .panel-header { padding: 24px 28px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; }
        .panel-header h3 { margin: 0; font-size: 20px; color: #0f172a; }
        .panel-header span { color: #64748b; font-size: 14px; }
        .panel-body { padding: 24px 28px 28px; }
        .order-table { width: 100%; border-collapse: collapse; }
        .order-table th, .order-table td { padding: 16px 20px; text-align: left; border-bottom: 1px solid #e2e8f0; }
        .order-table th { background: #f8fafc; font-weight: 700; color: #0f172a; font-size: 14px; }
        .order-table td { color: #64748b; font-size: 14px; }
        .order-id { font-weight: 700; color: #0f172a; font-family: 'Monaco', 'Menlo', monospace; }
        .customer-name { font-weight: 600; color: #0f172a; }
        .order-amount { font-weight: 700; color: #16a34a; font-size: 16px; }
        .status-badge { padding: 6px 12px; border-radius: 20px; font-size: 12px; font-weight: 700; text-transform: uppercase; }
        .status-pending { background: #fef3c7; color: #f59e0b; }
        .status-processing { background: #dbeafe; color: #2563eb; }
        .status-completed { background: #dcfce7; color: #16a34a; }
        .status-cancelled { background: #fee2e2; color: #dc2626; }
        .status-prepared { background: #fef3c7; color: #d97706; }
        .status-picked-up { background: #dcfce7; color: #15803d; }
        .status-confirmed { background: #dbeafe; color: #1d4ed8; }
        .status-delivered { background: #dcfce7; color: #15803d; }
        .payment-method { display: inline-flex; align-items: center; gap: 6px; padding: 4px 8px; background: #f8fafc; border-radius: 8px; font-size: 12px; color: #64748b; }
        .action-buttons { display: flex; gap: 8px; }
        .btn-view { background: #3b82f6; color: white; border: none; padding: 8px 12px; border-radius: 8px; font-size: 12px; font-weight: 600; cursor: pointer; }
        .btn-view:hover { background: #2563eb; }
        .btn-update { background: #16a34a; color: white; border: none; padding: 8px 12px; border-radius: 8px; font-size: 12px; font-weight: 600; cursor: pointer; }
        .btn-update:hover { background: #15803d; }
        .empty-state { padding: 60px 20px; color: #64748b; text-align: center; }
        .empty-state i { font-size: 48px; color: #cbd5e1; margin-bottom: 16px; }
        .empty-state h4 { margin: 0 0 8px 0; color: #475569; }
        .order-details { margin-top: 20px; padding: 20px; background: #f8fafc; border-radius: 12px; }
        .order-detail-row { display: flex; justify-content: space-between; margin-bottom: 12px; }
        .order-detail-label { font-weight: 600; color: #475569; }
        .order-detail-value { color: #0f172a; }
        .order-items { margin-top: 20px; }
        .order-item { display: flex; align-items: center; gap: 16px; padding: 12px 0; border-bottom: 1px solid #e2e8f0; }
        .item-image { width: 50px; height: 50px; background: #e2e8f0; border-radius: 8px; display: flex; align-items: center; justify-content: center; color: #64748b; }
        .item-info h5 { margin: 0 0 4px 0; font-size: 14px; color: #0f172a; }
        .item-info p { margin: 0; font-size: 12px; color: #64748b; }
        .item-quantity { font-weight: 600; color: #16a34a; }
        .item-price { font-weight: 700; color: #0f172a; }
        @media (max-width: 1024px) { .layout-grid { grid-template-columns: 1fr; } .order-table { font-size: 12px; } .order-table th, .order-table td { padding: 12px 8px; } }
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
    <a href="adminOrders.jsp" class="active"><i class="fa-solid fa-shopping-cart"></i> Orders<% if (newOrdersCount > 0) { %><span style="color: #ef4444; margin-left: 6px;" title="<%= newOrdersCount %> New Order(s)"><i class="fa-solid fa-circle-check"></i></span><% } %></a>
    <a href="adminPayments.jsp"><i class="fa-solid fa-credit-card"></i> Payments</a>
    <a href="inventory.jsp"><i class="fa-solid fa-warehouse"></i> Inventory</a>
    <div class="nav-section">Content</div>
    <a href="adminReviews.jsp"><i class="fa-solid fa-star"></i> Reviews</a>
    <a href="adminNotifications.jsp"><i class="fa-solid fa-bell"></i> Notifications</a>
    <div class="sidebar-footer">
        <div style="font-size: 11px; color: rgba(255,255,255,0.5); text-align: center;">&copy; 2026 CeylonFresh Admin</div>
    </div>
</div>
<div class="main">
    <div class="topbar">
        <div class="topbar-left">
            <h2>Order Management</h2>
            <div class="breadcrumb">Admin / Orders</div>
        </div>
        <div class="topbar-right">
            <div class="topbar-date"><i class="fa-solid fa-calendar-days"></i> <%= new java.util.Date().toString().substring(0,10) %></div>
            <a href="LogoutServlet" class="logout-link" title="Sign Out">
                <i class="fa-solid fa-right-from-bracket"></i> Logout
            </a>
        </div>
    </div>
    <div class="content">
        <div class="stat-grid">
            <div class="stat-card">
                <div class="stat-top">
                    <div class="stat-icon orange"><i class="fa-solid fa-shopping-cart"></i></div>
                </div>
                <div class="stat-num"><%= orders.size() %></div>
                <div class="stat-label">Total Orders</div>
            </div>
            <div class="stat-card">
                <div class="stat-top">
                    <div class="stat-icon green"><i class="fa-solid fa-dollar-sign"></i></div>
                </div>
                <div class="stat-num">Rs. <%= String.format("%.0f", totalRevenue) %></div>
                <div class="stat-label">Total Revenue</div>
            </div>
            <div class="stat-card">
                <div class="stat-top">
                    <div class="stat-icon blue"><i class="fa-solid fa-clock"></i></div>
                </div>
                <div class="stat-num"><%= pendingOrders %></div>
                <div class="stat-label">Pending Orders</div>
            </div>
            <div class="stat-card">
                <div class="stat-top">
                    <div class="stat-icon purple"><i class="fa-solid fa-check-circle"></i></div>
                </div>
                <div class="stat-num"><%= completedOrders %></div>
                <div class="stat-label">Completed Orders</div>
            </div>
        </div>
        <div class="panel">
            <div class="panel-header">
                <h3>All Orders</h3>
                <span><%= orders.size() %> orders found</span>
            </div>
            <div class="panel-body">
                <% if (orders.isEmpty()) { %>
                <div class="empty-state">
                    <i class="fa-solid fa-shopping-bag"></i>
                    <h4>No Orders Yet</h4>
                    <p>Orders will appear here once customers start placing them.</p>
                </div>
                <% } else { %>
                <div style="overflow-x: auto;">
                    <table class="order-table">
                        <thead>
                            <tr>
                                <th>Order ID</th>
                                <th>Customer</th>
                                <th>Amount</th>
                                <th>Payment Method</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (String[] order : orders) {
                                String orderId = order.length > 0 ? order[0] : "—";
                                String userName = order.length > 2 ? order[2] : "—";
                                String total = order.length > 3 ? order[3] : "0";
                                String paymentMethod = order.length > 4 ? order[4] : "—";
                                String address = order.length > 5 ? order[5] : "—";

                                // Format amount
                                String displayAmount = total;
                                try {
                                    displayAmount = "Rs. " + String.format("%.2f", Double.parseDouble(total));
                                } catch (Exception e) {}

                                String status = order.length > 7 ? order[7].trim() : "Confirmed";
                                String statusLabel = status.isEmpty() ? "Confirmed" : status;
                                String statusClass = statusLabel.toLowerCase().replace(" ", "-");
                            %>
                            <tr>
                                <td><span class="order-id"><%= orderId.length() > 12 ? orderId.substring(0, 12) + "..." : orderId %></span></td>
                                <td><span class="customer-name"><%= userName %></span></td>
                                <td><span class="order-amount"><%= displayAmount %></span></td>
                                <td>
                                    <span class="payment-method">
                                        <i class="fa-solid fa-credit-card"></i>
                                        <%= paymentMethod %>
                                    </span>
                                </td>
                                <td><span class="status-badge status-<%= statusClass %>"><%= statusLabel %></span></td>
                                <td>
                                    <div class="action-buttons">
                                        <a class="btn-view" href="adminOrderDetails.jsp?orderId=<%= orderId %>">
                                            <i class="fa-solid fa-eye"></i> View
                                        </a>
                                        <% if ("Confirmed".equalsIgnoreCase(status)) { %>
                                        <form action="OrderServlet" method="post" style="display:inline;">
                                            <input type="hidden" name="action" value="prepare">
                                            <input type="hidden" name="orderId" value="<%= orderId %>">
                                            <button type="submit" class="btn-update">
                                                <i class="fa-solid fa-truck-fast"></i> Prepare
                                            </button>
                                        </form>
                                        <% } else if ("Prepared".equalsIgnoreCase(status)) { %>
                                        <button class="btn-update" disabled>
                                            <i class="fa-solid fa-box-open"></i> Prepared
                                        </button>
                                        <% } else { %>
                                        <button class="btn-update" disabled>
                                            <i class="fa-solid fa-check"></i> <%= statusLabel %>
                                        </button>
                                        <% } %>
                                    </div>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
                <% } %>
            </div>
        </div>
    </div>
</div>

<script>
function viewOrder(orderId, customer, amount, payment, address) {
    alert('Order Details:\\n\\nOrder ID: ' + orderId + '\\nCustomer: ' + customer + '\\nAmount: ' + amount + '\\nPayment: ' + payment + '\\nAddress: ' + address);
}

function updateStatus(orderId) {
    const newStatus = prompt('Enter new status (pending/processing/completed/cancelled):', 'processing');
    if (newStatus && ['pending', 'processing', 'completed', 'cancelled'].includes(newStatus.toLowerCase())) {
        alert('Status updated to: ' + newStatus + ' for order ' + orderId);
        // In a real application, this would make an AJAX call to update the status
    }
}
</script>
</body>
</html>


