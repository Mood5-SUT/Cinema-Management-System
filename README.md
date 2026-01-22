# 🎬 Cinema Management System - SQL Database Design

## 📋 Database Overview

A comprehensive SQL database schema for managing a multi-branch cinema system with support for movies, screenings, bookings, payments, and user management.

## 🗺️ Database Schema Diagram

```
Branchs ┬─ Screens ┬─ Showtimes ┬─ Booking ┬─ Payment
        │          │             │          └─ Tickets
        │          │             └─ Movies
        │          └─ Seats
        │
        ├─ Movies (additional relation)
        ├─ Users ┬─ Staff
        │        └─ Customers ─ Reviews
        └─ Booking (customer relation)
```

## 📊 Tables Structure

### **1. Branchs Table** - Cinema Locations
```sql
Branch_id INT PK
Branch_name VARCHAR(55)
Branch_location VARCHAR(100)
Number_of_screens INT
```

### **2. Movies Table** - Film Catalog
```sql
Movie_id INT PK
Movie_name VARCHAR(100)
Duration TIME
Rate FLOAT
Release_date DATE
Genre VARCHAR(60)
Description VARCHAR(350)
Branch_id INT FK → Branchs(Branch_id)  -- Added via ALTER
```

### **3. Screens Table** - Cinema Halls
```sql
Screen_id INT PK
Screen_number INT
Seat_capacity INT
Screen_type VARCHAR(20)  -- e.g., "Standard", "IMAX", "3D"
Branch_id INT FK → Branchs(Branch_id)
```

### **4. Showtimes Table** - Movie Screenings
```sql
Showtime_id INT PK
Start_time TIME
End_time TIME
Showtime_date DATE
Screen_id INT FK → Screens(Screen_id)
Movie_id INT FK → Movies(Movie_id)
```

### **5. Seats Table** - Individual Seating
```sql
Seat_id INT PK
Seat_number INT
Seat_type VARCHAR(15)  -- e.g., "Standard", "VIP", "Handicap"
Seat_status VARCHAR(10)  -- e.g., "Available", "Booked", "Reserved"
Screen_id INT FK → Screens(Screen_id)
```

### **6. Booking Table** - Reservation Records
```sql
Booking_id INT PK
Booking_date DATE
Booking_type VARCHAR(15)  -- e.g., "Online", "Box Office"
Number_of_seats INT
Total_amount DOUBLE
Seat_id INT FK → Seats(Seat_id)
Showtime_id INT FK → Showtimes(Showtime_id)
customer_id INT FK → Customers(customer_id)  -- Added via ALTER
```

### **7. Payment Table** - Transaction Records
```sql
Payment_id INT PK
Payment_method VARCHAR(10)  -- e.g., "Cash", "Card", "Online"
Payment_status VARCHAR(10)  -- e.g., "Pending", "Paid", "Failed"
Payment_date DATE
Booking_id INT FK → Booking(Booking_id)
```

### **8. Tickets Table** - Issued Tickets
```sql
Ticket_id INT PK
Issue_date DATE
Seat_number INT
Seat_id INT FK → Seats(Seat_id)
Booking_id INT FK → Booking(Booking_id)
Payment_id INT FK → Payment(Payment_id)
```

### **9. Users Table** - Authentication System
```sql
User_id INT PK
Email VARCHAR(100) UNIQUE
Password VARCHAR(12)
Role VARCHAR(15)  -- e.g., "Admin", "Staff", "Customer"
Branch_id INT FK → Branchs(Branch_id)  -- NULL for customers
```

### **10. Staff Table** - Employee Records
```sql
Staff_id INT PK
Staff_name VARCHAR(100)
Staff_phone VARCHAR(11)
Staff_email VARCHAR(100)
Job_title VARCHAR(45)
Role VARCHAR(10) DEFAULT 'Staff'
User_id INT FK → Users(User_id)
```

### **11. Customers Table** - Patron Records
```sql
Customer_id INT PK
Customer_name VARCHAR(100)
Customer_phone VARCHAR(11)
Customer_email VARCHAR(100)
Role VARCHAR(10) DEFAULT 'Customer'
User_id INT FK → Users(User_id)
```

### **12. Reviews Table** - Customer Feedback
```sql
Review_id INT PK
Review_rate FLOAT
Comment VARCHAR(150)
Review_date DATE
Customer_id INT FK → Customers(Customer_id)
Movie_id INT FK → Movies(Movie_id)
```

## 🔄 Relationships

### **Primary Foreign Key Relationships**:
1. **Screens → Branchs** (One-to-Many)
2. **Showtimes → Screens** (One-to-Many)
3. **Showtimes → Movies** (One-to-Many)
4. **Seats → Screens** (One-to-Many)
5. **Booking → Seats** (One-to-Many)
6. **Booking → Showtimes** (One-to-Many)
7. **Booking → Customers** (One-to-Many) *[Added via ALTER]*
8. **Payment → Booking** (One-to-One)
9. **Tickets → Seats + Booking + Payment** (Composite)
10. **Staff → Users** (One-to-One)
11. **Customers → Users** (One-to-One)
12. **Reviews → Customers + Movies** (Many-to-One)
13. **Movies → Branchs** (One-to-Many) *[Added via ALTER]*

