package com.grocery.model;

public class Product {
   private String id;
   private String name;
   private double price;
   private int stock;
   private String category;
   private String imageUrl;
   private String description;

   public Product() {}

   public Product(String id, String name, double price, int stock, String category, String imageUrl, String description) {
      this.id = id;
      this.name = name;
      this.price = price;
      this.stock = stock;
      this.category = category;
      this.imageUrl = imageUrl != null ? imageUrl : "";
      this.description = description != null ? description : "";
   }

   public Product(String id, String name, double price, int stock, String category) {
      this(id, name, price, stock, category, "", "");
   }

   public String getId() { return id; }
   public String getName() { return name; }
   public double getPrice() { return price; }
   public int getStock() { return stock; }
   public String getCategory() { return category; }
   public String getImageUrl() { return imageUrl; }
   public String getDescription() { return description; }

   public void setStock(int stock) {
      this.stock = stock;
   }

   public String toFileString() {
      return id + "," + name + "," + category + "," + price + "," + stock + "," + imageUrl + "," + description;
   }
}
