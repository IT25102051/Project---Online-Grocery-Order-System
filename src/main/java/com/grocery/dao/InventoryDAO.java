package com.grocery.dao;

import com.grocery.model.Inventory;
import java.io.*;
import java.util.*;

public class InventoryDAO {
    private final String filePath;

    public InventoryDAO(String dataDirectory) {
        File directory = new File(dataDirectory);
        File file = new File(directory, "inventory.txt");
        this.filePath = file.getAbsolutePath();
    }

    public void addInventory(Inventory inventory) throws IOException {
        File file = new File(filePath);
        file.getParentFile().mkdirs();

        try (FileWriter fw = new FileWriter(file, true)) {
            fw.write(inventory.toFileString() + "\n");
        }
    }

    public List<String> getAllInventory() throws IOException {
        return readFile();
    }

    public boolean deleteInventory(String id) throws IOException {
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
                lines.add(line);
            }
        }

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