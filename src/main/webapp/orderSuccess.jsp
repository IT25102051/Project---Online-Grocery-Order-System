<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String username = (String) session.getAttribute("username");
    if (username == null) { response.sendRedirect("login.jsp"); return; }
    String orderId  = (String) session.getAttribute("lastOrderId");
    String total    = (String) session.getAttribute("lastOrderTotal");
    String payment  = (String) session.getAttribute("lastPayment");
    if (orderId == null) orderId = "—";
    if (total == null) total = "0.00";
    if (payment == null) payment = "—";
%>
<!DOCTYPE html>
<html>
<head>
    <title>Order Confirmed - CeylonFresh</title>
    <style>
        *{margin:0;padding:0;box-sizing:border-box;font-family:'Segoe UI',sans-serif;}
        body{background:linear-gradient(135deg,#f0fdf4,#dcfce7);min-height:100vh;display:flex;flex-direction:column;align-items:center;justify-content:center;padding:30px;}
        .card{background:white;border-radius:30px;box-shadow:0 20px 50px rgba(0,0,0,0.1);padding:52px 60px;max-width:520px;width:100%;text-align:center;}
        .check-circle{width:90px;height:90px;background:#16a34a;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:44px;margin:0 auto 24px;}
        h1{font-size:34px;color:#14532d;margin-bottom:10px;}
        .sub{color:#6b7280;font-size:16px;margin-bottom:32px;line-height:1.6;}
        .order-details{background:#f8fffe;border:1px solid #d1fae5;border-radius:18px;padding:22px;margin-bottom:30px;text-align:left;}
        .detail-row{display:flex;justify-content:space-between;align-items:center;padding:10px 0;border-bottom:1px solid #e8fef0;font-size:15px;}
        .detail-row:last-child{border-bottom:none;}
        .detail-label{color:#6b7280;font-weight:500;}
        .detail-value{color:#14532d;font-weight:700;}
        .total-row .detail-value{font-size:20px;color:#16a34a;}
        .btn-group{display:flex;gap:14px;flex-direction:column;}
        .btn-primary{display:block;padding:15px;background:#16a34a;color:white;text-decoration:none;border-radius:14px;font-weight:bold;font-size:16px;transition:0.2s;}
        .btn-primary:hover{background:#15803d;transform:translateY(-2px);}
        .btn-secondary{display:block;padding:14px;background:#f0fdf4;color:#16a34a;text-decoration:none;border-radius:14px;font-weight:bold;font-size:15px;border:2px solid #d1fae5;transition:0.2s;}
        .btn-secondary:hover{background:#dcfce7;}
    </style>
</head>
<body>
<div class="card">
    <div class="check-circle">✅</div>
    <h1>Order Confirmed!</h1>
    <p class="sub">Your grocery order has been placed successfully.<br>We'll deliver it to your doorstep soon!</p>

    <div class="order-details">
        <div class="detail-row">
            <span class="detail-label">Order ID</span>
            <span class="detail-value"><%= orderId %></span>
        </div>
        <div class="detail-row">
            <span class="detail-label">Customer</span>
            <span class="detail-value"><%= username %></span>
        </div>
        <div class="detail-row">
            <span class="detail-label">Payment Method</span>
            <span class="detail-value"><%= payment %></span>
        </div>
        <div class="detail-row total-row">
            <span class="detail-label">Amount Paid</span>
            <span class="detail-value">Rs. <%= total %></span>
        </div>
    </div>

    <div class="btn-group">
        <a href="products.jsp" class="btn-primary">Continue Shopping 🛍️</a>
        <a href="OrderHistoryServlet" class="btn-secondary">View My Orders 📦</a>
        <a href="customerDashboard.jsp" class="btn-secondary">Back to Dashboard</a>
    </div>
</div>
</body>
</html>
