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
        //getting the current session to check if someone is logged in
        HttpSession session = request.getSession(false);

        //checking if the session exists and has a valid user id
        if (session != null && session.getAttribute("userID") != null) {
            String ownerId = (String) session.getAttribute("userID");

            //fetching only the books that belong to this specific user
            List<String[]> userBooks = FileManager.ListAllBooksFromUser(getServletContext(), ownerId);

            //attaching the list of books to the request so the jsp can display them
            request.setAttribute("userBooks", userBooks);

            //sending everything to the dashboard jsp page to render
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
        } else {
            //redirecting back to login page if they arent logged in
            response.sendRedirect("index.jsp");
        }
    }
}