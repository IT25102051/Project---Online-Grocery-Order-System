<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="com.grocery.dao.ProductDAO" %>
<%
    String adminName = (String) session.getAttribute("username");
    String adminRole = (String) session.getAttribute("role");
    if (adminName == null || !"Admin".equalsIgnoreCase(adminRole)) {
        response.sendRedirect("adminLogin.jsp");
        return;
    }

    ProductDAO dao = new ProductDAO(application.getRealPath("/"));
    List<String> products = dao.getAllProducts();
    int totalProducts = products.size();
    Set<String> categories = new HashSet<>();
    int lowStockCount = 0;
    for (String line : products) {
        String[] p = line.split(",", -1);
        if (p.length < 5) continue;
        categories.add(p[2].trim());
        try {
            if (Integer.parseInt(p[4].trim()) < 20) lowStockCount++;
        } catch (Exception ignored) {}
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Products - CeylonFresh Admin</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f3f6fb; display: flex; min-height: 100vh; color: #334155; }
        .sidebar { width: 260px; background: linear-gradient(135deg,#0f766e 0%,#16a34a 100%); color: white; padding: 20px 0; position: fixed; height: 100vh; overflow-y: auto; box-shadow: 2px 0 18px rgba(15,23,42,0.12); }
        .sidebar-brand { text-align: center; padding: 24px 20px; border-bottom: 1px solid rgba(255,255,255,0.18); margin-bottom: 20px; }
        .logo-text { font-size: 26px; font-weight: 800; color: white; letter-spacing: 1px; }
        .logo-text span { color: #fbbf24; }
        .logo-sub { font-size: 12px; color: rgba(255,255,255,0.72); margin-top: 6px; letter-spacing: 0.5px; }
        .sidebar-admin { display: flex; align-items: center; gap: 12px; padding: 18px 20px; border-bottom: 1px solid rgba(255,255,255,0.18); margin-bottom: 18px; }
        .sa-avatar { width: 44px; height: 44px; background: #fde047; color: #0f172a; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 18px; }
        .sa-info strong { display: block; font-size: 14px; line-height: 1.2; }
        .sa-info span { font-size: 12px; color: rgba(255,255,255,0.78); }
        .nav-section { padding: 14px 20px 6px; font-size: 11px; text-transform: uppercase; color: rgba(255,255,255,0.65); letter-spacing: 1px; }
        .sidebar a { display: block; color: white; text-decoration: none; padding: 13px 20px; transition: all 0.25s ease-in-out; border-left: 3px solid transparent; font-size: 14px; }
        .sidebar a:hover, .sidebar a.active { background: rgba(255,255,255,0.12); border-left-color: #fbbf24; }
        .sidebar a i { width: 20px; margin-right: 12px; }
        .sidebar-footer { position: absolute; bottom: 0; width: 100%; padding: 20px; }
        .logout-btn { display: block; background: rgba(255,255,255,0.12); border: 1px solid rgba(255,255,255,0.22); border-radius: 10px; padding: 12px 14px; text-align: center; color: white; font-weight: 600; }
        .logout-btn:hover { background: rgba(255,255,255,0.18); }
        .main { margin-left: 260px; flex: 1; }
        .topbar { background: white; padding: 24px 30px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #e2e8f0; }
        .topbar-left h2 { margin: 0; color: #0f172a; font-size: 26px; letter-spacing: -0.02em; }
        .breadcrumb { color: #64748b; font-size: 13px; margin-top: 8px; }
        .topbar-right { display: flex; align-items: center; gap: 14px; }
        .topbar-date { color: #475569; font-size: 14px; padding: 10px 14px; background: #f8fafc; border-radius: 10px; display: flex; align-items: center; gap: 8px; }
        .logout-link { color: #ef4444; text-decoration: none; font-size: 14px; font-weight: 700; padding: 10px 16px; background: #fef2f2; border: 1px solid #fee2e2; border-radius: 10px; display: flex; align-items: center; gap: 8px; transition: all 0.2s; }
        .logout-link:hover { background: #fee2e2; transform: translateY(-1px); }
        .notif-btn { background: #16a34a; color: white; border: none; padding: 11px 16px; border-radius: 10px; cursor: pointer; font-weight: 600; }
        .content { padding: 30px; }
        .stat-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 20px; margin-bottom: 28px; }
        .stat-card { background: white; padding: 24px; border-radius: 18px; box-shadow: 0 18px 40px rgba(15,23,42,0.06); border: 1px solid rgba(148,163,184,0.12); }
        .stat-top { display: flex; align-items: center; justify-content: space-between; margin-bottom: 18px; }
        .stat-icon { width: 52px; height: 52px; border-radius: 14px; display: flex; align-items: center; justify-content: center; color: white; font-size: 20px; }
        .stat-icon.blue { background: #2563eb; }
        .stat-icon.green { background: #16a34a; }
        .stat-icon.orange { background: #f97316; }
        .stat-num { font-size: 32px; font-weight: 800; color: #0f172a; margin-bottom: 6px; }
        .stat-label { color: #64748b; font-size: 14px; }
        .dashboard-grid { display: grid; grid-template-columns: 360px minmax(0, 1fr); gap: 24px; align-items: start; }
        .panel { background: white; border-radius: 20px; box-shadow: 0 18px 40px rgba(15,23,42,0.06); border: 1px solid rgba(148,163,184,0.12); overflow: hidden; }
        .panel-header { padding: 24px 28px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; }
        .panel-header h3 { margin: 0; font-size: 20px; color: #0f172a; }
        .panel-header span { color: #64748b; font-size: 14px; }
        .panel-body { padding: 24px 28px 28px; }
        .form-group { margin-bottom: 18px; }
        .form-group label { display: block; font-weight: 700; margin-bottom: 8px; color: #0f172a; }
        .form-group input { width: 100%; padding: 14px 16px; border-radius: 14px; border: 1px solid #cbd5e1; font-size: 14px; color: #0f172a; background: #f8fafc; }
        .form-group input:focus { outline: none; border-color: #16a34a; background: white; }
        .form-actions { display: flex; gap: 14px; flex-wrap: wrap; margin-top: 10px; }
        .btn { display: inline-flex; align-items: center; justify-content: center; gap: 10px; border: none; border-radius: 14px; padding: 14px 18px; background: #16a34a; color: white; font-weight: 700; cursor: pointer; transition: background 0.25s ease; }
        .btn:hover { background: #15803d; }
        .btn-secondary { background: #475569; }
        .btn-secondary:hover { background: #334155; }
        .table-wrap { overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; min-width: 720px; }
        th, td { text-align: left; padding: 16px 18px; border-bottom: 1px solid #e2e8f0; }
        thead th { color: #334155; font-size: 14px; text-transform: uppercase; letter-spacing: 0.08em; border-bottom: 2px solid #e2e8f0; }
        tbody tr:hover { background: #f8fafc; }
        .product-name { font-weight: 700; color: #0f172a; }
        .badge { display: inline-flex; align-items: center; gap: 6px; padding: 6px 12px; border-radius: 999px; font-size: 12px; font-weight: 700; color: #0f172a; background: #f8fafc; }
        .badge.low { color: #b91c1c; background: #fee2e2; }
        .action-buttons { display: flex; gap: 10px; flex-wrap: wrap; }
        .action-buttons button { padding: 10px 14px; border-radius: 12px; border: none; cursor: pointer; font-size: 13px; }
        .btn-edit { background: #3b82f6; color: white; }
        .btn-delete { background: #ef4444; color: white; }
        .empty-state { padding: 40px; color: #64748b; text-align: center; }
    </style>
</head>
<body>
<div class="sidebar">
    <div class="sidebar-brand">
        <div class="logo-text">Fresh<span>Cart</span></div>
        <div class="logo-sub">Admin Panel</div>
    </div>
    <div class="sidebar-admin">
        <div class="sa-avatar"><%= adminName.substring(0,1).toUpperCase() %></div>
        <div class="sa-info">
            <strong><%= adminName %></strong>
            <span>Administrator</span>
        </div>
    </div>
    <div class="nav-section">Main</div>
    <a href="adminDashboard.jsp"><i class="fa-solid fa-gauge"></i> Dashboard</a>
    <div class="nav-section">Manage</div>
    <a href="adminProducts.jsp" class="active"><i class="fa-solid fa-box"></i> Products</a>
    <a href="adminUsers.jsp"><i class="fa-solid fa-users"></i> Users</a>
    <a href="adminOrders.jsp"><i class="fa-solid fa-shopping-cart"></i> Orders</a>
    <a href="adminPayments.jsp"><i class="fa-solid fa-credit-card"></i> Payments</a>
    <a href="inventory.jsp"><i class="fa-solid fa-warehouse"></i> Inventory</a>
    <div class="nav-section">Content</div>
    <a href="adminReviews.jsp"><i class="fa-solid fa-star"></i> Reviews</a>
    <a href="adminNotifications.jsp"><i class="fa-solid fa-bell"></i> Notifications</a>
    <div class="sidebar-footer">
        <div style="font-size: 11px; color: rgba(255,255,255,0.5); text-align: center;">&copy; 2026 CeylonFresh Admin</div>
    </div>
</div>
<div class="main">
    <div class="topbar">
        <div class="topbar-left">
            <h2>Manage Products</h2>
            <div class="breadcrumb">Admin / Products</div>
        </div>
        <div class="topbar-right">
            <div class="topbar-date"><i class="fa-solid fa-calendar-days"></i> <%= new java.util.Date().toString().substring(0, 10) %></div>
            <a href="LogoutServlet" class="logout-link" title="Sign Out">
                <i class="fa-solid fa-right-from-bracket"></i> Logout
            </a>
            <button class="notif-btn" onclick="resetProductForm(); document.getElementById('product-name').focus();">
                <i class="fa-solid fa-plus"></i> Add New
            </button>
        </div>
    </div>
    <div class="content">
        <div class="stat-grid">
            <div class="stat-card">
                <div class="stat-top">
                    <div class="stat-icon blue"><i class="fa-solid fa-box-open"></i></div>
                </div>
                <div class="stat-num"><%= totalProducts %></div>
                <div class="stat-label">Total Products</div>
            </div>
            <div class="stat-card">
                <div class="stat-top">
                    <div class="stat-icon green"><i class="fa-solid fa-tags"></i></div>
                </div>
                <div class="stat-num"><%= categories.size() %></div>
                <div class="stat-label">Categories</div>
            </div>
            <div class="stat-card">
                <div class="stat-top">
                    <div class="stat-icon orange"><i class="fa-solid fa-chart-line"></i></div>
                </div>
                <div class="stat-num"><%= lowStockCount %></div>
                <div class="stat-label">Low Stock Items</div>
            </div>
        </div>
        <div class="dashboard-grid">
            <div class="panel">
                <div class="panel-header">
                    <h3>Add / Update Product</h3>
                    <% if (request.getParameter("msg") != null) { %>
                        <span style="color: #16a34a; font-weight: 700; background: #dcfce7; padding: 4px 12px; border-radius: 8px;">
                            <i class="fa-solid fa-check"></i> <%= request.getParameter("msg") %>
                        </span>
                    <% } else { %>
                        <span>Quick create or modify stock</span>
                    <% } %>
                </div>
                <div class="panel-body">
                    <form id="product-form" action="product" method="post">
                        <input type="hidden" id="product-action" name="action" value="add">
                        <input type="hidden" id="product-id" name="id" value="">
                        <div class="form-group">
                            <label id="form-title">Add Product</label>
                            <input id="product-name" name="name" placeholder="Fresh Organic Avocado" required>
                        </div>
                        <div class="form-group">
                            <label>Category</label>
                            <select id="product-category" name="category" required style="width: 100%; padding: 14px 16px; border-radius: 14px; border: 1px solid #cbd5e1; font-size: 14px; color: #0f172a; background: #f8fafc; outline: none; appearance: none; -webkit-appearance: none; -moz-appearance: none;">
                                <option value="" disabled selected>Select Category</option>
                                <option value="Produce">Produce</option>
                                <option value="Dairy">Dairy</option>
                                <option value="Beverages">Beverages</option>
                                <option value="Snacks">Snacks</option>
                                <option value="Spices">Spices</option>
                                <option value="Pantry">Pantry</option>
                                <option value="Rice & Grains">Rice & Grains</option>
                                <option value="Desserts">Desserts</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Price</label>
                            <input id="product-price" name="price" type="number" step="0.01" min="0.01" placeholder="12.99" required>
                        </div>
                        <div class="form-group">
                            <label>Stock</label>
                            <input id="product-stock" name="stock" type="number" min="0" placeholder="100" required>
                        </div>
                        <div class="form-group">
                            <label>Image URL</label>
                            <input id="product-image" name="image" type="url" placeholder="https://..." required>
                        </div>
                        <div class="form-group">
                            <label>Description</label>
                            <input id="product-description" name="description" type="text" placeholder="Fresh farm produce">
                        </div>
                        <div class="form-group">
                            <label>Expiry Date</label>
                            <input id="product-expiry" name="expiryDate" type="date">
                        </div>
                        <div class="form-actions">
                            <button id="submit-btn" class="btn" type="submit"><i class="fa-solid fa-plus"></i> Add Product</button>
                            <button class="btn btn-secondary" type="button" onclick="resetProductForm()">Clear</button>
                        </div>
                    </form>
                </div>
            </div>
            <div class="panel">
                <div class="panel-header">
                    <h3>Product Catalog</h3>
                    <span>Manage inventory from a single dashboard</span>
                </div>
                <div class="panel-body">
                    <div class="table-wrap">
                        <table>
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>Product</th>
                                    <th>Category</th>
                                    <th>Price</th>
                                    <th>Stock</th>
                                    <th>Expiry</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (products.isEmpty()) { %>
                                <tr><td colspan="6" class="empty-state">No products found. Add your first item to populate the catalog.</td></tr>
                                <% } else {
                                    int index = 1;
                                    for (String line : products) {
                                        String[] p = line.split(",", -1);
                                        if (p.length < 6) continue;
                                        String id = p[0].trim();
                                        String name = p[1].trim();
                                        String category = p[2].trim();
                                        String price = p[3].trim();
                                        String stock = p[4].trim();
                                        String image = p[5].trim();
                                        String description = p.length > 6 ? p[6].trim() : "";
                                        String expiry = p.length > 7 ? p[7].trim() : "N/A";
                                    %>
                                <tr>
                                    <td><%= index++ %></td>
                                    <td><div class="product-name"><%= name %></div></td>
                                    <td><span class="badge"><i class="fa-solid fa-tag"></i> <%= category %></span></td>
                                    <td>Rs. <%= price %></td>
                                    <td><%= stock %> <%= Integer.parseInt(stock.isEmpty() ? "0" : stock) < 20 ? "<span class=\"badge low\">Low</span>" : "" %></td>
                                    <td><%= expiry %></td>
                                    <td>
                                        <div class="action-buttons">
                                            <button class="btn btn-secondary" type="button" onclick="editProduct('<%= id %>', '<%= name.replace("'", "\\'") %>', '<%= price %>', '<%= stock %>', '<%= category.replace("'", "\\'") %>', '<%= image.replace("'", "\\'") %>', '<%= description.replace("'", "\\'") %>', '<%= expiry %>')">
                                                <i class="fa-solid fa-pen"></i> Edit
                                            </button>
                                            <form action="product" method="post" style="display:inline-flex; gap:10px; margin:0;">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="id" value="<%= id %>">
                                                <button class="btn btn-delete" type="submit">Delete</button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                                <% }
                                } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<script>
function editProduct(id, name, price, stock, category, image, description, expiry) {
            document.getElementById('product-id').value = id;
            document.getElementById('product-name').value = name;
            document.getElementById('product-category').value = category;
            document.getElementById('product-price').value = price;
            document.getElementById('product-stock').value = stock;
            document.getElementById('product-image').value = image || '';
            document.getElementById('product-description').value = description || '';
            document.getElementById('product-expiry').value = expiry !== 'N/A' ? expiry : '';
        document.getElementById('product-action').value = 'update';
        document.getElementById('form-title').innerText = 'Edit Product';
        document.getElementById('submit-btn').innerHTML = '<i class="fa-solid fa-pen"></i> Update Product';
    }

    function resetProductForm() {
        document.getElementById('product-form').reset();
        document.getElementById('product-id').value = '';
        document.getElementById('product-action').value = 'add';
        document.getElementById('form-title').innerText = 'Add Product';
        document.getElementById('submit-btn').innerHTML = '<i class="fa-solid fa-plus"></i> Add Product';
    }
</script>
</body>
</html>
