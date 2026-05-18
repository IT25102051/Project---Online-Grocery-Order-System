package com.grocery.model;

public class Product {
   private String id;
   private String name;
   private double price;
   private int stock;
   private String category;
   private String imageUrl;
   private String description;
   private String expiryDate;

   public Product() {}

   public Product(String id, String name, double price, int stock, String category, String imageUrl, String description, String expiryDate) {
      this.id = id;
      this.name = name;
      this.price = price;
      this.stock = stock;
      this.category = category;
      this.imageUrl = imageUrl != null ? imageUrl : "";
      this.description = description != null ? description : "";
      this.expiryDate = expiryDate != null ? expiryDate : "N/A";
   }

   public Product(String id, String name, double price, int stock, String category, String imageUrl, String description) {
      this(id, name, price, stock, category, imageUrl, description, "N/A");
   }

   public Product(String id, String name, double price, int stock, String category) {
      this(id, name, price, stock, category, "", "", "N/A");
   }

   public String getId() { return id; }
   public String getName() { return name; }
   public double getPrice() { return price; }
   public int getStock() { return stock; }
   public String getCategory() { return category; }
   public String getImageUrl() { return imageUrl; }
   public String getDescription() { return description; }
   public String getExpiryDate() { return expiryDate; }

   public void setStock(int stock) {
      this.stock = stock;
   }

   public String toFileString() {
      return id + "," + name + "," + category + "," + price + "," + stock + "," + imageUrl + "," + description + "," + expiryDate;
   }
}
