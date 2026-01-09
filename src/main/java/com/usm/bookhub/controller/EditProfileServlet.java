package com.usm.bookhub.controller;

import com.usm.bookhub.util.FileManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/editProfile")
public class EditProfileServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        // 1. Get User ID
        HttpSession session = request.getSession();
        String userID = (String) session.getAttribute("userID");

        if (userID == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        // 2. Get New Data from Form
        String newName = request.getParameter("fullName");
        String newPhone = request.getParameter("phone");
        String newAddress = request.getParameter("address");
        String newMajor = request.getParameter("major");

        // 3. Update the File
        // 🟢 FIXED: Added 'getServletContext()' so it finds the file correctly
        FileManager.updateUser(getServletContext(), userID, newName, newPhone, newAddress, newMajor);

        // 4. Update the Session (so the "Welcome, Name" changes instantly)
        session.setAttribute("userName", newName);

        // 5. Refresh Page
        response.setContentType("text/html");
        response.getWriter().println("<script>");
        response.getWriter().println("alert('Profile Updated Successfully! ✅');");
        response.getWriter().println("location='dashboard.jsp';");
        response.getWriter().println("</script>");
    }
}
