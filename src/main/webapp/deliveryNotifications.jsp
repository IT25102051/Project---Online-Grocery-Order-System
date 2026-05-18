<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.io.*, java.util.*" %>
<%
    String role = (String) session.getAttribute("role");
    if (role == null || !"Delivery".equalsIgnoreCase(role)) {
        response.sendRedirect("login.jsp");
        return;
    }
    String username = (String) session.getAttribute("username");
    String dataDir = application.getRealPath("/") + "data/";

    // Load delivery notifications
    List<String[]> notifications = new ArrayList<>();
    int unreadCount = 0;
    int readCount = 0;
    File notifFile = new File(dataDir + "notifications.txt");
    if (notifFile.exists()) {
        try (BufferedReader br = new BufferedReader(new FileReader(notifFile))) {
            String line;
            while ((line = br.readLine()) != null) {
                line = line.trim();
                if (line.isEmpty()) continue;
                String[] raw = line.split(",", 6);
                String recipient = raw.length > 1 ? raw[1].trim() : "All";
                String title = raw.length > 2 ? raw[2].replace(";", ",") : "";
                String message = raw.length > 3 ? raw[3].replace(";", ",") : "";
                String time = raw.length > 4 ? raw[4] : "";
                String readFlag = raw.length > 5 ? raw[5].trim() : "unread";
                if ("All".equalsIgnoreCase(recipient) || "Delivery".equalsIgnoreCase(recipient)) {
                    notifications.add(new String[]{raw[0], recipient, title, message, time, readFlag});
                    if ("read".equalsIgnoreCase(readFlag)) {
                        readCount++;
                    } else {
                        unreadCount++;
                    }
                }
            }
        }
    }
    // Reverse so newest first
    Collections.reverse(notifications);
    int totalNotifications = notifications.size();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Notification Center - Delivery</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', 'Segoe UI', sans-serif;
            background: #f1f5f9;
            color: #334155;
            min-height: 100vh;
        }

        /* ── Animated background ── */
        .bg-glow {
            position: fixed;
            top: -200px;
            right: -200px;
            width: 600px;
            height: 600px;
            background: radial-gradient(circle, rgba(22, 163, 74, 0.08) 0%, transparent 70%);
            border-radius: 50%;
            pointer-events: none;
            animation: float-glow 8s ease-in-out infinite;
        }

        .bg-glow-2 {
            position: fixed;
            bottom: -150px;
            left: -150px;
            width: 500px;
            height: 500px;
            background: radial-gradient(circle, rgba(59, 130, 246, 0.05) 0%, transparent 70%);
            border-radius: 50%;
            pointer-events: none;
            animation: float-glow 10s ease-in-out infinite reverse;
        }

        @keyframes float-glow {
            0%, 100% { transform: translate(0, 0) scale(1); }
            50% { transform: translate(30px, 20px) scale(1.05); }
        }

        /* ── Container ── */
        .page-container {
            max-width: 960px;
            margin: 0 auto;
            padding: 32px 24px 80px;
            position: relative;
            z-index: 1;
        }

        /* ── Top Navigation Bar ── */
        .top-nav {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 36px;
            gap: 16px;
        }

        .back-btn {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            padding: 12px 22px;
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 14px;
            color: #475569;
            text-decoration: none;
            font-weight: 600;
            font-size: 14px;
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
        }

        .back-btn:hover {
            background: #f0fdf4;
            color: #15803d;
            transform: translateX(-3px);
            border-color: rgba(22, 163, 74, 0.4);
        }

        .back-btn svg {
            width: 18px;
            height: 18px;
        }

        .user-badge {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 10px 18px;
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 14px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.04);
        }

        .user-avatar {
            width: 36px;
            height: 36px;
            background: linear-gradient(135deg, #16a34a, #22d3ee);
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 800;
            font-size: 14px;
            color: white;
        }

        .user-info strong {
            display: block;
            font-size: 13px;
            color: #0f172a;
            line-height: 1.2;
        }

        .user-info span {
            font-size: 11px;
            color: #64748b;
        }

        /* ── Page Header ── */
        .page-header {
            text-align: center;
            margin-bottom: 40px;
        }

        .page-header .icon-wrap {
            width: 72px;
            height: 72px;
            margin: 0 auto 20px;
            background: linear-gradient(135deg, #16a34a, #059669);
            border-radius: 22px;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 12px 40px rgba(22, 163, 74, 0.2);
            animation: bell-ring 3s ease-in-out infinite;
        }

        @keyframes bell-ring {
            0%, 100% { transform: rotate(0); }
            5% { transform: rotate(8deg); }
            10% { transform: rotate(-8deg); }
            15% { transform: rotate(5deg); }
            20% { transform: rotate(0); }
        }

        .page-header .icon-wrap svg {
            width: 34px;
            height: 34px;
            color: white;
        }

        .page-header h1 {
            font-size: 36px;
            font-weight: 800;
            color: #0f172a;
            margin-bottom: 10px;
            letter-spacing: -0.02em;
        }

        .page-header p {
            color: #64748b;
            font-size: 16px;
            max-width: 500px;
            margin: 0 auto;
            line-height: 1.7;
        }

        /* ── Stats Grid ── */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 18px;
            margin-bottom: 32px;
        }

        .stat-card {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 20px;
            padding: 24px;
            text-align: center;
            backdrop-filter: blur(10px);
            transition: all 0.3s ease;
        }

        .stat-card:hover {
            background: #f8fafc;
            transform: translateY(-4px);
            border-color: rgba(22, 163, 74, 0.3);
            box-shadow: 0 16px 40px rgba(0, 0, 0, 0.08);
        }

        .stat-card .stat-icon {
            width: 48px;
            height: 48px;
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 16px;
            font-size: 22px;
        }

        .stat-card .stat-icon.total {
            background: rgba(59, 130, 246, 0.15);
        }

        .stat-card .stat-icon.unread {
            background: rgba(239, 68, 68, 0.15);
        }

        .stat-card .stat-icon.read-icon {
            background: rgba(22, 163, 74, 0.15);
        }

        .stat-card h2 {
            font-size: 36px;
            font-weight: 800;
            color: #0f172a;
            margin-bottom: 6px;
        }

        .stat-card p {
            color: #64748b;
            font-size: 13px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.06em;
        }

        /* ── Filter Bar ── */
        .filter-bar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 14px;
            margin-bottom: 24px;
            flex-wrap: wrap;
        }

        .filter-tabs {
            display: flex;
            gap: 8px;
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 14px;
            padding: 5px;
        }

        .filter-tab {
            padding: 10px 20px;
            border-radius: 10px;
            border: none;
            background: transparent;
            color: #64748b;
            font-weight: 600;
            font-size: 13px;
            cursor: pointer;
            transition: all 0.25s ease;
            font-family: 'Inter', sans-serif;
        }

        .filter-tab:hover {
            color: #0f172a;
        }

        .filter-tab.active {
            background: #16a34a;
            color: white;
            box-shadow: 0 4px 12px rgba(22, 163, 74, 0.3);
        }

        .mark-all-btn {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 20px;
            border-radius: 12px;
            border: 1px solid rgba(22, 163, 74, 0.3);
            background: rgba(22, 163, 74, 0.1);
            color: #16a34a;
            font-weight: 600;
            font-size: 13px;
            cursor: pointer;
            transition: all 0.25s ease;
            font-family: 'Inter', sans-serif;
        }

        .mark-all-btn:hover {
            background: rgba(22, 163, 74, 0.2);
            border-color: #16a34a;
        }

        .mark-all-btn svg {
            width: 16px;
            height: 16px;
        }

        /* ── Notification List ── */
        .notification-list {
            display: flex;
            flex-direction: column;
            gap: 14px;
        }

        .notif-card {
            display: flex;
            align-items: flex-start;
            gap: 18px;
            padding: 24px;
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 20px;
            transition: all 0.3s ease;
            box-shadow: 0 2px 10px rgba(0,0,0,0.04);
            position: relative;
            overflow: hidden;
            cursor: default;
        }

        .notif-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 4px;
            height: 100%;
            border-radius: 4px 0 0 4px;
            transition: background 0.3s ease;
        }

        .notif-card.is-unread::before {
            background: linear-gradient(180deg, #16a34a, #22d3ee);
        }

        .notif-card.is-read::before {
            background: #cbd5e1;
        }

        .notif-card:hover {
            background: #f8fafc;
            border-color: #d1d5db;
            transform: translateX(4px);
            box-shadow: 0 8px 30px rgba(0, 0, 0, 0.08);
        }

        .notif-card .notif-icon {
            width: 52px;
            height: 52px;
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            flex-shrink: 0;
        }

        .notif-icon.type-order { background: rgba(22, 163, 74, 0.15); }
        .notif-icon.type-promo { background: rgba(251, 191, 36, 0.15); }
        .notif-icon.type-payment { background: rgba(59, 130, 246, 0.15); }
        .notif-icon.type-delivery { background: rgba(139, 92, 246, 0.15); }
        .notif-icon.type-default { background: rgba(100, 116, 139, 0.15); }

        .notif-body {
            flex: 1;
            min-width: 0;
        }

        .notif-body h3 {
            font-size: 17px;
            font-weight: 700;
            color: #0f172a;
            margin-bottom: 6px;
            line-height: 1.4;
        }

        .notif-body .notif-message {
            color: #64748b;
            font-size: 14px;
            line-height: 1.7;
            margin-bottom: 12px;
        }

        .notif-meta {
            display: flex;
            align-items: center;
            gap: 14px;
            flex-wrap: wrap;
        }

        .notif-time {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 12px;
            color: #475569;
            font-weight: 500;
        }

        .notif-time svg {
            width: 14px;
            height: 14px;
        }

        .notif-recipient-badge {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 4px 10px;
            border-radius: 8px;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.04em;
        }

        .badge-all {
            background: rgba(59, 130, 246, 0.12);
            color: #2563eb;
        }

        .badge-delivery {
            background: rgba(139, 92, 246, 0.12);
            color: #7c3aed;
        }

        .notif-actions {
            display: flex;
            flex-direction: column;
            align-items: flex-end;
            gap: 10px;
            flex-shrink: 0;
        }

        .status-pill {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 14px;
            border-radius: 10px;
            font-size: 12px;
            font-weight: 700;
        }

        .status-pill.unread {
            background: rgba(239, 68, 68, 0.12);
            color: #dc2626;
        }

        .status-pill.read {
            background: rgba(22, 163, 74, 0.12);
            color: #16a34a;
        }

        .status-pill .dot {
            width: 7px;
            height: 7px;
            border-radius: 50%;
        }

        .status-pill.unread .dot {
            background: #dc2626;
            animation: pulse-dot 1.5s infinite;
        }

        .status-pill.read .dot {
            background: #16a34a;
        }

        @keyframes pulse-dot {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.3; }
        }

        .mark-read-btn {
            padding: 7px 14px;
            border: 1px solid #bbf7d0;
            background: #f0fdf4;
            border-radius: 10px;
            color: #15803d;
            font-size: 12px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.25s ease;
            font-family: 'Inter', sans-serif;
        }

        .mark-read-btn:hover {
            background: rgba(22, 163, 74, 0.2);
            border-color: #16a34a;
        }

        /* ── Empty State ── */
        .empty-state {
            text-align: center;
            padding: 60px 30px;
            background: #fafbfc;
            border: 2px dashed #d1d5db;
            border-radius: 24px;
        }

        .empty-state .empty-icon {
            width: 80px;
            height: 80px;
            margin: 0 auto 20px;
            background: #f1f5f9;
            border-radius: 24px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 36px;
        }

        .empty-state h3 {
            font-size: 22px;
            font-weight: 700;
            color: #0f172a;
            margin-bottom: 10px;
        }

        .empty-state p {
            color: #64748b;
            font-size: 15px;
            max-width: 400px;
            margin: 0 auto;
            line-height: 1.7;
        }

        /* ── Responsive ── */
        @media (max-width: 768px) {
            .stats-grid {
                grid-template-columns: 1fr;
            }

            .page-header h1 {
                font-size: 28px;
            }

            .top-nav {
                flex-direction: column;
                align-items: stretch;
            }

            .notif-card {
                flex-direction: column;
                gap: 14px;
            }

            .notif-actions {
                flex-direction: row;
                align-items: center;
            }

            .filter-bar {
                flex-direction: column;
                align-items: stretch;
            }
        }
    </style>
