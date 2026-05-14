package com.grocery.model;

public class Notification {
   private String notificationId;
   private String userId;
   private String message;
   private String status;

   public Notification(String notificationId, String userId, String message, String status) {
      this.notificationId = notificationId;
      this.userId = userId;
      this.message = message;
      this.status = status;
   }

   public String getNotificationId() {
      return notificationId;
   }

   public String toFileString() {
      return notificationId + "," + userId + "," + message + "," + status;
   }
}