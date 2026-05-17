package com.grocery.servlet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@WebServlet("/UserServlet")
public class UserServlet extends HttpServlet {

    private String getFilePath() {
        return getServletContext().getRealPath("/") + "data/users.txt";
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("register".equals(action)) {
            register(request, response);
        } else if ("delete".equals(action)) {
            deleteUser(request, response);
        }
    }

    private void deleteUser(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String id = request.getParameter("id");
        if (id == null || id.trim().isEmpty()) {
            response.sendRedirect("adminUsers.jsp");
            return;
        }

        String filePath = getFilePath();
        File file = new File(filePath);
        if (!file.exists()) {
            response.sendRedirect("adminUsers.jsp");
            return;
        }

        List<String> lines = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = br.readLine()) != null) {
                if (!line.trim().startsWith(id + ",")) {
                    lines.add(line);
                }
            }
        }

        try (FileWriter fw = new FileWriter(file, false)) {
            for (String line : lines) {
                fw.write(line + "\n");
            }
        }

        response.sendRedirect("adminUsers.jsp?deleted=ok");
    }

    private void register(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String name     = request.getParameter("name");
        String email    = request.getParameter("email");
        String password = request.getParameter("password");
        String role     = request.getParameter("role");

        // Validate fields
        if (name == null || name.trim().isEmpty() ||
                email == null || email.trim().isEmpty() ||
                password == null || password.trim().isEmpty()) {
            response.sendRedirect("register.jsp?error=empty");
            return;
        }

        if (role == null || role.trim().isEmpty()) {
            role = "Customer";
        }

        String filePath = getFilePath();

        // Check duplicate email
        File file = new File(filePath);
        if (file.exists()) {
            BufferedReader br = new BufferedReader(new FileReader(file));
            String line;
            while ((line = br.readLine()) != null) {
                String[] parts = line.split(",");
                if (parts.length >= 3 && parts[2].trim().equalsIgnoreCase(email.trim())) {
                    br.close();
                    response.sendRedirect("register.jsp?error=exists");
                    return;
                }
            }
            br.close();
        }

        // Write new user: id, name, email, password, role
        String id = UUID.randomUUID().toString();
        String userData = id + "," + name.trim() + "," + email.trim() + "," + password + "," + role;

        file.getParentFile().mkdirs();
        FileWriter fw = new FileWriter(file, true);
        fw.write(userData + "\n");
        fw.close();

        response.sendRedirect("login.jsp?success=ok");
    }
}
