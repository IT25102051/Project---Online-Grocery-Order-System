<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.grocery.dao.ReviewDAO" %>
<%@ page import="com.grocery.model.Review" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String username = (String) session.getAttribute("username");
    String role     = (String) session.getAttribute("role");
    String userId   = (String) session.getAttribute("userId");

    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    ReviewDAO reviewDao = new ReviewDAO(application.getRealPath("/"));
    List<Review> reviews = (List<Review>) request.getAttribute("reviews");
    if (reviews == null) {
        reviews = reviewDao.getAllReviewObjects();
        Collections.reverse(reviews);
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Customer Reviews - CeylonFresh</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        :root {
            --primary: #064e3b;
            --primary-light: #10b981;
            --bg-color: #f8fafc;
            --text-main: #0f172a;
        }
        *{margin:0;padding:0;box-sizing:border-box;font-family:'Outfit',sans-serif;}
        body{background:var(--bg-color); color:var(--text-main); display: flex; min-height: 100vh;}

        /* SIDEBAR */
        .sidebar{position:fixed;left:0;top:0;width:280px;height:100vh;background:linear-gradient(180deg,var(--primary),#065f46);padding:35px 25px;color:white;box-shadow:5px 0 20px rgba(0,0,0,0.08);z-index:100;}
        .logo{font-size:28px;font-weight:800;margin-bottom:50px;display:flex;align-items:center;gap:10px;color:white;text-decoration:none;}
        .logo i {color:var(--primary-light);}
        .menu a{display:flex;align-items:center;gap:15px;padding:16px 18px;margin-bottom:12px;text-decoration:none;color:rgba(255,255,255,0.8);border-radius:16px;transition:0.3s;font-weight:600;font-size:16px;}
        .menu a:hover{background:rgba(255,255,255,0.1);color:white;transform:translateX(5px);}
        .menu a.active{background:white;color:var(--primary);box-shadow:0 10px 20px rgba(0,0,0,0.1);}
        .menu a.logout{margin-top:50px;color:#fca5a5;}
        .menu a.logout:hover{background:rgba(239,68,68,0.1);color:#ef4444;}

        /* MAIN CONTENT */
        .main{margin-left:280px;flex:1;padding:40px;}
        .header{margin-bottom:40px;display:flex;justify-content:space-between;align-items:center;}
        .header h1{font-size:36px;font-weight:800;color:var(--primary);}

        /* STATS */
        .stats{display:grid;grid-template-columns:repeat(3,1fr);gap:24px;margin-bottom:40px;}
        .stat-card{background:white;padding:30px;border-radius:24px;box-shadow:0 10px 30px rgba(0,0,0,0.03);text-align:center;}
        .stat-card h2{font-size:32px;color:var(--primary);margin-bottom:8px;}
        .stat-card p{color:#64748b;font-weight:600;font-size:14px;}

        /* LAYOUT */
        .review-grid{display:grid;grid-template-columns:1fr 1.5fr;gap:40px;}

        /* FORM */
        .card{background:white;padding:40px;border-radius:30px;box-shadow:0 10px 30px rgba(0,0,0,0.03);height:fit-content;}
        .card h2{font-size:24px;margin-bottom:25px;color:var(--primary);}
        .input-group{margin-bottom:20px;}
        .input-group label{display:block;margin-bottom:8px;font-weight:600;color:#475569;font-size:14px;}
        .input-group input, .input-group select, .input-group textarea{width:100%;padding:14px;border:1px solid #e2e8f0;border-radius:14px;outline:none;transition:0.3s;font-size:15px;}
        .input-group input:focus, .input-group select:focus, .input-group textarea:focus{border-color:var(--primary-light);box-shadow:0 0 0 4px rgba(16,185,129,0.1);}
        textarea{height:120px;resize:none;}
        .btn{width:100%;padding:16px;background:var(--primary);color:white;border:none;border-radius:14px;font-weight:700;font-size:16px;cursor:pointer;transition:0.3s;}
        .btn:hover{background:#065f46;transform:translateY(-2px);box-shadow:0 10px 20px rgba(6,78,59,0.2);}

        /* REVIEW LIST */
        .review-list{max-height:800px;overflow-y:auto;padding-right:10px;}
        .review-list::-webkit-scrollbar{width:6px;}
        .review-list::-webkit-scrollbar-thumb{background:#e2e8f0;border-radius:10px;}
        .review-card{background:white;padding:30px;border-radius:24px;margin-bottom:24px;box-shadow:0 10px 30px rgba(0,0,0,0.03);position:relative;border:1px solid transparent;transition:0.3s;}
        .review-card:hover{border-color:var(--primary-light);transform:translateY(-4px);}
        .review-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:15px;}
        .customer{display:flex;align-items:center;gap:12px;}
        .avatar{width:48px;height:48px;border-radius:50%;background:linear-gradient(135deg,var(--primary-light),var(--primary));color:white;display:flex;justify-content:center;align-items:center;font-weight:800;font-size:18px;}
        .customer h3{font-size:18px;color:var(--primary);}
        .rating{color:#fbbf24;font-size:14px;}
        .product-tag{display:inline-block;padding:6px 14px;background:#f1f5f9;color:#475569;border-radius:99px;font-size:12px;font-weight:700;margin-bottom:12px;}
        .review-text{color:#475569;line-height:1.6;font-size:15px;}
        .delete-btn{position:absolute;top:30px;right:30px;color:#ef4444;background:none;border:none;cursor:pointer;font-size:18px;transition:0.2s;opacity:0.3;}
        .delete-btn:hover{opacity:1;transform:scale(1.1);}

        @media(max-width:1100px){
            .review-grid{grid-template-columns:1fr;}
            .sidebar{display:none;}
            .main{margin-left:0;}
        }
    </style>
</head>
<body>

<%
    double averageRating = 0;
    int totalReviews = reviews.size();
    int satisfiedCount = 0;
    for (Review r : reviews) {
        averageRating += r.getRating();
        if (r.getRating() >= 4) satisfiedCount++;
    }
    if (totalReviews > 0) averageRating /= totalReviews;
    int satisfactionRate = totalReviews > 0 ? (int) Math.round((satisfiedCount * 100.0) / totalReviews) : 0;
%>

<div class="sidebar">
    <a href="customerDashboard.jsp" class="logo"><i class="fa-solid fa-leaf"></i> CeylonFresh</a>
    <div class="menu">
        <a href="customerDashboard.jsp"><i class="fa-solid fa-gauge"></i> Dashboard</a>
        <a href="products.jsp"><i class="fa-solid fa-store"></i> Products</a>
        <a href="OrderHistoryServlet"><i class="fa-solid fa-box"></i> Orders</a>
        <a href="notifications.jsp"><i class="fa-solid fa-bell"></i> Notifications</a>
        <a href="reviews.jsp" class="active"><i class="fa-solid fa-star"></i> Reviews</a>
        <a href="LogoutServlet" class="logout"><i class="fa-solid fa-right-from-bracket"></i> Logout</a>
    </div>
</div>

<div class="main">
    <div class="header">
        <h1>Customer Feedback</h1>
    </div>

    <div class="stats">
        <div class="stat-card">
            <h2><%= totalReviews > 0 ? String.format("%.1f", averageRating) : "0" %><span style="font-size:18px;color:#fbbf24;">★</span></h2>
            <p>Average Rating</p>
        </div>
        <div class="stat-card">
            <h2><%= totalReviews %></h2>
            <p>Total Reviews</p>
        </div>
        <div class="stat-card">
            <h2><%= satisfactionRate %>%</h2>
            <p>Satisfaction Rate</p>
        </div>
    </div>

    <div class="review-grid">
        <div class="card">
            <h2>Share Your Experience</h2>
            <form action="ReviewServlet" method="post">
                <input type="hidden" name="action" value="add">
                <input type="hidden" name="productName" value="General Feedback">
                <div class="input-group">
                    <label>Rating</label>
                    <select name="rating">
                        <option value="5">⭐⭐⭐⭐⭐ (5/5)</option>
                        <option value="4">⭐⭐⭐⭐ (4/5)</option>
                        <option value="3">⭐⭐⭐ (3/5)</option>
                        <option value="2">⭐⭐ (2/5)</option>
                        <option value="1">⭐ (1/5)</option>
                    </select>
                </div>
                <div class="input-group">
                    <label>Your Review</label>
                    <textarea name="reviewText" placeholder="What did you like about our products?" required></textarea>
                </div>
                <button type="submit" class="btn">Submit Review</button>
            </form>
        </div>

        <div class="review-list">
            <h2 style="margin-bottom:25px; color:var(--primary);">Recent Reviews</h2>
            <% if (reviews.isEmpty()) { %>
            <div class="review-card" style="text-align:center;padding:40px;color:#94a3b8;">
                <i class="fa-solid fa-star-half-stroke" style="font-size:32px;margin-bottom:15px;opacity:0.3;"></i>
                <p>No reviews yet. Be the first to share your experience!</p>
            </div>
            <% } else {
                for (Review r : reviews) {
                    String initials = r.getUserName().isEmpty() ? "?" : r.getUserName().substring(0,1).toUpperCase();
                    boolean isOwner = r.getUserName().equalsIgnoreCase(username) || "Admin".equalsIgnoreCase(role);
            %>
            <div class="review-card">
                <div class="review-header">
                    <div class="customer">
                        <div class="avatar"><%= initials %></div>
                        <div>
                            <h3><%= r.getUserName() %></h3>
                            <div class="rating"><%= "★".repeat(r.getRating()) %><%= "☆".repeat(5-r.getRating()) %></div>
                        </div>
                    </div>
                    <% if (isOwner) { %>
                    <form action="ReviewServlet" method="post" onsubmit="return confirm('Delete this review?')">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="reviewId" value="<%= r.getReviewId() %>">
                        <button type="submit" class="delete-btn"><i class="fa-solid fa-trash-can"></i></button>
                    </form>
                    <% } %>
                </div>
                <p class="review-text"><%= r.getComment() %></p>
            </div>
            <% } } %>
        </div>
    </div>
</div>

</body>
</html>
