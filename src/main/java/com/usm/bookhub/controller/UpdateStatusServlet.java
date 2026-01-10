package com.usm.bookhub.controller;

import com.usm.bookhub.util.FileManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/updateStatus")
public class UpdateStatusServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String bookId = request.getParameter("bookId");
        String newStatus = request.getParameter("newStatus");
        String customerId = request.getParameter("customerId");
        String returnDate = request.getParameter("returnDate"); // Captured from JS prompt

        // Update the method call in your ChangeBookStatus to pass the returnDate
        FileManager.ChangeBookStatus(getServletContext(), bookId, newStatus, customerId, returnDate);

        response.sendRedirect("dashboard");
    }
}
