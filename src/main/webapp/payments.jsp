<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Payments - CeylonFresh</title>

    <style>

        *{
            margin:0;
            padding:0;
            box-sizing:border-box;
            font-family:'Segoe UI',sans-serif;
        }

        body{
            background:#f0fdf4;
        }

        .navbar{
            background:white;
            padding:20px 60px;
            display:flex;
            justify-content:space-between;
            align-items:center;
            box-shadow:0 5px 20px rgba(0,0,0,0.08);
        }

        .logo{
            font-size:30px;
            font-weight:bold;
            color:#15803d;
        }

        .nav-links a{
            margin-left:25px;
            text-decoration:none;
            color:#374151;
            font-weight:600;
        }

        .container{
            padding:50px 70px;
        }

        .header{
            margin-bottom:35px;
        }

        .header h1{
            font-size:50px;
            color:#14532d;
        }

        .header p{
            color:#6b7280;
            margin-top:10px;
            font-size:18px;
        }

        .payment-grid{
            display:grid;
            grid-template-columns:repeat(auto-fit,minmax(320px,1fr));
            gap:25px;
        }

        .payment-card{
            background:white;
            padding:30px;
            border-radius:25px;
            box-shadow:0 10px 25px rgba(0,0,0,0.08);
            transition:0.3s;
        }

        .payment-card:hover{
            transform:translateY(-5px);
        }

        .payment-icon{
            font-size:50px;
            margin-bottom:20px;
        }

        .payment-card h2{
            color:#15803d;
            margin-bottom:15px;
            font-size:30px;
        }

        .payment-card p{
            color:#6b7280;
            line-height:1.7;
            margin-bottom:20px;
        }

        .status{
            display:inline-block;
            padding:8px 16px;
            border-radius:20px;
            background:#16a34a;
            color:white;
            font-size:14px;
            font-weight:bold;
        }

        .pay-btn{
            width:100%;
            margin-top:25px;
            padding:14px;
            border:none;
            border-radius:14px;
            background:#16a34a;
            color:white;
            font-weight:bold;
            cursor:pointer;
            font-size:16px;
        }

        .pay-btn:hover{
            background:#15803d;
        }

        @media(max-width:900px){

            .navbar{
                flex-direction:column;
                gap:20px;
                padding:20px;
            }

            .container{
                padding:30px;
            }
        }

    </style>

</head>

<body>

<div class="navbar">

    <div class="logo">
        🛒 CeylonFresh
    </div>

    <div class="nav-links">

        <a href="customerDashboard.jsp">Dashboard</a>

        <a href="products.jsp">Products</a>

        <a href="cart.jsp">Cart</a>

        <a href="orders.jsp">Orders</a>

        <a href="LogoutServlet">Logout</a>

    </div>

</div>

<div class="container">

    <div class="header">

        <h1>Payments</h1>

        <p>
            Manage your grocery payment methods and transactions.
        </p>

    </div>

    <div class="payment-grid">

        <!-- COD -->

        <div class="payment-card">

            <div class="payment-icon">💵</div>

            <h2>Cash On Delivery</h2>

            <p>
                Pay directly when your grocery order arrives.
            </p>

            <span class="status">
                Active
            </span>

            <form action="PaymentHistoryServlet" method="post">

                <input type="hidden"
                       name="method"
                       value="Cash On Delivery">

                <button class="pay-btn" type="submit">

                    Continue Payment

                </button>

            </form>

        </div>

        <!-- Credit Card -->

        <div class="payment-card">

            <div class="payment-icon">💳</div>

            <h2>Credit Card</h2>

            <p>
                Secure payment using Visa,
                MasterCard or Amex.
            </p>

            <span class="status">
                Secure
            </span>

            <form action="PaymentHistoryServlet" method="post">

                <input type="hidden"
                       name="method"
                       value="Credit Card">

                <button class="pay-btn" type="submit">

                    Continue Payment

                </button>

            </form>

        </div>

    </div>
</body>
</html>
