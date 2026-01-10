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
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String bookId = request.getParameter("bookId");
        String title = request.getParameter("title");
        String salePrice = request.getParameter("salePrice");
        String rentPrice = request.getParameter("rentPrice");

        FileManager.UpdateBookDetails(getServletContext(), bookId, title, salePrice, rentPrice);

        Part filePart = request.getPart("bookImage");
        if (filePart != null && filePart.getSize() > 0) {
            // 🟢 Step A: Clean up any old image files with different extensions
            FileManager.deleteOldImages(getServletContext(), bookId);

            // 🟢 Step B: Save the new image
            String fileName = filePart.getSubmittedFileName();
            String extension = fileName.substring(fileName.lastIndexOf("."));
            String uploadPath = getServletContext().getRealPath("/images/books/");

            filePart.write(uploadPath + File.separator + bookId + extension);
        }
        response.sendRedirect("dashboard");
    }
}