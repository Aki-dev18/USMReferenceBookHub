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

//config for handling file uploads since we are sending images
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 1,
        maxFileSize = 1024 * 1024 * 10,
        maxRequestSize = 1024 * 1024 * 15
)
@WebServlet("/updateQR")
public class UpdateQRServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        //getting the current user id from the session
        HttpSession session = request.getSession();
        String userID = (String) session.getAttribute("userID");

        if (userID == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        //retrieving the uploaded file from the request
        Part filePart = request.getPart("qrFile");

        if (filePart != null && filePart.getSize() > 0) {

            //asking tomcat for the real path to the images folder
            String uploadPath = getServletContext().getRealPath("") + File.separator + "images" + File.separator + "profiles";

            //creating the folder if it doesnt exist yet
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            //extracting the file extension from the original name
            String fileName = filePart.getSubmittedFileName();
            String extension = "";
            int i = fileName.lastIndexOf('.');
            if (i > 0) {
                extension = fileName.substring(i);
            }

            //renaming the file to match the user id
            String newFileName = userID + extension;

            //deleting any old qr codes so we dont have duplicates
            String[] commonExtensions = {".jpg", ".jpeg", ".png"};
            for (String ext : commonExtensions) {
                File oldFile = new File(uploadPath + File.separator + userID + ext);
                if (oldFile.exists()) {
                    oldFile.delete();
                }
            }

            //saving the actual file to the directory
            filePart.write(uploadPath + File.separator + newFileName);

            //showing a success alert and reloading dashboard
            response.setContentType("text/html");
            response.getWriter().println("<script>");
            response.getWriter().println("alert('QR Code Uploaded Successfully! 📸');");
            response.getWriter().println("location='dashboard';");
            response.getWriter().println("</script>");

        } else {
            //redirecting if no file was actually selected
            response.sendRedirect("dashboard.jsp?error=nofile");
        }
    }
}