</head>
<body>

<div class="bg-glow"></div>
<div class="bg-glow-2"></div>

<div class="page-container">

    <!-- TOP NAV -->
    <nav class="top-nav">
        <a href="deliveryDashboard.jsp" class="back-btn">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" d="M10.5 19.5 3 12m0 0 7.5-7.5M3 12h18" />
            </svg>
            Back to Dashboard
        </a>
        <div class="user-badge">
            <div class="user-avatar"><%= username != null ? username.substring(0, 1).toUpperCase() : "D" %></div>
            <div class="user-info">
                <strong><%= username != null ? username : "Delivery Staff" %></strong>
                <span>Delivery Team</span>
            </div>
        </div>
    </nav>

    <!-- PAGE HEADER -->
    <div class="page-header">
        <div class="icon-wrap">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" d="M14.857 17.082a23.848 23.848 0 0 0 5.454-1.31A8.967 8.967 0 0 1 18 9.75V9A6 6 0 0 0 6 9v.75a8.967 8.967 0 0 1-2.312 6.022c1.733.64 3.56 1.085 5.455 1.31m5.714 0a24.255 24.255 0 0 1-5.714 0m5.714 0a3 3 0 1 1-5.714 0" />
            </svg>
        </div>
        <h1>Notification Center</h1>
        <p>All your delivery alerts and admin notifications in one place. Stay informed and never miss an update.</p>
    </div>

    <!-- STATS -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon total">📬</div>
            <h2><%= totalNotifications %></h2>
            <p>Total Alerts</p>
        </div>
        <div class="stat-card">
            <div class="stat-icon unread">🔴</div>
            <h2><%= unreadCount %></h2>
            <p>Unread</p>
        </div>
        <div class="stat-card">
            <div class="stat-icon read-icon">✅</div>
            <h2><%= readCount %></h2>
            <p>Read</p>
        </div>
    </div>

    <!-- FILTER BAR -->
    <div class="filter-bar">
        <div class="filter-tabs">
            <button class="filter-tab active" onclick="filterNotifs('all')">All</button>
            <button class="filter-tab" onclick="filterNotifs('unread')">Unread</button>
            <button class="filter-tab" onclick="filterNotifs('read')">Read</button>
        </div>
        <form action="NotificationServlet" method="post" style="margin:0;">
            <input type="hidden" name="action" value="markAllRead">
            <button type="submit" class="mark-all-btn">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75 11.25 15 15 9.75M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" />
                </svg>
                Mark All Read
            </button>
        </form>
    </div>

    <!-- NOTIFICATION LIST -->
    <div class="notification-list" id="notifList">
        <% if (notifications.isEmpty()) { %>
        <div class="empty-state">
            <div class="empty-icon">🔔</div>
            <h3>No notifications yet</h3>
            <p>Admin notifications and delivery alerts will appear here once they are sent. Check back later!</p>
        </div>
        <% } else {
            for (String[] n : notifications) {
                String title = n.length > 2 ? n[2] : "Notification";
                String message = n.length > 3 ? n[3] : "No details available.";
                String time = n.length > 4 ? n[4] : "Unknown time";
                String readFlag = n.length > 5 ? n[5].trim() : "unread";
                String recipientRaw = n.length > 1 ? n[1].trim() : "All";
                boolean isRead = "read".equalsIgnoreCase(readFlag);

                // Determine icon type
                String lower = title.toLowerCase();
                String iconClass = "type-default";
                String iconEmoji = "🔔";
                if (lower.contains("payment")) {
                    iconClass = "type-payment"; iconEmoji = "💳";
                } else if (lower.contains("delivery") || lower.contains("pickup") || lower.contains("dispatch")) {
                    iconClass = "type-delivery"; iconEmoji = "🚚";
                } else if (lower.contains("offer") || lower.contains("sale") || lower.contains("promo") || lower.contains("discount")) {
                    iconClass = "type-promo"; iconEmoji = "🎉";
                } else if (lower.contains("order") || lower.contains("package")) {
                    iconClass = "type-order"; iconEmoji = "📦";
                }

                String recipientBadgeClass = "Delivery".equalsIgnoreCase(recipientRaw) ? "badge-delivery" : "badge-all";
                String recipientLabel = "Delivery".equalsIgnoreCase(recipientRaw) ? "Delivery" : "All Users";
        %>
        <div class="notif-card <%= isRead ? "is-read" : "is-unread" %>" data-status="<%= isRead ? "read" : "unread" %>">
            <div class="notif-icon <%= iconClass %>">
                <%= iconEmoji %>
            </div>
            <div class="notif-body">
                <h3><%= title %></h3>
                <p class="notif-message"><%= message %></p>
                <div class="notif-meta">
                    <span class="notif-time">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M12 6v6h4.5m4.5 0a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" />
                        </svg>
                        <%= time %>
                    </span>
                    <span class="notif-recipient-badge <%= recipientBadgeClass %>">
                        <%= recipientLabel %>
                    </span>
                </div>
            </div>
            <div class="notif-actions">
                <% if (isRead) { %>
                <div class="status-pill read">
                    <span class="dot"></span> Read
                </div>
                <% } else { %>
                <div class="status-pill unread">
                    <span class="dot"></span> Unread
                </div>
                <form action="NotificationServlet" method="post" style="margin:0;">
                    <input type="hidden" name="action" value="markRead">
                    <input type="hidden" name="id" value="<%= n[0] %>">
                    <button type="submit" class="mark-read-btn">Mark Read</button>
                </form>
                <% } %>
            </div>
        </div>
        <% }
        } %>
    </div>

</div>

<script>
    function filterNotifs(type) {
        // Update active tab
        document.querySelectorAll('.filter-tab').forEach(function(tab) {
            tab.classList.remove('active');
        });
        event.target.classList.add('active');

        // Filter cards
        var cards = document.querySelectorAll('.notif-card');
        cards.forEach(function(card) {
            var status = card.getAttribute('data-status');
            if (type === 'all') {
                card.style.display = 'flex';
            } else if (type === 'unread' && status === 'unread') {
                card.style.display = 'flex';
            } else if (type === 'read' && status === 'read') {
                card.style.display = 'flex';
            } else {
                card.style.display = 'none';
            }
        });
    }
</script>

</body>
</html>
