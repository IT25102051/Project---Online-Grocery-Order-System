package com.grocery.servlet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import java.io.*;

@WebServlet("/PaymentHistoryServlet")
public class PaymentHistoryServlet extends HttpServlet {

    private final String FILE_PATH = "data/payments.txt";

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        String method = request.getParameter("method");

        File file = new File(FILE_PATH);

        file.getParentFile().mkdirs();

        FileWriter fw = new FileWriter(file, true);

        fw.write(method + " Payment Successful\n");

        fw.close();

        response.sendRedirect("paymentHistory.jsp");
    }
}
