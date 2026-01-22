CREATE DATABASE Cinema;
USE Cinema;

-- Create Branchs table
CREATE TABLE Branchs (
    Branch_id INT PRIMARY KEY AUTO_INCREMENT,
    Branch_name VARCHAR(55),
    Branch_location VARCHAR(100),
    Number_of_screens INT
);

-- Create Movies table
CREATE TABLE Movies (
    Movie_id INT PRIMARY KEY AUTO_INCREMENT,
    Movie_name VARCHAR(100),
    Duration TIME,
    Rate FLOAT,
    Release_date DATE,
    Genre VARCHAR(60),
    Description VARCHAR(350)
);

-- Create Screens table
CREATE TABLE Screens (
    Screen_id INT PRIMARY KEY AUTO_INCREMENT,
    Screen_number INT,
    Seat_capacity INT,
    Screen_type VARCHAR(20),
    Branch_id INT,
    FOREIGN KEY (Branch_id) REFERENCES Branchs(Branch_id)
);

-- Create Showtimes table
CREATE TABLE Showtimes (
    Showtime_id INT PRIMARY KEY AUTO_INCREMENT,
    Start_time TIME,
    End_time TIME,
    Showtime_date DATE,
    Screen_id INT,
    Movie_id INT,
    FOREIGN KEY (Screen_id) REFERENCES Screens(Screen_id),
    FOREIGN KEY (Movie_id) REFERENCES Movies(Movie_id)
);
	
-- Create Seats table
CREATE TABLE Seats (
    Seat_id INT PRIMARY KEY AUTO_INCREMENT,
    Seat_number INT,
    Seat_type VARCHAR(15),
    Seat_status VARCHAR(10),
    Screen_id INT,
    FOREIGN KEY (Screen_id) REFERENCES Screens(Screen_id)
);

-- Create Booking table
CREATE TABLE Booking (
    Booking_id INT PRIMARY KEY AUTO_INCREMENT,
    Booking_date DATE,
    Booking_type VARCHAR(15),
    Number_of_seats INT,
    Total_amount DOUBLE,
    Seat_id INT,
    Showtime_id INT,
    FOREIGN KEY (Seat_id) REFERENCES Seats(Seat_id),
    FOREIGN KEY (Showtime_id) REFERENCES Showtimes(Showtime_id)
);

-- Create Payment table
CREATE TABLE Payment (
    Payment_id INT PRIMARY KEY AUTO_INCREMENT,
    Payment_method VARCHAR(10),
    Payment_status VARCHAR(10),
    Payment_date DATE,
    Booking_id INT,
    FOREIGN KEY (Booking_id) REFERENCES Booking(Booking_id)
);

-- Create Tickets table
CREATE TABLE Tickets (
    Ticket_id INT PRIMARY KEY AUTO_INCREMENT,
    Issue_date DATE,
    Seat_number INT,
    Seat_id INT,
    Booking_id INT,
    Payment_id INT,
    FOREIGN KEY (Seat_id) REFERENCES Seats(Seat_id),
    FOREIGN KEY (Booking_id) REFERENCES Booking(Booking_id),
    FOREIGN KEY (Payment_id) REFERENCES Payment(Payment_id)
);

-- Create Users table
CREATE TABLE Users (
    User_id INT PRIMARY KEY AUTO_INCREMENT,
    Email VARCHAR(100) UNIQUE,
    Password VARCHAR(12),
    Role VARCHAR(15),
    Branch_id INT,
    FOREIGN KEY (Branch_id) REFERENCES Branchs(Branch_id)
);

-- Create Staff table (linked to Users optionally)
CREATE TABLE Staff (
    Staff_id INT PRIMARY KEY AUTO_INCREMENT,
    Staff_name VARCHAR(100),
    Staff_phone VARCHAR(11),
    Staff_email VARCHAR(100),
    Job_title VARCHAR(45),
    Role VARCHAR(10) DEFAULT 'Staff',
    User_id INT,
    FOREIGN KEY (User_id) REFERENCES Users(User_id)
);

-- Create Customers table (linked to Users optionally)
CREATE TABLE Customers (
    Customer_id INT PRIMARY KEY AUTO_INCREMENT,
    Customer_name VARCHAR(100),
    Customer_phone VARCHAR(11),
    Customer_email VARCHAR(100),
    Role VARCHAR(10) DEFAULT 'Customer',
    User_id INT,
    FOREIGN KEY (User_id) REFERENCES Users(User_id)
);

-- Create Reviews table
CREATE TABLE Reviews (
    Review_id INT PRIMARY KEY AUTO_INCREMENT,
    Review_rate FLOAT,
    Comment VARCHAR(150),
    Review_date DATE,
    Customer_id INT,
    Movie_id INT,
    FOREIGN KEY (Customer_id) REFERENCES Customers(Customer_id),
    FOREIGN KEY (Movie_id) REFERENCES Movies(Movie_id)
);

alter table movies
add column Branch_id int;

alter table movies
add constraint relation
foreign key (Branch_id) references Branchs(Branch_id);

select showtimes.showtime_id,showtimes.start_time,showtimes.End_time,showtimes.showtime_date,movies.Movie_name,screens.screen_number,Branchs.Branch_location
from showtimes
join Movies on showtimes.Movie_id=Movies.Movie_id
join screens on  showtimes.screen_id=screens.screen_id
join branchs on screens.Branch_id=Branchs.Branch_id


Alter table Booking
add column customer_id int;

alter table Booking
add constraint co
foreign key (customer_id) references Customers(customer_id);



select Booking.Total_amount, Booking.Booking_type,Booking.Booking_id,Booking.Booking_date,Customers.customer_name,Seats.seat_number
from Booking 
join Seats on Booking.Seat_id=Seats.Seat_id
join Customers on Booking.customer_id=Customers.customer_id;


SELECT 
    Showtimes.Showtime_id,
    Movies.Movie_name,
    Showtimes.Showtime_date,
    Showtimes.Start_time,
    Showtimes.End_time,
    Screens.Screen_number,
    Screens.Screen_type
FROM Showtimes
JOIN Movies ON Showtimes.Movie_id = Movies.Movie_id
JOIN Screens ON Showtimes.Screen_id = Screens.Screen_id;

SELECT 
    Movies.Movie_name,
    COUNT(Reviews.Review_id) AS Total_Reviews
FROM Movies
LEFT JOIN Reviews ON Movies.Movie_id = Reviews.Movie_id
GROUP BY Movies.Movie_name;



