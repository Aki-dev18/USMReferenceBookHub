package com.usm.bookhub.util;

import jakarta.servlet.ServletContext;
import java.io.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;

public class FileManager {

    //method for reading everything inside a text file
    public static List<String> readAllLines(ServletContext context, String fileName) {
        List<String> lines = new ArrayList<>();

        //finding where the file actually is inside the project
        String realPath = context.getRealPath("/data/" + fileName);
        File file = new File(realPath);

        //checking if the file even exists before we try to read it
        if (!file.exists()) {
            System.out.println("File not found at: " + realPath);
            return lines;
        }

        try (Scanner scanner = new Scanner(file)) {
            while (scanner.hasNextLine()) {
                String line = scanner.nextLine().trim();
                if (!line.isEmpty())
                    lines.add(line);
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
        return lines;
    }

    //method for writing just one line into the file
    public static void writeLine(ServletContext context, String fileName, String data) {
        try {
            String realPath = context.getRealPath("/data/" + fileName);

            //setting true so we append to the end instead of overwriting
            FileWriter fw = new FileWriter(realPath, true);
            BufferedWriter bw = new BufferedWriter(fw);
            PrintWriter out = new PrintWriter(bw);

            out.println(data);

            //closing everything so it saves properly
            out.close();
            bw.close();
            fw.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    //method for finding who the user is using their id
    public static String[] getUserByID(ServletContext context, String targetID) {
        List<String> lines = readAllLines(context, "users.txt");

        for (String line : lines) {
            String[] parts = line.split("\\|");

            //checking if this is the user we are looking for
            if (parts.length > 0 && parts[0].equals(targetID)) {
                return parts;
            }
        }
        return null;
    }

    //method for saving the whole list of users back to the file
    public static void saveAllUsers(ServletContext context, List<String> lines) {
        try {
            String realPath = context.getRealPath("/data/users.txt");
            PrintWriter out = new PrintWriter(new FileWriter(realPath));

            for (String line : lines) {
                out.println(line);
            }
            out.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    //method for updating the user info when they edit their profile
    public static void updateUser(ServletContext context, String userId, String newName, String newPhone, String newAddress, String newMajor) {
        List<String> lines = readAllLines(context, "users.txt");
        List<String> newLines = new ArrayList<>();

        for (String line : lines) {
            String[] parts = line.split("\\|");

            if (parts.length >= 8 && parts[0].equals(userId)) {
                //constructing the new line with updated info but keeping the old stuff too
                String updatedLine = parts[0] + "|" + parts[1] + "|" + parts[2] + "|" +
                        newName + "|" + newPhone + "|" + newAddress + "|" + newMajor + "|" + parts[7];
                newLines.add(updatedLine);
            } else {
                newLines.add(line);
            }
        }
        saveAllUsers(context, newLines);
    }

    //method for overwriting a file with a completely new list
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

    //method for getting all the books that belong to a specific person
    public static List<String[]> ListAllBooksFromUser(ServletContext context, String ownerId) {

        List<String> AllBookList = readAllLines(context, "books.txt");
        List<String[]> MatchedBookList = new ArrayList<String[]>();

        for (int i = 0; i < AllBookList.size(); i++) {
            String book= AllBookList.get(i);
            String[] parts=book.split("\\|");

            if (parts[4].equals(ownerId))
                MatchedBookList.add(parts); // add the book to the list if the id is matched

        }
        return MatchedBookList;
    }

    //method for removing a book from the list
    public static void DeleteBook(ServletContext context, String bookId) {
        String realPath = context.getRealPath("/data/books.txt");
        List<String> AllBooks=readAllLines(context, "books.txt");
        List<String> UpdatedListBooks = new ArrayList<String>();

        for (int i = 0; i < AllBooks.size(); i++) {
            String book= AllBooks.get(i);
            String[] parts=book.split("\\|");

            //skipping the book we want to delete so it does not get saved
            if(!parts[0].equals(bookId))
                UpdatedListBooks.add(book);
        }
        RewriteFile(context, "books.txt", UpdatedListBooks);

    }

    //method for changing the title or price of a book
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

    //method for deleting the old image so it does not clash with the new one
    public static void deleteOldImages(ServletContext context, String bookId) {
        String folderPath = context.getRealPath("/images/books/");
        String[] extensions = {".jpeg", ".jpg", ".png"};

        for (int i = 0; i < extensions.length; i++) {

            String ext = extensions[i];

            File file = new File(folderPath + File.separator + bookId + ext);

            if (file.exists()) {
                file.delete(); // removes the file if found
            }
        }
    }

    //method for updating the book status to rented or purchased
    public static void ChangeBookStatus(ServletContext context, String bookId, String newStatus, String customerId, String returnDate) {
        List<String> AllBooks = readAllLines(context, "books.txt");
        List<String> UpdatedListBooks = new ArrayList<String>();

        for (int i = 0; i < AllBooks.size(); i++) {
            String book = AllBooks.get(i);
            String[] parts = book.split("\\|");

            if (parts[0].equals(bookId)) {
                parts[5] = newStatus;
                book = String.join("|", parts);

                //checking if we need to record this transaction
                if (newStatus.equalsIgnoreCase("Rented") || newStatus.equalsIgnoreCase("Purchased")) {
                    String title = parts[1];
                    String seller = parts[4];

                    String price;
                    if (newStatus.equalsIgnoreCase("Rented")) {
                        price = parts[3]; // use renting Price
                    }

                    else {
                        price = parts[2]; // use selling Price
                    }

                    String type;
                    if (newStatus.equalsIgnoreCase("Purchased")) {
                        type = "Purchase"; // set transaction type to Purchase
                    } else {
                        type = "Rent"; // set transaction type to Rent
                    }

                    addTransactionRecord(context, title, customerId, seller, type, price, returnDate);
                }
            }
            UpdatedListBooks.add(book);
        }
        RewriteFile(context, "books.txt", UpdatedListBooks);
    }

    //method for adding the transaction into our record file
    public static void addTransactionRecord(ServletContext context, String title, String buyer, String seller, String type, String price, String returnDate) {
        List<String> allRecords = readAllLines(context, "record.txt");
        String recordID = String.format("RCD%03d", allRecords.size());
        String date = java.time.LocalDate.now().toString();

        //putting all the info together in one format
        String recordLine = recordID + "|" + title + "|" + buyer + "|" + seller + "|" + type + "|" + price + "|" + date + "|" + returnDate;

        writeLine(context, "record.txt", recordLine); // append the file by writing a new line
    }
}
