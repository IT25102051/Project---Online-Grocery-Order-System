package com.grocery.dao;

import com.grocery.model.Notification;
import java.io.*;
import java.util.*;

public class NotificationDAO {
    private final String filePath;

    public NotificationDAO(String appRealPath) {
        this.filePath = appRealPath + "data/notifications.txt";
    }

    public void addNotification(Notification notification) throws IOException {
        File file = new File(filePath);
        file.getParentFile().mkdirs();
        try (FileWriter fw = new FileWriter(file, true)) {
            fw.write(notification.toFileString() + "\n");
        }
    }

    public List<Notification> getAllNotifications() throws IOException {
        List<Notification> notifications = new ArrayList<>();
        File file = new File(filePath);
        if (!file.exists()) {
            return notifications;
        }
        try (BufferedReader br = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = br.readLine()) != null) {
                line = line.trim();
                if (!line.isEmpty()) {
                    notifications.add(Notification.fromFileString(line));
                }
            }
        }
        Collections.reverse(notifications);
        return notifications;
    }

    public boolean updateNotification(Notification updated) throws IOException {
        List<String> lines = readFile();
        boolean updatedAny = false;
        for (int i = 0; i < lines.size(); i++) {
            String[] parts = lines.get(i).split(",", 2);
            if (parts.length >= 1 && parts[0].equals(updated.getNotificationId())) {
                lines.set(i, updated.toFileString());
                updatedAny = true;
                break;
            }
        }
        writeFile(lines);
        return updatedAny;
    }

    public boolean markAllRead() throws IOException {
        List<Notification> notifications = getAllNotifications();
        boolean updatedAny = false;
        for (Notification notification : notifications) {
            if (!notification.isRead()) {
                notification.setRead(true);
                updateNotification(notification);
                updatedAny = true;
            }
        }
        return updatedAny;
    }

    public Notification getNotificationById(String id) throws IOException {
        for (Notification notification : getAllNotifications()) {
            if (notification.getNotificationId().equals(id)) {
                return notification;
            }
        }
        return null;
    }

    public boolean deleteNotification(String id) throws IOException {
        List<String> lines = readFile();
        boolean removed = lines.removeIf(line -> line.startsWith(id + ","));
        writeFile(lines);
        return removed;
    }

    private List<String> readFile() throws IOException {
        List<String> lines = new ArrayList<>();
        File file = new File(filePath);
        if (!file.exists()) return lines;
        try (BufferedReader br = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = br.readLine()) != null) {
                if (!line.trim().isEmpty()) {
                    lines.add(line);
                }
            }
        }
        return lines;
    }

    private void writeFile(List<String> lines) throws IOException {
        File file = new File(filePath);
        file.getParentFile().mkdirs();
        try (FileWriter fw = new FileWriter(file, false)) {
            for (String line : lines) {
                fw.write(line + "\n");
            }
        }
    }
}
