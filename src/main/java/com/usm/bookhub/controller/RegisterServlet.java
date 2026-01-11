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

        //getting all the info the user typed into the signup form
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String major = request.getParameter("major");

        //logic for automatically making a new user id by checking the file
        List<String> users = FileManager.readAllLines(getServletContext(), "users.txt");

        int newId = 1001;

        if (!users.isEmpty()) {
            //grabbing the last line to calculate the next id number
            String lastLine = users.get(users.size() - 1);
            String[] parts = lastLine.split("\\|");
            try {
                int lastId = Integer.parseInt(parts[0]);
                newId = lastId + 1;
            } catch (NumberFormatException e) {
                //ignoring errors if the file format is weird
            }
        }

        //putting all the data together into one string separated by pipes
        String newUserLine = newId + "|" + email + "|" + password + "|" + fullName + "|" + phone + "|" + address + "|" + major + "|student";

        //saving the new user line into the text file
        FileManager.writeLine(getServletContext(), "users.txt", newUserLine);

        //showing a success message with their new id and sending them to login
        response.setContentType("text/html");
        response.getWriter().println("<script type=\"text/javascript\">");
        response.getWriter().println("alert('Account created successfully! User ID: " + newId + "');");
        response.getWriter().println("location='index.jsp';");
        response.getWriter().println("</script>");
    }
}