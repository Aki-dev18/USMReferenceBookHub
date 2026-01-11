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

        //getting the current user session to check login status
        HttpSession session = request.getSession();
        String userID = (String) session.getAttribute("userID");

        if (userID == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        //retrieving the updated profile details from the form
        String newName = request.getParameter("fullName");
        String newPhone = request.getParameter("phone");
        String newAddress = request.getParameter("address");
        String newMajor = request.getParameter("major");

        //calling the file manager to save the new details to the text file
        FileManager.updateUser(getServletContext(), userID, newName, newPhone, newAddress, newMajor);

        //updating the session variable so the welcome name changes instantly
        session.setAttribute("userName", newName);

        //displaying a success popup and reloading the dashboard
        response.setContentType("text/html");
        response.getWriter().println("<script>");
        response.getWriter().println("alert('Profile Updated Successfully! ✅');");
        response.getWriter().println("location='dashboard';");
        response.getWriter().println("</script>");
    }
}
