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

//configuration for allowing larger file uploads for images
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2,
        maxFileSize = 1024 * 1024 * 50,
        maxRequestSize = 1024 * 1024 * 100
)
@WebServlet("/addBook")
public class AddBookServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        //checking if the user is logged in before letting them add a book
        HttpSession session = request.getSession();
        String userID = (String) session.getAttribute("userID");

        if (userID == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        try {
            //getting the book details sent from the form
            String title = request.getParameter("title");
            String salePrice = request.getParameter("salePrice");
            String rentPrice = request.getParameter("rentPrice");

            //logic for generating a unique book id without crashing
            List<String> books = FileManager.readAllLines(getServletContext(), "books.txt");
            int nextIdNum = 1001;

            for (String line : books) {
                //skipping empty lines or the header row to avoid errors
                if (line.trim().isEmpty() || line.startsWith("BookID")) continue;

                try {
                    String[] parts = line.split("\\|");
                    String idStr = parts[0];

                    //extracting the number part of the id to find the max
                    if (idStr.startsWith("B")) {
                        int num = Integer.parseInt(idStr.substring(1));
                        if (num >= nextIdNum) {
                            nextIdNum = num + 1;
                        }
                    }
                } catch (Exception ignored) {
                    //ignoring bad lines so the loop keeps going
                }
            }
            String newBookID = "B" + nextIdNum;

            //logic for handling the book cover image upload
            Part filePart = request.getPart("bookImage");
            String fileName = "default.jpg";

            if (filePart != null && filePart.getSize() > 0) {
                String submittedName = filePart.getSubmittedFileName();
                String extension = ".jpg";

                //getting the correct file extension
                if (submittedName.contains(".")) {
                    extension = submittedName.substring(submittedName.lastIndexOf('.'));
                }

                fileName = newBookID + extension;

                //finding the correct folder path on the server to save images
                String appPath = getServletContext().getRealPath("");

                //fallback check if path is null
                if (appPath == null) appPath = System.getProperty("java.io.tmpdir");

                String uploadPath = appPath + File.separator + "images" + File.separator + "books";

                //creating the directory if it doesnt exist yet
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) uploadDir.mkdirs();

                //saving the actual file to the folder
                filePart.write(uploadPath + File.separator + fileName);
            }

            //formatting all the book data into a single line
            String newBookLine = newBookID + "|" + title + "|" + salePrice + "|" + rentPrice + "|" + userID + "|Available";

            //writing the new book line to the text file
            FileManager.writeLine(getServletContext(), "books.txt", newBookLine);

            //redirecting back to the dashboard inventory tab after success
            response.sendRedirect("dashboard?tab=Inventory&status=success");

        } catch (Exception e) {
            //printing the error trace so we can see what went wrong in console
            e.printStackTrace();

            //displaying an alert to the user if the process fails
            response.setContentType("text/html");
            response.getWriter().println("<script>");
            response.getWriter().println("alert('Error adding book: " + e.getMessage().replace("'", "") + "');");
            response.getWriter().println("location='dashboard.jsp';");
            response.getWriter().println("</script>");
        }
    }
}