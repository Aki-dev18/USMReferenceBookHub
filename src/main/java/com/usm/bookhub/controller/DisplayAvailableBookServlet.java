package com.usm.bookhub.controller;

import com.usm.bookhub.util.FileManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.util.List;

@WebServlet("/marketplace")
public class DisplayAvailableBookServlet extends HttpServlet{
    private String [] bookID= {};
    private String [] title = {};
    private double [] salePrice = {};
    private double [] rentPrice = {};
    private int [] userID = {};
    private String [] status = {};

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
        int count = 0;

        // Getting all the book data from books.txt file
        List<String> lines = FileManager.readAllLines(getServletContext(), "books.txt");



        //Reading each book into a new list based on the category of data
        for(String line : lines) {
            String [] parts = line.split("\\|");
            bookID[count] = parts[0];
            title[count] = parts[1];
            salePrice[count] = Double.parseDouble(parts[2]);
            rentPrice[count] = Double.parseDouble(parts[3]);
            userID[count] = Integer.parseInt(parts[4]);
            status[count] = parts[5];
            count++;
        }
    }

}
