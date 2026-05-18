package com.grocery.servlet;

import com.grocery.dao.NotificationDAO;
import com.grocery.model.Notification;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.util.*;

@WebServlet("/OrderServlet")
public class OrderServlet extends HttpServlet {

   @Override
   protected void doPost(HttpServletRequest request, HttpServletResponse response)
           throws ServletException, IOException {

      HttpSession session = request.getSession(false);
      if (session == null || session.getAttribute("userId") == null) {
         response.sendRedirect("login.jsp");
         return;
      }

      String action = request.getParameter("action");
      if ("prepare".equals(action)) {
         prepareOrder(request, response, session);
      } else if ("pickup".equals(action)) {
         pickupOrder(request, response, session);
      } else if ("deliver".equals(action)) {
         deliverOrder(request, response, session);
      } else if ("not_delivered".equals(action)) {
         notDeliveredOrder(request, response, session);
      } else {
         placeOrder(request, response, session);
      }
   }

   private void placeOrder(HttpServletRequest request, HttpServletResponse response, HttpSession session)
           throws IOException {

      String userId        = (String) session.getAttribute("userId");
      String username      = (String) session.getAttribute("username");
      String email         = (String) session.getAttribute("email");
      String paymentMethod = request.getParameter("paymentMethod");
      String address       = request.getParameter("address");
      String phone         = request.getParameter("phone");
      String total         = request.getParameter("total");
      String cardNumber    = request.getParameter("cardNumber");
      String expiry        = request.getParameter("expiry");
      String cvv           = request.getParameter("cvv");

      if (paymentMethod == null || paymentMethod.trim().isEmpty()) {
         paymentMethod = "Cash on Delivery";
      }

      boolean cardPayment = "Credit Card".equalsIgnoreCase(paymentMethod) || "Debit Card".equalsIgnoreCase(paymentMethod);
      if (cardPayment) {
         if (cardNumber == null || cardNumber.trim().isEmpty() ||
                 expiry == null || expiry.trim().isEmpty() ||
                 cvv == null || cvv.trim().isEmpty()) {
            response.sendRedirect("checkout.jsp?error=card");
            return;
         }
      }

      String dataDir = getServletContext().getRealPath("/") + "data/";
      String orderId = "ORD-" + System.currentTimeMillis();
      String orderStatus = "Confirmed";

      // Read cart items for this user before clearing
      File cartFile = new File(dataDir + "cart.txt");
      List<String[]> userCartItems = new ArrayList<>();
      List<String> remainingCart = new ArrayList<>();

      if (cartFile.exists()) {
         try (BufferedReader br = new BufferedReader(new FileReader(cartFile))) {
            String line;
            while ((line = br.readLine()) != null) {
               line = line.trim();
               if (line.isEmpty()) continue;
               String[] parts = line.split(",");
               if (parts.length >= 4 && parts[1].trim().equals(userId)) {
                  userCartItems.add(parts); // [CartId, UserId, ProductId, Quantity]
               } else {
                  remainingCart.add(line);
               }
            }
         }
      }

      // If cart is empty, do nothing
      if (userCartItems.isEmpty()) {
         response.sendRedirect("cart.jsp?userId=" + userId);
         return;
      }

      // Update Inventory in products.txt
      File productsFile = new File(dataDir + "products.txt");
      List<String> updatedProducts = new ArrayList<>();
      Map<String, String[]> productDetails = new HashMap<>(); // Store for order_items

      if (productsFile.exists()) {
         try (BufferedReader br = new BufferedReader(new FileReader(productsFile))) {
            String line;
            while ((line = br.readLine()) != null) {
               line = line.trim();
               if (line.isEmpty()) continue;
               String[] parts = line.split(",", -1);
               if (parts.length >= 6) {
                  String pid = parts[0].trim();
                  int stock = 0;
                  try { stock = Integer.parseInt(parts[4].trim()); } catch(Exception ignored) {}

                  // Check if this product is in the user's cart
                  int orderedQty = 0;
                  for (String[] item : userCartItems) {
                     if (item[2].trim().equals(pid)) {
                        try { orderedQty += Integer.parseInt(item[3].trim()); } catch(Exception ignored) {}
                     }
                  }

                  if (orderedQty > 0) {
                     int newStock = Math.max(0, stock - orderedQty);
                     parts[4] = String.valueOf(newStock); // Update stock
                     productDetails.put(pid, parts); // Save info for order_items

                     // Rebuild product line
                     StringBuilder newLine = new StringBuilder(parts[0]);
                     for (int i = 1; i < parts.length; i++) {
                        newLine.append(",").append(parts[i]);
                     }
                     updatedProducts.add(newLine.toString());
                  } else {
                     updatedProducts.add(line);
                  }
               } else {
                  updatedProducts.add(line);
               }
            }
         }

         // Rewrite products.txt with updated stock
         try (FileWriter pfw = new FileWriter(productsFile, false)) {
            for (String pLine : updatedProducts) {
               pfw.write(pLine + "\n");

               // Check for low stock alert
               String[] parts = pLine.split(",", -1);
               if (parts.length >= 5) {
                  try {
                     int stock = Integer.parseInt(parts[4].trim());
                     if (stock < 20) {
                        String productName = parts[1].trim();
                        NotificationDAO nDao = new NotificationDAO(getServletContext().getRealPath("/"));
                        String nid = UUID.randomUUID().toString().substring(0, 8);
                        nDao.addNotification(new Notification(nid, "Delivery", "Low Stock Alert: " + productName,
                                "Stock for " + productName + " is low (" + stock + "). Please prepare for replenishment.", new Date().toString()));
                     }
                  } catch (Exception ignored) {}
               }
            }
         }
      }

      // Save order with status and optional delivery assignment
      File ordersFile = new File(dataDir + "orders.txt");
      ordersFile.getParentFile().mkdirs();
      try (FileWriter fw = new FileWriter(ordersFile, true)) {
         String cleanAddress = address != null ? address.replace(",", " ").replace("\n", " ") : "";
         String cleanPhone = phone != null ? phone.replace(",", " ") : "";
         fw.write(orderId + "," + userId + "," + username + "," + total + "," + paymentMethod + "," + cleanAddress + "," + cleanPhone + "," + orderStatus + "," + "" + "\n");
      }

      // Save order items into order_items.txt (OrderItemId, OrderId, ProductId, Quantity, Price)
      File orderItemsFile = new File(dataDir + "order_items.txt");
      try (FileWriter oifw = new FileWriter(orderItemsFile, true)) {
         for (String[] cartItem : userCartItems) {
            String pId = cartItem[2].trim();
            String qty = cartItem[3].trim();
            String price = "0.0";
            if (productDetails.containsKey(pId)) {
               price = productDetails.get(pId)[3];
            }
            String orderItemId = "OI-" + System.currentTimeMillis() + "-" + (int)(Math.random()*1000);
            oifw.write(orderItemId + "," + orderId + "," + pId + "," + qty + "," + price + "\n");
         }
      }

      String paymentStatus = cardPayment ? "Completed" : "Pending";
      String paymentId = "PAY-" + System.currentTimeMillis();
      File paymentsFile = new File(dataDir + "payments.txt");
      try (FileWriter pfw = new FileWriter(paymentsFile, true)) {
         pfw.write(paymentId + "," + orderId + "," + paymentMethod + "," + total + "," + paymentStatus + "\n");
      }

      NotificationDAO notificationDAO = new NotificationDAO(getServletContext().getRealPath("/"));
      notificationDAO.addNotification(new Notification(UUID.randomUUID().toString().substring(0, 8), "Admin", "New order is available!", "A new order " + orderId + " has been placed by " + username + ".", new Date().toString()));

      if (cardPayment) {
         String title = "Card Payment Received";
         String message = "Your payment for order " + orderId + " has been processed successfully.";
         notificationDAO.addNotification(new Notification(UUID.randomUUID().toString().substring(0, 8), userId, title, message, new Date().toString()));
      }

      // Rewrite cart file without the user's items
      try (FileWriter cfw = new FileWriter(cartFile, false)) {
         for (String l : remainingCart) {
            cfw.write(l + "\n");
         }
      }

      session.setAttribute("lastOrderId", orderId);
      session.setAttribute("lastOrderTotal", total);
      session.setAttribute("lastPayment", paymentMethod);

      response.sendRedirect("orderSuccess.jsp");
   }

