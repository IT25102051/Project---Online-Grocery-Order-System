<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.io.*, java.util.*" %>
<%
    String username = (String) session.getAttribute("username");
    String role     = (String) session.getAttribute("role");
    String userId   = (String) session.getAttribute("userId");
    String email    = (String) session.getAttribute("email");

    if (username == null || role == null || userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Retrieve password from users.txt
    String password = "";
    String filePath = application.getRealPath("/") + "data/users.txt";
    File file = new File(filePath);
    if (file.exists()) {
        try (BufferedReader br = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = br.readLine()) != null) {
                line = line.trim();
                if (line.isEmpty()) continue;
                String[] p = line.split(",");
                if (p.length >= 5 && p[0].trim().equals(userId)) {
                    password = p[3].trim();
                    break;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Setup dynamic theme variables based on user role
    boolean isDelivery = "Delivery".equalsIgnoreCase(role);
    boolean isAdmin    = "Admin".equalsIgnoreCase(role);

    String primaryColor      = "#064e3b";  // Customer Green
    String primaryLight      = "#10b981";
    String bgGradientStart  = "#f0fdf4";
    String backDashboardUrl  = "customerDashboard.jsp";
    String portalTitle       = "Customer Portal";

    if (isDelivery) {
        primaryColor     = "#16a34a";  // Delivery Emerald
        primaryLight     = "#22d3ee";  // Teal accent
        bgGradientStart = "#f0fdfa";
        backDashboardUrl = "deliveryDashboard.jsp";
        portalTitle      = "Delivery Partner Portal";
    } else if (isAdmin) {
        primaryColor     = "#1e3a8a";  // Admin Royal Blue
        primaryLight     = "#3b82f6";
        bgGradientStart = "#eff6ff";
        backDashboardUrl = "adminDashboard.jsp";
        portalTitle      = "Administration Panel";
    }

    // Count customer notifications if Customer
    int notificationCount = 0;
    boolean hasUnread = false;
    if (!isDelivery && !isAdmin) {
        File notifFile = new File(application.getRealPath("/") + "data/notifications.txt");
        if (notifFile.exists()) {
            try (BufferedReader br = new BufferedReader(new FileReader(notifFile))) {
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
                            hasUnread = true;
                            notificationCount++;
                        }
                    }
                }
            } catch (Exception ignored) {}
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile - CeylonFresh</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        :root {
            --primary: <%= primaryColor %>;
            --primary-light: <%= primaryLight %>;
            --bg-start: <%= bgGradientStart %>;
            --text-dark: #0f172a;
            --text-light: #64748b;
            --transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Outfit', sans-serif;
        }

        body {
            background: linear-gradient(135deg, var(--bg-start), #f8fafc);
            color: var(--text-dark);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        /* NAVBAR */
        .navbar {
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(12px);
            padding: 16px 40px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 4px 30px rgba(0, 0, 0, 0.03);
            position: sticky;
            top: 0;
            z-index: 100;
        }

        .logo {
            font-size: 24px;
            font-weight: 800;
            color: var(--primary);
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .logo i {
            color: var(--primary-light);
        }

        .nav-links {
            display: flex;
            align-items: center;
            gap: 24px;
        }

        .nav-links a {
            text-decoration: none;
            color: #475569;
            font-weight: 600;
            font-size: 15px;
            transition: var(--transition);
        }

        .nav-links a:hover {
            color: var(--primary);
        }

        .nav-links a.logout {
            color: #ef4444;
        }

        .nav-links a.logout:hover {
            color: #b91c1c;
        }

        .avatar {
            width: 42px;
            height: 42px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--primary-light), var(--primary));
            color: white;
            display: flex;
            justify-content: center;
            align-items: center;
            font-weight: 700;
            font-size: 18px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
            border: 2px solid white;
            cursor: pointer;
            transition: var(--transition);
        }

        .avatar:hover {
            transform: scale(1.08);
        }

        /* CONTAINER */
        .profile-container {
            max-width: 1000px;
            width: 100%;
            margin: 40px auto;
            padding: 0 24px;
            flex: 1;
        }

        /* HEADER */
        .profile-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }

        .profile-header h1 {
            font-size: 36px;
            font-weight: 850;
            color: var(--primary);
            letter-spacing: -0.5px;
        }

        .back-btn {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 12px 20px;
            background: white;
            border: 1px solid #e2e8f0;
            border-radius: 14px;
            color: var(--text-dark);
            text-decoration: none;
            font-weight: 700;
            font-size: 14px;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.02);
            transition: var(--transition);
        }

        .back-btn:hover {
            background: #f8fafc;
            border-color: #cbd5e1;
            transform: translateX(-4px);
        }

        /* FEEDBACK BANNERS */
        .alert {
            padding: 16px 24px;
            border-radius: 18px;
            font-weight: 600;
            font-size: 15px;
            margin-bottom: 30px;
            display: flex;
            align-items: center;
            gap: 12px;
            animation: slideIn 0.4s ease-out;
        }

        .alert-success {
            background: #d1fae5;
            color: #065f46;
            border-left: 5px solid #10b981;
        }

        .alert-danger {
            background: #fee2e2;
            color: #991b1b;
            border-left: 5px solid #ef4444;
        }

        @keyframes slideIn {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* GRID LAYOUT */
        .profile-grid {
            display: grid;
            grid-template-columns: 1fr 1.5fr;
            gap: 30px;
        }

        @media (max-width: 850px) {
            .profile-grid {
                grid-template-columns: 1fr;
            }
        }

        /* CARD STYLE */
        .card {
            background: white;
            border-radius: 30px;
            padding: 40px;
            box-shadow: 0 20px 40px rgba(15, 23, 42, 0.03);
            border: 1px solid rgba(226, 232, 240, 0.8);
            position: relative;
            overflow: hidden;
        }

        /* DETAILS CARD (LEFT) */
        .details-card {
            text-align: center;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
        }

        .big-avatar {
            width: 110px;
            height: 110px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--primary-light), var(--primary));
            color: white;
            display: flex;
            justify-content: center;
            align-items: center;
            font-weight: 800;
            font-size: 48px;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
            border: 4px solid white;
            margin-bottom: 24px;
            animation: pulse-avatar 3s infinite alternate;
        }

        @keyframes pulse-avatar {
            0% { transform: scale(1); }
            100% { transform: scale(1.03); box-shadow: 0 12px 30px rgba(0, 0, 0, 0.15); }
        }

        .details-card h2 {
            font-size: 24px;
            font-weight: 800;
            margin-bottom: 6px;
            color: var(--text-dark);
        }

        .role-badge {
            display: inline-block;
            padding: 6px 16px;
            border-radius: 99px;
            font-size: 13px;
            font-weight: 800;
            background: var(--bg-start);
            color: var(--primary);
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 30px;
            border: 1px solid rgba(16, 185, 129, 0.2);
        }

        .info-list {
            width: 100%;
            display: grid;
            gap: 20px;
            text-align: left;
            border-top: 1px solid #f1f5f9;
            padding-top: 24px;
        }

        .info-item {
            display: flex;
            align-items: flex-start;
            gap: 14px;
        }

        .info-item i {
            font-size: 18px;
            color: var(--primary-light);
            margin-top: 3px;
            width: 24px;
            text-align: center;
        }

        .info-label {
            font-size: 12px;
            color: var(--text-light);
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 2px;
        }

        .info-value {
            font-size: 15px;
            font-weight: 600;
            color: var(--text-dark);
            word-break: break-all;
        }

        /* FORM CARD (RIGHT) */
        .form-card h2 {
            font-size: 24px;
            font-weight: 800;
            margin-bottom: 12px;
            color: var(--primary);
        }

        .form-card p {
            font-size: 15px;
            color: var(--text-light);
            margin-bottom: 30px;
        }

        .input-group {
            margin-bottom: 24px;
            position: relative;
        }

        .input-group label {
            display: block;
            font-size: 13px;
            font-weight: 700;
            color: #475569;
            margin-bottom: 8px;
            text-transform: uppercase;
            letter-spacing: 0.3px;
        }

        .input-wrapper {
            position: relative;
            display: flex;
            align-items: center;
        }

        .input-wrapper i.prefix-icon {
            position: absolute;
            left: 16px;
            color: #94a3b8;
            font-size: 18px;
            transition: var(--transition);
        }

        .input-wrapper input {
            width: 100%;
            padding: 16px 16px 16px 48px;
            border: 1px solid #cbd5e1;
            border-radius: 16px;
            outline: none;
            font-size: 15px;
            font-weight: 600;
            color: var(--text-dark);
            transition: var(--transition);
            background: #fafbfc;
        }

        .input-wrapper input:focus {
            border-color: var(--primary);
            background: white;
            box-shadow: 0 0 0 4px rgba(16, 185, 129, 0.08);
        }

        .input-wrapper input:focus + i.prefix-icon {
            color: var(--primary);
        }

        .toggle-pw {
            position: absolute;
            right: 16px;
            color: #94a3b8;
            cursor: pointer;
            transition: var(--transition);
            padding: 4px;
        }

        .toggle-pw:hover {
            color: var(--text-dark);
        }

        .btn-submit {
            width: 100%;
            padding: 18px;
            border: none;
            background: var(--primary);
            color: white;
            border-radius: 16px;
            font-weight: 700;
            font-size: 16px;
            cursor: pointer;
            transition: var(--transition);
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.04);
        }

        .btn-submit:hover {
            background: #047857;
            transform: translateY(-2px);
            box-shadow: 0 15px 30px rgba(6, 78, 59, 0.15);
        }

        .btn-submit:active {
            transform: translateY(0);
        }

        /* FOOTER */
        .footer {
            background: var(--primary);
            color: white;
            padding: 24px;
            text-align: center;
            font-size: 14px;
            margin-top: 40px;
        }

        .footer p {
            opacity: 0.8;
        }
    </style>
