package com.usm.bookhub.controller;

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

// 1. THIS ANNOTATION IS REQUIRED FOR FILE UPLOADS
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 1, // 1 MB
        maxFileSize = 1024 * 1024 * 10,      // 10 MB
        maxRequestSize = 1024 * 1024 * 15    // 15 MB
)
@WebServlet("/updateQR")
public class UpdateQRServlet extends HttpServlet {

    // 🔴 IMPORTANT: Update this path!
    // Copy the path from your FileManager.java, but change the end to "images/profiles/"
    private static final String UPLOAD_DIR = "C:/Users/User/Documents/GitHub/USMReferenceBookHub/src/main/webapp/images/profiles/";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        // 1. Get the current User ID
        HttpSession session = request.getSession();
        String userID = (String) session.getAttribute("userID");

        if (userID == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        // 2. Get the File from the Form
        Part filePart = request.getPart("qrFile"); // Matches name="qrFile" in HTML

        if (filePart != null && filePart.getSize() > 0) {

            // 3. Determine File Extension (jpg, png, etc.)
            String fileName = filePart.getSubmittedFileName();
            String extension = "";
            int i = fileName.lastIndexOf('.');
            if (i > 0) {
                extension = fileName.substring(i); // e.g., ".jpg"
            }

            // 4. Create the New Name (e.g., "1001.jpg")
            // We use the UserID so one user only has ONE QR code (it overwrites old ones)
            String newFileName = userID + extension;
            // === CLEANUP: Delete any old QR codes (jpg, png, jpeg) ===
            String[] commonExtensions = {".jpg", ".jpeg", ".png"};
            for (String ext : commonExtensions) {
                File oldFile = new File(UPLOAD_DIR + userID + ext);
                if (oldFile.exists()) {
                    oldFile.delete(); // 🗑️ Delete the old one!
                }
            }

            // 5. Save the file to disk
            // Note: We are saving to the SRC folder so it doesn't disappear on rebuild
            filePart.write(UPLOAD_DIR + newFileName);

            // 6. Success!
            response.setContentType("text/html");
            response.getWriter().println("<script>");
            response.getWriter().println("alert('QR Code Uploaded Successfully! 📸');");
            response.getWriter().println("location='dashboard.jsp';");
            response.getWriter().println("</script>");

        } else {
            // No file uploaded
            response.sendRedirect("dashboard.jsp?error=nofile");
        }
    }
}
