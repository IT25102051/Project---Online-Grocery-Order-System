package com.grocery.servlet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.util.*;

@WebServlet("/OrderHistoryServlet")
public class OrderHistoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String userId  = (String) session.getAttribute("userId");
        String dataDir = getServletContext().getRealPath("/") + "data/";

        // Read orders filtered by userId
        // Format: orderId, userId, username, total, paymentMethod, address, phone
        List<String[]> userOrders = new ArrayList<>();
        File ordersFile = new File(dataDir + "orders.txt");

        if (ordersFile.exists()) {
            BufferedReader br = new BufferedReader(new FileReader(ordersFile));
            String line;
            while ((line = br.readLine()) != null) {
                line = line.trim();
                if (line.isEmpty()) continue;
                String[] parts = line.split(",", 9);
                if (parts.length >= 4 && parts[1].trim().equals(userId)) {
                    userOrders.add(parts);
                }
            }
            br.close();
        }

        // Reverse so newest orders appear first
        Collections.reverse(userOrders);

        request.setAttribute("userOrders", userOrders);
        request.getRequestDispatcher("orders.jsp").forward(request, response);
    }
}