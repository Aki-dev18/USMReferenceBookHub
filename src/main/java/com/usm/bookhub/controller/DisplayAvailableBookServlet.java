package com.usm.bookhub.controller;

import com.usm.bookhub.model.Book;
import com.usm.bookhub.util.FileManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/defunct")
public class DisplayAvailableBookServlet extends HttpServlet{

    //method for handling the get request to show available books
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {

        //getting all the book data from the text file
        List<String> lines = FileManager.readAllLines(getServletContext(), "books.txt");

        List<Book> availableBooks = new ArrayList<>();

        //looping through the lines to filter out only the available books
        for(String line : lines) {
            String [] parts = line.split("\\|");

            if (parts.length < 6)
                continue;

            String status = parts[5].trim();

            if ("Available".equalsIgnoreCase(status))
            {
                Book book = new Book(parts[0], parts[1], Double.parseDouble(parts[2]), Double.parseDouble(parts[3]), Integer.parseInt(parts[4]), status);
                availableBooks.add(book);
            }
        }

        //sending the list of books to the jsp so it can be displayed
        request.setAttribute("bookList", availableBooks);

        //forwarding the request to the dashboard page
        request.getRequestDispatcher("dashboard.jsp").forward(request, response);
    }

}
