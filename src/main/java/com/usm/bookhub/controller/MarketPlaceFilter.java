package com.usm.bookhub.controller;

import com.usm.bookhub.model.Book;
import com.usm.bookhub.util.FileManager;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;


@WebFilter("/dashboard")
public class MarketPlaceFilter implements Filter{

    public void doFilter(ServletRequest req, ServletResponse resp, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        ServletContext context = req.getServletContext();

        // --- Your Logic ---
        List<String> lines = FileManager.readAllLines(context, "books.txt");
        List<Book> availableBooks = new ArrayList<>();

        if (lines != null) {
            //Reading each book into a new list based on the category of data
            for(String line : lines) {
                String [] parts = line.split("\\|");
                if (parts.length >= 6) {
                    String status = parts[5].trim();
                    if ("Available".equalsIgnoreCase(status)) {
                        Book book = new Book(parts[0], parts[1], Double.parseDouble(parts[2]), Double.parseDouble(parts[3]), Integer.parseInt(parts[4]), status);
                        availableBooks.add(book);
                    }
                }
            }
        }

        // Pass data to the request
        request.setAttribute("bookList", availableBooks);

        // --- HAND OFF ---
        // This passes the request to the ACTUAL DashboardServlet.
        // If no Servlet exists at "/dashboard", this line causes a 404.
        chain.doFilter(req, resp);
    }

    // Boilerplate
    public void init(FilterConfig config){}
    public void destroy(){}
}