## 📈 Key Queries

### **1. Complete Showtime Information**
```sql
SELECT 
    Showtimes.Showtime_id,
    Movies.Movie_name,
    Showtimes.Showtime_date,
    Showtimes.Start_time,
    Showtimes.End_time,
    Screens.Screen_number,
    Screens.Screen_type,
    Branchs.Branch_location
FROM Showtimes
JOIN Movies ON Showtimes.Movie_id = Movies.Movie_id
JOIN Screens ON Showtimes.Screen_id = Screens.Screen_id
JOIN Branchs ON Screens.Branch_id = Branchs.Branch_id;
```

### **2. Booking Details with Customer Information**
```sql
SELECT 
    Booking.Booking_id,
    Booking.Booking_date,
    Booking.Booking_type,
    Booking.Total_amount,
    Customers.customer_name,
    Seats.seat_number
FROM Booking 
JOIN Seats ON Booking.Seat_id = Seats.Seat_id
JOIN Customers ON Booking.customer_id = Customers.customer_id;
```

### **3. Movie Review Counts**
```sql
SELECT 
    Movies.Movie_name,
    COUNT(Reviews.Review_id) AS Total_Reviews,
    AVG(Reviews.Review_rate) AS Average_Rating
FROM Movies
LEFT JOIN Reviews ON Movies.Movie_id = Reviews.Movie_id
GROUP BY Movies.Movie_name
ORDER BY Total_Reviews DESC;
```

## 🔧 Modifications Applied

### **ALTER Statements Applied**:
```sql
-- 1. Add Branch relationship to Movies
ALTER TABLE movies
ADD COLUMN Branch_id INT;

ALTER TABLE movies
ADD CONSTRAINT fk_movies_branch
FOREIGN KEY (Branch_id) REFERENCES Branchs(Branch_id);

-- 2. Add Customer relationship to Booking
ALTER TABLE Booking
ADD COLUMN customer_id INT;

ALTER TABLE Booking
ADD CONSTRAINT fk_booking_customer
FOREIGN KEY (customer_id) REFERENCES Customers(customer_id);
```

## 💡 Business Logic Implementation

### **1. Seat Availability Check** (Example Trigger Concept)
```sql
-- Before booking, check if seat is available
DELIMITER $$
CREATE TRIGGER check_seat_availability
BEFORE INSERT ON Booking
FOR EACH ROW
BEGIN
    DECLARE seat_status VARCHAR(10);
    
    SELECT Seat_status INTO seat_status
    FROM Seats WHERE Seat_id = NEW.Seat_id;
    
    IF seat_status != 'Available' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Seat is not available';
    END IF;
END$$
DELIMITER ;
```

### **2. Automatic Ticket Generation** (Example Procedure)
```sql
DELIMITER $$
CREATE PROCEDURE GenerateTickets(IN booking_id INT)
BEGIN
    DECLARE seat_num INT;
    DECLARE seat_id_val INT;
    DECLARE payment_id_val INT;
    
    -- Get booking details
    SELECT Seat_id INTO seat_id_val FROM Booking WHERE Booking_id = booking_id;
    SELECT Payment_id INTO payment_id_val FROM Payment WHERE Booking_id = booking_id;
    SELECT Seat_number INTO seat_num FROM Seats WHERE Seat_id = seat_id_val;
    
    -- Insert ticket
    INSERT INTO Tickets (Issue_date, Seat_number, Seat_id, Booking_id, Payment_id)
    VALUES (CURDATE(), seat_num, seat_id_val, booking_id, payment_id_val);
    
    -- Update seat status
    UPDATE Seats SET Seat_status = 'Booked' WHERE Seat_id = seat_id_val;
END$$
DELIMITER ;
```

## 🎯 Use Cases

### **For Cinema Management**:
1. **Branch Operations**: Track screens, capacity, and types
2. **Movie Scheduling**: Manage showtimes across multiple screens
3. **Revenue Tracking**: Monitor booking and payment status
4. **Customer Management**: Handle patron information and reviews

### **For Customers**:
1. **Movie Selection**: View showtimes and ratings
2. **Seat Booking**: Choose preferred seats
3. **Payment Processing**: Multiple payment methods
4. **Feedback System**: Submit reviews and ratings

### **For Staff**:
1. **Booking Management**: Handle box office transactions
2. **Screen Management**: Monitor seat availability
3. **Reporting**: Generate sales and attendance reports

## 📊 Sample Data Population

