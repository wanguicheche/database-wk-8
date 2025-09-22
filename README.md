# 📚 Simple Library Management Database (MySQL)

## Overview
This project is a **simple Library Management System** implemented in **MySQL**.  
It was created as part of my database assignment. The goal is to design, implement, and test a small relational database that supports basic library operations such as tracking books, authors, members, copies, and loans.

A corresponding **Entity–Relationship Diagram (ERD)** sketch has been created in **draw.io** and is attached in this repository.

---

## Database Design
The system contains 6 main tables:

1. **Authors** – stores author details.  
2. **Books** – stores book details (title, ISBN, year).  
3. **Book_Authors** – junction table for the many-to-many relationship between books and authors.  
4. **Copies** – tracks physical copies of books with barcodes and status (available/loaned/lost).  
5. **Members** – library members who borrow books.  
6. **Loans** – records borrowing transactions (who borrowed which copy, when, and return status).

---

## Features
- ✅ **Relational integrity** with primary keys and foreign keys.  
- ✅ **Support for many-to-many** (Books ↔ Authors) using a junction table.  
- ✅ **Sample data included** (authors, books, members, loans).  
- ✅ **Test queries** to verify results.  

---

## How to Run
1. Open **MySQL Workbench** (or any MySQL client).  
2. Create the database using the provided `CREATE DATABASE` script.  
3. Execute the `CREATE TABLE` scripts in order.  
4. Insert the sample data with the provided `INSERT` statements.  
5. Run the test queries to confirm the schema is working.

---

## Files Included
- `library_schema.sql` → SQL code to create the database schema.  
- `library_seed.sql` → Sample data inserts.  
- `queries.sql` → Example SELECT queries.  
- `library_erd.drawio.png` → ERD sketch exported from draw.io.  
- `README.md` → This file.

---

## Notes
- The ERD sketch was created using **draw.io** and exported as a PNG for easier viewing.  
- The database uses **InnoDB** storage engine to support transactions and foreign keys.  
- Code is kept intentionally **simple and beginner-friendly**, following good practices.

---
