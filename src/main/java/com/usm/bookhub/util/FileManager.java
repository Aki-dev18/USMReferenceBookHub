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
}
