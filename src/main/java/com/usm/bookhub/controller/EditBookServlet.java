package com.usm.bookhub.controller;

import com.usm.bookhub.util.FileManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.File;
import java.io.IOException;

@WebServlet("/editBook")
@MultipartConfig
public class EditBookServlet extends HttpServlet {

    //method for handling the update request when editing a book
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        //getting the new details entered in the edit form
        String bookId = request.getParameter("bookId");
        String title = request.getParameter("title");
        String salePrice = request.getParameter("salePrice");
        String rentPrice = request.getParameter("rentPrice");

        //saving the text changes to the text file first
        FileManager.UpdateBookDetails(getServletContext(), bookId, title, salePrice, rentPrice);

        //checking if the user actually uploaded a new picture
        Part filePart = request.getPart("bookImage");
        if (filePart != null && filePart.getSize() > 0) {

            //deleting any old photos so we dont have duplicates with different extensions
            FileManager.deleteOldImages(getServletContext(), bookId);

            //extracting the file extension and finding the save path
            String fileName = filePart.getSubmittedFileName();
            String extension = fileName.substring(fileName.lastIndexOf("."));
            String uploadPath = getServletContext().getRealPath("/images/books/");

            //saving the new image file to the server folder
            filePart.write(uploadPath + File.separator + bookId + extension);
        }

        //sending them back to the dashboard to see the changes
        response.sendRedirect("dashboard");
    }
}