### **Insert Sample Branches**:
```sql
INSERT INTO Branchs (Branch_name, Branch_location, Number_of_screens)
VALUES 
    ('Downtown Cinema', '123 Main St, City Center', 8),
    ('Mall Cinema', '456 Mall Rd, Shopping District', 6),
    ('Premium Cinema', '789 Luxury Blvd, Uptown', 4);
```

### **Insert Sample Movies**:
```sql
INSERT INTO Movies (Movie_name, Duration, Rate, Release_date, Genre, Description, Branch_id)
VALUES 
    ('The Adventure Begins', '02:15:00', 8.5, '2024-03-01', 'Action', 'An epic journey starts...', 1),
    ('Romantic Nights', '01:45:00', 7.8, '2024-02-14', 'Romance', 'A love story for the ages...', 1);
```

## 🔍 Optimization Suggestions

### **1. Indexing Strategy**:
```sql
-- Add indexes for frequently queried columns
CREATE INDEX idx_showtimes_date ON Showtimes(Showtime_date);
CREATE INDEX idx_movies_genre ON Movies(Genre);
CREATE INDEX idx_booking_date ON Booking(Booking_date);
CREATE INDEX idx_customers_email ON Customers(Customer_email);
```

### **2. Partitioning** (For large datasets):
```sql
-- Partition Booking table by month for archival
ALTER TABLE Booking PARTITION BY RANGE (YEAR(Booking_date)*100 + MONTH(Booking_date)) (
    PARTITION p202401 VALUES LESS THAN (202402),
    PARTITION p202402 VALUES LESS THAN (202403),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);
```

## 🛡️ Security Considerations

### **User Authentication Flow**:
1. Users register via `Users` table
2. Role-based access control (Admin/Staff/Customer)
3. Passwords should be hashed (not plain VARCHAR(12))
4. Consider implementing `Password_hash` column with proper encryption

### **Data Privacy**:
1. Customer PII (email, phone) in separate table
2. Payment details should be tokenized
3. Consider GDPR compliance for EU customers

## 📈 Reporting Queries

### **Daily Revenue Report**:
```sql
SELECT 
    DATE(Booking.Booking_date) AS Sale_Date,
    COUNT(Booking.Booking_id) AS Total_Bookings,
    SUM(Booking.Total_amount) AS Daily_Revenue,
    Branchs.Branch_name
FROM Booking
JOIN Showtimes ON Booking.Showtime_id = Showtimes.Showtime_id
JOIN Screens ON Showtimes.Screen_id = Screens.Screen_id
JOIN Branchs ON Screens.Branch_id = Branchs.Branch_id
WHERE Booking.Booking_date = CURDATE()
GROUP BY Sale_Date, Branchs.Branch_name;
```

### **Popular Movies Report**:
```sql
SELECT 
    Movies.Movie_name,
    COUNT(Booking.Booking_id) AS Tickets_Sold,
    AVG(Reviews.Review_rate) AS Average_Rating,
    Branchs.Branch_name
FROM Movies
LEFT JOIN Showtimes ON Movies.Movie_id = Showtimes.Movie_id
LEFT JOIN Booking ON Showtimes.Showtime_id = Booking.Showtime_id
LEFT JOIN Reviews ON Movies.Movie_id = Reviews.Movie_id
LEFT JOIN Branchs ON Movies.Branch_id = Branchs.Branch_id
WHERE Movies.Release_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY Movies.Movie_name, Branchs.Branch_name
ORDER BY Tickets_Sold DESC;
```

## 🔄 Migration & Backup Strategy

### **Regular Backups**:
```sql
-- Daily backup script
mysqldump -u root -p Cinema > cinema_backup_$(date +%Y%m%d).sql
```

### **Version Control**:
- Keep DDL scripts in Git
- Document all schema changes
- Use migration tools for production

## 🚀 Deployment Checklist

- [ ] Create database with `CREATE DATABASE Cinema;`
- [ ] Run all CREATE TABLE statements
- [ ] Apply ALTER TABLE modifications
- [ ] Create necessary indexes
- [ ] Insert initial data (branches, admin users)
- [ ] Test key queries
- [ ] Set up backup schedule
- [ ] Configure user permissions

## 📝 Notes for Developers

1. **Seat Management**: Consider implementing seat locking during booking process
2. **Concurrent Booking**: Implement transaction isolation for seat selection
3. **Payment Gateway Integration**: Extend Payment table for transaction IDs
4. **Mobile App Support**: Consider API endpoints for mobile access
5. **Analytics Integration**: Add columns for tracking source of bookings

---

## 📞 Support & Maintenance

### **Regular Maintenance Tasks**:
1. **Daily**: Check booking/payment synchronization
2. **Weekly**: Clean up expired showtimes
3. **Monthly**: Archive old booking records
4. **Quarterly**: Update movie catalog

### **Monitoring**:
- Track database size growth
- Monitor query performance
- Set alerts for failed payments
- Regular security audits

---

*Database Version: 1.0.0*  
*Last Updated: 20-5-2025*  
*Compatible with: MySQL 5.7+, MariaDB 10.3+*
