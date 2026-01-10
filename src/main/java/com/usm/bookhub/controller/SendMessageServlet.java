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

        // 1. Get Session Info
        HttpSession session = request.getSession();
        String senderID = (String) session.getAttribute("userID");

        if (senderID == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        // 2. Get Form Data
        String receiverID = request.getParameter("receiverID");
        String messageText = request.getParameter("message");

        if (receiverID == null || messageText == null || messageText.trim().isEmpty()) {
            response.sendRedirect("chat.jsp?withUser=" + receiverID);
            return;
        }

        // 3. Find the Path
        String realPath = getServletContext().getRealPath("/data/messages.txt");
        File file = new File(realPath);

        // 4. GENERATE INCREMENTING ID (The New Logic)
        int nextIdNum = 1001; // Default start if file is empty

        if (file.exists()) {
            try (Scanner scanner = new Scanner(file)) {
                while (scanner.hasNextLine()) {
                    String line = scanner.nextLine();
                    // Line format: M1001|Sender|Receiver...
                    String[] parts = line.split("\\|");

                    if (parts.length > 0 && parts[0].startsWith("M")) {
                        try {
                            // Extract number part: "M1005" -> 1005
                            String numberPart = parts[0].substring(1);
                            int currentNum = Integer.parseInt(numberPart);

                            // If this ID is bigger, update our next target
                            if (currentNum >= nextIdNum) {
                                nextIdNum = currentNum + 1;
                            }
                        } catch (NumberFormatException e) {
                            // Ignore weird lines
                        }
                    }
                }
            }
        }

        String msgID = "M" + nextIdNum; // Result: "M1006"

        // 5. Generate Timestamp
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));

        // 6. Append to File
        String line = String.format("%s|%s|%s|%s|%s", msgID, senderID, receiverID, messageText, timestamp);

        try (BufferedWriter writer = new BufferedWriter(new FileWriter(file, true))) {
            writer.write(line);
            writer.newLine();
        } catch (IOException e) {
            e.printStackTrace();
        }

        // 7. Redirect back to chat
        response.sendRedirect("chat.jsp?withUser=" + receiverID);
    }
}