</head>
<body>

<!-- NAVBAR -->
<div class="navbar">
    <a class="logo" href="<%= backDashboardUrl %>"><i class="fa-solid fa-leaf"></i> CeylonFresh</a>
    <div class="nav-links">
        <% if (!isDelivery && !isAdmin) { %>
            <a href="products.jsp"><i class="fa-solid fa-store"></i> Products</a>
            <a href="cart.jsp?userId=<%= userId %>"><i class="fa-solid fa-cart-shopping"></i> Cart</a>
            <a href="OrderHistoryServlet"><i class="fa-solid fa-box"></i> Orders</a>
            <a href="notifications.jsp">
                <i class="fa-solid fa-bell" style="position: relative;">
                    <% if (hasUnread) { %>
                        <span style="position: absolute; top: -3px; right: -3px; display: block; width: 8px; height: 8px; background: #ef4444; border-radius: 50%; border: 1px solid white;"></span>
                    <% } %>
                </i> Notifications
            </a>
            <a href="reviews.jsp"><i class="fa-solid fa-star"></i> Reviews</a>
        <% } else if (isDelivery) { %>
            <a href="deliveryNotifications.jsp"><i class="fa-solid fa-bell"></i> Alerts</a>
        <% } %>
        <a href="LogoutServlet" class="logout"><i class="fa-solid fa-arrow-right-from-bracket"></i> Logout</a>
        <div class="avatar"><%= username.substring(0, 1).toUpperCase() %></div>
    </div>
