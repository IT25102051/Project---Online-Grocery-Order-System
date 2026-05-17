<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.io.*, java.util.*" %>
<%
    String adminName = (String) session.getAttribute("username");
    String adminRole = (String) session.getAttribute("role");
    if (adminName == null || !"Admin".equalsIgnoreCase(adminRole)) {
        response.sendRedirect("adminLogin.jsp");
        return;
    }

    String paymentId = request.getParameter("paymentId");
    String dataDir = application.getRealPath("/") + "data/";
    String[] payment = null;
    String[] order = null;
    if (paymentId != null && !paymentId.trim().isEmpty()) {
        File pf = new File(dataDir + "payments.txt");
        if (pf.exists()) {
            try (BufferedReader br = new BufferedReader(new FileReader(pf))) {
                String line;
                while ((line = br.readLine()) != null) {
                    String[] parts = line.split(",", 6);
                    if (parts.length > 0 && parts[0].trim().equals(paymentId.trim())) {
                        payment = parts;
                        break;
                    }
                }
            }
        }
        if (payment != null && payment.length > 1) {
            String orderId = payment[1].trim();
            File of = new File(dataDir + "orders.txt");
            if (of.exists()) {
                try (BufferedReader br = new BufferedReader(new FileReader(of))) {
                    String line;
                    while ((line = br.readLine()) != null) {
                        String[] parts = line.split(",", 9);
                        if (parts.length > 0 && parts[0].trim().equals(orderId)) {
                            order = parts;
                            break;
                        }
                    }
                }
            }
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Payment Details - CeylonFresh Admin</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f3f6fb; margin: 0; color: #334155; }
        .page { max-width: 960px; margin: 0 auto; padding: 32px; }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; }
        .header h1 { margin: 0; font-size: 32px; }
        .header .breadcrumb { color: #64748b; font-size: 14px; }
        .card { background: white; border-radius: 20px; padding: 28px; box-shadow: 0 18px 40px rgba(15,23,42,0.06); border: 1px solid rgba(148,163,184,0.12); }
        .section { margin-top: 20px; }
        .section-title { margin-bottom: 18px; color: #0f172a; font-size: 20px; }
        .detail-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 18px; }
        .detail-item { background: #f8fafc; padding: 18px; border-radius: 16px; }
        .detail-label { display: block; color: #64748b; margin-bottom: 6px; font-size: 13px; }
        .detail-value { font-size: 16px; font-weight: 700; color: #0f172a; }
        .order-summary { margin-top: 20px; }
        .order-summary p { margin: 8px 0; }
        .back-link { display: inline-flex; align-items: center; gap: 8px; padding: 12px 18px; color: #0f172a; border-radius: 14px; text-decoration: none; border: 1px solid #cbd5e1; margin-top: 24px; }
        .empty-state { padding: 50px; text-align: center; color: #64748b; }
    </style>
</head>
<body>
<div class="page">
    <div class="header">
        <div>
            <h1>Payment Details</h1>
            <div class="breadcrumb">Admin / Payments / Details</div>
        </div>
        <div>
            <a class="back-link" href="adminPayments.jsp"><i class="fa-solid fa-arrow-left"></i> Back to Payments</a>
        </div>
    </div>
    <div class="card">
        <% if (payment == null) { %>
            <div class="empty-state">
                <i class="fa-solid fa-triangle-exclamation" style="font-size: 32px;"></i>
                <h2>Payment not found</h2>
                <p>The requested payment record could not be found.</p>
            </div>
        <% } else {
            String orderId = payment.length > 1 ? payment[1] : "—";
            String method = payment.length > 2 ? payment[2] : "—";
            String amount = payment.length > 3 ? payment[3] : "0";
            String status = payment.length > 4 ? payment[4] : "—";
            String date = payment.length > 5 ? payment[5] : "—";
        %>
            <div class="section">
                <div class="section-title">Payment Summary</div>
                <div class="detail-grid">
                    <div class="detail-item">
                        <span class="detail-label">Payment ID</span>
                        <span class="detail-value"><%= payment[0] %></span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Order ID</span>
                        <span class="detail-value"><a href="adminOrderDetails.jsp?orderId=<%= orderId %>"><%= orderId %></a></span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Method</span>
                        <span class="detail-value"><%= method %></span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Amount</span>
                        <span class="detail-value">Rs. <%= amount %></span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Status</span>
                        <span class="detail-value"><%= status %></span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Date</span>
                        <span class="detail-value"><%= date %></span>
                    </div>
                </div>
            </div>
            <% if (order != null) { %>
            <div class="section order-summary">
                <div class="section-title">Related Order</div>
                <p><strong>Customer:</strong> <%= order.length > 2 ? order[2] : "—" %></p>
                <p><strong>Status:</strong> <%= order.length > 7 ? order[7] : "Confirmed" %></p>
                <p><strong>Delivery:</strong> <%= order.length > 8 ? order[8] : "N/A" %></p>
                <p><strong>Shipping Address:</strong> <%= order.length > 5 ? order[5] : "—" %></p>
            </div>
            <% } else { %>
            <div class="section order-summary">
                <div class="section-title">Related Order</div>
                <p>The order linked to this payment could not be found in the system.</p>
            </div>
            <% } %>
        <% } %>
    </div>
</div>
</body>
</html>
