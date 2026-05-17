package com.grocery.servlet;

import com.grocery.model.Cart;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.util.*;

@WebServlet("/CartServlet")
public class CartServlet extends HttpServlet {

    private String getFilePath() {
        return getServletContext().getRealPath("/") + "data/cart.txt";
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("add".equals(action)) {
            addToCart(request, response);
        } else if ("update".equals(action)) {
            updateCart(request, response);
        } else if ("delete".equals(action)) {
            deleteCart(request, response);
        }
    }

    // ADD - redirect back to products page with toast confirmation
    private void addToCart(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String userId    = request.getParameter("userId");
        String productId = request.getParameter("productId");
        int qty = 1;
        try { qty = Integer.parseInt(request.getParameter("quantity")); } catch(Exception e){}

        String cartId = UUID.randomUUID().toString();

        File file = new File(getFilePath());
        file.getParentFile().mkdirs();
        FileWriter fw = new FileWriter(file, true);
        fw.write(cartId + "," + userId + "," + productId + "," + qty + "\n");
        fw.close();

        String category = request.getParameter("category");
        String search = request.getParameter("search");

        String redirectUrl = "products.jsp?added=true";
        if (category != null && !category.isEmpty()) redirectUrl += "&category=" + java.net.URLEncoder.encode(category, "UTF-8");
        if (search != null && !search.isEmpty()) redirectUrl += "&search=" + java.net.URLEncoder.encode(search, "UTF-8");

        response.sendRedirect(redirectUrl);
    }

    // UPDATE
    private void updateCart(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String cartId = request.getParameter("cartId");
        int newQty = 1;
        try { newQty = Integer.parseInt(request.getParameter("quantity")); } catch(Exception e){}
        String userId = request.getParameter("userId");

        List<String> lines = readFile();
        List<String> updated = new ArrayList<>();
        for (String line : lines) {
            String[] parts = line.split(",");
            if (parts.length >= 4 && parts[0].equals(cartId)) {
                updated.add(parts[0] + "," + parts[1] + "," + parts[2] + "," + newQty);
            } else {
                updated.add(line);
            }
        }
        writeFile(updated);
        response.sendRedirect("cart.jsp");
    }

    // DELETE
    private void deleteCart(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String cartId = request.getParameter("cartId");
        String userId = request.getParameter("userId");

        List<String> lines = readFile();
        lines.removeIf(line -> line.startsWith(cartId + ","));
        writeFile(lines);
        response.sendRedirect("cart.jsp?userId=" + userId);
    }

    private List<String> readFile() throws IOException {
        List<String> lines = new ArrayList<>();
        File file = new File(getFilePath());
        if (!file.exists()) return lines;
        BufferedReader br = new BufferedReader(new FileReader(file));
        String line;
        while ((line = br.readLine()) != null) if (!line.trim().isEmpty()) lines.add(line.trim());
        br.close();
        return lines;
    }

    private void writeFile(List<String> lines) throws IOException {
        FileWriter fw = new FileWriter(getFilePath(), false);
        for (String line : lines) fw.write(line + "\n");
        fw.close();
    }
}
