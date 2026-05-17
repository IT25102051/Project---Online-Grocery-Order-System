<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%
    String role = (String) session.getAttribute("role");
    if (role == null || !"Delivery".equalsIgnoreCase(role)) {
        response.sendRedirect("login.jsp");
        return;
    }
    String username = (String) session.getAttribute("username");
    String dataDir = application.getRealPath("/") + "data/";

    List<String[]> preparedOrders = new ArrayList<>();
    List<String[]> pickedUpOrders = new ArrayList<>();
    File ordersFile = new File(dataDir + "orders.txt");
    if (ordersFile.exists()) {
        try (BufferedReader br = new BufferedReader(new FileReader(ordersFile))) {
            String line;
            while ((line = br.readLine()) != null) {
                line = line.trim();
                if (line.isEmpty()) continue;
                String[] parts = line.split(",", 9);
                String status = parts.length > 7 ? parts[7].trim() : "Confirmed";
                if ("Prepared".equalsIgnoreCase(status) || "Out for Delivery".equalsIgnoreCase(status)) {
                    preparedOrders.add(parts);
                } else if ("Picked Up".equalsIgnoreCase(status)) {
                    pickedUpOrders.add(parts);
                }
            }
        }
    }

    Map<String, List<String>> orderItemsMap = new HashMap<>();
    File itemsFile = new File(dataDir + "order_items.txt");
    if (itemsFile.exists()) {
        try (BufferedReader br = new BufferedReader(new FileReader(itemsFile))) {
            String line;
            while ((line = br.readLine()) != null) {
                line = line.trim();
                if (line.isEmpty()) continue;
                String[] parts = line.split(",", 5);
                if (parts.length >= 4) {
                    String oid = parts[0];
                    String pname = parts[2];
                    String qty = parts[3];
                    orderItemsMap.computeIfAbsent(oid, k -> new ArrayList<>()).add(qty + "x " + pname);
                }
            }
        }
    }

    List<String[]> deliveryNotifications = new ArrayList<>();
    int unreadDeliveryCount = 0;
    File notifFile = new File(dataDir + "notifications.txt");
    if (notifFile.exists()) {
        try (BufferedReader br = new BufferedReader(new FileReader(notifFile))) {
            String line;
            while ((line = br.readLine()) != null) {
                line = line.trim();
                if (line.isEmpty()) continue;
                String[] raw = line.split(",", 6);
                String recipient = raw.length > 1 ? raw[1].trim() : "All";
                String title = raw.length > 2 ? raw[2].replace(";", ",") : "";
                String message = raw.length > 3 ? raw[3].replace(";", ",") : "";
                String time = raw.length > 4 ? raw[4] : "";
                String readFlag = raw.length > 5 ? raw[5].trim() : "unread";
                if ("All".equalsIgnoreCase(recipient) || "Delivery".equalsIgnoreCase(recipient)) {
                    deliveryNotifications.add(new String[]{raw[0], recipient, title, message, time, readFlag});
                    if (!"read".equalsIgnoreCase(readFlag)) {
                        unreadDeliveryCount++;
                    }
                }
            }
        }
    }

    int totalReadyOrders = preparedOrders.size();
    int totalDeliveryAlerts = deliveryNotifications.size();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Delivery Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        body { margin: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f3f7fb; color: #102a43; }
        .dashboard-container { max-width: 1200px; margin: 0 auto; padding: 28px 24px 60px; }
        .dashboard-head { display: flex; align-items: flex-start; justify-content: space-between; gap: 24px; margin-bottom: 28px; }
        .eyebrow { text-transform: uppercase; letter-spacing: .16em; font-size: 12px; color: #16a34a; margin-bottom: 12px; font-weight: 700; }
        .dashboard-head h1 { font-size: 38px; margin: 0 0 10px; color: #0f172a; }
        .dashboard-head p { margin: 0; color: #475569; line-height: 1.7; max-width: 680px; }
        .action-buttons { display: flex; flex-wrap: wrap; gap: 12px; }
        .btn { display: inline-flex; align-items: center; gap: 10px; border: none; padding: 14px 20px; border-radius: 16px; font-weight: 700; cursor: pointer; text-decoration: none; }
        .btn-primary { background: #16a34a; color: white; }
        .btn-secondary { background: #ffffff; color: #0f172a; border: 1px solid #d1d5db; }
        .stat-grid { display: grid; grid-template-columns: repeat(3, minmax(220px, 1fr)); gap: 20px; margin-bottom: 30px; }
        .stat-card { background: white; border-radius: 24px; padding: 26px; box-shadow: 0 20px 50px rgba(15, 23, 42, 0.08); }
        .stat-card span { display: block; color: #64748b; margin-bottom: 14px; font-size: 14px; }
        .stat-card h2 { margin: 0; font-size: 42px; color: #0f172a; }
        .stat-card p { margin-top: 8px; color: #475569; font-size: 14px; }
        .section-grid { display: grid; grid-template-columns: 1.6fr 1fr; gap: 24px; }
        .panel { background: white; border-radius: 24px; padding: 28px; box-shadow: 0 20px 50px rgba(15, 23, 42, 0.08); }
        .panel .panel-title { font-size: 22px; margin-bottom: 16px; color: #0f172a; }
        .panel .panel-description { color: #64748b; margin-bottom: 24px; }
        .order-table { width: 100%; border-collapse: collapse; }
        .order-table th, .order-table td { padding: 18px 16px; border-bottom: 1px solid #e2e8f0; text-align: left; font-size: 14px; }
        .order-table th { color: #334155; background: #f8fafc; font-weight: 700; }
        .order-table tbody tr:hover { background: #f8fafc; }
        .order-table td button { border: none; background: #16a34a; color: white; padding: 10px 18px; border-radius: 14px; cursor: pointer; font-weight: 700; }
        .notification-list { display: grid; gap: 18px; }
        .notification-card { border-radius: 20px; padding: 18px 22px; background: #f8fafc; border: 1px solid #e2e8f0; }
        .notification-card strong { display: block; font-size: 16px; color: #0f172a; margin-bottom: 8px; }
        .notification-card p { margin: 0 0 8px; color: #475569; font-size: 14px; line-height: 1.7; }
        .notification-card .meta { font-size: 12px; color: #64748b; }
        .notification-card .badge { display: inline-flex; align-items: center; gap: 6px; margin-top: 12px; background: #e0f2fe; color: #0c4a6e; padding: 6px 10px; border-radius: 999px; font-size: 12px; }
        .empty-state { text-align: center; padding: 42px 24px; border: 2px dashed #cbd5e1; border-radius: 24px; background: white; color: #64748b; }
        .empty-state h4 { margin: 0 0 12px; color: #0f172a; }
        .notif-icon-btn { position: relative; display: inline-flex; align-items: center; justify-content: center; width: 52px; height: 52px; border-radius: 16px; background: #ffffff; border: 1px solid #d1d5db; cursor: pointer; text-decoration: none; transition: all 0.3s ease; }
        .notif-icon-btn:hover { background: #f0fdf4; border-color: #16a34a; transform: translateY(-2px); box-shadow: 0 8px 20px rgba(22, 163, 74, 0.15); }
        .notif-icon-btn svg { width: 24px; height: 24px; color: #334155; }
        .notif-icon-btn:hover svg { color: #16a34a; }
        .notif-badge { position: absolute; top: -6px; right: -6px; background: #ef4444; color: white; font-size: 11px; font-weight: 800; min-width: 22px; height: 22px; border-radius: 999px; display: flex; align-items: center; justify-content: center; padding: 0 6px; border: 2px solid white; animation: pulse-badge 2s infinite; }
        @keyframes pulse-badge { 0%, 100% { transform: scale(1); } 50% { transform: scale(1.1); } }
        @media (max-width: 1024px) { .section-grid { grid-template-columns: 1fr; } }
        @media (max-width: 768px) { .dashboard-head { flex-direction: column; } }
    </style>
</head>
<body>
<div class="dashboard-container">
    <header class="dashboard-head">
        <div>
            <div class="eyebrow">Delivery Operations</div>
            <h1>Delivery Dashboard</h1>
            <p>Welcome back, <strong><%= username != null ? username : "Delivery Team" %></strong>. This dashboard shows only admin-assigned delivery alerts and orders ready for pickup.</p>
        </div>
        <div class="action-buttons">
            <a href="deliveryNotifications.jsp" class="notif-icon-btn" title="Notification Center">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M14.857 17.082a23.848 23.848 0 0 0 5.454-1.31A8.967 8.967 0 0 1 18 9.75V9A6 6 0 0 0 6 9v.75a8.967 8.967 0 0 1-2.312 6.022c1.733.64 3.56 1.085 5.455 1.31m5.714 0a24.255 24.255 0 0 1-5.714 0m5.714 0a3 3 0 1 1-5.714 0" />
                </svg>
                <% if (unreadDeliveryCount > 0) { %>
                <span class="notif-badge"><%= unreadDeliveryCount %></span>
                <% } %>
            </a>
            <a href="LogoutServlet" class="btn btn-primary">Logout</a>
        </div>
    </header>

    <% if (request.getParameter("picked") != null) { %>
    <div class="panel" style="margin-bottom:24px; border-left:4px solid #16a34a;">
        <strong>Success</strong>
        <p>Order pickup updated successfully. The admin has been notified.</p>
    </div>
    <% } %>
    <% if (request.getParameter("delivered") != null) { %>
    <div class="panel" style="margin-bottom:24px; border-left:4px solid #16a34a;">
        <strong>Delivery Complete</strong>
        <p>Order has been marked as delivered. The admin has been notified about the payment collection.</p>
    </div>
    <% } %>

    <div class="stat-grid">
        <div class="stat-card">
            <span>Total Ready Orders</span>
            <h2><%= totalReadyOrders %></h2>
            <p>Orders prepared and awaiting pickup.</p>
        </div>
        <div class="stat-card">
            <span>Delivery Alerts</span>
            <h2><%= totalDeliveryAlerts %></h2>
            <p>Admin-selected alerts sent to delivery staff.</p>
        </div>
        <div class="stat-card">
            <span>Unread Alerts</span>
            <h2><%= unreadDeliveryCount %></h2>
            <p>Delivery notifications still unread.</p>
        </div>
    </div>

    <div class="section-grid">
        <div class="panel">
            <div class="panel-title">Pickup Queue</div>
            <div class="panel-description"> orders ready for collection and delivery.</div>
            <% if (preparedOrders.isEmpty()) { %>
            <div class="empty-state">
                <h4>No orders ready yet</h4>
                <p>The admin will assign orders here once they are prepared for pickup.</p>
            </div>
            <% } else { %>
            <table class="order-table">
                <thead>
                <tr>
                    <th>Order</th>
                    <th>Customer</th>
                    <th>Total</th>
                    <th>Payment</th>
                    <th>Address</th>
                    <th>Action</th>
                </tr>
                </thead>
                <tbody>
                <% for (String[] order : preparedOrders) {
                    String orderId = order.length > 0 ? order[0] : "—";
                    String customer = order.length > 2 ? order[2] : "—";
                    String total = order.length > 3 ? order[3] : "0";
                    String payment = order.length > 4 ? order[4] : "—";
                    String address = order.length > 5 ? order[5] : "—";
                    String displayAmount = total;
                    try { displayAmount = "Rs. " + String.format("%.2f", Double.parseDouble(total)); } catch (Exception ignored) {}
                %>
                <tr>
                    <td>
                        <strong><%= orderId %></strong>
                        <div style="font-size:12px; color:#64748b; margin-top:6px; max-width:180px;">
                            <%= String.join(", ", orderItemsMap.getOrDefault(orderId, Collections.emptyList())) %>
                        </div>
                    </td>
                    <td><%= customer %></td>
                    <td><%= displayAmount %></td>
                    <td><%= payment %></td>
                    <td><%= address %></td>
                    <td>
                        <form action="OrderServlet" method="post">
                            <input type="hidden" name="action" value="pickup">
                            <input type="hidden" name="orderId" value="<%= orderId %>">
                            <button type="submit" class="btn btn-primary" style="padding:10px 18px;"><i class="fa-solid fa-truck"></i> Pickup</button>
                        </form>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
            <% } %>

            <% if (!pickedUpOrders.isEmpty()) { %>
            <div class="panel-title" style="margin-top:28px;">Active Deliveries</div>
            <div class="panel-description">Orders you have picked up — mark as delivered when done.</div>
            <table class="order-table">
                <thead>
                <tr>
                    <th>Order</th>
                    <th>Customer</th>
                    <th>Total</th>
                    <th>Payment</th>
                    <th>Address</th>
                    <th>Action</th>
                </tr>
                </thead>
                <tbody>
                <% for (String[] order : pickedUpOrders) {
                    String pOrderId = order.length > 0 ? order[0] : "—";
                    String pCustomer = order.length > 2 ? order[2] : "—";
                    String pTotal = order.length > 3 ? order[3] : "0";
                    String pPayment = order.length > 4 ? order[4] : "—";
                    String pAddress = order.length > 5 ? order[5] : "—";
                    String pDisplayAmount = pTotal;
                    try { pDisplayAmount = "Rs. " + String.format("%.2f", Double.parseDouble(pTotal)); } catch (Exception ignored) {}
                    boolean isCOD = "Cash on Delivery".equalsIgnoreCase(pPayment);
                %>
                <tr>
                    <td>
                        <strong><%= pOrderId %></strong>
                        <div style="font-size:12px; color:#64748b; margin-top:6px; max-width:180px;">
                            <%= String.join(", ", orderItemsMap.getOrDefault(pOrderId, Collections.emptyList())) %>
                        </div>
                    </td>
                    <td><%= pCustomer %></td>
                    <td><%= pDisplayAmount %></td>
                    <td><%= pPayment %><%= isCOD ? " 💵" : "" %></td>
                    <td><%= pAddress %></td>
                    <td style="display:flex; gap:8px;">
                        <form action="OrderServlet" method="post" style="margin:0;">
                            <input type="hidden" name="action" value="deliver">
                            <input type="hidden" name="orderId" value="<%= pOrderId %>">
                            <button type="submit" class="btn btn-primary" style="padding:10px 14px; background:#2563eb; font-size:13px;" title="Delivered"><i class="fa-solid fa-check-circle"></i></button>
                        </form>
                        <form action="OrderServlet" method="post" style="margin:0;">
                            <input type="hidden" name="action" value="not_delivered">
                            <input type="hidden" name="orderId" value="<%= pOrderId %>">
                            <button type="submit" class="btn btn-primary" style="padding:10px 14px; background:#ef4444; font-size:13px;" title="Not Delivered"><i class="fa-solid fa-times-circle"></i></button>
                        </form>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
            <% } %>
        </div>

        <div class="panel" style="margin-bottom:24px;">
            <div class="panel-title" style="color:#2563eb;"><i class="fa-solid fa-truck-ramp-box"></i> Active Supply Requests</div>
            <div class="panel-description">Assigned inventory tasks from Admin.</div>
            <div class="notification-list">
                <%
                    List<String[]> activeRequests = new ArrayList<>();
                    File iFile = new File(dataDir + "inventory.txt");
                    if (iFile.exists()) {
                        try (BufferedReader ibr = new BufferedReader(new FileReader(iFile))) {
                            String iline;
                            while ((iline = ibr.readLine()) != null) {
                                iline = iline.trim();
                                if (iline.isEmpty()) continue;
                                String[] iparts = iline.split(",", -1);

                                String invId = "";
                                String pName = "";
                                String qty = "0";
                                String supplier = "";
                                String status = "Requested";

                                if (iparts.length >= 6) {
                                    invId = iparts[0].trim();
                                    pName = iparts[2].trim();
                                    qty = iparts[3].trim();
                                    supplier = iparts[4].trim();
                                    status = iparts[5].trim();
                                } else if (iparts.length >= 4) {
                                    invId = iparts[0].trim();
                                    pName = iparts[1].trim();
                                    qty = iparts[2].trim();
                                    supplier = iparts[3].trim();
                                }

                                if (username.equalsIgnoreCase(supplier) && ("Pending".equals(status) || "Approved".equals(status))) {
                                    activeRequests.add(new String[]{invId, "", pName, qty, supplier, status});
                                }
                            }
                        }
                    }
                    if (activeRequests.isEmpty()) {
                %>
                <div class="empty-state" style="border-color:#16a34a; background:#f0fdf4;">
                    <h4 style="color:#166534;">No Active Requests</h4>
                    <p>You have no pending supply tasks.</p>
                </div>
                <% } else {
                    for (String[] req : activeRequests) {
                        String invId = req[0];
                        String pName = req[2];
                        String qty = req[3];
                        String status = req[5];
                %>
                <div class="notification-card" style="border-left:4px solid #3b82f6; display:flex; justify-content:space-between; align-items:center;">
                    <div>
                        <strong><%= pName %></strong>
                        <p>Quantity: <strong><%= qty %> units</strong></p>
                        <div class="meta">Status: <span style="font-weight:700; color:#2563eb;"><%= "Approved".equals(status) ? "Stock Available" : status %></span></div>
                    </div>
                    <div style="display:flex; gap:8px;">
                        <% if ("Pending".equals(status)) { %>
                        <form action="InventoryServlet" method="post" style="margin:0;">
                            <input type="hidden" name="action" value="updateStatus">
                            <input type="hidden" name="inventoryId" value="<%= invId %>">
                            <input type="hidden" name="status" value="Approved">
                            <button type="submit" class="btn btn-primary" style="padding:8px 12px; font-size:12px; background:#f59e0b;" title="Accept and Approve Request">
                                <i class="fa-solid fa-thumbs-up"></i> Accept & Approve
                            </button>
                        </form>
                        <% } else if ("Approved".equals(status)) { %>
                        <form action="InventoryServlet" method="post" style="margin:0;">
                            <input type="hidden" name="action" value="updateStatus">
                            <input type="hidden" name="inventoryId" value="<%= invId %>">
                            <input type="hidden" name="status" value="Delivered">
                            <button type="submit" class="btn btn-primary" style="padding:8px 12px; font-size:12px; background:#16a34a;" title="Mark as Delivered">
                                <i class="fa-solid fa-truck-ramp-box"></i> Mark Delivered
                            </button>
                        </form>
                        <% } %>
                    </div>
                </div>
                <% } } %>
            </div>
        </div>

        <div class="panel">
            <div class="panel-title">Admin Delivery Alerts</div>

            <div class="panel-description">Only notifications selected for Delivery staff appear here.</div>
            <% if (deliveryNotifications.isEmpty()) { %>
            <div class="empty-state">
                <h4>No delivery alerts</h4>
                <p>Admin notifications will appear here once sent.</p>
            </div>
            <% } else { %>
            <div class="notification-list">
                <% for (String[] note : deliveryNotifications) {
                    String title = note.length > 2 ? note[2] : "Delivery update";
                    String message = note.length > 3 ? note[3] : "";
                    String time = note.length > 4 ? note[4] : "Unknown time";
                    String status = note.length > 5 ? note[5] : "unread";
                %>
                <div class="notification-card" style="display:flex; justify-content:space-between; align-items:flex-start;">
                    <div>
                        <strong><%= title %></strong>
                        <p><%= message %></p>
                        <div class="meta">Sent: <%= time %> · <span class="badge"><%= "read".equalsIgnoreCase(status) ? "Read" : "Unread" %></span></div>
                    </div>
                    <% if (!"read".equalsIgnoreCase(status)) {
                        String nid = note.length > 0 ? note[0] : "";
                    %>
                    <form action="NotificationServlet" method="post" style="margin:0;">
                        <input type="hidden" name="action" value="markRead">
                        <input type="hidden" name="id" value="<%= nid %>">
                        <button type="submit" class="btn btn-secondary" style="padding:8px 12px; font-size:12px;"><i class="fa-solid fa-check"></i> Mark Read</button>
                    </form>
                    <% } %>
                </div>
                <% } %>
            </div>
            <% } %>
        </div>
    </div>
</div>
</body>
</html>
