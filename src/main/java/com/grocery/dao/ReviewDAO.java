package com.grocery.dao;

import com.grocery.model.Review;
import java.io.*;
import java.util.*;

public class ReviewDAO {
    private final String FILE_PATH = "data/reviews.txt";

    public void addReview(Review review) throws IOException {
        File file = new File(FILE_PATH);
        file.getParentFile().mkdirs();

        FileWriter fw = new FileWriter(file, true);
        fw.write(review.toFileString() + "\n");
        fw.close();
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
        File file = new File(FILE_PATH);

        if (!file.exists()) return lines;

        BufferedReader br = new BufferedReader(new FileReader(file));
        String line;

        while ((line = br.readLine()) != null) {
            lines.add(line);
        }

        br.close();
        return lines;
    }

    private void writeFile(List<String> lines) throws IOException {
        FileWriter fw = new FileWriter(FILE_PATH, false);

        for (String line : lines) {
            fw.write(line + "\n");
        }

        fw.close();
    }
}
