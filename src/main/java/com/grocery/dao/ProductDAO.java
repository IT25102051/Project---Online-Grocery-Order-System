package com.grocery.dao;

import com.grocery.model.Product;
import java.io.*;
import java.util.*;

public class ProductDAO {
    private String filePath;

    public ProductDAO() {
        // Fallback for cases where path isn't provided
        this.filePath = "data/products.txt";
    }

    public ProductDAO(String basePath) {
        this.filePath = basePath + File.separator + "data" + File.separator + "products.txt";
    }

    public void addProduct(Product product) throws IOException {
        File file = new File(filePath);
        if (file.getParentFile() != null) {
            file.getParentFile().mkdirs();
        }

        try (FileWriter fw = new FileWriter(file, true)) {
            fw.write(product.toFileString() + "\n");
        }
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
        File file = new File(filePath);

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
        try (FileWriter fw = new FileWriter(filePath, false)) {
            for (String line : lines) {
                fw.write(line + "\n");
            }
        }
    }
}
