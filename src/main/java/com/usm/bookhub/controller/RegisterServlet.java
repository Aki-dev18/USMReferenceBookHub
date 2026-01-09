package com.usm.bookhub.controller;

import com.usm.bookhub.util.FileManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        // 1. Get data from the HTML form
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String major = request.getParameter("major");

        // 2. Generate a new User ID automatically
        // 🟢 FIXED: Added 'getServletContext()' so it finds the file on any laptop
        List<String> users = FileManager.readAllLines(getServletContext(), "users.txt");

        int newId = 1001; // Default starting ID

        if (!users.isEmpty()) {
            String lastLine = users.get(users.size() - 1);
            String[] parts = lastLine.split("\\|"); // Split by "|"
            try {
                int lastId = Integer.parseInt(parts[0]);
                newId = lastId + 1;
            } catch (NumberFormatException e) {
                // If the file is messy, stick to default
            }
        }

        // 3. Format the data string
        // UserID|Email|Password|FullName|Phone|Address|Major|Role
        String newUserLine = newId + "|" + email + "|" + password + "|" + fullName + "|" + phone + "|" + address + "|" + major + "|student";

        // 4. Save to file
        // 🟢 FIXED: Added 'getServletContext()' here too
        FileManager.writeLine(getServletContext(), "users.txt", newUserLine);

        // 5. Success! Send them back to Login
        response.setContentType("text/html");
        response.getWriter().println("<script type=\"text/javascript\">");
        response.getWriter().println("alert('Account created successfully! User ID: " + newId + "');");
        response.getWriter().println("location='index.jsp';");
        response.getWriter().println("</script>");
    }
}