</div>

<!-- CONTAINER -->
<div class="profile-container">

    <!-- HEADER -->
    <div class="profile-header">
        <div>
            <h1 id="page-title">Manage Profile</h1>
            <p style="color: var(--text-light); margin-top: 4px; font-weight: 500;"><%= portalTitle %> &middot; Update details below</p>
        </div>
        <a href="<%= backDashboardUrl %>" class="back-btn"><i class="fa-solid fa-arrow-left"></i> Dashboard</a>
    </div>

    <!-- FEEDBACK BANNERS -->
    <%
        String success = request.getParameter("success");
        String error = request.getParameter("error");
        if ("ok".equals(success)) {
    %>
        <div class="alert alert-success">
            <i class="fa-solid fa-circle-check" style="font-size: 20px;"></i>
            <span>Profile updated successfully! All changes are now live. 🎉</span>
        </div>
    <%
        } else if (error != null) {
            String errorMsg = "An error occurred. Please try again.";
            if ("empty".equals(error)) {
                errorMsg = "All profile fields are required.";
            } else if ("exists".equals(error)) {
                errorMsg = "This email address is already in use by another user.";
            } else if ("passwordMismatch".equals(error)) {
                errorMsg = "The password and confirm password fields must match.";
            } else if ("failed".equals(error)) {
                errorMsg = "System failure. Could not update your profile.";
            }
    %>
        <div class="alert alert-danger">
            <i class="fa-solid fa-circle-exclamation" style="font-size: 20px;"></i>
            <span><%= errorMsg %></span>
        </div>
    <%
        }
    %>

    <!-- GRID LAYOUT -->
    <div class="profile-grid">
        
        <!-- DETAILS CARD (LEFT) -->
        <div class="card details-card">
            <div class="big-avatar"><%= username.substring(0, 1).toUpperCase() %></div>
            <h2><%= username %></h2>
            <div class="role-badge"><%= role %></div>
            
            <div class="info-list">
                <div class="info-item">
                    <i class="fa-solid fa-id-card"></i>
                    <div>
                        <div class="info-label">User Reference ID</div>
                        <div class="info-value"><%= userId %></div>
                    </div>
                </div>
                <div class="info-item">
                    <i class="fa-solid fa-envelope"></i>
                    <div>
                        <div class="info-label">Email Address</div>
                        <div class="info-value"><%= email %></div>
                    </div>
                </div>
                <div class="info-item">
                    <i class="fa-solid fa-shield-halved"></i>
                    <div>
                        <div class="info-label">System Privileges</div>
                        <div class="info-value"><%= role.equalsIgnoreCase("Admin") ? "Super User (Admin)" : role + " Access" %></div>
                    </div>
                </div>
            </div>
        </div>

        <!-- FORM CARD (RIGHT) -->
        <div class="card form-card">
            <h2>Edit Profile Details</h2>
            <p>Modify your account information below and click Save Changes.</p>
            
            <form action="UserServlet" method="post" onsubmit="return validateForm()">
                <input type="hidden" name="action" value="updateProfile">
                
                <div class="input-group">
                    <label for="name">Full Name</label>
                    <div class="input-wrapper">
                        <i class="fa-solid fa-user prefix-icon"></i>
                        <input type="text" id="name" name="name" value="<%= username %>" required>
                    </div>
                </div>

                <div class="input-group">
                    <label for="email">Email Address</label>
                    <div class="input-wrapper">
                        <i class="fa-solid fa-envelope prefix-icon"></i>
                        <input type="email" id="email" name="email" value="<%= email %>" required>
                    </div>
                </div>

                <div class="input-group">
                    <label for="password">Password</label>
                    <div class="input-wrapper">
                        <i class="fa-solid fa-lock prefix-icon"></i>
                        <input type="password" id="password" name="password" value="<%= password %>" required>
                        <i class="fa-solid fa-eye toggle-pw" id="togglePasswordBtn" onclick="togglePasswordVisibility('password')"></i>
                    </div>
                </div>

                <div class="input-group" style="margin-bottom: 30px;">
                    <label for="confirmPassword">Confirm Password</label>
                    <div class="input-wrapper">
                        <i class="fa-solid fa-circle-check prefix-icon"></i>
                        <input type="password" id="confirmPassword" name="confirmPassword" value="<%= password %>" required>
                        <i class="fa-solid fa-eye toggle-pw" id="toggleConfirmBtn" onclick="togglePasswordVisibility('confirmPassword')"></i>
                    </div>
                </div>

                <button type="submit" class="btn-submit">
                    <i class="fa-solid fa-floppy-disk"></i> Save Changes
                </button>
            </form>
        </div>

    </div>

</div>

<!-- FOOTER -->
<div class="footer">
    <p>&copy; <%= Calendar.getInstance().get(Calendar.YEAR) %> CeylonFresh. Premium Sri Lankan groceries, delivered fresh.</p>
</div>

<script>
    function togglePasswordVisibility(id) {
        var input = document.getElementById(id);
        var btn = id === 'password' ? document.getElementById('togglePasswordBtn') : document.getElementById('toggleConfirmBtn');
        if (input.type === "password") {
            input.type = "text";
            btn.classList.remove('fa-eye');
            btn.classList.add('fa-eye-slash');
        } else {
            input.type = "password";
            btn.classList.remove('fa-eye-slash');
            btn.classList.add('fa-eye');
        }
    }

    function validateForm() {
        var pw = document.getElementById('password').value;
        var cpw = document.getElementById('confirmPassword').value;
        if (pw !== cpw) {
            alert("Error: Passwords do not match. Please verify.");
            return false;
        }
        return true;
    }
</script>
</body>
</html>
