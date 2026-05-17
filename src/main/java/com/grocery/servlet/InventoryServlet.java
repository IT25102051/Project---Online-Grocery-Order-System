package com.grocery.servlet;

import com.grocery.dao.InventoryDAO;
import com.grocery.dao.NotificationDAO;
import com.grocery.model.Inventory;
import com.grocery.model.Notification;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.UUID;

@WebServlet("/InventoryServlet")
public class InventoryServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !"Admin".equalsIgnoreCase((String) session.getAttribute("role"))) {
            response.sendRedirect("adminLogin.jsp");
            return;
        }

        InventoryDAO dao = new InventoryDAO(getServletContext().getRealPath("/") + "data");
        NotificationDAO notificationDao = new NotificationDAO(getServletContext().getRealPath("/"));

        String action = request.getParameter("action");

        if ("add".equals(action)) {
            int addedStock = 0;
            try {
                addedStock = Integer.parseInt(request.getParameter("stock"));
            } catch (Exception ignored) {}

            String productId = request.getParameter("productId");
            String supplier = request.getParameter("supplier");
            String inventoryId = request.getParameter("inventoryId");

            String basePath = getServletContext().getRealPath("/");
            com.grocery.dao.ProductDAO productDao = new com.grocery.dao.ProductDAO(basePath);
            String productName = "Unknown Product";

            try {
                List<String> products = productDao.getAllProducts();
                List<String> updatedProducts = new java.util.ArrayList<>();
                for (String line : products) {
                    String[] parts = line.split(",", -1);
                    if (parts.length >= 5 && parts[0].trim().equals(productId)) {
                        productName = parts[1].trim();
                        int currentStock = Integer.parseInt(parts[4].trim());
                        parts[4] = String.valueOf(currentStock + addedStock);
                        updatedProducts.add(String.join(",", parts));
                    } else {
                        updatedProducts.add(line);
                    }
                }

                try (java.io.FileWriter pfw = new java.io.FileWriter(new java.io.File(basePath + "data/products.txt"), false)) {
                    for (String pLine : updatedProducts) {
                        pfw.write(pLine + "\n");
                    }
                }
            } catch (Exception e) {}

            Inventory inventory = new Inventory(inventoryId, productName, addedStock, supplier);
            dao.addInventory(inventory);

            String id = UUID.randomUUID().toString().substring(0, 8);
            notificationDao.addNotification(new Notification(id, "Admin", "Stock Restocked: " + productName,
                    "Added " + addedStock + " units to " + productName + ".", new java.util.Date().toString(), false));
        }

        if ("delete".equals(action)) {
            dao.deleteInventory(request.getParameter("inventoryId"));
            String id = UUID.randomUUID().toString().substring(0, 8);
            String title = "Inventory Item Removed";
            String message = "An inventory item with ID " + request.getParameter("inventoryId") + " has been removed from stock.";
            String timestamp = new java.util.Date().toString();
            notificationDao.addNotification(new Notification(id, "Delivery", title, message, timestamp, false));
        }

        response.sendRedirect("inventory.jsp");
    }
}