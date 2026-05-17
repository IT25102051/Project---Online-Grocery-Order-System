package com.grocery.model;

public class Cart {
    private String cartId;
    private String userId;
    private String productId;
    private int quantity;

    public Cart() {}

    public Cart(String cartId, String userId, String productId, int quantity) {
        this.cartId = cartId;
        this.userId = userId;
        this.productId = productId;
        this.quantity = quantity;
    }

    public String getCartId() { return cartId; }
    public String getUserId() { return userId; }
    public String getProductId() { return productId; }
    public int getQuantity() { return quantity; }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }
}
