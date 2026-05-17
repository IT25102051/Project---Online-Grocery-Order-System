<%@ page import="com.grocery.dao.UserDAO" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>User Management</title>

    <style>

        body{
            font-family:Arial;
            background:#f4fff4;
            padding:40px;
        }

        h1{
            color:#15803d;
        }

        form{
            background:white;
            padding:20px;
            border-radius:12px;
            margin-bottom:30px;
            box-shadow:0 5px 15px rgba(0,0,0,0.1);
        }

        input,select{
            padding:12px;
            margin:8px;
            border:1px solid #ccc;
            border-radius:8px;
        }

        button{
            background:#16a34a;
            color:white;
            border:none;
            padding:12px 20px;
            border-radius:8px;
            cursor:pointer;
        }

        table{
            width:100%;
            border-collapse:collapse;
            background:white;
            box-shadow:0 5px 15px rgba(0,0,0,0.1);
        }

        th{
            background:#16a34a;
            color:white;
            padding:14px;
        }

        td{
            border:1px solid #ddd;
            padding:12px;
            text-align:center;
        }

    </style>

</head>

<body>

<h1>User Management</h1>

<form action="UserServlet" method="post">

    <input type="hidden" name="action" value="add">

    <input type="text"
           name="userId"
           placeholder="User ID"
           required>

    <input type="text"
           name="name"
           placeholder="Full Name"
           required>

    <input type="email"
           name="email"
           placeholder="Email"
           required>

    <input type="password"
           name="password"
           placeholder="Password"
           required>

    <select name="role">
        <option value="Customer">Customer</option>
        <option value="Admin">Admin</option>
    </select>

    <button type="submit">Add User</button>

</form>

<table>

<tr>
    <th>User ID</th>
    <th>Name</th>
    <th>Email</th>
    <th>Password</th>
    <th>Role</th>
    <th>Action</th>
</tr>

<%

    UserDAO dao = new UserDAO();

    List<String> users = dao.getAllUsers();

    for(String line : users){

        String[] data = line.split(",");

        if(data.length < 5){
            continue;
        }

%>

<tr>

    <td><%= data[0] %></td>
    <td><%= data[1] %></td>
    <td><%= data[2] %></td>
    <td><%= data[3] %></td>
    <td><%= data[4] %></td>

    <td>

        <form action="UserServlet" method="post">

            <input type="hidden"
                   name="action"
                   value="delete">

            <input type="hidden"
                   name="userId"
                   value="<%= data[0] %>">

            <button type="submit">
                Delete
            </button>

        </form>

    </td>

</tr>

<%
    }
%>

</table>

</body>
</html>
