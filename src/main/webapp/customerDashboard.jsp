<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String username = (String) session.getAttribute("username");
    String role     = (String) session.getAttribute("role");
    String userId   = (String) session.getAttribute("userId");

    if (username == null || !"Customer".equalsIgnoreCase(role)) {
        response.sendRedirect("login.jsp");
        return;
    }
    boolean hasUnreadNotifications = false;
    java.io.File notificationFile = new java.io.File(application.getRealPath("/") + "data/notifications.txt");
    if (notificationFile.exists()) {
        try (java.io.BufferedReader br = new java.io.BufferedReader(new java.io.FileReader(notificationFile))) {
            String line;
            while ((line = br.readLine()) != null) {
                line = line.trim();
                if (line.isEmpty()) continue;
                String[] raw = line.split(",", 6);
                if (raw.length >= 6) {
                    String recipient = raw[1].trim();
                    String readFlag = raw[5].trim();
                    boolean allowed = "All".equalsIgnoreCase(recipient)
                            || recipient.equalsIgnoreCase(role)
                            || recipient.equalsIgnoreCase(userId);
                    if (allowed && !"read".equalsIgnoreCase(readFlag)) {
                        hasUnreadNotifications = true;
                        break;
                    }
                }
            }
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>CeylonFresh - Customer Dashboard</title>
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
        body{background:var(--bg-color); color:var(--text-main);}

        /* NAVBAR */
        .navbar{background:rgba(255,255,255,0.9);backdrop-filter:blur(10px);padding:16px 40px;display:flex;justify-content:space-between;align-items:center;box-shadow:0 4px 20px rgba(0,0,0,0.05);position:sticky;top:0;z-index:100;}
        .logo{font-size:24px;font-weight:800;color:var(--primary);text-decoration:none;display:flex;align-items:center;gap:8px;}
        .logo i {color:var(--primary-light);}
        .nav-links{display:flex;align-items:center;gap:24px;}
        .nav-links a{text-decoration:none;color:#475569;font-weight:600;font-size:15px;transition:0.3s;}
        .nav-links a:hover{color:var(--primary-light);}
        .nav-links a.logout{color:#ef4444;}
        .avatar{width:42px;height:42px;border-radius:50%;background:linear-gradient(135deg,var(--primary-light),var(--primary));color:white;display:flex;justify-content:center;align-items:center;font-weight:700;font-size:18px;box-shadow:0 4px 10px rgba(16,185,129,0.3);}

        /* HERO */
        .hero{margin:30px 40px;background:linear-gradient(135deg,var(--primary-light),var(--primary));border-radius:32px;padding:60px 70px;color:white;display:flex;justify-content:space-between;align-items:center;box-shadow:0 20px 40px rgba(6,78,59,0.15);}
        .hero-text h1{font-size:48px;line-height:1.2;margin-bottom:16px;font-weight:800;}
        .hero-text p{font-size:18px;margin-bottom:30px;opacity:0.9;}
        .hero-btn{padding:16px 32px;background:white;color:var(--primary);border-radius:99px;text-decoration:none;font-weight:700;font-size:16px;display:inline-flex;align-items:center;gap:10px;transition:0.3s;box-shadow:0 10px 20px rgba(0,0,0,0.1);}
        .hero-btn:hover{transform:translateY(-3px);box-shadow:0 15px 30px rgba(0,0,0,0.2);}
        .hero-image{font-size:120px;line-height:1; animation:float 4s ease-in-out infinite;}

        /* SECTION */
        .section{padding:0 40px 50px;max-width:1400px;margin:0 auto;}
        .section-title{font-size:32px;font-weight:800;color:var(--primary);margin-bottom:30px;}

        /* CATEGORY CARDS */
        .categories{display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:24px;}
        .category-card{background:white;border-radius:24px;text-align:center;box-shadow:0 10px 30px rgba(0,0,0,0.03);transition:all 0.4s;text-decoration:none;color:var(--text-main);border:1px solid transparent;overflow:hidden;}
        .category-card:hover{transform:translateY(-8px);border-color:var(--primary-light);box-shadow:0 20px 40px rgba(16,185,129,0.1);}
        .category-img{width:100%;height:140px;object-fit:cover;transition:0.5s;}
        .category-card:hover .category-img{transform:scale(1.1);}
        .category-info{padding:20px;}
        .category-card h3{font-size:16px;font-weight:700;}

        /* DASHBOARD CARDS */
        .dashboard-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));gap:24px;}
        .dashboard-card{background:white;border-radius:24px;padding:36px;text-align:center;text-decoration:none;color:var(--text-main);box-shadow:0 10px 30px rgba(0,0,0,0.03);transition:all 0.4s;border:1px solid transparent;}
        .dashboard-card:hover{transform:translateY(-8px);border-color:var(--primary-light);box-shadow:0 20px 40px rgba(16,185,129,0.1);}
        .dashboard-icon{width:70px;height:70px;background:#d1fae5;color:var(--primary-light);border-radius:20px;display:flex;align-items:center;justify-content:center;font-size:30px;margin:0 auto 20px;}
        .dashboard-card h2{color:var(--primary);margin-bottom:10px;font-size:22px;}
        .dashboard-card p{color:#64748b;font-size:15px;line-height:1.6;}

        /* OFFER BANNER */
        .offer{margin:0 40px 50px;background:linear-gradient(135deg,#f59e0b,#d97706);border-radius:32px;padding:50px;color:white;text-align:center;box-shadow:0 20px 40px rgba(217,119,6,0.2);}
        .offer h1{font-size:42px;margin-bottom:12px;font-weight:800;}
        .offer p{font-size:18px;opacity:0.95;}

        /* FOOTER */
        .footer{background:var(--primary);color:white;padding:40px;text-align:center;}
        .footer h2{margin-bottom:10px;font-weight:800;}

        @keyframes float { 0%{transform:translateY(0);} 50%{transform:translateY(-20px);} 100%{transform:translateY(0);} }

        @media(max-width:900px){
            .hero{flex-direction:column;text-align:center;gap:30px;padding:40px 24px;}
            .hero-text h1{font-size:36px;}
            .hero-image{display:none;}
            .navbar{flex-direction:column;gap:16px;}
        }
    </style>
</head>
<body>

<!-- NAVBAR -->
<div class="navbar">
    <a class="logo" href="customerDashboard.jsp"><i class="fa-solid fa-leaf"></i> CeylonFresh</a>
    <div class="nav-links">
        <a href="products.jsp"><i class="fa-solid fa-store"></i> Products</a>
        <a href="cart.jsp?userId=<%= userId %>"><i class="fa-solid fa-cart-shopping"></i> Cart</a>
        <a href="OrderHistoryServlet"><i class="fa-solid fa-box"></i> Orders</a>
        <a href="notifications.jsp">
            <i class="fa-solid fa-bell" style="position: relative;">
                <% if (hasUnreadNotifications) { %>
                    <span style="position: absolute; top: -3px; right: -3px; display: block; width: 8px; height: 8px; background: #ef4444; border-radius: 50%; border: 1px solid white;"></span>
                <% } %>
            </i> Notifications
        </a>
        <a href="reviews.jsp"><i class="fa-solid fa-star"></i> Reviews</a>
        <a href="LogoutServlet" class="logout"><i class="fa-solid fa-arrow-right-from-bracket"></i> Logout</a>
        <a href="profile.jsp" class="avatar-link" title="My Profile" style="text-decoration: none;">
            <div class="avatar" style="cursor: pointer; transition: transform 0.2s ease;"><%= username.substring(0,1).toUpperCase() %></div>
        </a>
    </div>
</div>

<!-- HERO -->
<div class="hero">
    <div class="hero-text">
        <h1>Ayubowan, <%= username %> 👋<br>Shop the best of Sri Lanka.</h1>
        <p>Browse fresh local produce, high-quality Ceylon tea, and daily essentials delivered fast anywhere in Colombo.</p>
        <a href="products.jsp" class="hero-btn">Shop Now <i class="fa-solid fa-arrow-right"></i></a>
    </div>
    <div class="hero-image">🍍</div>
</div>

<!-- CATEGORIES -->
<div class="section">
    <h1 class="section-title">Shop By Category</h1>
    <div class="categories">
        <a href="products.jsp?category=Rice%20%26%20Grains" class="category-card">
            <img src="https://images.unsplash.com/photo-1586201375761-83865001e31c?q=80&w=800" class="category-img">
            <div class="category-info"><h3>Rice & Grains</h3></div>
        </a>
        <a href="products.jsp?category=Produce" class="category-card">
            <img src="https://images.unsplash.com/photo-1610348725531-843dff563e2c?auto=format&fit=crop&w=800&q=80" class="category-img">
            <div class="category-info"><h3>Fresh Produce</h3></div>
        </a>
        <a href="products.jsp?category=Dairy" class="category-card">
            <img src="https://smallscalefarms.ca/cdn/shop/collections/1_240x240_f79d8fce-e554-4dd0-bb20-3a1f5e861941_1024x1024.png?v=1773447782" class="category-img">
            <div class="category-info"><h3>Dairy & Eggs</h3></div>
        </a>
        <a href="products.jsp?category=Beverages" class="category-card">
            <img src="https://images.unsplash.com/photo-1625772299848-391b6a87d7b3?auto=format&fit=crop&w=800&q=80" class="category-img">
            <div class="category-info"><h3>Tea & Beverages</h3></div>
        </a>
        <a href="products.jsp?category=Snacks" class="category-card">
            <img src="https://www.britishcornershop.co.uk/assets/img/collections/one-col/best-of-british-one-col.jpg" class="category-img">
            <div class="category-info"><h3>Snacks & Sweets</h3></div>
        </a>
        <a href="products.jsp?category=Pantry" class="category-card">
            <img src="https://www.allrecipes.com/thmb/q75xkm9Q_Du0U4t9QEFFNL-Umsg=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/pantry-items-2000-3e4035faae884c508a1455ce50391bcb.jpg" class="category-img">
            <div class="category-info"><h3>Pantry Essentials</h3></div>
        </a>
        <a href="products.jsp" class="category-card">
            <img src="https://images.unsplash.com/photo-1542838132-92c53300491e?q=80&w=800" class="category-img">
            <div class="category-info"><h3>All Items</h3></div>
        </a>
    </div>
</div>

<!-- QUICK DASHBOARD -->
<div class="section">
    <h1 class="section-title">Quick Access</h1>
    <div class="dashboard-grid">

        <a href="products.jsp" class="dashboard-card">
            <div class="dashboard-icon"><i class="fa-solid fa-bag-shopping"></i></div>
            <h2>Products</h2>
            <p>Browse our entire catalog of premium Sri Lankan groceries.</p>
        </a>

        <a href="cart.jsp?userId=<%= userId %>" class="dashboard-card">
            <div class="dashboard-icon"><i class="fa-solid fa-cart-arrow-down"></i></div>
            <h2>My Cart</h2>
            <p>Review and checkout your selected items securely.</p>
        </a>

        <a href="OrderHistoryServlet" class="dashboard-card">
            <div class="dashboard-icon"><i class="fa-solid fa-truck-fast"></i></div>
            <h2>Orders</h2>
            <p>Track your deliveries in real-time to your doorstep.</p>
        </a>

        <a href="paymentHistory.jsp" class="dashboard-card">
            <div class="dashboard-icon"><i class="fa-regular fa-credit-card"></i></div>
            <h2>Payments</h2>
            <p>View your past transactions and Cash on Delivery records.</p>
        </a>

        <a href="notifications.jsp" class="dashboard-card">
            <div class="dashboard-icon"><i class="fa-regular fa-bell"></i></div>
            <h2>Alerts</h2>
            <p>Check updates on your order status and exclusive offers.</p>
        </a>

        <a href="reviews.jsp" class="dashboard-card">
            <div class="dashboard-icon"><i class="fa-regular fa-star-half-stroke"></i></div>
            <h2>Reviews</h2>
            <p>Share your experience about our local products.</p>
        </a>

    </div>
</div>

<!-- OFFER -->
<div class="offer">
    <h1>🎉 Avurudu Special Offers</h1>
    <p>Enjoy up to 20% OFF on traditional sweets, spices, and Samba rice!</p>
</div>

<!-- FOOTER -->
<div class="footer">
    <h2>CeylonFresh</h2>
    <p>Premium Sri Lankan groceries, delivered fresh to your door.</p>
</div>

</body>
</html>
