<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String existingRole = (String) session.getAttribute("role");
    if ("Admin".equalsIgnoreCase(existingRole)) {
        response.sendRedirect("adminDashboard.jsp"); return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Admin Login - CeylonFresh</title>
    <style>
        *{margin:0;padding:0;box-sizing:border-box;font-family:'Segoe UI',sans-serif;}
        body{min-height:100vh;background:#0f172a;display:flex;align-items:center;justify-content:center;padding:20px;}
        .wrapper{display:flex;width:960px;min-height:580px;border-radius:32px;overflow:hidden;box-shadow:0 30px 80px rgba(0,0,0,0.5);}
        .left{width:45%;background:linear-gradient(160deg,#16a34a 0%,#14532d 100%);padding:56px 48px;display:flex;flex-direction:column;justify-content:center;color:white;position:relative;overflow:hidden;}
        .left::before{content:'';position:absolute;top:-80px;right:-80px;width:300px;height:300px;border-radius:50%;background:rgba(255,255,255,0.05);}
        .left::after{content:'';position:absolute;bottom:-60px;left:-60px;width:220px;height:220px;border-radius:50%;background:rgba(255,255,255,0.05);}
        .left-brand{font-size:28px;font-weight:800;margin-bottom:48px;}
        .left-brand span{color:#86efac;}
        .left h1{font-size:38px;font-weight:800;line-height:1.2;margin-bottom:16px;}
        .left p{font-size:15px;line-height:1.7;opacity:0.85;margin-bottom:36px;}
        .feature{display:flex;align-items:center;gap:12px;margin-bottom:14px;font-size:14px;opacity:0.9;}
        .feature-dot{width:8px;height:8px;border-radius:50%;background:#86efac;flex-shrink:0;}
        .right{width:55%;background:white;padding:56px 52px;display:flex;flex-direction:column;justify-content:center;}
        .admin-badge{display:inline-flex;align-items:center;gap:8px;background:#f0fdf4;color:#16a34a;padding:8px 16px;border-radius:50px;font-size:13px;font-weight:700;margin-bottom:28px;border:1px solid #dcfce7;}
        .right h2{font-size:34px;font-weight:800;color:#0f172a;margin-bottom:6px;}
        .right p.sub{color:#64748b;font-size:15px;margin-bottom:32px;}
        .error-box{background:#fef2f2;border:1px solid #fecaca;border-radius:14px;padding:14px 18px;margin-bottom:22px;color:#dc2626;font-size:14px;font-weight:500;}
        .field{margin-bottom:20px;}
        .field label{display:block;font-size:13px;font-weight:700;color:#374151;margin-bottom:8px;text-transform:uppercase;letter-spacing:0.5px;}
        .input-wrap{position:relative;}
        .input-wrap .icon{position:absolute;left:16px;top:50%;transform:translateY(-50%);font-size:18px;}
        .field input{width:100%;padding:14px 16px 14px 48px;border:2px solid #e5e7eb;border-radius:14px;font-size:15px;outline:none;transition:0.2s;background:#fafafa;}
        .field input:focus{border-color:#16a34a;background:white;box-shadow:0 0 0 4px rgba(22,163,74,0.08);}
        .login-btn{width:100%;padding:16px;background:#16a34a;color:white;border:none;border-radius:14px;font-size:16px;font-weight:700;cursor:pointer;transition:0.25s;margin-top:8px;}
        .login-btn:hover{background:#15803d;transform:translateY(-2px);box-shadow:0 8px 24px rgba(22,163,74,0.35);}
        .divider{text-align:center;margin:22px 0;color:#9ca3af;font-size:13px;position:relative;}
        .divider::before,.divider::after{content:'';position:absolute;top:50%;width:42%;height:1px;background:#e5e7eb;}
        .divider::before{left:0;} .divider::after{right:0;}
        .back-link{display:block;text-align:center;color:#64748b;text-decoration:none;font-size:14px;font-weight:600;}
        .back-link:hover{color:#16a34a;}
        .hint{background:#f8fafc;border:1px solid #e2e8f0;border-radius:12px;padding:14px 16px;margin-top:20px;font-size:13px;color:#64748b;line-height:1.6;}
        .hint strong{color:#374151;}
        @media(max-width:860px){.wrapper{flex-direction:column;width:100%;max-width:480px;}.left,.right{width:100%;padding:36px 32px;}.left::before,.left::after{display:none;}}
    </style>
</head>
<body>
<div class="wrapper">
    <div class="left">
        <div class="left-brand">🛒 <span>CeylonFresh</span></div>
        <h1>Admin Control Panel</h1>
        <p>Manage your entire grocery store from one powerful dashboard.</p>
        <div class="feature"><div class="feature-dot"></div> Real-time order tracking</div>
        <div class="feature"><div class="feature-dot"></div> Inventory management</div>
        <div class="feature"><div class="feature-dot"></div> Customer & payment reports</div>
        <div class="feature"><div class="feature-dot"></div> Notification management</div>
    </div>
    <div class="right">
        <div class="admin-badge">🔐 Admin Access Only</div>
        <h2>Welcome Back</h2>
        <p class="sub">Sign in to access the admin dashboard</p>
        <%
            String err = request.getParameter("error");
            if ("invalid".equals(err)) {
        %><div class="error-box">⚠️ Invalid credentials. Please try again.</div><%
            } else if ("unauthorized".equals(err)) {
        %><div class="error-box">🚫 You are not authorized as an admin.</div><% } %>
        <form action="LoginServlet" method="post">
            <input type="hidden" name="adminLogin" value="true">
            <div class="field">
                <label>Email Address</label>
                <div class="input-wrap">
                    <span class="icon">📧</span>
                    <input type="email" name="email" placeholder="admin@gmail.com" required>
                </div>
            </div>
            <div class="field">
                <label>Password</label>
                <div class="input-wrap">
                    <span class="icon">🔒</span>
                    <input type="password" name="password" placeholder="Enter admin password" required>
                </div>
            </div>
            <button class="login-btn" type="submit">Sign In to Dashboard →</button>
        </form>
        <div class="divider">or</div>
        <a href="login.jsp" class="back-link">← Back to Customer Login</a>
        <div class="hint"><strong>Demo credentials:</strong><br>Email: admin@gmail.com &nbsp;|&nbsp; Password: admin123</div>
    </div>
</div>
</body>
</html>
