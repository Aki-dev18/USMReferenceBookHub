package com.usm.bookhub.model;

public class Book {
    private String bookID;
    private String title;
    private double salePrice;
    private double rentPrice;
    private int userID;
    private String status;

    //Constructor
    public Book(String bookId, String bookTitle, double bookSale, double bookRent, int userId, String bookStatus) {
        bookID = bookId;
        title = bookTitle;
        salePrice = bookSale;
        rentPrice = bookRent;
        userID = userId;
        status = bookStatus;
    }

    //Getter functions
    public String getBookID() {
        return bookID;
    }

    public String getTitle() {
        return title;
    }

    public double getSalePrice() {
        return salePrice;
    }

    public double getRentPrice()
    {
        return rentPrice;
    }
    public int getUserID()
    {
        return userID;
    }

    public String getStatus()
    {
        return status;
    }
}
