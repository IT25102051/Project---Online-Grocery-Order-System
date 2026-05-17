package com.grocery.dao;

import com.grocery.model.Product;
import java.io.*;
import java.util.*;

public class ProductDAO {
    private final String FILE_PATH = "data/products.txt";

    public void addProduct(Product product) throws IOException {
        File file = new File(FILE_PATH);
        file.getParentFile().mkdirs();

        FileWriter fw = new FileWriter(file, true);
        fw.write(product.toFileString() + "\n");
        fw.close();
    }

    public List<String> getAllProducts() throws IOException {
        return readFile();
    }

    public boolean deleteProduct(String id) throws IOException {
        List<String> lines = readFile();
        boolean removed = lines.removeIf(line -> line.startsWith(id + ","));
        writeFile(lines);
        return removed;
    }

    public boolean updateProduct(Product product) throws IOException {
        List<String> lines = readFile();
        boolean updated = false;
        for (int i = 0; i < lines.size(); i++) {
            String line = lines.get(i);
            if (line.startsWith(product.getId() + ",")) {
                lines.set(i, product.toFileString());
                updated = true;
                break;
            }
        }
        if (updated) {
            writeFile(lines);
        }
        return updated;
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