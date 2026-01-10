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

// 1. Required for File Uploads (Images)
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 1, // 1 MB
        maxFileSize = 1024 * 1024 * 10,      // 10 MB
        maxRequestSize = 1024 * 1024 * 15    // 15 MB
)
@WebServlet("/addBook")
public class AddBookServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        // 1. Security: Who is adding this book?
        HttpSession session = request.getSession();
        String userID = (String) session.getAttribute("userID");

        if (userID == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        // 2. Get Form Data
        String title = request.getParameter("title");
        String salePrice = request.getParameter("salePrice");
        String rentPrice = request.getParameter("rentPrice");

        // 3. Generate New Book ID (e.g., "B1001")
        // We use 'getServletContext()' to read the file safely
        List<String> books = FileManager.readAllLines(getServletContext(), "books.txt");
        int nextIdNum = 1001; // Default start

        if (!books.isEmpty()) {
            try {
                // Get the last line -> split -> get ID (e.g., "B1005") -> remove 'B' -> parse int
                String lastLine = books.get(books.size() - 1);
                String lastIdStr = lastLine.split("\\|")[0]; // "B1005"
                String numberPart = lastIdStr.substring(1);   // "1005"
                nextIdNum = Integer.parseInt(numberPart) + 1;
            } catch (Exception e) {
                // If ID format is weird, just keep 1001
            }
        }
        String newBookID = "B" + nextIdNum;

        // 4. Handle Image Upload
        Part filePart = request.getPart("bookImage");
        String fileName = "default.jpg"; // Fallback

        if (filePart != null && filePart.getSize() > 0) {
            // Determine extension (jpg/png)
            String submittedName = filePart.getSubmittedFileName();
            String extension = ".jpg";
            int i = submittedName.lastIndexOf('.');
            if (i > 0) extension = submittedName.substring(i);

            // SAVE IMAGE: Use the BookID as the name (e.g., "B1001.jpg")
            fileName = newBookID + extension;

            // Dynamic Path: images/books/
            String uploadPath = getServletContext().getRealPath("") + File.separator + "images" + File.separator + "books";

            // Create folder if missing
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdirs();

            // Write File
            filePart.write(uploadPath + File.separator + fileName);
        }

        // 5. Save Data to Text File
        // Format: BookID|Title|SalePrice|RentPrice|UserID|Status
        String newBookLine = newBookID + "|" + title + "|" + salePrice + "|" + rentPrice + "|" + userID + "|Available";

        FileManager.writeLine(getServletContext(), "books.txt", newBookLine);

        // 6. Success! Redirect to Inventory tab
        response.setContentType("text/html");
        response.getWriter().println("<script>");
        response.getWriter().println("alert('Book Listed Successfully! ID: " + newBookID + "');");
        // We add a query param '?tab=Inventory' so we can use JS later to open the right tab automatically
        response.getWriter().println("location='dashboard.jsp?tab=Inventory';");
        response.getWriter().println("</script>");
    }
}