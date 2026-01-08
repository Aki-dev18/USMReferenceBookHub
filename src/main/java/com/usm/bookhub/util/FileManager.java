package com.usm.bookhub.util;

import java.io.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;

public class FileManager {

    // 🔴 IMPORTANT: CHANGE THIS PATH TO YOUR LAPTOP'S PATH
    // Right-click your "data" folder in IntelliJ -> Copy Path/Reference -> Absolute Path
    private static final String BASE_PATH = "C:/Users/User/Documents/GitHub/USMReferenceBookHub/src/main/webapp/data/";

    public static List<String> readAllLines(String fileName) {
        List<String> lines = new ArrayList<>();
        File file = new File(BASE_PATH + fileName);

        if (!file.exists()) return lines;

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

    public static void writeLine(String fileName, String data) {
        try (FileWriter fw = new FileWriter(BASE_PATH + fileName, true);
             BufferedWriter bw = new BufferedWriter(fw);
             PrintWriter out = new PrintWriter(bw)) {
            out.println(data);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    // === NEW METHOD: Find a specific user by ID ===
    public static String[] getUserByID(String targetID) {
        List<String> lines = readAllLines("users.txt");

        for (String line : lines) {
            String[] parts = line.split("\\|");

            // parts[0] is the UserID. Does it match?
            if (parts.length > 0 && parts[0].equals(targetID)) {
                return parts; // Found them! Return the data array.
            }
        }
        return null; // User not found
    }

    // 1. RE-WRITE the entire file (Used when editing/deleting)
    public static void saveAllUsers(List<String> lines) {
        try (PrintWriter out = new PrintWriter(new FileWriter(BASE_PATH + "users.txt"))) {
            for (String line : lines) {
                out.println(line);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    // 2. THE UPDATE LOGIC
    public static void updateUser(String userId, String newName, String newPhone, String newAddress, String newMajor) {
        List<String> lines = readAllLines("users.txt");
        List<String> newLines = new ArrayList<>();

        for (String line : lines) {
            String[] parts = line.split("\\|");

            // If this is the user we are looking for, UPDATE their info
            if (parts.length >= 8 && parts[0].equals(userId)) {
                // Keep ID, Email, Password, Role the same. Only change the rest.
                // Format: ID|Email|Password|Name|Phone|Address|Major|Role
                String updatedLine = parts[0] + "|" + parts[1] + "|" + parts[2] + "|" +
                        newName + "|" + newPhone + "|" + newAddress + "|" + newMajor + "|" + parts[7];
                newLines.add(updatedLine);
            } else {
                // If not the user, keep the line exactly as it was
                newLines.add(line);
            }
        }
        // Save the fresh list back to the file
        saveAllUsers(newLines);
    }
}
