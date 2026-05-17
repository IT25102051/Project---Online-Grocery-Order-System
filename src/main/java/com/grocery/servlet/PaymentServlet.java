package com.grocery.servlet;

import com.grocery.dao.PaymentDAO;
import com.grocery.model.Payment;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/PaymentServlet")
public class PaymentServlet extends HttpServlet {
    private PaymentDAO dao = new PaymentDAO();

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("add".equals(action)) {
            Payment payment = new Payment(
                    request.getParameter("paymentId"),
                    request.getParameter("orderId"),
                    request.getParameter("method"),
                    Double.parseDouble(request.getParameter("amount")),
                    request.getParameter("status")
            );

            dao.addPayment(payment);
        }

        if ("delete".equals(action)) {
            dao.deletePayment(request.getParameter("paymentId"));
        }

        response.sendRedirect("payments.jsp");
    }
}
