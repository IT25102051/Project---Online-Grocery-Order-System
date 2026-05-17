<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CeylonFresh - Sri Lanka's Premium Online Grocery</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        :root {
            --primary: #064e3b;
            --primary-light: #10b981;
            --secondary: #fbbf24;
            --bg-color: #f8fafc;
            --text-main: #0f172a;
            --text-muted: #64748b;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Outfit', sans-serif;
        }

        body {
            background-color: var(--bg-color);
            color: var(--text-main);
            overflow-x: hidden;
        }

        /* Glassmorphism Navbar */
        .navbar {
            position: fixed;
            top: 0;
            width: 100%;
            padding: 20px 40px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: rgba(255, 255, 255, 0.8);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            z-index: 1000;
            box-shadow: 0 4px 30px rgba(0, 0, 0, 0.05);
        }

        .logo {
            font-size: 28px;
            font-weight: 800;
            color: var(--primary);
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .logo i { color: var(--primary-light); }

        .nav-menu a {
            text-decoration: none;
            color: var(--text-main);
            margin-left: 30px;
            font-weight: 500;
            font-size: 16px;
            transition: all 0.3s;
        }

        .nav-menu a:hover {
            color: var(--primary-light);
        }

        .nav-btn {
            background: linear-gradient(135deg, var(--primary-light), var(--primary));
            color: white !important;
            padding: 10px 24px;
            border-radius: 99px;
            box-shadow: 0 10px 20px rgba(16, 185, 129, 0.3);
        }
        .nav-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 14px 25px rgba(16, 185, 129, 0.4);
        }

        /* Hero Section */
        .hero {
            padding: 160px 40px 100px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            max-width: 1300px;
            margin: 0 auto;
            gap: 60px;
        }

        .hero-content {
            flex: 1;
            animation: fadeUp 1s ease forwards;
        }

        .badge {
            display: inline-block;
            background: #d1fae5;
            color: #047857;
            padding: 8px 16px;
            border-radius: 99px;
            font-weight: 600;
            font-size: 14px;
            margin-bottom: 24px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .hero-content h1 {
            font-size: 64px;
            line-height: 1.1;
            font-weight: 800;
            margin-bottom: 24px;
            color: var(--primary);
        }
        .hero-content h1 span {
            color: var(--primary-light);
        }

        .hero-copy {
            font-size: 18px;
            color: var(--text-muted);
            line-height: 1.7;
            margin-bottom: 40px;
            max-width: 500px;
        }

        .hero-buttons {
            display: flex;
            gap: 20px;
        }

        .primary-btn {
            background: var(--primary);
            color: white;
            padding: 16px 36px;
            border-radius: 99px;
            text-decoration: none;
            font-weight: 600;
            font-size: 18px;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            transition: all 0.3s;
            box-shadow: 0 15px 30px rgba(6, 78, 59, 0.3);
        }
        .primary-btn:hover {
            background: #022c22;
            transform: translateY(-3px);
            box-shadow: 0 20px 40px rgba(6, 78, 59, 0.4);
        }

        .secondary-btn {
            background: white;
            color: var(--primary);
            padding: 16px 36px;
            border-radius: 99px;
            text-decoration: none;
            font-weight: 600;
            font-size: 18px;
            border: 2px solid var(--primary);
            transition: all 0.3s;
        }
        .secondary-btn:hover {
            background: var(--primary);
            color: white;
        }

        .hero-image {
            flex: 1;
            position: relative;
            animation: fadeLeft 1s ease forwards;
        }
        .hero-image img {
            width: 100%;
            border-radius: 40px;
            box-shadow: 0 30px 60px rgba(0,0,0,0.15);
        }

        .floating-card {
            position: absolute;
            bottom: -30px;
            left: -30px;
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(10px);
            padding: 20px 30px;
            border-radius: 24px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            display: flex;
            align-items: center;
            gap: 15px;
            animation: float 4s ease-in-out infinite;
        }
        .floating-card i {
            font-size: 30px;
            color: var(--secondary);
        }
        .floating-card div {
            font-weight: 700;
            color: var(--primary);
        }
        .floating-card span {
            display: block;
            font-size: 14px;
            color: var(--text-muted);
            font-weight: 500;
        }

        /* Features */
        .features {
            background: white;
            padding: 100px 40px;
        }
        .section-header {
            text-align: center;
            margin-bottom: 60px;
        }
        .section-header h2 {
            font-size: 42px;
            color: var(--primary);
            margin-bottom: 16px;
        }
        .section-header p {
            font-size: 18px;
            color: var(--text-muted);
        }

        .feature-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 40px;
            max-width: 1200px;
            margin: 0 auto;
        }

        .feature-card {
            background: var(--bg-color);
            padding: 40px;
            border-radius: 30px;
            text-align: center;
            transition: all 0.4s ease;
            border: 1px solid transparent;
        }
        .feature-card:hover {
            transform: translateY(-10px);
            background: white;
            border-color: #e2e8f0;
            box-shadow: 0 30px 60px rgba(0,0,0,0.05);
        }
        .feature-icon {
            width: 80px;
            height: 80px;
            background: #d1fae5;
            color: var(--primary-light);
            border-radius: 24px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 32px;
            margin: 0 auto 24px;
            transition: transform 0.3s;
        }
        .feature-card:hover .feature-icon {
            transform: scale(1.1) rotate(5deg);
        }
        .feature-card h3 {
            font-size: 22px;
            margin-bottom: 16px;
            color: var(--text-main);
        }
        .feature-card p {
            color: var(--text-muted);
            line-height: 1.6;
        }

        /* Animations */
        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(40px); }
            to { opacity: 1; transform: translateY(0); }
        }
        @keyframes fadeLeft {
            from { opacity: 0; transform: translateX(40px); }
            to { opacity: 1; transform: translateX(0); }
        }
        @keyframes float {
            0% { transform: translateY(0px); }
            50% { transform: translateY(-15px); }
            100% { transform: translateY(0px); }
        }
    </style>
