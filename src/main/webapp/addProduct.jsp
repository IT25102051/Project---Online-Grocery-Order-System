<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Add Product</title>

    <style>

        body{
            font-family:Segoe UI;
            background:#f3fef5;
            padding:50px;
        }

        .form-box{
            max-width:600px;
            margin:auto;
            background:white;
            padding:40px;
            border-radius:25px;
            box-shadow:0 10px 25px rgba(0,0,0,0.08);
        }

        h1{
            color:#14532d;
            margin-bottom:30px;
        }

        input{
            width:100%;
            padding:16px;
            margin-bottom:20px;
            border:1px solid #ccc;
            border-radius:12px;
        }

        button{
            width:100%;
            padding:16px;
            background:#16a34a;
            color:white;
            border:none;
            border-radius:12px;
            font-size:18px;
            font-weight:bold;
            cursor:pointer;
        }

    </style>

</head>

<body>

<div class="form-box">

    <h1>➕ Add Product</h1>

    <form action="ProductServlet" method="post">

        <input type="hidden"
               name="action"
               value="add">

        <input type="text"
               name="name"
               placeholder="Product Name"
               required>

        <input type="text"
               name="category"
               placeholder="Category"
               required>

        <input type="text"
               name="price"
               placeholder="Price"
               required>

        <input type="text"
               name="stock"
               placeholder="Stock"
               required>

        <input type="text"
               name="image"
               placeholder="Image URL"
               required>

        <input type="text"
               name="description"
               placeholder="Product Description"
               required>

        <button type="submit">

            Add Product

        </button>

    </form>

</div>

</body>
</html>
