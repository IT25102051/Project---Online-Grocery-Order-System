package com.grocery.servlet;

import com.grocery.dao.ProductDAO;
import com.grocery.model.Product;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/product")
public class ProductServlet extends HttpServlet {

    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String basePath = getServletContext().getRealPath("/");
        ProductDAO dao = new ProductDAO(basePath);
        String action = req.getParameter("action");

        if ("add".equals(action)) {
            int count = dao.getAllProducts().size();
            String id = String.format("P%03d", count + 1);
            String expiryDate = req.getParameter("expiryDate");
            if (expiryDate == null || expiryDate.isEmpty()) expiryDate = "N/A";

            Product p = new Product(
                    id,
                    req.getParameter("name"),
                    Double.parseDouble(req.getParameter("price")),
                    Integer.parseInt(req.getParameter("stock")),
                    req.getParameter("category"),
                    req.getParameter("image"),
                    req.getParameter("description"),
                    expiryDate
            );
            dao.addProduct(p);
            resp.sendRedirect("adminProducts.jsp?msg=Product Added");

        } else if ("update".equals(action)) {
            String expiryDate = req.getParameter("expiryDate");
            if (expiryDate == null || expiryDate.isEmpty()) expiryDate = "N/A";

            Product p = new Product(
                    req.getParameter("id"),
                    req.getParameter("name"),
                    Double.parseDouble(req.getParameter("price")),
                    Integer.parseInt(req.getParameter("stock")),
                    req.getParameter("category"),
                    req.getParameter("image"),
                    req.getParameter("description"),
                    expiryDate
            );
            dao.updateProduct(p);
            resp.sendRedirect("adminProducts.jsp?msg=Product Updated");

        } else if ("delete".equals(action)) {
            dao.deleteProduct(req.getParameter("id"));
            resp.sendRedirect("adminProducts.jsp?msg=Product Deleted");

        } else {
            resp.sendRedirect("adminProducts.jsp");
        }
    }
}
