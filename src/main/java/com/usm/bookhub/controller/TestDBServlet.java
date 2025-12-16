package com.usm.bookhub.controller;

import com.usm.bookhub.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;

@WebServlet("/test")
public class TestDBServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();

        out.println("<html><body>");
        out.println("<h2>Oracle Connection Test</h2>");

        // Attempt to connect
        Connection conn = DBConnection.getConnection();

        if (conn != null) {
            out.println("<h3 style='color:green'>SUCCESS: Connected to Oracle Database!</h3>");
        } else {
            out.println("<h3 style='color:red'>FAILED: Could not connect. Check console logs.</h3>");
        }
        out.println("</body></html>");
    }
}
