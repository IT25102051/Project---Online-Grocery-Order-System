package com.grocery.model;

public class Inventory {
    private String inventoryId;
    private String productName;
    private int stock;
    private String supplier;

    public Inventory(String inventoryId, String productName, int stock, String supplier) {
        this.inventoryId = inventoryId;
        this.productName = productName;
        this.stock = stock;
        this.supplier = supplier;
    }

    public String getInventoryId() {
        return inventoryId;
    }

    public String toFileString() {
        return inventoryId + "," + productName + "," + stock + "," + supplier;
    }
}