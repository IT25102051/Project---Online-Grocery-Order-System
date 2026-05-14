<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.io.*, java.util.*" %>
<%
    // Session guard
    String username = (String) session.getAttribute("username");
    String userId   = (String) session.getAttribute("userId");
    String role     = (String) session.getAttribute("role");

    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Read products from file
    List<String[]> products = new ArrayList<>();
    String filePath = application.getRealPath("/") + "data/products.txt";
    File file = new File(filePath);
    if (file.exists()) {
        BufferedReader br = new BufferedReader(new FileReader(file));
        String line;
        while ((line = br.readLine()) != null) {
            line = line.trim();
            if (!line.isEmpty()) {
                String[] parts = line.split(",", 7);
                if (parts.length >= 5) products.add(parts);
            }
        }
        br.close();
    }

    // Category filter
    String filterCat = request.getParameter("category");
    if (filterCat == null) filterCat = "All";

    // Search filter
    String search = request.getParameter("search");
    if (search == null) search = "";

    // Collect distinct categories
    Set<String> categories = new LinkedHashSet<>();
    categories.add("All");
    for (String[] p : products) {
        if (p.length >= 3) categories.add(p[2]);
    }
    int notificationCount = 0;
    File notificationFile = new File(application.getRealPath("/") + "data/notifications.txt");
    if (notificationFile.exists()) {
        try (BufferedReader br = new BufferedReader(new FileReader(notificationFile))) {
            while (br.readLine() != null) {
                notificationCount++;
            }
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>CeylonFresh - Products</title>
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
        body{background:var(--bg-color);min-height:100vh;color:var(--text-main);}

        /* NAVBAR */
        .navbar{background:rgba(255,255,255,0.9);backdrop-filter:blur(10px);padding:16px 40px;display:flex;justify-content:space-between;align-items:center;box-shadow:0 4px 20px rgba(0,0,0,0.05);position:sticky;top:0;z-index:100;}
        .logo{font-size:24px;font-weight:800;color:var(--primary);text-decoration:none;display:flex;align-items:center;gap:8px;}
        .logo i {color:var(--primary-light);}
        .nav-links{display:flex;align-items:center;gap:24px;}
        .nav-links a{text-decoration:none;color:#475569;font-weight:600;font-size:15px;transition:0.3s;}
        .nav-links a:hover{color:var(--primary-light);}
        .nav-links a.logout{color:#ef4444;}
        .avatar{width:42px;height:42px;border-radius:50%;background:linear-gradient(135deg,var(--primary-light),var(--primary));color:white;display:flex;justify-content:center;align-items:center;font-weight:700;font-size:18px;box-shadow:0 4px 10px rgba(16,185,129,0.3);}

        /* PAGE HEADER */
        .page-header{background:linear-gradient(135deg,var(--primary-light),var(--primary));margin:30px 40px;border-radius:32px;padding:50px 60px;color:white;display:flex;justify-content:space-between;align-items:center;box-shadow:0 20px 40px rgba(6,78,59,0.15);}
        .page-header h1{font-size:42px;font-weight:800;margin-bottom:10px;}
        .page-header p{font-size:18px;opacity:0.9;}
        .page-header-icon{font-size:100px;animation:float 4s ease-in-out infinite;}

        /* SEARCH + FILTER BAR */
        .filter-bar{margin:0 40px 30px;display:flex;gap:16px;align-items:center;flex-wrap:wrap;max-width:1400px;margin-left:auto;margin-right:auto;}
        .search-input{flex:1;min-width:260px;padding:16px 20px;border:1px solid #e2e8f0;border-radius:16px;font-size:16px;outline:none;background:white;box-shadow:0 4px 10px rgba(0,0,0,0.02);transition:0.3s;}
        .search-input:focus{border-color:var(--primary-light);box-shadow:0 0 0 4px rgba(16,185,129,0.1);}
        .cat-btn{padding:12px 24px;border:1px solid #e2e8f0;border-radius:99px;background:white;color:#64748b;font-size:15px;font-weight:600;cursor:pointer;transition:all 0.3s;}
        .cat-btn:hover,.cat-btn.active{background:var(--primary);color:white;border-color:var(--primary);box-shadow:0 10px 20px rgba(6,78,59,0.2);transform:translateY(-2px);}

        /* PRODUCT GRID */
        .grid-section{padding:0 40px 60px;max-width:1400px;margin:0 auto;}
        .product-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(280px,1fr));gap:24px;}

        /* PRODUCT CARD */
        .product-card{background:white;border-radius:24px;overflow:hidden;box-shadow:0 10px 30px rgba(0,0,0,0.03);transition:all 0.4s;display:flex;flex-direction:column;border:1px solid transparent;}
        .product-card:hover{transform:translateY(-8px);border-color:var(--primary-light);box-shadow:0 20px 40px rgba(16,185,129,0.1);}
        .product-img{height:220px;background:#f1f5f9;display:flex;justify-content:center;align-items:center;overflow:hidden;}
        .product-img img{width:100%;height:100%;object-fit:cover;transition:0.5s;}
        .product-card:hover .product-img img{transform:scale(1.05);}
        .product-icon{font-size:90px;}
        .product-body{padding:24px;flex:1;display:flex;flex-direction:column;}
        .product-category{font-size:12px;color:var(--primary-light);font-weight:700;text-transform:uppercase;letter-spacing:1px;margin-bottom:8px;}
        .product-name{font-size:20px;font-weight:800;color:var(--primary);margin-bottom:8px;line-height:1.3;}
        .product-desc{font-size:14px;color:#64748b;margin-bottom:18px;flex:1;line-height:1.5;}
        .product-footer{display:flex;justify-content:space-between;align-items:center;margin-bottom:18px;}
        .product-price{font-size:24px;font-weight:800;color:var(--primary-light);}
        .product-stock{font-size:13px;color:#64748b;font-weight:600;}
        .stock-low{color:#ef4444;background:#fee2e2;padding:4px 8px;border-radius:6px;}

        /* ADD TO CART FORM */
        .cart-row{display:flex;gap:12px;align-items:center;}
        .qty-input{width:70px;padding:12px;border:1px solid #e2e8f0;border-radius:14px;font-size:16px;outline:none;text-align:center;font-weight:600;}
        .qty-input:focus{border-color:var(--primary-light);}
        .cart-btn{flex:1;padding:14px;border:none;border-radius:14px;background:var(--primary);color:white;font-weight:700;font-size:15px;cursor:pointer;transition:all 0.3s;display:flex;align-items:center;justify-content:center;gap:8px;}
        .cart-btn:hover{background:var(--primary-light);transform:translateY(-2px);box-shadow:0 8px 20px rgba(16,185,129,0.3);}
        .cart-btn:disabled{background:#cbd5e1;cursor:not-allowed;box-shadow:none;transform:none;}

        /* EMPTY STATE */
        .empty{text-align:center;padding:100px 20px;color:#64748b;}
        .empty-icon{font-size:80px;margin-bottom:20px;opacity:0.5;}
        .empty h2{font-size:28px;color:var(--text-main);margin-bottom:10px;font-weight:800;}

        /* TOAST */
        .toast{position:fixed;bottom:30px;right:30px;background:var(--primary-light);color:white;padding:16px 24px;border-radius:16px;font-weight:700;display:none;z-index:999;box-shadow:0 10px 30px rgba(16,185,129,0.3);font-size:16px;}

        @keyframes float { 0%{transform:translateY(0);} 50%{transform:translateY(-15px);} 100%{transform:translateY(0);} }

        @media(max-width:900px){
            .navbar,.page-header,.filter-bar,.grid-section{padding-left:20px;padding-right:20px;margin-left:0;margin-right:0;}
            .page-header{flex-direction:column;text-align:center;gap:20px;padding:40px 24px;}
            .page-header h1{font-size:32px;}
            .page-header-icon{display:none;}
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
        <a href="notifications.jsp"><i class="fa-solid fa-bell"></i> Notifications<%= notificationCount > 0 ? " (" + notificationCount + ")" : "" %></a>
        <a href="reviews.jsp"><i class="fa-solid fa-star"></i> Reviews</a>
        <a href="LogoutServlet" class="logout"><i class="fa-solid fa-arrow-right-from-bracket"></i> Logout</a>
        <div class="avatar"><%= username.substring(0,1).toUpperCase() %></div>
    </div>
</div>

<!-- PAGE HEADER -->
<div class="page-header">
    <div>
        <h1>Fresh Products 🥬</h1>
        <p>Browse and add groceries to your cart easily</p>
    </div>
    <div class="page-header-icon">🛍️</div>
</div>

<!-- SEARCH + CATEGORY FILTER -->
<form class="filter-bar" method="get" action="products.jsp">
    <input class="search-input" type="text" name="search" placeholder="🔍 Search products..." value="<%= search %>">
    <%
        for (String cat : categories) {
            String active = cat.equals(filterCat) ? "active" : "";
    %>
        <button type="submit" name="category" value="<%= cat %>" class="cat-btn <%= active %>"><%= cat %></button>
    <%  } %>
</form>

<!-- PRODUCT GRID -->
<div class="grid-section">
<%
    // Emoji map for categories
    Map<String,String> emojiMap = new HashMap<>();
    emojiMap.put("Fruits",  "🍎");
    emojiMap.put("Dairy",   "🥛");
    emojiMap.put("Grains",  "🌾");
    emojiMap.put("Vegetables","🥦");
    emojiMap.put("Bakery",  "🍞");
    emojiMap.put("Meat",    "🥩");
    emojiMap.put("Seafood", "🐟");
    emojiMap.put("Snacks",  "🍪");

    // Filter list
    List<String[]> filtered = new ArrayList<>();
    for (String[] p : products) {
        boolean catOk  = filterCat.equals("All") || (p.length >= 3 && p[2].equalsIgnoreCase(filterCat));
        boolean srchOk = search.isEmpty()
                      || p[1].toLowerCase().contains(search.toLowerCase())
                      || (p.length >= 3 && p[2].toLowerCase().contains(search.toLowerCase()))
                      || (p.length >= 7 && p[6].toLowerCase().contains(search.toLowerCase()));
        if (catOk && srchOk) filtered.add(p);
    }

    if (filtered.isEmpty()) {
%>
    <div class="empty">
        <div class="empty-icon">🔍</div>
        <h2>No products found</h2>
        <p>Try a different search or category.</p>
    </div>
<%
    } else {
%>
    <div class="product-grid">
    <%
        for (String[] p : filtered) {
            String pid      = p[0];
            String pname    = p[1];
            String pcat     = p.length >= 3 ? p[2] : "";
            String pprice   = p.length >= 4 ? p[3] : "0";
            String pstock   = p.length >= 5 ? p[4] : "0";
            String pimage   = p.length >= 6 ? p[5] : "";
            String pdesc    = p.length >= 7 ? p[6] : "";
            String emoji    = emojiMap.getOrDefault(pcat, "🛒");
            int    stockInt = 0;
            try { stockInt = Integer.parseInt(pstock.trim()); } catch(Exception e){}
            boolean outOfStock = stockInt <= 0;
    %>
        <div class="product-card">
            <div class="product-img">
                <% if (!pimage.isEmpty()) { %>
                    <img src="<%= pimage %>" alt="<%= pname %>" />
                <% } else { %>
                    <div class="product-icon"><%= emoji %></div>
                <% } %>
            </div>
            <div class="product-body">
                <div class="product-category"><%= pcat %></div>
                <div class="product-name"><%= pname %></div>
                <div class="product-desc"><%= pdesc.isEmpty() ? "Fresh quality product" : pdesc %></div>
                <div class="product-footer">
                    <div class="product-price">Rs. <%= pprice %></div>
                    <div class="product-stock <%= outOfStock ? "stock-low" : "" %>">
                        <%= outOfStock ? "Out of stock" : "In stock: " + pstock %>
                    </div>
                </div>
                <form action="CartServlet" method="post">
                    <input type="hidden" name="action" value="add">
                    <input type="hidden" name="userId" value="<%= userId %>">
                    <input type="hidden" name="productId" value="<%= pid %>">
                    <input type="hidden" name="category" value="<%= filterCat %>">
                    <input type="hidden" name="search" value="<%= search %>">
                    <div class="cart-row">
                        <input class="qty-input" type="number" name="quantity" value="1" min="1" max="<%= stockInt > 0 ? stockInt : 1 %>" <%= outOfStock ? "disabled" : "" %>>
                        <button class="cart-btn" type="submit" <%= outOfStock ? "disabled" : "" %>>
                            <%= outOfStock ? "Unavailable" : "Add to Cart 🛒" %>
                        </button>
                    </div>
                </form>
            </div>
        </div>
    <%  } %>
    </div>
<%  } %>
</div>

<!-- TOAST notification -->
<div class="toast" id="toast">✅ Added to cart!</div>

<%
    String added = request.getParameter("added");
    if ("true".equals(added)) {
%>
<script>
    const toast = document.getElementById('toast');
    toast.style.display = 'block';
    setTimeout(() => toast.style.display = 'none', 2500);
</script>
<% } %>

</body>
</html>