</head>
<body>

<header class="navbar">
    <div class="logo"><i class="fa-solid fa-leaf"></i> CeylonFresh</div>
    <nav class="nav-menu">
        <a href="products.jsp">Categories</a>
        <a href="#features">Why Us</a>
        <a href="login.jsp" style="font-weight:600;">Sign In</a>
        <a href="register.jsp" class="nav-btn">Get Started</a>
    </nav>
</header>

<section class="hero">
    <div class="hero-content">
        <span class="badge">Sri Lanka's #1 Online Grocery</span>
        <h1>Fresh from the farm to your <span>doorstep.</span></h1>
        <p class="hero-copy">Skip the traffic and long queues. Get fresh Keeri Samba, Ceylon Tea, vegetables, and daily essentials delivered anywhere in Colombo.</p>
        <div class="hero-buttons">
            <a class="primary-btn" href="products.jsp">Shop Now <i class="fa-solid fa-arrow-right"></i></a>
            <a class="secondary-btn" href="register.jsp">Create Account</a>
        </div>
    </div>
    <div class="hero-image">
        <img src="https://images.unsplash.com/photo-1542838132-92c53300491e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1674&q=80" alt="Fresh Sri Lankan Groceries">
        <div class="floating-card">
            <i class="fa-solid fa-star"></i>
            <div>
                4.9/5 Rating
                <span>From 20,000+ Lankans</span>
            </div>
        </div>
    </div>
</section>

