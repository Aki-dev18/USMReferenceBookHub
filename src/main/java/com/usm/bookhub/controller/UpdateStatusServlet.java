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
        //getting the book details and new status sent from the jsp
        String bookId = request.getParameter("bookId");
        String newStatus = request.getParameter("newStatus");
        String customerId = request.getParameter("customerId");
        String returnDate = request.getParameter("returnDate");

        //calling the file manager logic to update the status and record the transaction
        FileManager.ChangeBookStatus(getServletContext(), bookId, newStatus, customerId, returnDate);

        //redirecting back to the main dashboard page
        response.sendRedirect("dashboard");
    }
}
