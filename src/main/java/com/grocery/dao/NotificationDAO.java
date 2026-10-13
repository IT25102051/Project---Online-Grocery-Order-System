package com.grocery.dao;

import com.grocery.model.Notification;
import java.io.*;
import java.util.*;

public class NotificationDAO {
    private final String filePath;

    public NotificationDAO(String appRealPath) {
        this.filePath = appRealPath + "data/notifications.txt"; //create full path for notification file
    }

    // adds new notification to file
    public void addNotification(Notification notification) throws IOException {
        File file = new File(filePath);
        file.getParentFile().mkdirs();
        try (FileWriter fw = new FileWriter(file, true)) { //opens file writer
            fw.write(notification.toFileString() + "\n"); // writes notification ata into file
        }
    }

    public List<Notification> getAllNotifications() throws IOException { //returns all notifications
        List<Notification> notifications = new ArrayList<>(); //create empty notification list
        File file = new File(filePath);
        if (!file.exists()) {
            return notifications; //If file doesn't exist → return empty list.
        }
        try (BufferedReader br = new BufferedReader(new FileReader(file))) { //Opens file for reading.
            String line; //Stores each line temporarily.
            while ((line = br.readLine()) != null) { //read file line by line
                line = line.trim(); // removes extra spaces
                if (!line.isEmpty()) { //skips empty lines
                    notifications.add(Notification.fromFileString(line)); //add object to list
                }
            }
        }
        Collections.reverse(notifications); //Reverses list and Latest notifications appear first.
        return notifications;
    }

    public boolean updateNotification(Notification updated) throws IOException {
        List<String> lines = readFile(); //reads all file lines
        boolean updatedAny = false; // track update status
        for (int i = 0; i < lines.size(); i++) {
            String[] parts = lines.get(i).split(",", 2); //Splits line into ID and remaining content.
            if (parts.length >= 1 && parts[0].equals(updated.getNotificationId())) { //check matching ID
                lines.set(i, updated.toFileString());
                updatedAny = true; //Marks update successful
                break; // stop loop after update
            }
        }
        writeFile(lines); // save updated lines back to file
        return updatedAny;
    }

    public boolean markAllRead() throws IOException { //marks all notification as read
        List<Notification> notifications = getAllNotifications(); //gets all notifications
        boolean updatedAny = false;
        for (Notification notification : notifications) {
            if (!notification.isRead()) { //check unread notifications
                notification.setRead(true); //marks as read
                updateNotification(notification); //save updated notification
                updatedAny = true;
            }
        }
        return updatedAny;
    }

    public Notification getNotificationById(String id) throws IOException { //finds notification by ID
        for (Notification notification : getAllNotifications()) {
            if (notification.getNotificationId().equals(id)) { //cheks matching ID
                return notification; //Returns matching notification.
            }
        }
        return null; //Returns null if not found.
    }

    public boolean deleteNotification(String id) throws IOException {
        List<String> lines = readFile(); //read all file lines
        boolean removed = lines.removeIf(line -> line.startsWith(id + ",")); //remove matching notification line
        writeFile(lines); //save updated file
        return removed; //return delete result
    }

    private List<String> readFile() throws IOException { //reads all line from file
        List<String> lines = new ArrayList<>(); //create empty list
        File file = new File(filePath);
        if (!file.exists())
            return lines; //return empty list if file missing
        try (BufferedReader br = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = br.readLine()) != null) { //read file line by line
                if (!line.trim().isEmpty()) {
                    lines.add(line); // add line into list
                }
            }
        }
        return lines;
    }

    private void writeFile(List<String> lines) throws IOException { //write all lines into file
        File file = new File(filePath);
        file.getParentFile().mkdirs();
        try (FileWriter fw = new FileWriter(file, false)) { //opens file in overwrite mode
            for (String line : lines) {
                fw.write(line + "\n"); //writes line into file
            }
        }
    }
}
