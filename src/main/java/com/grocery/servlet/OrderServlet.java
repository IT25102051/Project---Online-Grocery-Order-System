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

      // Save order with status and optional delivery assignment
      File ordersFile = new File(dataDir + "orders.txt");
      ordersFile.getParentFile().mkdirs();
      try (FileWriter fw = new FileWriter(ordersFile, true)) {
         fw.write(orderId + "," + userId + "," + username + "," + total + "," + paymentMethod + "," + address + "," + phone + "," + orderStatus + "," + "" + "\n");
      }

      String paymentStatus = cardPayment ? "Completed" : "Pending";
      String paymentId = "PAY-" + System.currentTimeMillis();
      File paymentsFile = new File(dataDir + "payments.txt");
      try (FileWriter pfw = new FileWriter(paymentsFile, true)) {
         pfw.write(paymentId + "," + orderId + "," + paymentMethod + "," + total + "," + paymentStatus + "\n");
      }

      if (cardPayment) {
         NotificationDAO notificationDAO = new NotificationDAO(getServletContext().getRealPath("/"));
         String title = "Card Payment Received";
         String message = "Your payment for order " + orderId + " has been processed successfully.";
         notificationDAO.addNotification(new Notification(UUID.randomUUID().toString().substring(0, 8), userId, title, message, new Date().toString()));
      }

      // Clear this user's cart
      File cartFile = new File(dataDir + "cart.txt");
      if (cartFile.exists()) {
         List<String> remaining = new ArrayList<>();
         try (BufferedReader br = new BufferedReader(new FileReader(cartFile))) {
            String line;
            while ((line = br.readLine()) != null) {
               line = line.trim();
               if (line.isEmpty()) continue;
               String[] parts = line.split(",");
               if (parts.length >= 2 && !parts[1].trim().equals(userId)) {
                  remaining.add(line);
               }
            }
         }
         try (FileWriter cfw = new FileWriter(cartFile, false)) {
            for (String l : remaining) {
               cfw.write(l + "\n");
            }
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
         String title = "Order Ready for Pickup";
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
            notificationDAO.addNotification(new Notification(UUID.randomUUID().toString().substring(0, 8), customerId, "Your Order Is On The Way", "Your order " + orderId + " has been picked up and is on the way.", new Date().toString()));
         }
      }

      response.sendRedirect("deliveryDashboard.jsp?picked=ok");
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
}