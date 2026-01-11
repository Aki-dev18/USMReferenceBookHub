package com.usm.bookhub.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Scanner;

@WebServlet("/sendMessage")
public class SendMessageServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        //getting the current session info to know who is sending
        HttpSession session = request.getSession();
        String senderID = (String) session.getAttribute("userID");

        if (senderID == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        //retrieving the receiver id and message text from the form
        String receiverID = request.getParameter("receiverID");
        String messageText = request.getParameter("message");

        if (receiverID == null || messageText == null || messageText.trim().isEmpty()) {
            response.sendRedirect("chat.jsp?withUser=" + receiverID);
            return;
        }

        //finding the exact path to the messages text file
        String realPath = getServletContext().getRealPath("/data/messages.txt");
        File file = new File(realPath);

        //logic for generating the next message id by scanning the file
        int nextIdNum = 1001;

        if (file.exists()) {
            try (Scanner scanner = new Scanner(file)) {
                while (scanner.hasNextLine()) {
                    String line = scanner.nextLine();
                    //splitting the line to get the id part
                    String[] parts = line.split("\\|");

                    if (parts.length > 0 && parts[0].startsWith("M")) {
                        try {
                            //extracting the number from the id string
                            String numberPart = parts[0].substring(1);
                            int currentNum = Integer.parseInt(numberPart);

                            //updating the next id if we find a bigger one
                            if (currentNum >= nextIdNum) {
                                nextIdNum = currentNum + 1;
                            }
                        } catch (NumberFormatException e) {
                            //ignoring lines that are formatted weirdly
                        }
                    }
                }
            }
        }

        String msgID = "M" + nextIdNum;

        //creating a timestamp for when the message was sent
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));

        //formatting the new message line to save
        String line = String.format("%s|%s|%s|%s|%s", msgID, senderID, receiverID, messageText, timestamp);

        //appending the new message line to the file
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(file, true))) {
            writer.write(line);
            writer.newLine();
        } catch (IOException e) {
            e.printStackTrace();
        }

        //redirecting the user back to the chat screen
        response.sendRedirect("chat.jsp?withUser=" + receiverID);
    }
}