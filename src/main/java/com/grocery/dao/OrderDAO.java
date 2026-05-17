package com.grocery.dao;

import com.grocery.model.Order;
import java.io.*;
import java.util.*;

public class OrderDAO {
    private final String FILE_PATH = "data/orders.txt";


    public void addOrder(Order order) throws IOException {
        File file = new File(FILE_PATH);
        file.getParentFile().mkdirs();

        FileWriter fw = new FileWriter(file, true);
        fw.write(order.toFileString() + "\n");
        fw.close();
    }

    public List<String> getAllOrders() throws IOException {
        return readFile();
    }

    public boolean deleteOrder(String id) throws IOException {
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
