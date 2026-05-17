<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String role = (String) session.getAttribute("role");
    String userId = (String) session.getAttribute("userId");
    String username = (String) session.getAttribute("username");
    if (userId == null || !"Customer".equalsIgnoreCase(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    String dataDir = application.getRealPath("/") + "data/";

    // 1) Load all orders for this user  — orderId -> order details
    //    orders.txt format: orderId,userId,customerName,total,paymentMethod,address,phone[,status,...]
    Map<String, String[]> userOrders = new LinkedHashMap<>();
    File ordersFile = new File(dataDir + "orders.txt");
    if (ordersFile.exists()) {
        try (BufferedReader br = new BufferedReader(new FileReader(ordersFile))) {
            String line;
            while ((line = br.readLine()) != null) {
                line = line.trim();
                if (line.isEmpty()) continue;
                String[] parts = line.split(",", 9);
                String orderUserId = parts.length > 1 ? parts[1].trim() : "";
                if (orderUserId.equals(userId)) {
                    String orderId = parts[0].trim();
                    userOrders.put(orderId, parts);
                }
            }
        }
    }

    // 2) Load payments and match to user's orders
    //    payments.txt formats:
    //    Old: paymentId,orderId,userId,method,amount,status
    //    New: paymentId,orderId,method,amount,status
    List<Map<String, String>> userPayments = new ArrayList<>();
    double totalPaid = 0;
    int completedCount = 0;
    int pendingCount = 0;
    File paymentsFile = new File(dataDir + "payments.txt");
    if (paymentsFile.exists()) {
        try (BufferedReader br = new BufferedReader(new FileReader(paymentsFile))) {
            String line;
            while ((line = br.readLine()) != null) {
                line = line.trim();
                if (line.isEmpty()) continue;
                String[] parts = line.split(",");
                if (parts.length < 4) continue;

                String paymentId, orderId, method, amountStr, payStatus;

                // Detect format: if parts[2] starts with "U" or is a UUID, it's the old format with userId
                if (parts.length >= 6 && (parts[2].trim().startsWith("U") || parts[2].trim().length() > 20)) {
                    paymentId = parts[0].trim();
                    orderId = parts[1].trim();
                    // parts[2] = userId (skip)
                    method = parts[3].trim();
                    amountStr = parts[4].trim();
                    payStatus = parts[5].trim();
                } else {
                    paymentId = parts[0].trim();
                    orderId = parts[1].trim();
                    method = parts[2].trim();
                    amountStr = parts[3].trim();
                    payStatus = parts.length > 4 ? parts[4].trim() : "Completed";
                }

                // Only include if the orderId belongs to this user
                if (userOrders.containsKey(orderId)) {
                    Map<String, String> payment = new LinkedHashMap<>();
                    payment.put("paymentId", paymentId);
                    payment.put("orderId", orderId);
                    payment.put("method", method);
                    payment.put("amount", amountStr);
                    payment.put("status", payStatus);

                    // Get customer name and order status from order data
                    String[] orderData = userOrders.get(orderId);
                    payment.put("customerName", orderData.length > 2 ? orderData[2].trim() : username);
                    payment.put("orderStatus", orderData.length > 7 ? orderData[7].trim() : "Confirmed");

                    userPayments.add(payment);

                    try {
                        double amt = Double.parseDouble(amountStr);
                        totalPaid += amt;
                    } catch (Exception ignored) {}

                    if ("Completed".equalsIgnoreCase(payStatus) || "Success".equalsIgnoreCase(payStatus)) {
                        completedCount++;
                    } else {
                        pendingCount++;
                    }
                }
            }
        }
    }

    // Reverse so newest first
    Collections.reverse(userPayments);
    int totalPayments = userPayments.size();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment History - CeylonFresh</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Inter', 'Segoe UI', sans-serif;
            background: #f1f5f9;
            color: #334155;
            min-height: 100vh;
        }

        /* ── Navbar ── */
        .navbar {
            background: white;
            padding: 16px 56px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 4px 16px rgba(0,0,0,0.06);
            position: sticky;
            top: 0;
            z-index: 100;
        }

        .logo {
            font-size: 26px;
            font-weight: 800;
            color: #16a34a;
            text-decoration: none;
        }

        .nav-links {
            display: flex;
            align-items: center;
            gap: 22px;
        }

        .nav-links a {
            text-decoration: none;
            color: #374151;
            font-weight: 600;
            font-size: 15px;
            transition: 0.2s;
        }

        .nav-links a:hover { color: #16a34a; }
        .nav-links a.active { color: #16a34a; }
        .nav-links a.logout { color: #dc2626; }

        .avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: #16a34a;
            color: white;
            display: flex;
            justify-content: center;
            align-items: center;
            font-weight: bold;
            font-size: 17px;
        }

        /* ── Page Container ── */
        .page-container {
            max-width: 1100px;
            margin: 0 auto;
            padding: 36px 24px 80px;
        }

        /* ── Page Header ── */
        .page-header {
            margin-bottom: 32px;
        }

        .page-header .breadcrumb {
            font-size: 13px;
            color: #94a3b8;
            margin-bottom: 8px;
            font-weight: 500;
        }

        .page-header .breadcrumb a {
            color: #16a34a;
            text-decoration: none;
        }

        .page-header h1 {
            font-size: 36px;
            font-weight: 800;
            color: #0f172a;
            margin-bottom: 8px;
        }

        .page-header p {
            color: #64748b;
            font-size: 16px;
            line-height: 1.6;
        }

        /* ── Stats Grid ── */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 18px;
            margin-bottom: 32px;
        }

        .stat-card {
            background: white;
            border-radius: 20px;
            padding: 24px;
            box-shadow: 0 4px 16px rgba(0,0,0,0.04);
            border: 1px solid #e2e8f0;
            transition: all 0.3s ease;
        }

        .stat-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 30px rgba(0,0,0,0.08);
            border-color: rgba(22, 163, 74, 0.3);
        }

        .stat-card .stat-icon {
            width: 48px;
            height: 48px;
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 22px;
            margin-bottom: 16px;
        }

        .stat-icon.blue { background: #dbeafe; }
        .stat-icon.green { background: #dcfce7; }
        .stat-icon.orange { background: #ffedd5; }
        .stat-icon.purple { background: #ede9fe; }

        .stat-card h2 {
            font-size: 30px;
            font-weight: 800;
            color: #0f172a;
            margin-bottom: 4px;
        }

        .stat-card p {
            color: #64748b;
            font-size: 13px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.04em;
        }

        /* ── Payment Table Panel ── */
        .panel {
            background: white;
            border-radius: 24px;
            box-shadow: 0 4px 16px rgba(0,0,0,0.04);
            border: 1px solid #e2e8f0;
            overflow: hidden;
        }

        .panel-header {
            padding: 24px 28px;
            border-bottom: 1px solid #f1f5f9;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .panel-header h2 {
            font-size: 20px;
            font-weight: 700;
            color: #0f172a;
        }

        .panel-header .count-badge {
            background: #f0fdf4;
            color: #16a34a;
            padding: 6px 14px;
            border-radius: 10px;
            font-size: 13px;
            font-weight: 700;
        }

        .table-wrap {
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            min-width: 750px;
        }

        thead th {
            text-align: left;
            padding: 14px 20px;
            color: #64748b;
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.06em;
            background: #f8fafc;
            border-bottom: 1px solid #e2e8f0;
        }

        tbody td {
            padding: 18px 20px;
            border-bottom: 1px solid #f1f5f9;
            font-size: 14px;
            color: #334155;
        }

        tbody tr {
            transition: background 0.2s ease;
        }

        tbody tr:hover {
            background: #f8fafc;
        }

        tbody tr:last-child td {
            border-bottom: none;
        }

        .pay-id {
            font-weight: 700;
            color: #0f172a;
            font-size: 13px;
        }

        .order-id {
            color: #16a34a;
            font-weight: 600;
            font-size: 13px;
        }

        .method-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 14px;
            border-radius: 10px;
            font-size: 12px;
            font-weight: 700;
        }

        .method-card {
            background: #dbeafe;
            color: #1e40af;
        }

        .method-cod {
            background: #ffedd5;
            color: #c2410c;
        }

        .method-debit {
            background: #ede9fe;
            color: #6d28d9;
        }

        .amount {
            font-weight: 800;
            color: #0f172a;
            font-size: 15px;
        }

        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 14px;
            border-radius: 10px;
            font-size: 12px;
            font-weight: 700;
        }

        .status-completed {
            background: #dcfce7;
            color: #166534;
        }

        .status-pending {
            background: #fef3c7;
            color: #92400e;
        }

        .status-dot {
            width: 7px;
            height: 7px;
            border-radius: 50%;
        }

        .status-completed .status-dot { background: #16a34a; }
        .status-pending .status-dot { background: #f59e0b; }

        /* ── Empty State ── */
        .empty-state {
            text-align: center;
            padding: 60px 30px;
        }

        .empty-state .empty-icon {
            width: 80px;
            height: 80px;
            margin: 0 auto 20px;
            background: #f1f5f9;
            border-radius: 24px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 36px;
        }

        .empty-state h3 {
            font-size: 22px;
            font-weight: 700;
            color: #0f172a;
            margin-bottom: 10px;
        }

        .empty-state p {
            color: #64748b;
            font-size: 15px;
            max-width: 400px;
            margin: 0 auto 24px;
            line-height: 1.7;
        }

        .empty-state .shop-btn {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 14px 28px;
            background: #16a34a;
            color: white;
            border-radius: 14px;
            text-decoration: none;
            font-weight: 700;
            font-size: 15px;
            transition: all 0.3s ease;
        }

        .empty-state .shop-btn:hover {
            background: #15803d;
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(22, 163, 74, 0.25);
        }

        /* ── Responsive ── */
        @media (max-width: 900px) {
            .stats-grid { grid-template-columns: repeat(2, 1fr); }
            .navbar { padding: 16px 20px; flex-direction: column; gap: 14px; }
            .page-container { padding: 24px 16px 60px; }
            .page-header h1 { font-size: 28px; }
        }

        @media (max-width: 600px) {
            .stats-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>

<!-- NAVBAR -->
<div class="navbar">
    <a class="logo" href="customerDashboard.jsp">🛒 CeylonFresh</a>
    <div class="nav-links">
        <a href="customerDashboard.jsp">Dashboard</a>
        <a href="products.jsp">Products</a>
        <a href="OrderHistoryServlet">Orders</a>
        <a href="paymentHistory.jsp" class="active">Payments</a>
        <a href="LogoutServlet" class="logout">Logout</a>
        <div class="avatar"><%= username != null ? username.substring(0,1).toUpperCase() : "C" %></div>
    </div>
</div>

<div class="page-container">

    <!-- PAGE HEADER -->
    <div class="page-header">
        <div class="breadcrumb">
            <a href="customerDashboard.jsp">Dashboard</a> / Payment History
        </div>
        <h1>💳 Payment History</h1>
        <p>View all your completed and pending grocery order payments in one place.</p>
    </div>

    <!-- STATS -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon blue">💳</div>
            <h2><%= totalPayments %></h2>
            <p>Total Payments</p>
        </div>
        <div class="stat-card">
            <div class="stat-icon green">✅</div>
            <h2><%= completedCount %></h2>
            <p>Completed</p>
        </div>
        <div class="stat-card">
            <div class="stat-icon orange">⏳</div>
            <h2><%= pendingCount %></h2>
            <p>Pending</p>
        </div>
        <div class="stat-card">
            <div class="stat-icon purple">💰</div>
            <h2>Rs. <%= String.format("%.2f", totalPaid) %></h2>
            <p>Total Spent</p>
        </div>
    </div>

    <!-- PAYMENT TABLE -->
    <div class="panel">
        <div class="panel-header">
            <h2>Your Payments</h2>
            <span class="count-badge"><%= totalPayments %> records</span>
        </div>

        <% if (userPayments.isEmpty()) { %>
        <div class="empty-state">
            <div class="empty-icon">💳</div>
            <h3>No payment history yet</h3>
            <p>Once you place and pay for orders, your payment records will appear here.</p>
            <a href="products.jsp" class="shop-btn">🛍️ Start Shopping</a>
        </div>
        <% } else { %>
        <div class="table-wrap">
            <table>
                <thead>
                <tr>
                    <th>#</th>
                    <th>Payment ID</th>
                    <th>Order ID</th>
                    <th>Method</th>
                    <th>Amount</th>
                    <th>Status</th>
                </tr>
                </thead>
                <tbody>
                <%
                    int idx = 1;
                    for (Map<String, String> pay : userPayments) {
                        String payId = pay.get("paymentId");
                        String ordId = pay.get("orderId");
                        String method = pay.get("method");
                        String amountStr = pay.get("amount");
                        String payStatus = pay.get("status");

                        // Format amount
                        String displayAmount = amountStr;
                        try {
                            displayAmount = "Rs. " + String.format("%.2f", Double.parseDouble(amountStr));
                        } catch (Exception ignored) {}

                        // Determine method badge class
                        String methodLower = method.toLowerCase();
                        String methodClass = "method-card";
                        String methodIcon = "💳";
                        if (methodLower.contains("cash") || methodLower.contains("cod")) {
                            methodClass = "method-cod";
                            methodIcon = "💵";
                        } else if (methodLower.contains("debit")) {
                            methodClass = "method-debit";
                            methodIcon = "🏦";
                        }

                        // Status
                        boolean isCompleted = "Completed".equalsIgnoreCase(payStatus) || "Success".equalsIgnoreCase(payStatus);
                        String statusClass = isCompleted ? "status-completed" : "status-pending";
                        String statusLabel = isCompleted ? "Completed" : "Pending";

                        // Shorten IDs for display
                        String shortPayId = payId.length() > 16 ? payId.substring(0, 16) + "…" : payId;
                        String shortOrdId = ordId.length() > 16 ? ordId.substring(0, 16) + "…" : ordId;
                %>
                <tr>
                    <td><%= idx++ %></td>
                    <td><span class="pay-id" title="<%= payId %>"><%= shortPayId %></span></td>
                    <td><span class="order-id" title="<%= ordId %>"><%= shortOrdId %></span></td>
                    <td>
                            <span class="method-badge <%= methodClass %>">
                                <%= methodIcon %> <%= method %>
                            </span>
                    </td>
                    <td><span class="amount"><%= displayAmount %></span></td>
                    <td>
                            <span class="status-badge <%= statusClass %>">
                                <span class="status-dot"></span>
                                <%= statusLabel %>
                            </span>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>
        <% } %>
    </div>

</div>

</body>
</html>
