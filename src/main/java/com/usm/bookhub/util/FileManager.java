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

    public static void RewriteFile(ServletContext context, String fileName,List<String> UpdatedList) {
        String realPath = context.getRealPath("/data/" + fileName);

        try (PrintWriter pw = new PrintWriter(realPath)) {
            for (int i = 0; i < UpdatedList.size(); i++) {
                pw.println(UpdatedList.get(i));
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
    }

    public static List<String[]> ListAllBooksFromUser(ServletContext context, String ownerId) {

        List<String> AllBookList = readAllLines(context, "books.txt");
        List<String[]> MatchedBookList = new ArrayList<String[]>();

        for (int i = 0; i < AllBookList.size(); i++) {
           String book= AllBookList.get(i);
           String[] parts=book.split("\\|");

           if (parts[4].equals(ownerId))
               MatchedBookList.add(parts);

        }
        return MatchedBookList;
    }

    public static void DeleteBook(ServletContext context, String bookId) {
        String realPath = context.getRealPath("/data/books.txt");
        List<String> AllBooks=readAllLines(context, "books.txt");
        List<String> UpdatedListBooks = new ArrayList<String>();

        for (int i = 0; i < AllBooks.size(); i++) {
            String book= AllBooks.get(i);
            String[] parts=book.split("\\|");

            if(!parts[0].equals(bookId))
                UpdatedListBooks.add(book);
        }
        RewriteFile(context, "books.txt", UpdatedListBooks);

    }

    public static void UpdateBookDetails(ServletContext context, String bookId, String newTitle, String newSalePrice, String newRentPrice) {
        List<String> AllBooks = readAllLines(context, "books.txt");
        List<String> UpdatedListBooks = new ArrayList<String>();

        for (int i = 0; i < AllBooks.size(); i++) {
            String book = AllBooks.get(i);
            String[] parts = book.split("\\|");

            if (parts[0].equals(bookId)) {
                parts[1] = newTitle;
                parts[2] = newSalePrice;
                parts[3] = newRentPrice;
                book = String.join("|", parts);
            }
            UpdatedListBooks.add(book);
        }
        RewriteFile(context, "books.txt", UpdatedListBooks);
    }

    // 🟢 Add this helper to remove old extensions before saving a new one
    public static void deleteOldImages(ServletContext context, String bookId) {
        String folderPath = context.getRealPath("/images/books/");
        String[] extensions = {".jpeg", ".jpg", ".png"};

        for (String ext : extensions) {
            File file = new File(folderPath + File.separator + bookId + ext);
            if (file.exists()) {
                file.delete(); // Removes old file to prevent the JSP from finding it first
            }
        }
    }

    // 🟢 Update the signature to accept 'returnDate'
    public static void ChangeBookStatus(ServletContext context, String bookId, String newStatus, String customerId, String returnDate) {
        List<String> AllBooks = readAllLines(context, "books.txt");
        List<String> UpdatedListBooks = new ArrayList<String>();

        for (int i = 0; i < AllBooks.size(); i++) {
            String book = AllBooks.get(i);
            String[] parts = book.split("\\|");

            if (parts[0].equals(bookId)) {
                parts[5] = newStatus; // Update status column
                book = String.join("|", parts);

                // Log to record.txt if it's a Rent or Purchase
                if (newStatus.equalsIgnoreCase("Rented") || newStatus.equalsIgnoreCase("Purchased")) {
                    String title = parts[1];
                    String seller = parts[4];
                    String price = newStatus.equalsIgnoreCase("Rented") ? parts[3] : parts[2];
                    String type = newStatus.equalsIgnoreCase("Purchased") ? "Purchase" : "Rent";

                    // 🟢 Pass the returnDate to the transaction logger
                    addTransactionRecord(context, title, customerId, seller, type, price, returnDate);
                }
            }
            UpdatedListBooks.add(book);
        }
        RewriteFile(context, "books.txt", UpdatedListBooks);
    }

    // Helper method to append the transaction to record.txt
    public static void addTransactionRecord(ServletContext context, String title, String buyer, String seller, String type, String price, String returnDate) {
        List<String> allRecords = readAllLines(context, "record.txt");
        String recordID = String.format("RCD%03d", allRecords.size());
        String date = java.time.LocalDate.now().toString();

        // Format: RecordID|BookTitle|BuyerID|SellerID|Type|Price|Date|ReturnDate
        String recordLine = recordID + "|" + title + "|" + buyer + "|" + seller + "|" + type + "|" + price + "|" + date + "|" + returnDate;

        writeLine(context, "record.txt", recordLine);
    }


}
