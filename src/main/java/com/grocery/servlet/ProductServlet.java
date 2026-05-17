package com.grocery.servlet;

import com.grocery.dao.ProductDAO;
import com.grocery.model.Product;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/product")
public class ProductServlet extends HttpServlet {

    private ProductDAO dao = new ProductDAO();

    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");

        if ("add".equals(action)) {
            Product p = new Product(
                    java.util.UUID.randomUUID().toString(),
                    req.getParameter("name"),
                    Double.parseDouble(req.getParameter("price")),
                    Integer.parseInt(req.getParameter("stock")),
                    req.getParameter("category"),
                    req.getParameter("image"),
                    req.getParameter("description")
            );
            dao.addProduct(p);
            resp.sendRedirect("adminProducts.jsp");

        } else if ("update".equals(action)) {
            Product p = new Product(
                    req.getParameter("id"),
                    req.getParameter("name"),
                    Double.parseDouble(req.getParameter("price")),
                    Integer.parseInt(req.getParameter("stock")),
                    req.getParameter("category"),
                    req.getParameter("image"),
                    req.getParameter("description")
            );
            dao.updateProduct(p);
            resp.sendRedirect("adminProducts.jsp");

        } else if ("delete".equals(action)) {
            dao.deleteProduct(req.getParameter("id"));
            resp.sendRedirect("adminProducts.jsp");

        } else {
            resp.sendRedirect("adminProducts.jsp");
        }
    }
}