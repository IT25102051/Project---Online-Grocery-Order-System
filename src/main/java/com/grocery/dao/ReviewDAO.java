package com.grocery.dao;

import com.grocery.model.Review;
import java.io.*;
import java.util.*;

public class ReviewDAO {
    private final String filePath;

    public ReviewDAO(String appRealPath) {
        this.filePath = appRealPath + "data/reviews.txt";
    }

    public ReviewDAO() {
        this.filePath = "data/reviews.txt";
    }

    public void addReview(Review review) throws IOException {
        File file = new File(filePath);
        file.getParentFile().mkdirs();

        try (FileWriter fw = new FileWriter(file, true)) {
            fw.write(review.toFileString() + "\n");
        }
    }

    public List<Review> getAllReviewObjects() throws IOException {
        List<Review> reviews = new ArrayList<>();
        List<String> lines = readFile();
        for (String line : lines) {
            String[] parts = line.split(",", 5);
            if (parts.length >= 5) {
                reviews.add(new Review(
                        parts[0].trim(),
                        parts[1].trim(),
                        parts[2].trim(),
                        Integer.parseInt(parts[3].trim()),
                        parts[4].trim()
                ));
            }
        }
        return reviews;
    }

    public Review getReviewById(String id) throws IOException {
        List<Review> reviews = getAllReviewObjects();
        for (Review r : reviews) {
            if (r.getReviewId().equals(id)) {
                return r;
            }
        }
        return null;
    }

    public List<String> getAllReviews() throws IOException {
        return readFile();
    }

    public boolean deleteReview(String id) throws IOException {
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
                String trimmed = line.trim();
                if (!trimmed.isEmpty()) {
                    lines.add(trimmed);
                }
            }
        }

        return lines;
    }

    private void writeFile(List<String> lines) throws IOException {
        File file = new File(filePath);
        if (file.getParentFile() != null) {
            file.getParentFile().mkdirs();
        }

        try (FileWriter fw = new FileWriter(file, false)) {
            for (String line : lines) {
                fw.write(line + "\n");
            }
        }
    }
}
