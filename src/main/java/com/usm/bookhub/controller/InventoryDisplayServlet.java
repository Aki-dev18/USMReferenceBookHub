package com.usm.bookhub.controller;

import com.usm.bookhub.util.FileManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/dashboard")
public class InventoryDisplayServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 1. Get the session
        HttpSession session = request.getSession(false);

        // 2. Check if user is logged in
        if (session != null && session.getAttribute("userID") != null) {
            String ownerId = (String) session.getAttribute("userID");

            // 3. Fetch books specifically for this user
            List<String[]> userBooks = FileManager.ListAllBooksFromUser(getServletContext(), ownerId);

            // 4. Pass the data to the JSP
            request.setAttribute("userBooks", userBooks);

            // 5. Forward to the JSP page
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
        } else {
            // Not logged in? Send back to login page
            response.sendRedirect("index.jsp");
        }
    }
}