<section id="categories" class="features" style="background:#f1f5f9; padding-top:40px;">
    <div class="section-header">
        <span class="badge" style="background:#dbeafe; color:#2563eb;">Product Catalog</span>
        <h2>Explore our categories</h2>
        <p>Everything you need, organized for your convenience.</p>
    </div>
    <div class="feature-grid" style="grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));">
        <a href="products.jsp?category=Rice%20%26%20Grains" class="feature-card" style="padding:0; overflow:hidden; text-decoration:none;">
            <div style="height:200px; overflow:hidden;">
                <img src="https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&w=800&q=80" style="width:100%; height:100%; object-fit:cover; transition:0.5s;" onmouseover="this.style.transform='scale(1.1)'" onmouseout="this.style.transform='scale(1)'">
            </div>
            <div style="padding:20px;">
                <h3>Rice & Grains</h3>
                <p>Authentic Sri Lankan staples</p>
            </div>
        </a>
        <a href="products.jsp?category=Produce" class="feature-card" style="padding:0; overflow:hidden; text-decoration:none;">
            <div style="height:200px; overflow:hidden;">
                <img src="https://images.unsplash.com/photo-1610348725531-843dff563e2c?auto=format&fit=crop&w=800&q=80" style="width:100%; height:100%; object-fit:cover; transition:0.5s;" onmouseover="this.style.transform='scale(1.1)'" onmouseout="this.style.transform='scale(1)'">
            </div>
            <div style="padding:20px;">
                <h3>Fresh Produce</h3>
                <p>Farm-fresh vegetables & fruits</p>
            </div>
        </a>
        <a href="products.jsp?category=Dairy" class="feature-card" style="padding:0; overflow:hidden; text-decoration:none;">
            <div style="height:200px; overflow:hidden;">
                <img src="https://smallscalefarms.ca/cdn/shop/collections/1_240x240_f79d8fce-e554-4dd0-bb20-3a1f5e861941_1024x1024.png?v=1773447782" style="width:100%; height:100%; object-fit:cover; transition:0.5s;" onmouseover="this.style.transform='scale(1.1)'" onmouseout="this.style.transform='scale(1)'">
            </div>
            <div style="padding:20px;">
                <h3>Dairy & Eggs</h3>
                <p>Milk, butter, and farm eggs</p>
            </div>
        </a>
        <a href="products.jsp?category=Beverages" class="feature-card" style="padding:0; overflow:hidden; text-decoration:none;">
            <div style="height:200px; overflow:hidden;">
                <img src="https://images.unsplash.com/photo-1625772299848-391b6a87d7b3?auto=format&fit=crop&w=800&q=80" style="width:100%; height:100%; object-fit:cover; transition:0.5s;" onmouseover="this.style.transform='scale(1.1)'" onmouseout="this.style.transform='scale(1)'">
            </div>
            <div style="padding:20px;">
                <h3>Tea & Beverages</h3>
                <p>Ceylon tea, juices, and more</p>
            </div>
        </a>
        <a href="products.jsp?category=Snacks" class="feature-card" style="padding:0; overflow:hidden; text-decoration:none;">
            <div style="height:200px; overflow:hidden;">
                <img src="https://www.britishcornershop.co.uk/assets/img/collections/one-col/best-of-british-one-col.jpg" style="width:100%; height:100%; object-fit:cover; transition:0.5s;" onmouseover="this.style.transform='scale(1.1)'" onmouseout="this.style.transform='scale(1)'">
            </div>
            <div style="padding:20px;">
                <h3>Snacks & Sweets</h3>
                <p>Treats for every occasion</p>
            </div>
        </a>
        <a href="products.jsp?category=Pantry" class="feature-card" style="padding:0; overflow:hidden; text-decoration:none;">
            <div style="height:200px; overflow:hidden;">
                <img src="https://www.allrecipes.com/thmb/q75xkm9Q_Du0U4t9QEFFNL-Umsg=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/pantry-items-2000-3e4035faae884c508a1455ce50391bcb.jpg" style="width:100%; height:100%; object-fit:cover; transition:0.5s;" onmouseover="this.style.transform='scale(1.1)'" onmouseout="this.style.transform='scale(1)'">
            </div>
            <div style="padding:20px;">
                <h3>Pantry Essentials</h3>
                <p>Spices, sauces, and cooking oils</p>
            </div>
        </a>
    </div>
</section>

<footer style="background:var(--primary); color:white; padding:60px 40px; text-align:center;">
    <div class="logo" style="justify-content:center; margin-bottom:20px;"><i class="fa-solid fa-leaf"></i> CeylonFresh</div>
    <p style="opacity:0.7; max-width:600px; margin:0 auto 30px;">Your trusted partner for fresh groceries in Sri Lanka. We deliver quality, convenience, and health to your home.</p>
    <div style="border-top:1px solid rgba(255,255,255,0.1); padding-top:30px; font-size:14px; opacity:0.6;">
        &copy; 2026 CeylonFresh. All rights reserved.
    </div>
</footer>

</body>
</html>
