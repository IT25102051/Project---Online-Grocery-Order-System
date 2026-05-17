<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // Already logged in? Redirect straight to dashboard
    String existingRole = (String) session.getAttribute("role");
    if (existingRole != null) {
        if ("Admin".equalsIgnoreCase(existingRole)) {
            response.sendRedirect("adminDashboard.jsp");
        } else {
            response.sendRedirect("customerDashboard.jsp");
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Login - Online Grocery Order System</title>
    <style>
        *{margin:0;padding:0;box-sizing:border-box;font-family:'Segoe UI',sans-serif;}
        body{height:100vh;background:linear-gradient(135deg,#16a34a,#84cc16);display:flex;justify-content:center;align-items:center;}
        .container{width:1000px;height:600px;background:white;border-radius:30px;overflow:hidden;display:flex;box-shadow:0 20px 50px rgba(0,0,0,0.25);}
        .left{width:50%;background:linear-gradient(rgba(0,0,0,0.4),rgba(0,0,0,0.4)),url('https://images.unsplash.com/photo-1542838132-92c53300491e?q=80&w=1200&auto=format&fit=crop');background-size:cover;background-position:center;color:white;padding:60px;display:flex;flex-direction:column;justify-content:center;}
        .left h1{font-size:52px;margin-bottom:20px;}
        .left p{font-size:18px;line-height:1.6;}
        .right{width:50%;display:flex;justify-content:center;align-items:center;padding:40px;}
        .login-box{width:100%;max-width:350px;}
        .login-box h2{font-size:38px;color:#15803d;margin-bottom:10px;}
        .login-box p{color:#6b7280;margin-bottom:30px;}
        .input-box{margin-bottom:20px;}
        .input-box input{width:100%;padding:15px;border:2px solid #d1d5db;border-radius:14px;font-size:16px;outline:none;transition:0.3s;}
        .input-box input:focus{border-color:#16a34a;box-shadow:0 0 10px rgba(22,163,74,0.2);}
        .login-btn{width:100%;padding:15px;border:none;border-radius:14px;background:#16a34a;color:white;font-size:17px;font-weight:bold;cursor:pointer;transition:0.3s;}
        .login-btn:hover{background:#15803d;transform:translateY(-2px);}
        .extra{margin-top:25px;text-align:center;}
        .extra a{color:#16a34a;text-decoration:none;font-weight:bold;}
        .error-msg{background:#fee2e2;color:#dc2626;padding:12px 16px;border-radius:12px;margin-bottom:20px;font-size:14px;}
        .logo{position:absolute;top:30px;left:40px;color:white;font-size:28px;font-weight:bold;}
        @media(max-width:900px){.container{flex-direction:column;width:95%;height:auto;}.left,.right{width:100%;}.left{height:250px;}}
    </style>
</head>
<body>

<div class="logo">🛒 CeylonFresh</div>

<div class="container">
    <div class="left">
        <h1>Fresh Groceries Delivered Fast</h1>
        <p>Order vegetables, fruits, dairy products and daily essentials with our smart Online Grocery Order System.</p>
    </div>

    <div class="right">
        <div class="login-box">

            <h2>Welcome Back 👋</h2>
            <p>Login to continue shopping</p>

            <%
                String loginError = request.getParameter("error");
                if ("invalid".equals(loginError)) {
            %>
                <div class="error-msg">⚠️ Invalid email or password. Please try again.</div>
            <% } %>

            <form action="LoginServlet" method="post">
                <div class="input-box">
                    <input type="email" name="email" placeholder="Enter Email" required>
                </div>
                <div class="input-box">
                    <input type="password" name="password" placeholder="Enter Password" required>
                </div>
                <button class="login-btn" type="submit">Login</button>
            </form>

            <div class="extra">
                Don't have an account? <a href="register.jsp">Register here</a>
            </div>
        </div>
    </div>
</div>

</body>
</html>
