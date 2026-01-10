package com.usm.bookhub.controller;

import com.usm.bookhub.util.FileManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/deleteBook")
public class DeleteBookServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Get the bookId from the hidden input in your JSP
        String bookId = request.getParameter("bookId");

        // 2. Safety check: make sure ID is not null
        if (bookId != null && !bookId.isEmpty()) {
            // 3. Call your method to update the books.txt file
            FileManager.DeleteBook(getServletContext(), bookId);
        }

        // 4. IMPORTANT: Redirect to the Dashboard Servlet
        // This makes the page refresh and show the updated list (minus the deleted book)
        response.sendRedirect("dashboard");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // If someone tries to access this URL directly via browser, just send them home
        response.sendRedirect("dashboard");
    }
}