   private void prepareOrder(HttpServletRequest request, HttpServletResponse response, HttpSession session)
           throws IOException {

      String role = (String) session.getAttribute("role");
      if (!"Admin".equalsIgnoreCase(role)) {
         response.sendRedirect("adminLogin.jsp");
         return;
      }

      String orderId = request.getParameter("orderId");
      if (orderId != null && updateOrderStatus(orderId, "Prepared", "")) {
         NotificationDAO notificationDAO = new NotificationDAO(getServletContext().getRealPath("/"));
         String title = "Order is ready!";
         String message = "Order " + orderId + " is prepared and ready for pickup by the delivery team.";
         notificationDAO.addNotification(new Notification(UUID.randomUUID().toString().substring(0, 8), "Delivery", title, message, new Date().toString()));
      }

      response.sendRedirect("adminOrders.jsp?prepared=ok");
   }

   private void pickupOrder(HttpServletRequest request, HttpServletResponse response, HttpSession session)
           throws IOException {

      String role = (String) session.getAttribute("role");
      if (!"Delivery".equalsIgnoreCase(role)) {
         response.sendRedirect("login.jsp");
         return;
      }

      String orderId = request.getParameter("orderId");
      String deliveryName = (String) session.getAttribute("username");
      String customerId = getOrderUserId(orderId);
      if (orderId != null && updateOrderStatus(orderId, "Picked Up", (String) session.getAttribute("userId"))) {
         NotificationDAO notificationDAO = new NotificationDAO(getServletContext().getRealPath("/"));
         notificationDAO.addNotification(new Notification(UUID.randomUUID().toString().substring(0, 8), "Admin", "Order Picked Up", "Delivery person " + deliveryName + " has picked up order " + orderId + ".", new Date().toString()));
         if (customerId != null && !customerId.isEmpty()) {
            notificationDAO.addNotification(new Notification(UUID.randomUUID().toString().substring(0, 8), customerId, "Your order is on the way", "Your order " + orderId + " has been picked up and is on the way by delivery personnel " + deliveryName + ".", new Date().toString()));
         }
      }

      response.sendRedirect("deliveryDashboard.jsp?picked=ok");
   }

