package com.usm.bookhub.controller;

import com.usm.bookhub.util.FileManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        // 1. Get input from the Login Form
        String emailInput = request.getParameter("email");
        String passwordInput = request.getParameter("password");

        // 🟢 STEP 2: FIXED
        // We now pass 'getServletContext()' so FileManager knows the correct path on ANY laptop
        List<String> lines = FileManager.readAllLines(getServletContext(), "users.txt");

        boolean isFound = false;
        String foundName = "";
        String foundID = "";

        // 3. Search for the user (The "Loop" Logic)
        for (String line : lines) {
            // Data format: UserID|Email|Password|FullName|...
            String[] parts = line.split("\\|");

            // Safety check: Make sure the line has enough data
            if (parts.length >= 4) {
                String emailInFile = parts[1];
                String passwordInFile = parts[2];

                // CHECK: Do they match?
                if (emailInFile.equals(emailInput) && passwordInFile.equals(passwordInput)) {
                    isFound = true;
                    foundID = parts[0];
                    foundName = parts[3];
                    break; // Stop looking, we found them!
                }
            }
        }

        // 4. Handle the Result
        if (isFound) {
            // SUCCESS: Create a "Session"
            HttpSession session = request.getSession();
            session.setAttribute("userID", foundID);
            session.setAttribute("userName", foundName);

            // Send to Dashboard
            response.sendRedirect("dashboard");

        } else {
            // FAILURE: Wrong email or password
            response.setContentType("text/html");
            response.getWriter().println("<script>");
            response.getWriter().println("alert('Invalid Email or Password! Try again.');");
            response.getWriter().println("location='index.jsp';");
            response.getWriter().println("</script>");
        }
    }
}