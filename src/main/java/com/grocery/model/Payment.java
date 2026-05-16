package com.grocery.model;

public class Payment {
   private String paymentId;
   private String orderId;
   private String method;
   private double amount;
   private String status;

   public Payment(String paymentId, String orderId, String method, double amount, String status) {
      this.paymentId = paymentId;
      this.orderId = orderId;
      this.method = method;
      this.amount = amount;
      this.status = status;
   }

   public String getPaymentId() {
      return paymentId;
   }

   public String toFileString() {
      return paymentId + "," + orderId + "," + method + "," + amount + "," + status;
   }
}