   private void deliverOrder(HttpServletRequest request, HttpServletResponse response, HttpSession session)
           throws IOException {

      String role = (String) session.getAttribute("role");
      if (!"Delivery".equalsIgnoreCase(role)) {
         response.sendRedirect("login.jsp");
         return;
      }

      String orderId = request.getParameter("orderId");
      String deliveryName = (String) session.getAttribute("username");

      if (orderId != null && updateOrderStatus(orderId, "Delivered", (String) session.getAttribute("userId"))) {
         NotificationDAO notificationDAO = new NotificationDAO(getServletContext().getRealPath("/"));

         // Check if this order is Cash on Delivery
         String paymentMethod = getOrderPaymentMethod(orderId);
         String customerName = getOrderCustomerName(orderId);
         String customerId = getOrderUserId(orderId);

         if ("Cash on Delivery".equalsIgnoreCase(paymentMethod)) {
            // Automatically mark COD payment as Completed
            updatePaymentStatus(orderId, "Completed");

            // Notify admin that COD payment was collected
            String title = "COD Payment Collected";
            String message = "Delivery person " + deliveryName + " has delivered order " + orderId
                    + " to " + customerName + " and collected Cash on Delivery payment. Payment is marked as Completed.";
            notificationDAO.addNotification(new Notification(
                    UUID.randomUUID().toString().substring(0, 8),
                    "Admin", title, message, new Date().toString()));
         }

         // Notify admin about delivery
         notificationDAO.addNotification(new Notification(
                 UUID.randomUUID().toString().substring(0, 8),
                 "Admin", "Order Delivered",
                 "Delivery person " + deliveryName + " has successfully delivered order " + orderId + ".",
                 new Date().toString()));

         // Notify customer
         if (customerId != null && !customerId.isEmpty()) {
            notificationDAO.addNotification(new Notification(
                    UUID.randomUUID().toString().substring(0, 8),
                    customerId, "Order Delivered",
                    "Your order " + orderId + " has been delivered successfully. Thank you for shopping with CeylonFresh!",
                    new Date().toString()));
         }
      }

      response.sendRedirect("deliveryDashboard.jsp?delivered=ok");
   }

   private void notDeliveredOrder(HttpServletRequest request, HttpServletResponse response, HttpSession session)
           throws IOException {

      String role = (String) session.getAttribute("role");
      if (!"Delivery".equalsIgnoreCase(role)) {
         response.sendRedirect("login.jsp");
         return;
      }

      String orderId = request.getParameter("orderId");
      String deliveryName = (String) session.getAttribute("username");

      if (orderId != null && updateOrderStatus(orderId, "Not Delivered", (String) session.getAttribute("userId"))) {
         NotificationDAO notificationDAO = new NotificationDAO(getServletContext().getRealPath("/"));

         // Notify admin about failed delivery
         notificationDAO.addNotification(new Notification(
                 UUID.randomUUID().toString().substring(0, 8),
                 "Admin", "Delivery Failed",
                 "Delivery person " + deliveryName + " reported that order " + orderId + " could not be delivered.",
                 new Date().toString()));
      }

      response.sendRedirect("deliveryDashboard.jsp?not_delivered=ok");
   }

