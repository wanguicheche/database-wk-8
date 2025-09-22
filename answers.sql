-- Step 1: Create a database
CREATE DATABASE simple_library
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_0900_ai_ci;
-- Tell MySQL we’ll use this database for the next commands
USE simple_library;

-- Step 2: Create the 6 tables (in dependency order)
-- AUTHORS: unique by name ; --- InnoDB is the default and most common engine. Our library DB needs relationships (FK constraints) and safe updates, InnoDB is the right choice.
CREATE TABLE authors (
  author_id  INT AUTO_INCREMENT PRIMARY KEY,
  full_name  VARCHAR(120) NOT NULL UNIQUE
) ENGINE=InnoDB;  

-- BOOKS: with attributes + unique ISBN
CREATE TABLE books (
  book_id      INT AUTO_INCREMENT PRIMARY KEY,
  title        VARCHAR(200) NOT NULL,
  isbn_13      CHAR(13) NOT NULL UNIQUE,
  publish_year INT NULL
) ENGINE=InnoDB;

-- Junction for M:N: Books_Authors
-- BOOK_AUTHORS: resolves many-to-many (book ↔ author)
CREATE TABLE book_authors (
  book_id   INT NOT NULL,   -- FK → books.book_id
  author_id INT NOT NULL,   -- FK → authors.author_id
  PRIMARY KEY (book_id, author_id),
  CONSTRAINT fk_ba_book
    FOREIGN KEY (book_id) REFERENCES books(book_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_ba_author
    FOREIGN KEY (author_id) REFERENCES authors(author_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- create physical copies of the books
CREATE TABLE copies (
  copy_id  INT AUTO_INCREMENT PRIMARY KEY,
  book_id  INT NOT NULL,
  barcode  VARCHAR(32) NOT NULL UNIQUE,  -- sticker on the copy
  status   ENUM('AVAILABLE','LOANED','LOST') NOT NULL DEFAULT 'AVAILABLE',
  CONSTRAINT fk_copy_book
    FOREIGN KEY (book_id) REFERENCES books(book_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Helpful lookup
CREATE INDEX idx_copies_book ON copies(book_id);

-- MEMBERS: people who borrow books
CREATE TABLE members (
  member_id  INT AUTO_INCREMENT PRIMARY KEY,
  full_name  VARCHAR(120) NOT NULL,
  email      VARCHAR(120) NOT NULL UNIQUE,
  joined_at  DATE NOT NULL
) ENGINE=InnoDB;

-- LOANS: one member borrows one copy
CREATE TABLE loans (
  loan_id     INT AUTO_INCREMENT PRIMARY KEY,
  copy_id     INT NOT NULL,     -- FK → copies.copy_id
  member_id   INT NOT NULL,     -- FK → members.member_id
  loan_date   DATE NOT NULL,
  due_date    DATE NOT NULL,
  return_date DATE NULL,        -- NULL until returned
  CONSTRAINT fk_loan_copy
    FOREIGN KEY (copy_id) REFERENCES copies(copy_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_loan_member
    FOREIGN KEY (member_id) REFERENCES members(member_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CHECK (loan_date <= due_date)
) ENGINE=InnoDB;

CREATE INDEX idx_loans_member ON loans(member_id);
CREATE INDEX idx_loans_copy   ON loans(copy_id);

-- STEP 3 — Insert a few rows so queries show results
-- Authors
INSERT INTO authors (full_name) VALUES
  ('J. R. R. Tolkien'),
  ('Harper Lee'),
  ('Andrew S. Tanenbaum');

-- Books
INSERT INTO books (title, isbn_13, publish_year) VALUES
  ('The Hobbit', '9780547928227', 1937),
  ('To Kill a Mockingbird', '9780061120084', 1960),
  ('Modern Operating Systems', '9780133591620', 2014);

-- M:N links (Book ↔ Author)
INSERT INTO book_authors (book_id, author_id) VALUES
  (1, 1),   -- Hobbit ↔ Tolkien
  (2, 2),   -- TKAM  ↔ Harper Lee
  (3, 3);   -- MOS   ↔ Tanenbaum

-- Copies
INSERT INTO copies (book_id, barcode, status) VALUES
  (1, 'HOB-0001', 'AVAILABLE'),
  (1, 'HOB-0002', 'AVAILABLE'),
  (2, 'TKM-0001', 'AVAILABLE'),
  (3, 'MOS-0001', 'AVAILABLE');

-- Members
INSERT INTO members (full_name, email, joined_at) VALUES
  ('Aisha Bello',  'aisha@aol.com',  '2024-01-10'),
  ('Marco Chen',   'marco@yahoo.com',  '2024-03-05'),
  ('Sara Johnson', 'sara.j@gmail.com', '2024-05-22');

-- Loans: one ongoing, one returned
INSERT INTO loans (copy_id, member_id, loan_date, due_date, return_date) VALUES
  (1, 1, '2025-09-10', '2025-09-24', NULL),          -- Aisha borrowing HOB-0001
  (4, 2, '2025-08-01', '2025-08-15', '2025-08-12');  -- Marco borrowed & returned MOS-0001

-- Reflect the ongoing loan in copy status (simple manual update)
UPDATE copies SET status = 'LOANED'    WHERE copy_id = 1;
UPDATE copies SET status = 'AVAILABLE' WHERE copy_id = 4;

-- STEP 4 — Quick checks
-- Books with their authors
SELECT b.title, a.full_name AS author
FROM books b
JOIN book_authors ba ON ba.book_id = b.book_id
JOIN authors a ON a.author_id = ba.author_id
ORDER BY b.title;

-- Copies and their availability
SELECT c.copy_id, c.barcode, b.title, c.status
FROM copies c
JOIN books b ON b.book_id = c.book_id
ORDER BY b.title, c.copy_id;

-- Current and recent loans with borrower names
SELECT l.loan_id, b.title, c.barcode, m.full_name, l.loan_date, l.due_date, l.return_date
FROM loans l
JOIN copies c  ON c.copy_id   = l.copy_id
JOIN books b   ON b.book_id   = c.book_id
JOIN members m ON m.member_id = l.member_id
ORDER BY l.loan_date DESC;



