package com.grocery.servlet;

import com.grocery.dao.ReviewDAO;
import com.grocery.model.Review;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.UUID;

@WebServlet("/ReviewServlet")
public class ReviewServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        ReviewDAO dao = new ReviewDAO(getServletContext().getRealPath("/"));
        List<Review> reviews = dao.getAllReviewObjects();
        request.setAttribute("reviews", reviews);
        
        // Check if the user wants JSON (simple manual implementation)
        String format = request.getParameter("format");
        if ("json".equalsIgnoreCase(format)) {
            response.setContentType("application/json");
            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < reviews.size(); i++) {
                Review r = reviews.get(i);
                json.append("{")
                    .append("\"id\":\"").append(r.getReviewId()).append("\",")
                    .append("\"product\":\"").append(r.getProductName()).append("\",")
                    .append("\"user\":\"").append(r.getUserName()).append("\",")
                    .append("\"rating\":").append(r.getRating()).append(",")
                    .append("\"comment\":\"").append(r.getComment().replace("\"", "\\\"")).append("\"")
                    .append("}");
                if (i < reviews.size() - 1) json.append(",");
            }
            json.append("]");
            response.getWriter().write(json.toString());
            return;
        }

        request.getRequestDispatcher("reviews.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String currentUsername = (String) session.getAttribute("username");
        String currentRole = (String) session.getAttribute("role");
        
        if (currentUsername == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String action = request.getParameter("action");
        ReviewDAO dao = new ReviewDAO(getServletContext().getRealPath("/"));

        if ("add".equals(action)) {
            String productName = request.getParameter("productName");
            String comment = request.getParameter("reviewText");
            int rating = 0;
            try {
                rating = Integer.parseInt(request.getParameter("rating"));
            } catch (Exception ignored) {}

            if (productName != null && comment != null && rating > 0) {
                Review review = new Review(
                        UUID.randomUUID().toString(),
                        productName.trim(),
                        currentUsername, // Force use session username for security
                        rating,
                        comment.trim()
                );
                dao.addReview(review);
            }
        }

        if ("delete".equals(action)) {
            String reviewId = request.getParameter("reviewId");
            Review review = dao.getReviewById(reviewId);
            
            if (review != null) {
                // Security: Only owner or admin can delete
                if (review.getUserName().equalsIgnoreCase(currentUsername) || "Admin".equalsIgnoreCase(currentRole)) {
                    dao.deleteReview(reviewId);
                } else {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }
            }
        }

        String referer = request.getHeader("referer");
        if (referer != null && !referer.isEmpty() && !referer.contains("ReviewServlet")) {
            response.sendRedirect(referer);
        } else {
            response.sendRedirect("reviews.jsp");
        }
    }
}
