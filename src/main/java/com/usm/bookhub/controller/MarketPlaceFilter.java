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

    //method for intercepting the request before it reaches the dashboard
    public void doFilter(ServletRequest req, ServletResponse resp, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        ServletContext context = req.getServletContext();

        //reading all the lines from the books text file
        List<String> lines = FileManager.readAllLines(context, "books.txt");
        List<Book> availableBooks = new ArrayList<>();

        if (lines != null) {
            //looping through each line to parse the book data
            for(String line : lines) {
                String [] parts = line.split("\\|");
                if (parts.length >= 6) {
                    String status = parts[5].trim();
                    //checking if the book is available before adding it to the list
                    if ("Available".equalsIgnoreCase(status)) {
                        Book book = new Book(parts[0], parts[1], Double.parseDouble(parts[2]), Double.parseDouble(parts[3]), Integer.parseInt(parts[4]), status);
                        availableBooks.add(book);
                    }
                }
            }
        }

        //attaching the list of available books to the request so the jsp can use it
        request.setAttribute("bookList", availableBooks);

        //passing the request along to the actual dashboard servlet
        chain.doFilter(req, resp);
    }

    //method for initializing the filter (boilerplate stuff)
    public void init(FilterConfig config){}

    //method for cleaning up when the filter is destroyed
    public void destroy(){}
}