   private boolean updateOrderStatus(String orderId, String status, String deliveryId) throws IOException {
      String dataDir = getServletContext().getRealPath("/") + "data/";
      File file = new File(dataDir + "orders.txt");
      if (!file.exists()) {
         return false;
      }

      List<String> lines = new ArrayList<>();
      boolean updated = false;

      try (BufferedReader br = new BufferedReader(new FileReader(file))) {
         String line;
         while ((line = br.readLine()) != null) {
            String[] parts = line.split(",", 9);
            if (parts.length >= 1 && parts[0].trim().equals(orderId)) {
               String orderUserId = parts.length > 1 ? parts[1].trim() : "";
               String orderName = parts.length > 2 ? parts[2].trim() : "";
               String orderTotal = parts.length > 3 ? parts[3].trim() : "";
               String paymentMethod = parts.length > 4 ? parts[4].trim() : "";
               String address = parts.length > 5 ? parts[5].trim() : "";
               String phone = parts.length > 6 ? parts[6].trim() : "";
               String existingStatus = parts.length > 7 ? parts[7].trim() : "Confirmed";
               String existingDeliveryId = parts.length > 8 ? parts[8].trim() : "";
               if (deliveryId == null || deliveryId.isEmpty()) {
                  deliveryId = existingDeliveryId;
               }
               lines.add(orderId + "," + orderUserId + "," + orderName + "," + orderTotal + "," + paymentMethod + "," + address + "," + phone + "," + status + "," + deliveryId);
               updated = true;
            } else {
               lines.add(line);
            }
         }
      }

      if (updated) {
         try (FileWriter fw = new FileWriter(file, false)) {
            for (String l : lines) {
               fw.write(l + "\n");
            }
         }
      }

      return updated;
   }

   private String getOrderUserId(String orderId) throws IOException {
      String dataDir = getServletContext().getRealPath("/") + "data/";
      File file = new File(dataDir + "orders.txt");
      if (!file.exists() || orderId == null) {
         return "";
      }

      try (BufferedReader br = new BufferedReader(new FileReader(file))) {
         String line;
         while ((line = br.readLine()) != null) {
            String[] parts = line.split(",", 9);
            if (parts.length > 1 && orderId.equals(parts[0].trim())) {
               return parts[1].trim();
            }
         }
      }
      return "";
   }

   private String getOrderPaymentMethod(String orderId) throws IOException {
      String dataDir = getServletContext().getRealPath("/") + "data/";
      File file = new File(dataDir + "orders.txt");
      if (!file.exists() || orderId == null) return "";
      try (BufferedReader br = new BufferedReader(new FileReader(file))) {
         String line;
         while ((line = br.readLine()) != null) {
            String[] parts = line.split(",", 9);
            if (parts.length > 4 && orderId.equals(parts[0].trim())) {
               return parts[4].trim();
            }
         }
      }
      return "";
   }

   private String getOrderCustomerName(String orderId) throws IOException {
      String dataDir = getServletContext().getRealPath("/") + "data/";
      File file = new File(dataDir + "orders.txt");
      if (!file.exists() || orderId == null) return "";
      try (BufferedReader br = new BufferedReader(new FileReader(file))) {
         String line;
         while ((line = br.readLine()) != null) {
            String[] parts = line.split(",", 9);
            if (parts.length > 2 && orderId.equals(parts[0].trim())) {
               return parts[2].trim();
            }
         }
      }
      return "";
   }

   private void updatePaymentStatus(String orderId, String status) throws IOException {
      String dataDir = getServletContext().getRealPath("/") + "data/";
      File file = new File(dataDir + "payments.txt");
      if (!file.exists()) return;

      List<String> lines = new ArrayList<>();
      boolean updated = false;

      try (BufferedReader br = new BufferedReader(new FileReader(file))) {
         String line;
         while ((line = br.readLine()) != null) {
            String[] parts = line.split(",", 5);
            if (parts.length >= 2 && parts[1].trim().equals(orderId)) {
               parts[4] = status;
               lines.add(String.join(",", parts));
               updated = true;
            } else {
               lines.add(line);
            }
         }
      }

      if (updated) {
         try (FileWriter fw = new FileWriter(file, false)) {
            for (String l : lines) fw.write(l + "\n");
         }
      }
   }
}
