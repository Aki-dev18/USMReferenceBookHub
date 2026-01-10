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

// 1. INCREASED LIMITS (50MB)
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2,  // 2 MB
        maxFileSize = 1024 * 1024 * 50,       // 50 MB (Big enough for phone photos)
        maxRequestSize = 1024 * 1024 * 100    // 100 MB
)
@WebServlet("/addBook")
public class AddBookServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        // 1. Security Check
        HttpSession session = request.getSession();
        String userID = (String) session.getAttribute("userID");

        if (userID == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        try {
            // 2. Get Form Data
            String title = request.getParameter("title");
            String salePrice = request.getParameter("salePrice");
            String rentPrice = request.getParameter("rentPrice");

            // 3. ROBUST ID GENERATION (Fixes the crash)
            List<String> books = FileManager.readAllLines(getServletContext(), "books.txt");
            int nextIdNum = 1001;

            for (String line : books) {
                // Ignore empty lines or header
                if (line.trim().isEmpty() || line.startsWith("BookID")) continue;

                try {
                    String[] parts = line.split("\\|");
                    String idStr = parts[0]; // e.g., "B1005"

                    if (idStr.startsWith("B")) {
                        int num = Integer.parseInt(idStr.substring(1)); // 1005
                        if (num >= nextIdNum) {
                            nextIdNum = num + 1;
                        }
                    }
                } catch (Exception ignored) {
                    // Skip bad lines without crashing
                }
            }
            String newBookID = "B" + nextIdNum;

            // 4. Handle Image Upload
            Part filePart = request.getPart("bookImage");
            String fileName = "default.jpg";

            if (filePart != null && filePart.getSize() > 0) {
                String submittedName = filePart.getSubmittedFileName();
                String extension = ".jpg";
                if (submittedName.contains(".")) {
                    extension = submittedName.substring(submittedName.lastIndexOf('.'));
                }

                fileName = newBookID + extension;

                // Dynamic Path
                String appPath = getServletContext().getRealPath("");
                // Safety check for path
                if (appPath == null) appPath = System.getProperty("java.io.tmpdir");

                String uploadPath = appPath + File.separator + "images" + File.separator + "books";

                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) uploadDir.mkdirs();

                filePart.write(uploadPath + File.separator + fileName);
            }

            // 5. Save Data
            String newBookLine = newBookID + "|" + title + "|" + salePrice + "|" + rentPrice + "|" + userID + "|Available";
            FileManager.writeLine(getServletContext(), "books.txt", newBookLine);

        // 6. Success Redirect (Hard Redirect)
        // This forces the browser to leave the white page immediately.
            response.sendRedirect("dashboard?tab=Inventory&status=success");

        } catch (Exception e) {
            // 🟢 ERROR TRAP: If anything crashes, print it and tell the user
            e.printStackTrace(); // Look at your server console for this!

            response.setContentType("text/html");
            response.getWriter().println("<script>");
            response.getWriter().println("alert('Error adding book: " + e.getMessage().replace("'", "") + "');");
            response.getWriter().println("location='dashboard.jsp';");
            response.getWriter().println("</script>");
        }
    }
}