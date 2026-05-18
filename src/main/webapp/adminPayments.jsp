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

    // Load payments: paymentId,orderId,method,amount,status,date
    List<String[]> payments = new ArrayList<>();
    File pmf = new File(dataDir + "payments.txt");
    if (pmf.exists()) {
        BufferedReader br = new BufferedReader(new FileReader(pmf));
        String line;
        while ((line = br.readLine()) != null) {
            line = line.trim();
            if (line.isEmpty()) continue;
            payments.add(line.split(",", 6));
        }
        br.close();
    }
    Collections.reverse(payments);

    // Calculate statistics
    double totalCollected = 0;
    int successfulPayments = 0;
    int pendingPayments = 0;
    int failedPayments = 0;

    for (String[] p : payments) {
        try {
            double amount = Double.parseDouble(p[3].trim());
            totalCollected += amount;
        } catch (Exception e) {}

        String status = p.length > 4 ? p[4].trim().toLowerCase() : "completed";
        if ("completed".equals(status) || "success".equals(status)) {
            successfulPayments++;
        } else if ("pending".equals(status)) {
            pendingPayments++;
        } else if ("failed".equals(status) || "cancelled".equals(status)) {
            failedPayments++;
        }
    }

    // Payment method breakdown
    Map<String, Integer> methodCounts = new HashMap<>();
    Map<String, Double> methodAmounts = new HashMap<>();
    for (String[] p : payments) {
        String method = p.length > 2 ? p[2].trim() : "Unknown";
        try {
            double amount = Double.parseDouble(p[3].trim());
            methodCounts.put(method, methodCounts.getOrDefault(method, 0) + 1);
            methodAmounts.put(method, methodAmounts.getOrDefault(method, 0.0) + amount);
        } catch (Exception e) {}
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Payment Management - CeylonFresh Admin</title>
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
        .content { padding: 30px; }
        .stat-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 20px; margin-bottom: 28px; }
        .stat-card { background: white; padding: 24px; border-radius: 18px; box-shadow: 0 18px 40px rgba(15,23,42,0.06); border: 1px solid rgba(148,163,184,0.12); }
        .stat-top { display: flex; align-items: center; justify-content: space-between; margin-bottom: 18px; }
        .stat-icon { width: 52px; height: 52px; border-radius: 14px; display: flex; align-items: center; justify-content: center; color: white; font-size: 20px; }
        .stat-icon.green { background: #16a34a; }
        .stat-icon.blue { background: #2563eb; }
        .stat-icon.orange { background: #f59e0b; }
        .stat-icon.red { background: #dc2626; }
        .stat-num { font-size: 32px; font-weight: 800; color: #0f172a; margin-bottom: 6px; }
        .stat-label { color: #64748b; font-size: 14px; }
        .layout-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; }
        .panel { background: white; border-radius: 20px; box-shadow: 0 18px 40px rgba(15,23,42,0.06); border: 1px solid rgba(148,163,184,0.12); overflow: hidden; }
        .panel-header { padding: 24px 28px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; }
        .panel-header h3 { margin: 0; font-size: 20px; color: #0f172a; }
        .panel-header span { color: #64748b; font-size: 14px; }
        .panel-body { padding: 24px 28px 28px; }
        .payment-table { width: 100%; border-collapse: collapse; }
        .payment-table th, .payment-table td { padding: 16px 20px; text-align: left; border-bottom: 1px solid #e2e8f0; }
        .payment-table th { background: #f8fafc; font-weight: 700; color: #0f172a; font-size: 14px; }
        .payment-table td { color: #64748b; font-size: 14px; }
        .payment-id { font-weight: 700; color: #0f172a; font-family: 'Monaco', 'Menlo', monospace; }
        .order-id { font-weight: 600; color: #2563eb; }
        .payment-amount { font-weight: 700; color: #16a34a; font-size: 16px; }
        .payment-method { display: inline-flex; align-items: center; gap: 8px; padding: 6px 12px; background: #f8fafc; border-radius: 8px; font-size: 12px; color: #64748b; font-weight: 600; }
        .method-icon { font-size: 14px; }
        .status-badge { padding: 6px 12px; border-radius: 20px; font-size: 12px; font-weight: 700; text-transform: uppercase; }
        .status-completed { background: #dcfce7; color: #166534; }
        .status-pending { background: #fef3c7; color: #f59e0b; }
        .status-failed { background: #fee2e2; color: #dc2626; }
        .status-cancelled { background: #f3f4f6; color: #6b7280; }
        .action-buttons { display: flex; gap: 8px; }
        .btn-view { background: #3b82f6; color: white; border: none; padding: 8px 12px; border-radius: 8px; font-size: 12px; font-weight: 600; cursor: pointer; }
        .btn-view:hover { background: #2563eb; }
        .btn-refund { background: #dc2626; color: white; border: none; padding: 8px 12px; border-radius: 8px; font-size: 12px; font-weight: 600; cursor: pointer; }
        .btn-refund:hover { background: #b91c1c; }
        .empty-state { padding: 60px 20px; color: #64748b; text-align: center; }
        .empty-state i { font-size: 48px; color: #cbd5e1; margin-bottom: 16px; }
        .empty-state h4 { margin: 0 0 8px 0; color: #475569; }
        .method-breakdown { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 16px; margin-top: 20px; }
        .method-item { display: flex; align-items: center; gap: 12px; padding: 16px; background: #f8fafc; border-radius: 12px; }
        .method-icon-large { width: 40px; height: 40px; border-radius: 10px; display: flex; align-items: center; justify-content: center; color: white; font-size: 16px; }
        .method-info h5 { margin: 0 0 4px 0; font-size: 14px; color: #0f172a; }
        .method-info p { margin: 0; font-size: 12px; color: #64748b; }
        @media (max-width: 1024px) { .layout-grid { grid-template-columns: 1fr; } .payment-table { font-size: 12px; } .payment-table th, .payment-table td { padding: 12px 8px; } }
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
    <a href="adminPayments.jsp" class="active"><i class="fa-solid fa-credit-card"></i> Payments</a>
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
            <h2>Payment Management</h2>
            <div class="breadcrumb">Admin / Payments</div>
        </div>
        <div class="topbar-right">
            <div class="topbar-date">Today: <%= new java.util.Date().toString().substring(0,10) %></div>
        </div>
    </div>
    <div class="content">
        <div class="stat-grid">
            <div class="stat-card">
                <div class="stat-top">
                    <div class="stat-icon green"><i class="fa-solid fa-dollar-sign"></i></div>
                </div>
                <div class="stat-num">Rs. <%= String.format("%.0f", totalCollected) %></div>
                <div class="stat-label">Total Collected</div>
            </div>
            <div class="stat-card">
                <div class="stat-top">
                    <div class="stat-icon blue"><i class="fa-solid fa-check-circle"></i></div>
                </div>
                <div class="stat-num"><%= successfulPayments %></div>
                <div class="stat-label">Successful Payments</div>
            </div>
            <div class="stat-card">
                <div class="stat-top">
                    <div class="stat-icon orange"><i class="fa-solid fa-clock"></i></div>
                </div>
                <div class="stat-num"><%= pendingPayments %></div>
                <div class="stat-label">Pending Payments</div>
            </div>
            <div class="stat-card">
                <div class="stat-top">
                    <div class="stat-icon red"><i class="fa-solid fa-times-circle"></i></div>
                </div>
                <div class="stat-num"><%= failedPayments %></div>
                <div class="stat-label">Failed Payments</div>
            </div>
        </div>
        <div class="layout-grid">
            <div class="panel">
                <div class="panel-header">
                    <h3>All Payment Transactions</h3>
                    <span><%= payments.size() %> transactions recorded</span>
                </div>
                <div class="panel-body">
                    <% if (payments.isEmpty()) { %>
                    <div class="empty-state">
                        <i class="fa-solid fa-credit-card"></i>
                        <h4>No Payment Records</h4>
                        <p>Payment transactions will appear here once customers start making purchases.</p>
                    </div>
                    <% } else { %>
                    <div style="overflow-x: auto;">
                        <table class="payment-table">
                            <thead>
                                <tr>
                                    <th>Payment ID</th>
                                    <th>Order ID</th>
                                    <th>Method</th>
                                    <th>Amount</th>
                                    <th>Status</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (String[] payment : payments) {
                                    String paymentId = payment.length > 0 ? payment[0] : "—";
                                    String orderId = payment.length > 1 ? payment[1] : "—";
                                    String method = payment.length > 2 ? payment[2] : "Unknown";
                                    String amount = payment.length > 3 ? payment[3] : "0";
                                    String status = payment.length > 4 ? payment[4].toLowerCase() : "completed";
                                    String date = payment.length > 5 ? payment[5] : "—";

                                    // Format amount
                                    String displayAmount = amount;
                                    try {
                                        displayAmount = "Rs. " + String.format("%.2f", Double.parseDouble(amount));
                                    } catch (Exception e) {}

                                    // Determine status class
                                    String statusClass = "completed";
                                    String statusLabel = "Completed";
                                    if ("pending".equals(status)) {
                                        statusClass = "pending";
                                        statusLabel = "Pending";
                                    } else if ("failed".equals(status) || "cancelled".equals(status)) {
                                        statusClass = "failed";
                                        statusLabel = "Failed";
                                    }

                                    // Method icon
                                    String methodIcon = "fa-credit-card";
                                    if (method.toLowerCase().contains("cash")) methodIcon = "fa-money-bill-wave";
                                    else if (method.toLowerCase().contains("debit")) methodIcon = "fa-credit-card";
                                    else if (method.toLowerCase().contains("paypal")) methodIcon = "fa-paypal";
                                %>
                                <tr>
                                    <td><span class="payment-id"><%= paymentId.length() > 12 ? paymentId.substring(0, 12) + "..." : paymentId %></span></td>
                                    <td><span class="order-id"><%= orderId.length() > 12 ? orderId.substring(0, 12) + "..." : orderId %></span></td>
                                    <td>
                                        <span class="payment-method">
                                            <i class="fa-solid <%= methodIcon %> method-icon"></i>
                                            <%= method %>
                                        </span>
                                    </td>
                                    <td><span class="payment-amount"><%= displayAmount %></span></td>
                                    <td><span class="status-badge status-<%= statusClass %>"><%= statusLabel %></span></td>
                                    <td>
                                        <div class="action-buttons">
                                            <a class="btn-view" href="adminPaymentDetails.jsp?paymentId=<%= paymentId %>">
                                                <i class="fa-solid fa-eye"></i> View
                                            </a>
                                            <% if ("completed".equals(statusClass)) { %>
                                            <button class="btn-refund" onclick="processRefund('<%= paymentId %>')">
                                                <i class="fa-solid fa-undo"></i> Refund
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
            <div class="panel">
                <div class="panel-header">
                    <h3>Payment Methods Breakdown</h3>
                    <span>Transaction distribution</span>
                </div>
                <div class="panel-body">
                    <% if (methodCounts.isEmpty()) { %>
                    <div class="empty-state">
                        <i class="fa-solid fa-chart-pie"></i>
                        <h4>No Payment Data</h4>
                        <p>Payment method statistics will appear here.</p>
                    </div>
                    <% } else { %>
                    <div class="method-breakdown">
                        <% for (Map.Entry<String, Integer> entry : methodCounts.entrySet()) {
                            String method = entry.getKey();
                            int count = entry.getValue();
                            double amount = methodAmounts.getOrDefault(method, 0.0);

                            String methodIcon = "fa-credit-card";
                            String bgColor = "#3b82f6";
                            if (method.toLowerCase().contains("cash")) {
                                methodIcon = "fa-money-bill-wave";
                                bgColor = "#16a34a";
                            } else if (method.toLowerCase().contains("debit")) {
                                methodIcon = "fa-credit-card";
                                bgColor = "#8b5cf6";
                            } else if (method.toLowerCase().contains("paypal")) {
                                methodIcon = "fa-paypal";
                                bgColor = "#2563eb";
                            }
                        %>
                        <div class="method-item">
                            <div class="method-icon-large" style="background: <%= bgColor %>;">
                                <i class="fa-solid <%= methodIcon %>"></i>
                            </div>
                            <div class="method-info">
                                <h5><%= method %></h5>
                                <p><%= count %> transactions • Rs. <%= String.format("%.0f", amount) %></p>
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

<script>
function viewPayment(paymentId, orderId, method, amount, status, date) {
    alert('Payment Details:\\n\\nPayment ID: ' + paymentId + '\\nOrder ID: ' + orderId + '\\nMethod: ' + method + '\\nAmount: ' + amount + '\\nStatus: ' + status + '\\nDate: ' + date);
}

function processRefund(paymentId) {
    const reason = prompt('Enter refund reason:', 'Customer request');
    if (reason && confirm('Are you sure you want to process a refund for payment ' + paymentId + '?')) {
        alert('Refund processed for payment ' + paymentId + '. Amount will be credited back to customer.');
        // In a real application, this would make an AJAX call to process the refund
    }
}
</script>
</body>
</html>


