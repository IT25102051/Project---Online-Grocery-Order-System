package com.grocery.util;

import java.io.*;

public class FileHandler {

    public static void write(String filePath, String data) {
        try (FileWriter fw = new FileWriter(filePath, true)) {
            fw.write(data + "\n");
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static String read(String filePath) {
        StringBuilder sb = new StringBuilder();

        try (BufferedReader br = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = br.readLine()) != null) {
                sb.append(line).append("\n");
            }
        } catch (IOException e) {
            e.printStackTrace();
        }

        return sb.toString();
    }
}
