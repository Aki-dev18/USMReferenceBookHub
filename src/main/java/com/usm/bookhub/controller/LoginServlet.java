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

        //getting the email and password the user typed in the form
        String emailInput = request.getParameter("email");
        String passwordInput = request.getParameter("password");

        //reading all the lines from users.txt using the context so the path is correct
        List<String> lines = FileManager.readAllLines(getServletContext(), "users.txt");

        boolean isFound = false;
        String foundName = "";
        String foundID = "";

        //looping through every user line in the file to find a match
        for (String line : lines) {
            //splitting the line data by the pipe symbol
            String[] parts = line.split("\\|");

            //making sure the line actually has data before we check it
            if (parts.length >= 4) {
                String emailInFile = parts[1];
                String passwordInFile = parts[2];

                //checking if the email and password match exactly
                if (emailInFile.equals(emailInput) && passwordInFile.equals(passwordInput)) {
                    isFound = true;
                    foundID = parts[0];
                    foundName = parts[3];
                    break;
                }
            }
        }

        //handling what happens after the loop finishes
        if (isFound) {
            //creating a session and saving their info so they stay logged in
            HttpSession session = request.getSession();
            session.setAttribute("userID", foundID);
            session.setAttribute("userName", foundName);

            //sending them to the dashboard page
            response.sendRedirect("dashboard");

        } else {
            //showing a popup alert if the login failed
            response.setContentType("text/html");
            response.getWriter().println("<script>");
            response.getWriter().println("alert('Invalid Email or Password! Try again.');");
            response.getWriter().println("location='index.jsp';");
            response.getWriter().println("</script>");
        }
    }
}