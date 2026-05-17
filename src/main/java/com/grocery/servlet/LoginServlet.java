package com.grocery.servlet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email       = request.getParameter("email");
        String password    = request.getParameter("password");
        boolean adminLogin = "true".equals(request.getParameter("adminLogin"));

        String filePath = getServletContext().getRealPath("/") + "data/users.txt";

        boolean found = false;
        String userId = "", name = "", role = "";

        File file = new File(filePath);
        if (file.exists()) {
            BufferedReader br = new BufferedReader(new FileReader(file));
            String line;
            while ((line = br.readLine()) != null) {
                line = line.trim();
                if (line.isEmpty()) continue;
                String[] p = line.split(",");
                if (p.length >= 5
                        && p[2].trim().equals(email)
                        && p[3].trim().equals(password)) {
                    found  = true;
                    userId = p[0].trim();
                    name   = p[1].trim();
                    role   = p[4].trim();
                    break;
                }
            }
            br.close();
        }

        if (!found) {
            String page = adminLogin ? "adminLogin.jsp" : "login.jsp";
            response.sendRedirect(page + "?error=invalid");
            return;
        }

        // Admin login page: reject non-admins
        if (adminLogin && !"Admin".equalsIgnoreCase(role)) {
            response.sendRedirect("adminLogin.jsp?error=unauthorized");
            return;
        }

        // Set session
        HttpSession session = request.getSession();
        session.setAttribute("userId",   userId);
        session.setAttribute("username", name);
        session.setAttribute("name",     name);
        session.setAttribute("email",    email);
        session.setAttribute("role",     role);

        if ("Admin".equalsIgnoreCase(role)) {
            response.sendRedirect("adminDashboard.jsp");
        } else if ("Delivery".equalsIgnoreCase(role)) {
            response.sendRedirect("deliveryDashboard.jsp");
        } else {
            response.sendRedirect("customerDashboard.jsp");
        }
    }
}
