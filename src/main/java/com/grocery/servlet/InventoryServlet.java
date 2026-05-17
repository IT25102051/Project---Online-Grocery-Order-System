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
        String userRole = (session != null) ? (String) session.getAttribute("role") : null;

        if (userRole == null || (!"Admin".equalsIgnoreCase(userRole) && !"Delivery".equalsIgnoreCase(userRole))) {
            response.sendRedirect("login.jsp");
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
                for (String line : products) {
                    String[] parts = line.split(",", -1);
                    if (parts.length >= 2 && parts[0].trim().equals(productId)) {
                        productName = parts[1].trim();
                        break;
                    }
                }
            } catch (Exception e) {}

            Inventory inventory = new Inventory(inventoryId, productId, productName, addedStock, supplier, "Pending");
            dao.addInventory(inventory);

            String id = UUID.randomUUID().toString().substring(0, 8);
            notificationDao.addNotification(new Notification(id, "Delivery", "New Inventory Request",
                    "Admin requested " + addedStock + " units of " + productName + " from " + supplier + ".", new java.util.Date().toString(), false));

        } else if ("updateStatus".equals(action)) {
            String invId = request.getParameter("inventoryId");
            String newStatus = request.getParameter("status");
            String basePath = getServletContext().getRealPath("/");

            try {
                List<String> records = dao.getAllInventory();
                List<String> updatedRecords = new java.util.ArrayList<>();
                Inventory target = null;

                for (String line : records) {
                    String[] parts = line.split(",", -1);
                    if (parts.length >= 6 && parts[0].trim().equals(invId)) {
                        parts[5] = newStatus;
                        target = new Inventory(parts[0], parts[1], parts[2], Integer.parseInt(parts[3]), parts[4], parts[5]);
                        updatedRecords.add(String.join(",", parts));
                    } else {
                        updatedRecords.add(line);
                    }
                }

                // Save updated inventory records
                try (java.io.FileWriter fw = new java.io.FileWriter(basePath + "data/inventory.txt", false)) {
                    for (String r : updatedRecords) fw.write(r + "\n");
                }

                // If Completed, update products.txt
                if ("Completed".equalsIgnoreCase(newStatus) && target != null) {
                    String pId = target.getProductId();
                    int amount = target.getStock();
                    List<String> pLines = new java.util.ArrayList<>();
                    try (java.io.BufferedReader pbr = new java.io.BufferedReader(new java.io.FileReader(basePath + "data/products.txt"))) {
                        String pline;
                        while ((pline = pbr.readLine()) != null) {
                            String[] pParts = pline.split(",", -1);
                            if (pParts.length >= 5 && pParts[0].trim().equals(pId)) {
                                int current = Integer.parseInt(pParts[4].trim());
                                pParts[4] = String.valueOf(current + amount);
                                pLines.add(String.join(",", pParts));
                            } else {
                                pLines.add(pline);
                            }
                        }
                    }
                    try (java.io.FileWriter pfw = new java.io.FileWriter(basePath + "data/products.txt", false)) {
                        for (String pl : pLines) pfw.write(pl + "\n");
                    }
                }

                // Notifications
                String nid = UUID.randomUUID().toString().substring(0, 8);
                String role = "Restocked".equals(newStatus) ? "Delivery" : "Admin";
                String msg = "Inventory " + invId + " status updated to: " + newStatus;
                notificationDao.addNotification(new Notification(nid, role, "Inventory Update", msg, new java.util.Date().toString(), false));

            } catch (Exception e) { e.printStackTrace(); }
        }

        if ("delete".equals(action)) {
            dao.deleteInventory(request.getParameter("inventoryId"));
            String id = UUID.randomUUID().toString().substring(0, 8);
            String title = "Inventory Item Removed";
            String message = "An inventory item with ID " + request.getParameter("inventoryId") + " has been removed from stock.";
            String timestamp = new java.util.Date().toString();
            notificationDao.addNotification(new Notification(id, "Delivery", title, message, timestamp, false));
        }

        if ("Delivery".equalsIgnoreCase(userRole)) {
            response.sendRedirect("deliveryDashboard.jsp");
        } else {
            response.sendRedirect("inventory.jsp");
        }
    }
}