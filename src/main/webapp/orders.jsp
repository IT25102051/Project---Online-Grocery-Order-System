<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%
    String username = (String) session.getAttribute("username");
    String userId   = (String) session.getAttribute("userId");
    if (username == null) { response.sendRedirect("login.jsp"); return; }

    // Orders passed from OrderHistoryServlet
    // Each String[]: [orderId, userId, userName, total, paymentMethod, address, phone]
    List<String[]> userOrders = (List<String[]>) request.getAttribute("userOrders");
    if (userOrders == null) userOrders = new ArrayList<>();

    // Status cycle based on order index (for demo realism)
    String[] statuses = {"Delivered", "Processing", "Out for Delivery", "Confirmed"};
    String[] statusColors = {"#16a34a", "#3b82f6", "#f97316", "#8b5cf6"};
    String[] statusEmojis = {"✅", "⏳", "🚚", "✔️"};
%>
<!DOCTYPE html>
<html>
<head>
    <title>My Orders - CeylonFresh</title>
    <style>
        *{margin:0;padding:0;box-sizing:border-box;font-family:'Segoe UI',sans-serif;}
        body{background:#f5fff7;min-height:100vh;}

        /* NAVBAR */
        .navbar{background:white;padding:16px 56px;display:flex;justify-content:space-between;align-items:center;box-shadow:0 4px 16px rgba(0,0,0,0.08);position:sticky;top:0;z-index:100;}
        .logo{font-size:26px;font-weight:bold;color:#16a34a;text-decoration:none;}
        .nav-links{display:flex;align-items:center;gap:20px;}
        .nav-links a{text-decoration:none;color:#374151;font-weight:600;font-size:15px;transition:0.2s;}
        .nav-links a:hover{color:#16a34a;}
        .nav-links a.logout{color:#dc2626;}
        .avatar{width:40px;height:40px;border-radius:50%;background:#16a34a;color:white;display:flex;justify-content:center;align-items:center;font-weight:bold;font-size:17px;}

        /* HEADER BANNER */
        .page-header{background:linear-gradient(135deg,#16a34a,#22c55e);margin:28px 56px;border-radius:28px;padding:38px 50px;color:white;display:flex;justify-content:space-between;align-items:center;}
        .page-header-text h1{font-size:38px;margin-bottom:8px;}
        .page-header-text p{font-size:16px;opacity:0.9;}
        .page-header-icon{font-size:100px;line-height:1;}

        /* STATS ROW */
        .stats-row{display:grid;grid-template-columns:repeat(4,1fr);gap:18px;margin:0 56px 32px;}
        .stat-card{background:white;border-radius:18px;padding:22px 20px;text-align:center;box-shadow:0 4px 14px rgba(0,0,0,0.07);}
        .stat-num{font-size:32px;font-weight:800;color:#14532d;margin-bottom:4px;}
        .stat-label{font-size:13px;color:#6b7280;font-weight:500;}

        /* ORDERS */
        .section{padding:0 56px 60px;}
        .section-title{font-size:22px;font-weight:700;color:#14532d;margin-bottom:20px;}

        .order-card{background:white;border-radius:22px;box-shadow:0 6px 20px rgba(0,0,0,0.07);margin-bottom:20px;overflow:hidden;transition:0.25s;}
        .order-card:hover{transform:translateY(-3px);box-shadow:0 12px 30px rgba(0,0,0,0.11);}

        .order-header{display:flex;justify-content:space-between;align-items:center;padding:20px 28px;border-bottom:1px solid #f0fdf4;}
        .order-id{font-size:17px;font-weight:800;color:#14532d;}
        .order-date{font-size:13px;color:#9ca3af;margin-top:3px;}
        .status-badge{padding:7px 16px;border-radius:50px;color:white;font-size:13px;font-weight:700;}

        .order-body{display:grid;grid-template-columns:1fr 1fr 1fr;gap:0;padding:22px 28px;}
        .order-field{padding:0 20px;}
        .order-field:first-child{padding-left:0;}
        .order-field:last-child{padding-right:0;border-right:none;}
        .order-field + .order-field{border-left:1px solid #f0fdf4;}
        .field-label{font-size:12px;color:#9ca3af;font-weight:600;text-transform:uppercase;letter-spacing:0.5px;margin-bottom:6px;}
        .field-value{font-size:15px;color:#1e293b;font-weight:600;}
        .field-value.amount{font-size:20px;color:#16a34a;font-weight:800;}

        .order-footer{background:#f8fffe;padding:14px 28px;display:flex;justify-content:space-between;align-items:center;border-top:1px solid #f0fdf4;}
        .order-footer-left{font-size:13px;color:#6b7280;}
        .footer-btn{padding:8px 20px;border-radius:10px;font-size:13px;font-weight:700;cursor:pointer;text-decoration:none;border:none;transition:0.2s;}
        .btn-reorder{background:#dcfce7;color:#16a34a;}
        .btn-reorder:hover{background:#16a34a;color:white;}

        /* EMPTY STATE */
        .empty-state{background:white;border-radius:24px;box-shadow:0 6px 20px rgba(0,0,0,0.07);padding:70px 40px;text-align:center;}
        .empty-icon{font-size:90px;margin-bottom:20px;}
        .empty-state h2{font-size:26px;color:#374151;margin-bottom:12px;}
        .empty-state p{color:#6b7280;font-size:16px;margin-bottom:28px;line-height:1.6;}
        .shop-now-btn{display:inline-block;padding:14px 32px;background:#16a34a;color:white;border-radius:14px;text-decoration:none;font-weight:bold;font-size:16px;transition:0.2s;}
        .shop-now-btn:hover{background:#15803d;transform:translateY(-2px);}

        @media(max-width:1000px){
            .navbar,.section,.stats-row,.page-header{margin-left:20px;margin-right:20px;padding-left:20px;padding-right:20px;}
            .page-header{flex-direction:column;gap:14px;text-align:center;}
            .page-header-icon{font-size:60px;}
            .stats-row{grid-template-columns:repeat(2,1fr);}
            .order-body{grid-template-columns:1fr;}
            .order-field{padding:8px 0 !important;border-left:none !important;border-bottom:1px solid #f0fdf4;}
            .navbar{flex-direction:column;gap:12px;}
        }
    </style>
</head>
<body>

<!-- NAVBAR -->
<div class="navbar">
    <a class="logo" href="customerDashboard.jsp">🛒 CeylonFresh</a>
    <div class="nav-links">
        <a href="products.jsp">Products</a>
        <a href="cart.jsp">🛒 Cart</a>
        <a href="OrderHistoryServlet">Orders</a>
        <a href="notifications.jsp">Notifications</a>
        <a href="LogoutServlet" class="logout">Logout</a>
        <div class="avatar"><%= username.substring(0,1).toUpperCase() %></div>
    </div>
</div>

<!-- PAGE HEADER -->
<div class="page-header">
    <div class="page-header-text">
        <h1>My Orders 📦</h1>
        <p>Track all your grocery purchases and delivery status</p>
    </div>
    <div class="page-header-icon">🛍️</div>
</div>

<!-- STATS -->
<%
    double totalSpent = 0;
    for (String[] o : userOrders) {
        try { totalSpent += Double.parseDouble(o[3].trim()); } catch(Exception e){}
    }
%>
<div class="stats-row">
    <div class="stat-card">
        <div class="stat-num"><%= userOrders.size() %></div>
        <div class="stat-label">Total Orders</div>
    </div>
    <div class="stat-card">
        <div class="stat-num">Rs. <%= String.format("%.2f", totalSpent) %></div>
        <div class="stat-label">Total Spent</div>
    </div>
    <div class="stat-card">
        <div class="stat-num"><%= userOrders.isEmpty() ? 0 : 1 %></div>
        <div class="stat-label">Active Orders</div>
    </div>
    <div class="stat-card">
        <div class="stat-num"><%= userOrders.isEmpty() ? 0 : userOrders.size() - 1 %></div>
        <div class="stat-label">Delivered</div>
    </div>
</div>

<!-- ORDERS LIST -->
<div class="section">
    <div class="section-title">Order History</div>

    <% if (userOrders.isEmpty()) { %>
    <div class="empty-state">
        <div class="empty-icon">📦</div>
        <h2>No Orders Yet</h2>
        <p>You haven't placed any orders yet.<br>Start shopping and your orders will appear here.</p>
        <a href="products.jsp" class="shop-now-btn">Start Shopping 🛍️</a>
    </div>

    <% } else {
        int idx = 0;
        for (String[] o : userOrders) {
            // Parse fields: orderId, userId, userName, total, paymentMethod, address, phone, status, deliveryId
            String orderId   = o.length > 0 ? o[0].trim() : "—";
            String total     = o.length > 3 ? o[3].trim() : "0.00";
            String payment   = o.length > 4 ? o[4].trim() : "—";
            String address   = o.length > 5 ? o[5].trim() : "—";
            String phone     = o.length > 6 ? o[6].trim() : "—";
            String status    = o.length > 7 ? o[7].trim() : "Confirmed";

            String statusColor = "#8b5cf6";
            String statusEmoji = "✔️";
            if ("Prepared".equalsIgnoreCase(status)) {
                statusColor = "#f59e0b";
                statusEmoji = "✔️";
            } else if ("Picked Up".equalsIgnoreCase(status) || "Out for Delivery".equalsIgnoreCase(status)) {
                statusColor = "#16a34a";
                statusEmoji = "🚚";
            } else if ("Confirmed".equalsIgnoreCase(status)) {
                statusColor = "#3b82f6";
                statusEmoji = "⏳";
            } else if ("Delivered".equalsIgnoreCase(status) || "Completed".equalsIgnoreCase(status)) {
                statusColor = "#16a34a";
                statusEmoji = "✅";
            }

            // Format display amount
            String displayAmt = total;
            try { displayAmt = String.format("%.2f", Double.parseDouble(total)); } catch(Exception e){}

            idx++;
    %>
    <div class="order-card">
        <div class="order-header">
            <div>
                <div class="order-id">📦 <%= orderId %></div>
                <div class="order-date">Placed by <%= username %></div>
            </div>
            <div class="status-badge" style="background:<%= statusColor %>">
                <%= statusEmoji %> <%= status %>
            </div>
        </div>

        <div class="order-body">
            <div class="order-field">
                <div class="field-label">Amount Paid</div>
                <div class="field-value amount">Rs. <%= displayAmt %></div>
            </div>
            <div class="order-field">
                <div class="field-label">Payment Method</div>
                <div class="field-value"><%= payment %></div>
            </div>
            <div class="order-field">
                <div class="field-label">Delivery Address</div>
                <div class="field-value"><%= address.length() > 40 ? address.substring(0,40) + "…" : address %></div>
            </div>
        </div>

        <div class="order-footer">
            <span class="order-footer-left">📞 Contact: <%= phone %></span>
            <a href="products.jsp" class="footer-btn btn-reorder">🔄 Reorder</a>
        </div>
    </div>
    <% } } %>

</div>

</body>
</html>
