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

    // 🟢 REMOVED: private static final String UPLOAD_DIR = "C:/...";
    // We will calculate this dynamically inside the method now.

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
        Part filePart = request.getPart("qrFile");

        if (filePart != null && filePart.getSize() > 0) {

            // 🟢 STEP 3: Find the path dynamically
            // Ask Tomcat: "Where is the 'images/profiles' folder on THIS computer?"
            String uploadPath = getServletContext().getRealPath("") + File.separator + "images" + File.separator + "profiles";

            // Safety: Create the directory if it doesn't exist
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            // 4. Determine File Extension (jpg, png, etc.)
            String fileName = filePart.getSubmittedFileName();
            String extension = "";
            int i = fileName.lastIndexOf('.');
            if (i > 0) {
                extension = fileName.substring(i);
            }

            // 5. Create the New Name (e.g., "1001.jpg")
            String newFileName = userID + extension;

            // === CLEANUP: Delete any old QR codes ===
            // We search inside our dynamic 'uploadPath' now
            String[] commonExtensions = {".jpg", ".jpeg", ".png"};
            for (String ext : commonExtensions) {
                File oldFile = new File(uploadPath + File.separator + userID + ext);
                if (oldFile.exists()) {
                    oldFile.delete();
                }
            }

            // 6. Save the file
            // We write to the dynamic path
            filePart.write(uploadPath + File.separator + newFileName);

            // 7. Success!
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
