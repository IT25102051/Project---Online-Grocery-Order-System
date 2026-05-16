🛒 CeylonFresh — Online Grocery Order System
> A full-stack Java Web Application (JSP + Servlets) for managing an online grocery store — built for customers, admins, and delivery personnel.
---
📌 Project Overview
CeylonFresh is a multi-role online grocery ordering system developed using Java Servlets, JSP, and file-based persistence (no database). It supports three distinct user roles — Customer, Admin, and Delivery — each with their own dashboard and functionality.
---
🚀 Features
👤 Customer
Register and log in securely
Browse products by category or search
Add products to cart and manage quantities
Checkout with Cash on Delivery or Credit/Debit Card
View order history and payment history
Submit and view product reviews and ratings
Receive real-time notifications (order status updates)
🛠️ Admin
Manage users (view, delete)
Add, update, and delete products (with image URL, expiry date, description)
View and manage all orders (update status: Confirmed → Prepared)
View payment records
Manage inventory — request stock replenishments with supplier info
Send notifications to All / specific users or roles
View and moderate product reviews
View reports and analytics
🚚 Delivery Personnel
View orders ready for pickup (status: Prepared)
Mark orders as Picked Up, Delivered, or Not Delivered
Automatically update payment status for Cash on Delivery orders
Receive low-stock alerts and inventory notifications
Manage inventory restock status
---
🏗️ Technology Stack
Layer	Technology
Backend	Java Servlets (javax.servlet)
Frontend	JSP (JavaServer Pages), HTML, CSS, JavaScript
Server	Apache Tomcat 9+
Build Tool	Maven
Persistence	Flat file storage (`.txt` files)
IDE	IntelliJ IDEA (with SmartTomcat plugin)
---
📁 Project Structure
```
src/
└── main/
    ├── java/
    │   └── com/grocery/
    │       ├── model/          # POJOs: User, Admin, Customer, Product, Order, Cart, Payment, Inventory, Review, Notification
    │       ├── dao/            # Data Access Objects (file I/O): UserDAO, ProductDAO, OrderDAO, PaymentDAO, InventoryDAO, ReviewDAO, NotificationDAO
    │       ├── servlet/        # HTTP Servlets: LoginServlet, UserServlet, ProductServlet, CartServlet, OrderServlet, PaymentServlet, InventoryServlet, ReviewServlet, NotificationServlet, LogoutServlet
    │       └── util/           # Utility: FileHandler
    └── webapp/
        ├── *.jsp               # Views: login, register, dashboards, products, cart, checkout, orders, reviews, notifications, admin panels, delivery panels
        └── data/               # Auto-generated flat files: users.txt, products.txt, cart.txt, orders.txt, payments.txt, inventory.txt, reviews.txt, notifications.txt, order_items.txt
```
---
🔧 Setup & Installation
Prerequisites
Java JDK 17+
Apache Maven 3.8+
Apache Tomcat 9.x or 10.x
IntelliJ IDEA (recommended) with SmartTomcat plugin
Steps
Clone the repository
```bash
   git clone https://github.com/your-username/Online_Grocery_Order_System.git
   cd Online_Grocery_Order_System
   ```
Build the project
```bash
   mvn clean install
   ```
Deploy to Tomcat
Option A: Use IntelliJ IDEA's SmartTomcat plugin (configured in `.smarttomcat/`)
Option B: Copy the generated `.war` from `target/` to Tomcat's `webapps/` directory
Option C: Run via Maven Tomcat plugin
Access the application
```
   http://localhost:8080/
   ```
Register a new account or use the admin login page at:
```
   http://localhost:8080/adminLogin.jsp
   ```
> To create the first Admin user, manually add a line to `data/users.txt`:
   > ```
   > <uuid>,Admin Name,admin@email.com,password,Admin
   > ```
---
💾 Data Storage
All data is persisted in plain-text CSV-style files under `{webapp_root}/data/`:
File	Contents
`users.txt`	id, name, email, password, role
`products.txt`	id, name, category, price, stock, imageUrl, description, expiryDate
`cart.txt`	cartId, userId, productId, quantity
`orders.txt`	orderId, userId, name, total, paymentMethod, address, phone, status, deliveryId
`order_items.txt`	orderItemId, orderId, productId, quantity, price
`payments.txt`	paymentId, orderId, method, amount, status
`inventory.txt`	inventoryId, productId, productName, stock, supplier, status
`reviews.txt`	reviewId, productName, userName, rating, comment
`notifications.txt`	notificationId, recipient, title, message, timestamp, read/unread
---
🧩 Architecture
This project follows a 3-Layer MVC Architecture:
```
View (JSP)  ←→  Controller (Servlet)  ←→  DAO (File I/O)  ←→  Model (POJO)
```
Model: Plain Java objects with `toFileString()` serialization
DAO: Reads/writes flat `.txt` files; no external database
Servlet: Handles HTTP requests, business logic, session management, redirects
View: JSP pages that render data passed via request/session attributes
OOP Concepts Used
Concept	Where
Inheritance	`Admin extends User`, `Customer extends User`
Polymorphism	`getDashboardAccess()` overridden in Admin, Customer
Encapsulation	Private fields with getters/setters in all model classes
Abstraction	DAO pattern abstracts file storage from servlets
---
📋 Modules
User Management — Registration, Login, Role-based access, Session management
Product Management — CRUD operations on grocery products
Cart Module — Add to cart, update quantity, remove items
Order Management — Checkout, order lifecycle (Confirmed → Prepared → Picked Up → Delivered)
Payment Module — COD and Card payments; auto-status update on delivery
Inventory Management — Stock tracking, restock requests, supplier management
Review & Rating System — Product reviews with star ratings
Notification System — Role-based notifications with read/unread tracking
---
🤝 Contributing
Fork the repository
Create your feature branch: `git checkout -b feature/my-feature`
Commit your changes: `git commit -m 'Add some feature'`
Push to the branch: `git push origin feature/my-feature`
Open a Pull Request
---
📄 License
This project is for academic/educational purposes.
---
👨‍💻 Authors
Developed as part of an Object-Oriented Programming (OOP) module project
