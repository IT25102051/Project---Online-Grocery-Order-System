package com.grocery.model;

public class Review {
    private String reviewId;
    private String productName;
    private String userName;
    private int rating;
    private String comment;

    public Review(String reviewId, String productName, String userName, int rating, String comment) {
        this.reviewId = reviewId;
        this.productName = productName;
        this.userName = userName;
        this.rating = rating;
        this.comment = comment;
    }

    public String getReviewId() {
        return reviewId;
    }

    public String getProductName() {
        return productName;
    }

    public String getUserName() {
        return userName;
    }

    public int getRating() {
        return rating;
    }

    public String getComment() {
        return comment;
    }

    public String toFileString() {
        return reviewId + "," + productName + "," + userName + "," + rating + "," + comment;
    }
}
