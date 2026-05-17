package com.grocery.model;

public class Order {
    private String orderId;
    private String userId;
    private String productName;
    private int quantity;
    private double total;

    public Order(String orderId, String userId, String productName, int quantity, double total) {
        this.orderId = orderId;
        this.userId = userId;
        this.productName = productName;
        this.quantity = quantity;
        this.total = total;
    }

    public String getOrderId() {
        return orderId;
    }

    public String toFileString() {
        return orderId + "," + userId + "," + productName + "," + quantity + "," + total;
    }
}