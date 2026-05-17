<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.io.*, java.util.*" %>
<%@ page import="com.grocery.dao.ReviewDAO" %>
<%@ page import="com.grocery.model.Review" %>
<%
    String adminName = (String) session.getAttribute("username");
    String adminRole = (String) session.getAttribute("role");
    if (adminName == null || !"Admin".equalsIgnoreCase(adminRole)) {
        response.sendRedirect("adminLogin.jsp");
        return;
    }

    ReviewDAO reviewDao = new ReviewDAO(application.getRealPath("/"));
    List<Review> reviews = reviewDao.getAllReviewObjects();
    Collections.reverse(reviews);

    double avgRating = 0;
    if (!reviews.isEmpty()) {
        double sum = 0;
        for (Review r : reviews) sum += r.getRating();
        avgRating = sum / reviews.size();
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Reviews - CeylonFresh Admin</title>
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
        .stat-icon.orange { background: #f59e0b; }
        .stat-icon.yellow { background: #eab308; }
        .stat-num { font-size: 32px; font-weight: 800; color: #0f172a; margin-bottom: 6px; }
        .stat-label { color: #64748b; font-size: 14px; }
        .panel { background: white; border-radius: 20px; box-shadow: 0 18px 40px rgba(15,23,42,0.06); border: 1px solid rgba(148,163,184,0.12); overflow: hidden; }
        .panel-header { padding: 24px 28px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; }
        .panel-header h3 { margin: 0; font-size: 20px; color: #0f172a; }
        .panel-header span { color: #64748b; font-size: 14px; }
        .panel-body { padding: 24px 28px 28px; }
        .table-wrap { overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; min-width: 800px; }
        th, td { text-align: left; padding: 16px 18px; border-bottom: 1px solid #e2e8f0; }
        thead th { color: #334155; font-size: 14px; text-transform: uppercase; letter-spacing: 0.08em; border-bottom: 2px solid #e2e8f0; }
        tbody tr:hover { background: #f8fafc; }
        .review-id { font-weight: 700; color: #0f172a; font-family: monospace; font-size: 12px; }
        .user-id { color: #64748b; font-size: 13px; font-weight: 600; }
        .product-id { font-weight: 600; color: #0f172a; }
        .rating-stars { display: flex; align-items: center; gap: 4px; }
        .star-filled { color: #f59e0b; }
        .star-empty { color: #e2e8f0; }
        .rating-text { margin-left: 8px; font-weight: 600; color: #374151; }
        .comment-text { color: #64748b; max-width: 250px; }
        .btn-delete { background: #fee2e2; color: #ef4444; border: none; padding: 8px 12px; border-radius: 8px; cursor: pointer; transition: 0.2s; font-size: 13px; font-weight: 600; }
        .btn-delete:hover { background: #fca5a5; transform: scale(1.05); }
        .empty-state { padding: 40px; color: #64748b; text-align: center; }
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
    <a href="inventory.jsp"><i class="fa-solid fa-warehouse"></i> Inventory</a>
    <div class="nav-section">Content</div>
    <a href="adminReviews.jsp" class="active"><i class="fa-solid fa-star"></i> Reviews</a>
    <a href="adminNotifications.jsp"><i class="fa-solid fa-bell"></i> Notifications</a>
    <div class="sidebar-footer">
        <a href="LogoutServlet" class="logout-btn">Logout</a>
    </div>
</div>
<div class="main">
    <div class="topbar">
        <div class="topbar-left">
            <h2>Manage Reviews</h2>
            <div class="breadcrumb">Admin / Reviews</div>
        </div>
        <div class="topbar-right">
            <div class="topbar-date">📅 <%= new java.util.Date().toString().substring(0, 10) %></div>
        </div>
    </div>
    <div class="content">
        <div class="stat-grid">
            <div class="stat-card">
                <div class="stat-top">
                    <div class="stat-icon orange"><i class="fa-solid fa-star"></i></div>
                </div>
                <div class="stat-num"><%= reviews.size() %></div>
                <div class="stat-label">Total Reviews</div>
            </div>
            <div class="stat-card">
                <div class="stat-top">
                    <div class="stat-icon yellow"><i class="fa-solid fa-chart-line"></i></div>
                </div>
                <div class="stat-num"><%= reviews.isEmpty() ? "-" : String.format("%.1f", avgRating) %></div>
                <div class="stat-label">Average Rating</div>
            </div>
        </div>
        <div class="panel">
            <div class="panel-header">
                <h3>Customer Reviews</h3>
                <span>Manage product reviews and ratings</span>
            </div>
            <div class="panel-body">
                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Review ID</th>
                                <th>User</th>
                                <th>Product</th>
                                <th>Rating</th>
                                <th>Comment</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (reviews.isEmpty()) { %>
                            <tr><td colspan="7" class="empty-state">No reviews found. Customer reviews will appear here.</td></tr>
                            <% } else {
                                int index = 1;
                                for (Review r : reviews) {
                            %>
                            <tr>
                                <td><%= index++ %></td>
                                <td><div class="review-id"><%= r.getReviewId().length() > 8 ? r.getReviewId().substring(0, 8) + "..." : r.getReviewId() %></div></td>
                                <td><span class="user-id"><%= r.getUserName() %></span></td>
                                <td><span class="product-id"><%= r.getProductName() %></span></td>
                                <td>
                                    <div class="rating-stars">
                                        <% for (int s = 0; s < 5; s++) {
                                            String starClass = s < r.getRating() ? "star-filled" : "star-empty";
                                        %>
                                        <i class="fa-solid fa-star <%= starClass %>"></i>
                                        <% } %>
                                        <span class="rating-text">(<%= r.getRating() %>)</span>
                                    </div>
                                </td>
                                <td><span class="comment-text"><%= r.getComment().length() > 50 ? r.getComment().substring(0, 50) + "…" : r.getComment() %></span></td>
                                <td>
                                    <form action="ReviewServlet" method="post" onsubmit="return confirm('Permanently delete this review?')">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="reviewId" value="<%= r.getReviewId() %>">
                                        <button type="submit" class="btn-delete"><i class="fa-solid fa-trash-can"></i> Delete</button>
                                    </form>
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
</body>
</html>
