<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.io.*, java.util.*" %>
<%
    // Session guard
    String username = (String) session.getAttribute("username");
    String userId   = (String) session.getAttribute("userId");
    String role     = (String) session.getAttribute("role");
    if (username == null) { response.sendRedirect("login.jsp"); return; }

    String dataDir = application.getRealPath("/") + "data/";

    // Load all products into a map: productId -> [name, price, stock, category]
    Map<String, String[]> productMap = new LinkedHashMap<>();
    File pFile = new File(dataDir + "products.txt");
    if (pFile.exists()) {
        BufferedReader br = new BufferedReader(new FileReader(pFile));
        String line;
        while ((line = br.readLine()) != null) {
            line = line.trim();
            if (line.isEmpty()) continue;
            String[] p = line.split(",", 6);
            if (p.length >= 4) productMap.put(p[0].trim(), p);
        }
        br.close();
    }

    // Load cart items for this user: [cartId, userId, productId, qty]
    List<String[]> cartItems = new ArrayList<>();
    File cFile = new File(dataDir + "cart.txt");
    if (cFile.exists()) {
        BufferedReader br = new BufferedReader(new FileReader(cFile));
        String line;
        while ((line = br.readLine()) != null) {
            line = line.trim();
            if (line.isEmpty()) continue;
            String[] c = line.split(",");
            if (c.length >= 4 && c[1].trim().equals(userId)) cartItems.add(c);
        }
        br.close();
    }

    // Compute totals
    double subtotal = 0;
    for (String[] c : cartItems) {
        String pid = c[2].trim();
        int qty = 1;
        try { qty = Integer.parseInt(c[3].trim()); } catch (Exception e) {}
        String[] prod = productMap.get(pid);
        if (prod != null) {
            double price = 0;
            try { price = Double.parseDouble(prod[3].trim()); } catch (Exception e) {}
            subtotal += price * qty;
        }
    }
    double delivery = cartItems.isEmpty() ? 0 : 250;
    double discount = subtotal > 1000 ? 100 : 0;
    double total    = subtotal + delivery - discount;
