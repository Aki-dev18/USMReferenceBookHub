package com.usm.bookhub.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    // 1. Oracle Configuration
    // 'xe' is the default Service ID for Oracle Express Edition.
    // If you use a different version, this might be 'orcl'.
    private static final String URL = "jdbc:oracle:thin:@localhost:1521:xe";

    // 2. Database Credentials
    // UPDATE THESE to match the user you created in SQL Developer
    private static final String USERNAME = "bookhub_admin";
    private static final String PASSWORD = "password123";

    // 3. Get Connection Method
    public static Connection getConnection() {
        Connection connection = null;
        try {
            // Load the Oracle Driver
            Class.forName("oracle.jdbc.driver.OracleDriver");

            // Connect to the DB
            connection = DriverManager.getConnection(URL, USERNAME, PASSWORD);
            System.out.println("Database connected successfully!");

        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            System.out.println("Error: Oracle JDBC Driver not found. Check pom.xml!");
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error: Connection Failed. Check URL, User, or Password.");
        }
        return connection;
    }
}
