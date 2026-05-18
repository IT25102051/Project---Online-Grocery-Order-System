package com.grocery.model;

public class Inventory {
    private String inventoryId;
    private String productId;
    private String productName;
    private int stock;
    private String supplier;
    private String status;

    public Inventory(String inventoryId, String productId, String productName, int stock, String supplier, String status) {
        this.inventoryId = inventoryId;
        this.productId = productId;
        this.productName = productName;
        this.stock = stock;
        this.supplier = supplier;
        this.status = status;
    }

    public String getInventoryId() { return inventoryId; }
    public String getProductId() { return productId; }
    public String getProductName() { return productName; }
    public int getStock() { return stock; }
    public String getSupplier() { return supplier; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String toFileString() {
        return inventoryId + "," + productId + "," + productName + "," + stock + "," + supplier + "," + status;
    }
}