package com.usm.bookhub.util;

import jakarta.servlet.ServletContext; // Make sure this is jakarta (Tomcat 10)
import java.io.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;

public class FileManager {

    // 🟢 REMOVED: private static final String BASE_PATH...
    // We now calculate the path dynamically inside each method.

    public static List<String> readAllLines(ServletContext context, String fileName) {
        List<String> lines = new ArrayList<>();

        // Ask Tomcat where "data/fileName" is on THIS specific computer
        String realPath = context.getRealPath("/data/" + fileName);
        File file = new File(realPath);

        if (!file.exists()) {
            System.out.println("File not found at: " + realPath); // Helpful for debugging
            return lines;
        }

        try (Scanner scanner = new Scanner(file)) {
            while (scanner.hasNextLine()) {
                String line = scanner.nextLine().trim();
                if (!line.isEmpty()) lines.add(line);
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
        return lines;
    }

    public static void writeLine(ServletContext context, String fileName, String data) {
        try {
            String realPath = context.getRealPath("/data/" + fileName);

            // "true" means append to the end of the file
            FileWriter fw = new FileWriter(realPath, true);
            BufferedWriter bw = new BufferedWriter(fw);
            PrintWriter out = new PrintWriter(bw);

            out.println(data);

            // Always close your streams!
            out.close();
            bw.close();
            fw.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    // === NEW METHOD: Find a specific user by ID ===
    // Note: We added 'ServletContext context' to the parameters
    public static String[] getUserByID(ServletContext context, String targetID) {
        // Pass context to readAllLines
        List<String> lines = readAllLines(context, "users.txt");

        for (String line : lines) {
            String[] parts = line.split("\\|");

            // parts[0] is the UserID.
            if (parts.length > 0 && parts[0].equals(targetID)) {
                return parts;
            }
        }
        return null; // User not found
    }

    // 1. RE-WRITE the entire file (Used when editing/deleting)
    public static void saveAllUsers(ServletContext context, List<String> lines) {
        try {
            String realPath = context.getRealPath("/data/users.txt");
            PrintWriter out = new PrintWriter(new FileWriter(realPath));

            for (String line : lines) {
                out.println(line);
            }
            out.close(); // Don't forget to close!
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    // 2. THE UPDATE LOGIC
    public static void updateUser(ServletContext context, String userId, String newName, String newPhone, String newAddress, String newMajor) {
        // Pass context here
        List<String> lines = readAllLines(context, "users.txt");
        List<String> newLines = new ArrayList<>();

        for (String line : lines) {
            String[] parts = line.split("\\|");

            if (parts.length >= 8 && parts[0].equals(userId)) {
                // Keep ID, Email, Password, Role the same. Only change the rest.
                String updatedLine = parts[0] + "|" + parts[1] + "|" + parts[2] + "|" +
                        newName + "|" + newPhone + "|" + newAddress + "|" + newMajor + "|" + parts[7];
                newLines.add(updatedLine);
            } else {
                newLines.add(line);
            }
        }
        // Pass context to save
        saveAllUsers(context, newLines);
    }
}
