<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.io.*, java.util.*" %>
<%
    String adminName = (String) session.getAttribute("username");
    String adminRole = (String) session.getAttribute("role");
    if (adminName == null || !"Admin".equalsIgnoreCase(adminRole)) {
        response.sendRedirect("adminLogin.jsp");
        return;
    }

    String orderId = request.getParameter("orderId");
    String dataDir = application.getRealPath("/") + "data/";
    String[] order = null;
    List<String[]> items = new ArrayList<>();
    if (orderId != null && !orderId.trim().isEmpty()) {
        File of = new File(dataDir + "orders.txt");
        if (of.exists()) {
            try (BufferedReader br = new BufferedReader(new FileReader(of))) {
                String line;
                while ((line = br.readLine()) != null) {
                    String[] parts = line.split(",", 9);
                    if (parts.length > 0 && parts[0].trim().equals(orderId.trim())) {
                        order = parts;
                        break;
                    }
                }
            }
        }
        File oif = new File(dataDir + "order_items.txt");
        File pf = new File(dataDir + "products.txt");
        Map<String, String> productNames = new HashMap<>();
        if (pf.exists()) {
            try (BufferedReader br = new BufferedReader(new FileReader(pf))) {
                String line;
                while ((line = br.readLine()) != null) {
                    String[] parts = line.split(",", -1);
                    if (parts.length >= 2) productNames.put(parts[0].trim(), parts[1].trim());
                }
            }
        }

        if (oif.exists()) {
            try (BufferedReader br = new BufferedReader(new FileReader(oif))) {
                String line;
                while ((line = br.readLine()) != null) {
                    String[] parts = line.split(",", -1);
                    if (parts.length >= 5 && parts[1].trim().equals(orderId.trim())) {
                        String pId = parts[2].trim();
                        String name = productNames.getOrDefault(pId, "Product " + pId);
                        // Store as: name, qty, price
                        items.add(new String[]{name, parts[3].trim(), parts[4].trim()});
                    }
                }
            }
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Order Details - CeylonFresh Admin</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f3f6fb; margin: 0; color: #334155; }
        .page { max-width: 1020px; margin: 0 auto; padding: 32px; }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; }
        .header h1 { margin: 0; font-size: 32px; }
        .header .breadcrumb { color: #64748b; font-size: 14px; }
        .card { background: white; border-radius: 20px; padding: 28px; box-shadow: 0 18px 40px rgba(15,23,42,0.06); border: 1px solid rgba(148,163,184,0.12); }
        .section { margin-top: 20px; }
        .section-title { margin-bottom: 18px; color: #0f172a; font-size: 20px; }
        .detail-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 18px; }
        .detail-item { background: #f8fafc; padding: 18px; border-radius: 16px; }
        .detail-label { display: block; color: #64748b; margin-bottom: 6px; font-size: 13px; }
        .detail-value { font-size: 16px; font-weight: 700; color: #0f172a; }
        .items-table { width: 100%; border-collapse: collapse; margin-top: 14px; }
        .items-table th, .items-table td { padding: 16px 14px; border-bottom: 1px solid #e2e8f0; text-align: left; }
        .items-table th { color: #334155; font-weight: 700; background: #f8fafc; }
        .back-link { display: inline-flex; align-items: center; gap: 8px; padding: 12px 18px; color: #0f172a; border-radius: 14px; text-decoration: none; border: 1px solid #cbd5e1; margin-top: 24px; }
        .empty-state { padding: 50px; text-align: center; color: #64748b; }
    </style>
</head>
<body>
<div class="page">
    <div class="header">
        <div>
            <h1>Order Details</h1>
            <div class="breadcrumb">Admin / Orders / Details</div>
        </div>
        <div>
            <a class="back-link" href="adminOrders.jsp"><i class="fa-solid fa-arrow-left"></i> Back to Orders</a>
        </div>
    </div>

    <div class="card">
        <% if (order == null) { %>
            <div class="empty-state">
                <i class="fa-solid fa-triangle-exclamation" style="font-size: 32px;"></i>
                <h2>Order not found</h2>
                <p>The requested order could not be located. Please return to the order list.</p>
            </div>
        <% } else {
            String orderStatus = order.length > 7 ? order[7] : "Confirmed";
            String deliveryId = order.length > 8 ? order[8] : "N/A";
        %>
            <div class="section">
                <div class="section-title">Summary</div>
                <div class="detail-grid">
                    <div class="detail-item">
                        <span class="detail-label">Order ID</span>
                        <span class="detail-value"><%= order[0] %></span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Customer</span>
                        <span class="detail-value"><%= order.length > 2 ? order[2] : "—" %></span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Total Amount</span>
                        <span class="detail-value">Rs. <%= order.length > 3 ? order[3] : "0.00" %></span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Payment Method</span>
                        <span class="detail-value"><%= order.length > 4 ? order[4] : "—" %></span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Order Status</span>
                        <span class="detail-value"><%= orderStatus %></span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Delivery ID</span>
                        <span class="detail-value"><%= deliveryId %></span>
                    </div>
                </div>
            </div>
            <div class="section">
                <div class="section-title">Shipping & Contact</div>
                <div class="detail-grid">
                    <div class="detail-item">
                        <span class="detail-label">Address</span>
                        <span class="detail-value"><%= order.length > 5 ? order[5] : "—" %></span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Phone</span>
                        <span class="detail-value"><%= order.length > 6 ? order[6] : "—" %></span>
                    </div>
                </div>
            </div>
            <div class="section">
                <div class="section-title">Order Items</div>
                <% if (items.isEmpty()) { %>
                <div class="empty-state">
                    <p>No line items were recorded for this order.</p>
                </div>
                <% } else { %>
                <table class="items-table">
                    <thead>
                        <tr>
                            <th>Product</th>
                            <th>Quantity</th>
                            <th>Price</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (String[] item : items) {
                            String name = item[0];
                            String quantity = item[1];
                            String price = item[2];
                        %>
                        <tr>
                            <td><%= name %></td>
                            <td><%= quantity %></td>
                            <td>Rs. <%= price %></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                <% } %>
            </div>
        <% } %>
    </div>
</div>
</body>
</html>
