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

    //method for handling the deletion request when the button is clicked
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        //getting the book id that was hidden in the form
        String bookId = request.getParameter("bookId");

        //checking to make sure the id actually exists before trying to delete
        if (bookId != null && !bookId.isEmpty()) {
            //calling the file manager to actually remove the line from the file
            FileManager.DeleteBook(getServletContext(), bookId);
        }

        //reloading the dashboard page so the book disappears from the list
        response.sendRedirect("dashboard");
    }

    //method for blocking direct access to this url
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        //sending them back to the dashboard if they try to type the url manually
        response.sendRedirect("dashboard");
    }
}
