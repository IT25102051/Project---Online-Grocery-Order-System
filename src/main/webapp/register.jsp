<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Register - Online Grocery Order System</title>
    <style>
        *{margin:0;padding:0;box-sizing:border-box;font-family:'Segoe UI',sans-serif;}
        body{min-height:100vh;background:linear-gradient(135deg,#22c55e,#a3e635);display:flex;justify-content:center;align-items:center;}
        .container{width:1050px;min-height:620px;background:white;border-radius:30px;overflow:hidden;display:flex;box-shadow:0 20px 50px rgba(0,0,0,0.25);}
        .left{width:48%;background:linear-gradient(rgba(0,0,0,0.45),rgba(0,0,0,0.45)),url('https://images.unsplash.com/photo-1542838132-92c53300491e?q=80&w=1200&auto=format&fit=crop');background-size:cover;background-position:center;color:white;padding:60px;display:flex;flex-direction:column;justify-content:center;}
        .left h1{font-size:50px;margin-bottom:20px;}
        .left p{font-size:18px;line-height:1.6;}
        .right{width:52%;display:flex;justify-content:center;align-items:center;padding:45px;}
        .register-box{width:100%;max-width:420px;}
        .register-box h2{font-size:36px;color:#15803d;margin-bottom:10px;}
        .register-box p{color:#6b7280;margin-bottom:25px;}
        .input-box{margin-bottom:15px;}
        .input-box input,.input-box select{width:100%;padding:14px;border:2px solid #d1d5db;border-radius:14px;font-size:15px;outline:none;}
        .input-box input:focus,.input-box select:focus{border-color:#16a34a;box-shadow:0 0 10px rgba(22,163,74,0.2);}
        .register-btn{width:100%;padding:15px;border:none;border-radius:14px;background:#16a34a;color:white;font-size:17px;font-weight:bold;cursor:pointer;transition:0.3s;}
        .register-btn:hover{background:#15803d;transform:translateY(-2px);}
        .extra{margin-top:22px;text-align:center;color:#374151;}
        .extra a{color:#16a34a;text-decoration:none;font-weight:bold;}
        .error-msg{background:#fee2e2;color:#dc2626;padding:12px 16px;border-radius:12px;margin-bottom:16px;font-size:14px;}
        .success-msg{background:#dcfce7;color:#16a34a;padding:12px 16px;border-radius:12px;margin-bottom:16px;font-size:14px;}
        .logo{position:absolute;top:30px;left:40px;color:white;font-size:28px;font-weight:bold;}
        @media(max-width:900px){.container{flex-direction:column;width:95%;}.left,.right{width:100%;}.left{min-height:260px;}}
    </style>
</head>
<body>

<div class="logo">🛒 CeylonFresh</div>

<div class="container">
    <div class="left">
        <h1>Create Your Grocery Account</h1>
        <p>Register now to browse products, add items to cart, place orders, make payments, and track delivery easily.</p>
    </div>

    <div class="right">
        <div class="register-box">

            <h2>Register Account 🥦</h2>
            <p>Join our Online Grocery Order System</p>

            <%
                String regError = request.getParameter("error");
                String regSuccess = request.getParameter("success");
                if ("exists".equals(regError)) {
            %>
                <div class="error-msg">⚠️ An account with this email already exists.</div>
            <% } else if ("empty".equals(regError)) { %>
                <div class="error-msg">⚠️ Please fill in all fields.</div>
            <% } else if ("ok".equals(regSuccess)) { %>
                <div class="success-msg">✅ Account created! You can now login.</div>
            <% } %>

            <form action="UserServlet" method="post">
                <input type="hidden" name="action" value="register">

                <div class="input-box">
                    <input type="text" name="name" placeholder="Full Name" required>
                </div>

                <div class="input-box">
                    <input type="email" name="email" placeholder="Email Address" required>
                </div>

                <div class="input-box">
                    <input type="password" name="password" placeholder="Password" required>
                </div>

                <div class="input-box">
                    <select name="role">
                        <option value="Customer">Customer</option>
                        <option value="Delivery">Delivery Person</option>
                    </select>
                </div>

                <button class="register-btn" type="submit">Create Account</button>
            </form>

            <div class="extra">
                Already have an account? <a href="login.jsp">Login here</a>
            </div>
        </div>
    </div>
</div>

</body>
</html>
