<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.io.*" %>

<!DOCTYPE html>
<html>
<head>

    <title>Update Products</title>

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
            max-width:1300px;
            margin:auto;
        }

        .top-bar{
            display:flex;
            justify-content:space-between;
            align-items:center;
            margin-bottom:40px;
        }

        .top-bar h1{
            font-size:42px;
            color:#14532d;
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
            repeat(auto-fit,minmax(350px,1fr));
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

        .content{
            padding:25px;
        }

        .title{
            font-size:28px;
            color:#14532d;
            margin-bottom:20px;
            font-weight:bold;
        }

        input{
            width:100%;
            padding:14px;
            margin-bottom:15px;
            border:1px solid #ccc;
            border-radius:12px;
            font-size:15px;
        }

        .update-btn{
            width:100%;
            padding:15px;
            background:#2563eb;
            color:white;
            border:none;
            border-radius:12px;
            font-size:16px;
            font-weight:bold;
            cursor:pointer;
            transition:0.3s;
        }

        .update-btn:hover{
            background:#1d4ed8;
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
            ✏️ Update Products
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

                    if(data.length >= 6){

        %>

        <div class="card">

            <img src="<%= data[5] %>"
                 alt="Product Image">

            <div class="content">

                <div class="title">
                    <%= data[1] %>
                </div>

                <form action="UpdateProductServlet"
                      method="post">

                    <input type="hidden"
                           name="oldName"
                           value="<%= data[0] %>">

                    <input type="text"
                           name="name"
                           value="<%= data[1] %>"
                           required>

                    <input type="text"
                           name="category"
                           value="<%= data[2] %>"
                           required>

                    <input type="text"
                           name="price"
                           value="<%= data[3] %>"
                           required>

                    <input type="text"
                           name="stock"
                           value="<%= data[4] %>"
                           required>

                    <input type="text"
                           name="image"
                           value="<%= data[5] %>"
                           required>

                    <input type="text"
                           name="description"
                           value="<%= data.length > 6 ? data[6] : "" %>"
                           placeholder="Description">

                    <button type="submit"
                            class="update-btn">

                        Update Product

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
