<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.io.*, java.util.*" %>
<%
    String username = (String) session.getAttribute("username");
    String userId   = (String) session.getAttribute("userId");
    String email    = (String) session.getAttribute("email");
    if (username == null) { response.sendRedirect("login.jsp"); return; }

    String dataDir = application.getRealPath("/") + "data/";

    // Load products
    Map<String, String[]> productMap = new LinkedHashMap<>();
    File pFile = new File(dataDir + "products.txt");
    if (pFile.exists()) {
        BufferedReader br = new BufferedReader(new FileReader(pFile));
        String line;
        while ((line = br.readLine()) != null) {
            line = line.trim(); if (line.isEmpty()) continue;
            String[] p = line.split(",", 6);
            if (p.length >= 4) productMap.put(p[0].trim(), p);
        }
        br.close();
    }

    // Load user's cart
    List<String[]> cartItems = new ArrayList<>();
    File cFile = new File(dataDir + "cart.txt");
    if (cFile.exists()) {
        BufferedReader br = new BufferedReader(new FileReader(cFile));
        String line;
        while ((line = br.readLine()) != null) {
            line = line.trim(); if (line.isEmpty()) continue;
            String[] c = line.split(",");
            if (c.length >= 4 && c[1].trim().equals(userId)) cartItems.add(c);
        }
        br.close();
    }

    if (cartItems.isEmpty()) { response.sendRedirect("cart.jsp"); return; }

    // Totals
    double subtotal = 0;
    for (String[] c : cartItems) {
        String[] prod = productMap.get(c[2].trim());
        int qty = 1; try { qty = Integer.parseInt(c[3].trim()); } catch(Exception e){}
        double price = 0; try { if(prod!=null) price = Double.parseDouble(prod[3].trim()); } catch(Exception e){}
        subtotal += price * qty;
    }
    double delivery = 250;
    double discount = subtotal > 1000 ? 100 : 0;
    double total    = subtotal + delivery - discount;
