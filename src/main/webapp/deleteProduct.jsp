<%@ page import="java.io.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>

    <title>Delete Products</title>

    <style>

        *{
            margin:0;
            padding:0;
            box-sizing:border-box;
            font-family:'Segoe UI',sans-serif;
        }

        body{
            background:#f3fef5;
            padding:40px;
        }

        .container{
            max-width:1200px;
            margin:auto;
        }

        .top-bar{
            display:flex;
            justify-content:space-between;
            align-items:center;
            margin-bottom:40px;
        }

        .top-bar h1{
            color:#14532d;
            font-size:42px;
        }

        .back-btn{
            background:#16a34a;
            color:white;
            padding:12px 25px;
            border-radius:12px;
            text-decoration:none;
            font-weight:bold;
        }

        .products-grid{
            display:grid;
            grid-template-columns:
            repeat(auto-fit,minmax(320px,1fr));
            gap:30px;
        }

        .card{
            background:white;
            border-radius:25px;
            overflow:hidden;
            box-shadow:0 10px 25px rgba(0,0,0,0.08);
            transition:0.3s;
        }

        .card:hover{
            transform:translateY(-5px);
        }

        .card img{
            width:100%;
            height:220px;
            object-fit:cover;
        }

        .card-content{
            padding:25px;
        }

        .category{
            background:#dcfce7;
            color:#166534;
            display:inline-block;
            padding:8px 16px;
            border-radius:20px;
            font-size:14px;
            margin-bottom:15px;
            font-weight:bold;
        }

        .product-name{
            font-size:28px;
            color:#14532d;
            margin-bottom:10px;
            font-weight:bold;
        }

        .price{
            color:#16a34a;
            font-size:24px;
            font-weight:bold;
            margin-bottom:20px;
        }

        .delete-btn{
            width:100%;
            padding:14px;
            border:none;
            border-radius:12px;
            background:#dc2626;
            color:white;
            font-size:16px;
            font-weight:bold;
            cursor:pointer;
            transition:0.3s;
        }

        .delete-btn:hover{
            background:#b91c1c;
        }

        .empty{
            background:white;
            padding:40px;
            border-radius:20px;
            text-align:center;
            color:#6b7280;
            font-size:20px;
        }

    </style>

</head>

<body>

<div class="container">

    <div class="top-bar">

        <h1>
            🗑 Delete Products
        </h1>

        <a href="adminProducts.jsp"
           class="back-btn">

            ← Back

        </a>

    </div>

    <div class="products-grid">

        <%

            String filePath =
                    application.getRealPath("/") +
                    "data/products.txt";

            File file = new File(filePath);

            if(file.exists()){

                BufferedReader br =
                        new BufferedReader(
                                new FileReader(file));

                String line;

                while((line = br.readLine()) != null){

                    String[] data =
                            line.split(",", -1);

                    if(data.length >= 5){

        %>

        <div class="card">

            <img src="<%= data[5] %>"
                 alt="Product Image">

            <div class="card-content">

                <div class="category">
                    <%= data[2] %>
                </div>

                <div class="product-name">
                    <%= data[1] %>
                </div>

                <div class="price">
                    Rs. <%= data[3] %>
                </div>

                <form action="DeleteProductServlet"
                      method="post">

                    <input type="hidden"
                           name="productName"
                           value="<%= data[0] %>">

                    <button type="submit"
                            class="delete-btn">

                        Delete Product

                    </button>

                </form>

            </div>

        </div>

        <%

                    }
                }

                br.close();

            }else{

        %>

        <div class="empty">

            No products available.

        </div>

        <%

            }

        %>

    </div>

</div>

</body>
</html>