%>
<!DOCTYPE html>
<html>
<head>
    <title>My Cart - CeylonFresh</title>
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
        .avatar{width:40px;height:40px;border-radius:50%;background:#16a34a;color:white;display:flex;justify-content:center;align-items:center;font-weight:bold;}

        /* PAGE */
        .page-header{background:linear-gradient(135deg,#16a34a,#22c55e);margin:28px 56px;border-radius:28px;padding:38px 50px;color:white;display:flex;justify-content:space-between;align-items:center;}
        .page-header h1{font-size:38px;margin-bottom:6px;}
        .page-header p{font-size:16px;opacity:0.9;}
        .page-header-icon{font-size:100px;line-height:1;}

        .layout{display:grid;grid-template-columns:1fr 360px;gap:28px;padding:0 56px 60px;}

        /* CART TABLE */
        .cart-card{background:white;border-radius:24px;box-shadow:0 6px 20px rgba(0,0,0,0.07);overflow:hidden;}
        .cart-card-header{padding:22px 28px;border-bottom:1px solid #f0fdf4;display:flex;justify-content:space-between;align-items:center;}
        .cart-card-header h2{font-size:20px;color:#14532d;font-weight:700;}
        .item-count{background:#dcfce7;color:#16a34a;padding:4px 14px;border-radius:50px;font-size:13px;font-weight:700;}

        table{width:100%;border-collapse:collapse;}
        thead th{background:#f8fffe;padding:14px 20px;text-align:left;font-size:13px;color:#6b7280;font-weight:600;text-transform:uppercase;letter-spacing:0.5px;}
        tbody tr{border-top:1px solid #f1f5f9;transition:0.15s;}
        tbody tr:hover{background:#f8fffe;}
        td{padding:16px 20px;vertical-align:middle;}

        .product-cell{display:flex;align-items:center;gap:14px;}
        .product-emoji{width:52px;height:52px;background:linear-gradient(135deg,#dcfce7,#bbf7d0);border-radius:14px;display:flex;align-items:center;justify-content:center;font-size:26px;flex-shrink:0;}
        .product-name{font-weight:700;color:#14532d;font-size:15px;}
        .product-cat{font-size:12px;color:#6b7280;margin-top:2px;}

        .price-cell{font-weight:700;color:#16a34a;font-size:16px;}
        .subtotal-cell{font-weight:700;color:#14532d;font-size:16px;}

        /* QTY form */
        .qty-form{display:flex;align-items:center;gap:8px;}
        .qty-input{width:60px;padding:8px 10px;border:2px solid #d1fae5;border-radius:10px;font-size:15px;text-align:center;outline:none;}
        .qty-input:focus{border-color:#16a34a;}
        .update-btn{padding:8px 14px;background:#e0f2fe;color:#0369a1;border:none;border-radius:10px;font-size:13px;font-weight:600;cursor:pointer;transition:0.2s;}
        .update-btn:hover{background:#0369a1;color:white;}
        .remove-btn{padding:8px 14px;background:#fee2e2;color:#dc2626;border:none;border-radius:10px;font-size:13px;font-weight:600;cursor:pointer;transition:0.2s;}
        .remove-btn:hover{background:#dc2626;color:white;}

        /* EMPTY */
        .empty{padding:80px 40px;text-align:center;}
        .empty-icon{font-size:80px;margin-bottom:18px;}
        .empty h2{font-size:24px;color:#374151;margin-bottom:10px;}
        .empty p{color:#6b7280;margin-bottom:24px;}
        .shop-btn{display:inline-block;padding:14px 28px;background:#16a34a;color:white;border-radius:14px;text-decoration:none;font-weight:bold;}

        /* ORDER SUMMARY */
        .summary-card{background:white;border-radius:24px;box-shadow:0 6px 20px rgba(0,0,0,0.07);padding:28px;height:fit-content;position:sticky;top:88px;}
        .summary-card h2{font-size:20px;color:#14532d;font-weight:700;margin-bottom:24px;padding-bottom:16px;border-bottom:2px solid #f0fdf4;}
        .summary-row{display:flex;justify-content:space-between;align-items:center;margin-bottom:16px;font-size:15px;color:#374151;}
        .summary-row span:last-child{font-weight:600;}
        .summary-divider{border:none;border-top:1px dashed #d1fae5;margin:18px 0;}
        .summary-total{display:flex;justify-content:space-between;align-items:center;font-size:22px;font-weight:800;color:#14532d;margin-bottom:24px;}
        .badge-free{background:#dcfce7;color:#16a34a;font-size:11px;padding:2px 8px;border-radius:50px;font-weight:700;}
        .badge-save{background:#fef9c3;color:#ca8a04;font-size:11px;padding:2px 8px;border-radius:50px;font-weight:700;}

        .checkout-btn{width:100%;padding:16px;background:#16a34a;color:white;border:none;border-radius:16px;font-size:17px;font-weight:bold;cursor:pointer;transition:0.25s;text-align:center;text-decoration:none;display:block;}
        .checkout-btn:hover{background:#15803d;transform:translateY(-2px);box-shadow:0 8px 20px rgba(22,163,74,0.3);}
        .checkout-btn.disabled{background:#9ca3af;cursor:not-allowed;pointer-events:none;}
        .continue-link{display:block;text-align:center;margin-top:14px;color:#16a34a;text-decoration:none;font-weight:600;font-size:14px;}
        .continue-link:hover{text-decoration:underline;}

        .discount-note{background:#fef9c3;border:1px solid #fde68a;border-radius:12px;padding:12px 14px;font-size:13px;color:#92400e;margin-bottom:18px;text-align:center;}

        @media(max-width:1000px){
            .layout{grid-template-columns:1fr;padding:0 20px 40px;}
            .page-header{margin:16px;padding:28px 24px;flex-direction:column;gap:14px;text-align:center;}
            .navbar{padding:16px 20px;flex-direction:column;gap:12px;}
            .summary-card{position:static;}
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
    <div>
        <h1>My Cart 🛒</h1>
        <p>Review your items and proceed to checkout</p>
    </div>
    <div class="page-header-icon">🧺</div>
</div>

<!-- LAYOUT -->
<div class="layout">

    <!-- CART ITEMS -->
    <div class="cart-card">
        <div class="cart-card-header">
            <h2>Cart Items</h2>
            <span class="item-count"><%= cartItems.size() %> item<%= cartItems.size() != 1 ? "s" : "" %></span>
        </div>

        <% if (cartItems.isEmpty()) { %>
        <div class="empty">
            <div class="empty-icon">🛒</div>
            <h2>Your cart is empty</h2>
            <p>Add some fresh groceries to get started!</p>
            <a href="products.jsp" class="shop-btn">Browse Products</a>
        </div>
        <% } else { %>
        <table>
            <thead>
            <tr>
                <th>Product</th>
                <th>Price</th>
                <th>Quantity</th>
                <th>Subtotal</th>
                <th>Action</th>
            </tr>
            </thead>
            <tbody>
            <%
                Map<String,String> emojiMap = new HashMap<>();
                emojiMap.put("Fruits","🍎"); emojiMap.put("Dairy","🥛");
                emojiMap.put("Grains","🌾"); emojiMap.put("Vegetables","🥦");
                emojiMap.put("Bakery","🍞"); emojiMap.put("Meat","🥩");

                for (String[] c : cartItems) {
                    String cartId = c[0].trim();
                    String pid    = c[2].trim();
                    int qty = 1;
                    try { qty = Integer.parseInt(c[3].trim()); } catch (Exception e) {}

                    String[] prod  = productMap.get(pid);
                    String pname   = prod != null ? prod[1].trim() : pid;
                    String pcat    = prod != null && prod.length >= 3 ? prod[2].trim() : "";
                    double price   = 0;
                    try { if (prod != null) price = Double.parseDouble(prod[3].trim()); } catch (Exception e) {}
                    double rowTotal = price * qty;
                    String emoji   = emojiMap.getOrDefault(pcat, "🛒");
            %>
            <tr>
                <td>
                    <div class="product-cell">
                        <div class="product-emoji"><%= emoji %></div>
                        <div>
                            <div class="product-name"><%= pname %></div>
                            <div class="product-cat"><%= pcat %></div>
                        </div>
                    </div>
                </td>
                <td class="price-cell">Rs. <%= String.format("%.2f", price) %></td>
                <td>
                    <form class="qty-form" action="CartServlet" method="post">
                        <input type="hidden" name="action" value="update">
                        <input type="hidden" name="cartId" value="<%= cartId %>">
                        <input type="hidden" name="userId" value="<%= userId %>">
                        <input class="qty-input" type="number" name="quantity" value="<%= qty %>" min="1" max="99">
                        <button class="update-btn" type="submit">Update</button>
                    </form>
                </td>
                <td class="subtotal-cell">Rs. <%= String.format("%.2f", rowTotal) %></td>
                <td>
                    <form action="CartServlet" method="post">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="cartId" value="<%= cartId %>">
                        <input type="hidden" name="userId" value="<%= userId %>">
                        <button class="remove-btn" type="submit">Remove</button>
                    </form>
                </td>
            </tr>
            <% } %>
            </tbody>
        </table>
        <% } %>
    </div>

    <!-- ORDER SUMMARY -->
    <div class="summary-card">
        <h2>Order Summary</h2>

        <% if (discount > 0) { %>
        <div class="discount-note">🎉 You saved Rs. <%= String.format("%.2f", discount) %> on this order!</div>
        <% } else if (!cartItems.isEmpty()) { %>
        <div class="discount-note">💡 Spend Rs. <%= String.format("%.2f", 1000 - subtotal) %> more to get Rs. 100 off!</div>
        <% } %>

        <div class="summary-row">
            <span>Subtotal (<%= cartItems.size() %> items)</span>
            <span>Rs. <%= String.format("%.2f", subtotal) %></span>
        </div>
        <div class="summary-row">
            <span>Delivery Fee</span>
            <% if (cartItems.isEmpty()) { %>
            <span>—</span>
            <% } else { %>
            <span>Rs. <%= String.format("%.2f", delivery) %></span>
            <% } %>
        </div>
        <% if (discount > 0) { %>
        <div class="summary-row">
            <span>Discount <span class="badge-save">SAVE</span></span>
            <span style="color:#16a34a;">- Rs. <%= String.format("%.2f", discount) %></span>
        </div>
        <% } %>

        <hr class="summary-divider">

        <div class="summary-total">
            <span>Total</span>
            <span>Rs. <%= String.format("%.2f", total) %></span>
        </div>

        <% if (!cartItems.isEmpty()) { %>
        <a href="checkout.jsp" class="checkout-btn">Proceed to Checkout →</a>
        <% } else { %>
        <span class="checkout-btn disabled">Proceed to Checkout →</span>
        <% } %>

        <a href="products.jsp" class="continue-link">← Continue Shopping</a>
    </div>

</div>

</body>
</html>