%>
<!DOCTYPE html>
<html>
<head>
    <title>Checkout - CeylonFresh</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        *{margin:0;padding:0;box-sizing:border-box;font-family:'Segoe UI',sans-serif;}
        body{background:#f5fff7;}
        .navbar{background:white;padding:16px 56px;display:flex;justify-content:space-between;align-items:center;box-shadow:0 4px 16px rgba(0,0,0,0.08);}
        .logo{font-size:26px;font-weight:bold;color:#16a34a;text-decoration:none;}
        .nav-links{display:flex;gap:20px;}
        .nav-links a{text-decoration:none;color:#374151;font-weight:600;font-size:15px;}
        .nav-links a:hover{color:#16a34a;}

        .page-header{background:linear-gradient(135deg,#16a34a,#22c55e);margin:28px 56px;border-radius:28px;padding:36px 50px;color:white;}
        .page-header h1{font-size:36px;margin-bottom:6px;}
        .page-header p{font-size:15px;opacity:0.9;}

        .steps{display:flex;align-items:center;gap:8px;padding:0 56px;margin-bottom:28px;}
        .step{display:flex;align-items:center;gap:8px;font-size:14px;font-weight:600;}
        .step-num{width:28px;height:28px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:13px;font-weight:700;}
        .step.done .step-num{background:#16a34a;color:white;}
        .step.active .step-num{background:#16a34a;color:white;}
        .step.pending .step-num{background:#e5e7eb;color:#9ca3af;}
        .step.done span,.step.active span{color:#14532d;}
        .step.pending span{color:#9ca3af;}
        .step-line{flex:1;height:2px;background:#d1fae5;max-width:60px;}

        .layout{display:grid;grid-template-columns:1fr 360px;gap:28px;padding:0 56px 60px;}

        /* FORM */
        .form-card{background:white;border-radius:24px;box-shadow:0 6px 20px rgba(0,0,0,0.07);padding:32px;}
        .form-card h2{font-size:20px;color:#14532d;font-weight:700;margin-bottom:24px;padding-bottom:14px;border-bottom:2px solid #f0fdf4;}
        .input-group{margin-bottom:18px;}
        .input-group label{display:block;margin-bottom:7px;color:#374151;font-weight:600;font-size:14px;}
        .input-group input,.input-group textarea,.input-group select{width:100%;padding:13px 16px;border:2px solid #e5e7eb;border-radius:12px;font-size:15px;outline:none;transition:0.2s;}
        .input-group input:focus,.input-group textarea:focus,.input-group select:focus{border-color:#16a34a;box-shadow:0 0 0 3px rgba(22,163,74,0.1);}
        .input-group textarea{resize:none;height:90px;}
        .two-col{display:grid;grid-template-columns:1fr 1fr;gap:16px;}

        .payment-options{display:grid;grid-template-columns:1fr 1fr 1fr;gap:10px;margin-top:8px;}
        .pay-option{border:2px solid #e5e7eb;border-radius:14px;padding:14px 10px;cursor:pointer;transition:0.2s;display:flex;align-items:center;gap:8px;}
        .pay-option:hover{border-color:#16a34a;background:#f0fdf4;}
        .pay-option input[type=radio]{accent-color:#16a34a;}
        .pay-option-icon{font-size:20px;}
        .pay-option-label{font-weight:600;color:#374151;font-size:13px;}

        .card-details-box{background:#f8fafc;padding:24px;border-radius:18px;border:1px solid #e2e8f0;margin-top:16px;}
        .error-msg{color:#ef4444;font-size:12px;margin-top:4px;display:none;font-weight:600;}

        .place-btn{width:100%;padding:16px;background:#16a34a;color:white;border:none;border-radius:16px;font-size:17px;font-weight:bold;cursor:pointer;transition:0.25s;margin-top:24px;}
        .place-btn:hover{background:#15803d;transform:translateY(-2px);box-shadow:0 8px 20px rgba(22,163,74,0.3);}

        /* SUMMARY */
        .summary-card{background:white;border-radius:24px;box-shadow:0 6px 20px rgba(0,0,0,0.07);padding:28px;height:fit-content;position:sticky;top:88px;}
        .summary-card h2{font-size:20px;color:#14532d;font-weight:700;margin-bottom:20px;padding-bottom:14px;border-bottom:2px solid #f0fdf4;}
        .summary-items{margin-bottom:18px;}
        .summary-item{display:flex;justify-content:space-between;align-items:center;padding:10px 0;border-bottom:1px solid #f1f5f9;font-size:14px;}
        .summary-item-name{color:#374151;font-weight:500;}
        .summary-item-price{color:#14532d;font-weight:700;}
        .summary-row{display:flex;justify-content:space-between;margin-bottom:12px;font-size:14px;color:#374151;}
        .summary-row span:last-child{font-weight:600;}
        .summary-divider{border:none;border-top:1px dashed #d1fae5;margin:14px 0;}
        .summary-total{display:flex;justify-content:space-between;font-size:22px;font-weight:800;color:#14532d;margin-top:14px;}
        .back-link{display:block;text-align:center;margin-top:14px;color:#16a34a;text-decoration:none;font-weight:600;font-size:14px;}
        .back-link:hover{text-decoration:underline;}

        @media(max-width:1100px){
            .payment-options{grid-template-columns:1fr 1fr;}
        }
        @media(max-width:1000px){
            .layout{grid-template-columns:1fr;padding:0 20px 40px;}
            .page-header,.steps{margin:16px;padding:24px 20px;}
            .navbar{padding:16px 20px;flex-direction:column;gap:12px;}
            .two-col{grid-template-columns:1fr;}
            .summary-card{position:static;}
        }
    </style>
</head>
<body>

<div class="navbar">
    <a class="logo" href="customerDashboard.jsp">🛒 CeylonFresh</a>
    <div class="nav-links">
        <a href="products.jsp">Products</a>
        <a href="cart.jsp">Cart</a>
        <a href="LogoutServlet">Logout</a>
    </div>
</div>

<div class="page-header">
    <h1>Checkout 📋</h1>
    <p>Enter your delivery details and confirm your order</p>
</div>

<div class="steps">
    <div class="step done"><div class="step-num">✓</div><span>Cart</span></div>
    <div class="step-line"></div>
    <div class="step active"><div class="step-num">2</div><span>Checkout</span></div>
    <div class="step-line"></div>
    <div class="step pending"><div class="step-num">3</div><span>Confirm</span></div>
</div>

<div class="layout">

    <div class="form-card">
        <h2>📦 Delivery Information</h2>
        <form action="OrderServlet" method="post" id="checkoutForm" onsubmit="return validateCheckout()">
            <input type="hidden" name="userId" value="<%= userId %>">
            <input type="hidden" name="total" value="<%= String.format("%.2f", total) %>">

            <div class="two-col">
                <div class="input-group">
                    <label>Full Name</label>
                    <input type="text" name="name" value="<%= username %>" required>
                </div>
                <div class="input-group">
                    <label>Phone Number</label>
                    <input type="text" name="phone" placeholder="e.g. 0771234567" required pattern="[0-9]{10}">
                </div>
            </div>
            <div class="input-group">
                <label>Email Address</label>
                <input type="email" name="email" value="<%= email != null ? email : "" %>" required>
            </div>
            <div class="input-group">
                <label>Delivery Address</label>
                <textarea name="address" placeholder="No. 12, Main Street, Colombo 03" required></textarea>
            </div>

            <h2 style="margin-top:24px;">💳 Payment Method</h2>
            <div class="payment-options">
                <label class="pay-option">
                    <input type="radio" name="paymentMethod" value="Cash on Delivery" checked onclick="toggleCard(false)">
                    <span class="pay-option-icon">💵</span>
                    <span class="pay-option-label">Cash on Delivery</span>
                </label>
                <label class="pay-option">
                    <input type="radio" name="paymentMethod" value="Credit Card" onclick="toggleCard(true)">
                    <span class="pay-option-icon">💳</span>
                    <span class="pay-option-label">Credit Card</span>
                </label>
                <label class="pay-option">
                    <input type="radio" name="paymentMethod" value="Debit Card" onclick="toggleCard(true)">
                    <span class="pay-option-icon">🏧</span>
                    <span class="pay-option-label">Debit Card</span>
                </label>
            </div>

            <div class="card-details-box" id="card-section" style="display:none;">
                <div class="input-group">
                    <label>Card Number</label>
                    <input type="text" name="cardNumber" id="cardNumber" placeholder="1234 5678 9012 3456" maxlength="19">
                    <div class="error-msg" id="err-card">Please enter a valid 16-digit card number.</div>
                </div>
                <div class="two-col">
                    <div class="input-group">
                        <label>Expiry Date</label>
                        <input type="text" name="expiry" id="expiry" placeholder="MM/YY" maxlength="5">
                        <div class="error-msg" id="err-expiry">Enter valid MM/YY.</div>
                    </div>
                    <div class="input-group">
                        <label>CVV</label>
                        <input type="password" name="cvv" id="cvv" placeholder="123" maxlength="3">
                        <div class="error-msg" id="err-cvv">Enter 3-digit CVV.</div>
                    </div>
                </div>
            </div>

            <button class="place-btn" type="submit">Place Order — Rs. <%= String.format("%.2f", total) %> →</button>
        </form>
    </div>

    <div class="summary-card">
        <h2>Order Summary</h2>
        <div class="summary-items">
            <%
                Map<String,String> emojiMap = new HashMap<>();
                emojiMap.put("Fruits","🍎"); emojiMap.put("Dairy","🥛");
                emojiMap.put("Grains","🌾"); emojiMap.put("Vegetables","🥦");
                emojiMap.put("Bakery","🍞");

                for (String[] c : cartItems) {
                    String[] prod = productMap.get(c[2].trim());
                    String pname  = prod != null ? prod[1].trim() : c[2].trim();
                    String pcat   = prod != null && prod.length >= 3 ? prod[2].trim() : "";
                    int qty = 1; try { qty = Integer.parseInt(c[3].trim()); } catch(Exception e){}
                    double price = 0; try { if(prod!=null) price = Double.parseDouble(prod[3].trim()); } catch(Exception e){}
                    String emoji = emojiMap.getOrDefault(pcat, "🛒");
            %>
            <div class="summary-item">
                <span class="summary-item-name"><%= emoji %> <%= pname %> × <%= qty %></span>
                <span class="summary-item-price">Rs. <%= String.format("%.2f", price * qty) %></span>
            </div>
            <% } %>
        </div>

        <div class="summary-row"><span>Subtotal</span><span>Rs. <%= String.format("%.2f", subtotal) %></span></div>
        <div class="summary-row"><span>Delivery</span><span>Rs. <%= String.format("%.2f", delivery) %></span></div>
        <% if (discount > 0) { %>
        <div class="summary-row"><span>Discount</span><span style="color:#16a34a;">- Rs. <%= String.format("%.2f", discount) %></span></div>
        <% } %>
        <hr class="summary-divider">
        <div class="summary-total"><span>Total</span><span>Rs. <%= String.format("%.2f", total) %></span></div>

        <a href="cart.jsp" class="back-link">← Back to Cart</a>
    </div>

</div>

<script>
    function toggleCard(show) {
        document.getElementById('card-section').style.display = show ? 'block' : 'none';
    }

    // Input formatting for Card Number
    document.getElementById('cardNumber').addEventListener('input', function (e) {
        let value = e.target.value.replace(/\D/g, '');
        let formatted = value.match(/.{1,4}/g)?.join(' ') || '';
        e.target.value = formatted;
    });

    // Input formatting for Expiry
    document.getElementById('expiry').addEventListener('input', function (e) {
        let value = e.target.value.replace(/\D/g, '');
        if (value.length > 2) {
            e.target.value = value.substring(0, 2) + '/' + value.substring(2, 4);
        } else {
            e.target.value = value;
        }
    });

    function validateCheckout() {
        const method = document.querySelector('input[name="paymentMethod"]:checked').value;
        if (method === 'Cash on Delivery') return true;

        let isValid = true;
        const cardNum = document.getElementById('cardNumber').value.replace(/\s/g, '');
        const expiry = document.getElementById('expiry').value;
        const cvv = document.getElementById('cvv').value;

        // Reset errors
        document.querySelectorAll('.error-msg').forEach(el => el.style.display = 'none');

        if (!/^\d{16}$/.test(cardNum)) {
            document.getElementById('err-card').style.display = 'block';
            isValid = false;
        }

        if (!/^(0[1-9]|1[0-2])\/\d{2}$/.test(expiry)) {
            document.getElementById('err-expiry').style.display = 'block';
            isValid = false;
        }

        if (!/^\d{3}$/.test(cvv)) {
            document.getElementById('err-cvv').style.display = 'block';
            isValid = false;
        }

        return isValid;
    }
</script>

</body>
</html>
