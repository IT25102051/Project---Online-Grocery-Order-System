package com.grocery.model;

public class Notification {
   private String notificationId;
   private String recipient;
   private String title;
   private String message;
   private String timestamp;
   private boolean read;

   public Notification(String notificationId, String recipient, String title, String message, String timestamp) {
      this(notificationId, recipient, title, message, timestamp, false);
   }

   public Notification(String notificationId, String recipient, String title, String message, String timestamp, boolean read) {
      this.notificationId = notificationId;
      this.recipient = recipient == null || recipient.trim().isEmpty() ? "All" : recipient.trim();
      this.title = title;
      this.message = message;
      this.timestamp = timestamp;
      this.read = read;
   }

   public Notification(String notificationId, String title, String message, String timestamp) {
      this(notificationId, "All", title, message, timestamp, false);
   }

   public String getNotificationId() {
      return notificationId;
   }

   public String getRecipient() {
      return recipient;
   }

   public String getTitle() {
      return title;
   }

   public String getMessage() {
      return message;
   }

   public String getTimestamp() {
      return timestamp;
   }

   public boolean isRead() {
      return read;
   }

   public void setRead(boolean read) {
      this.read = read;
   }

   public String toFileString() {
      return notificationId + "," + recipient.replace(",", ";") + "," + title.replace(",", ";").replace("\n", " ").replace("\r", "") + "," + message.replace(",", ";").replace("\n", " ").replace("\r", "") + "," + timestamp + "," + (read ? "read" : "unread");
   }

   public static Notification fromFileString(String line) {
      String[] parts = line.split(",", 6);
      String id = parts.length > 0 ? parts[0] : "";
      String recipient = "All";
      String title = "";
      String message = "";
      String timestamp = "";
      boolean read = false;
      if (parts.length == 6) {
         recipient = parts[1];
         title = parts[2].replace(";", ",");
         message = parts[3].replace(";", ",");
         timestamp = parts[4];
         read = "read".equalsIgnoreCase(parts[5].trim());
      } else if (parts.length == 5) {
         recipient = parts[1];
         title = parts[2].replace(";", ",");
         message = parts[3].replace(";", ",");
         timestamp = parts[4];
      } else if (parts.length == 4) {
         title = parts[1].replace(";", ",");
         message = parts[2].replace(";", ",");
         timestamp = parts[3];
      }
      return new Notification(id, recipient, title, message, timestamp, read);
   }
}
