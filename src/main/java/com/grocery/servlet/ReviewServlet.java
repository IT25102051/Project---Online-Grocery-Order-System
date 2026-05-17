package com.grocery.servlet;

import com.grocery.dao.ReviewDAO;
import com.grocery.model.Review;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/ReviewServlet")
public class ReviewServlet extends HttpServlet {
    private ReviewDAO dao = new ReviewDAO();

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("add".equals(action)) {
            Review review = new Review(
                    request.getParameter("reviewId"),
                    request.getParameter("productName"),
                    request.getParameter("userName"),
                    Integer.parseInt(request.getParameter("rating")),
                    request.getParameter("comment")
            );

            dao.addReview(review);
        }

        if ("delete".equals(action)) {
            dao.deleteReview(request.getParameter("reviewId"));
        }

        response.sendRedirect("reviews.jsp");
    }
}