create database music_database;
use music_database;
select * from album;
select * from artist;
select * from customer;
select * from employee;
select * from genre;
select * from invoice;
select * from invoice_line;
select * from media_type;
select * from playlist;
select * from playlist_track;
select * from track;


-- Question Set 1 - Easy

-- Q1: Who is the senior most employee based on job title?

SELECT employee_id, first_name, last_name, title, levels
FROM employee
ORDER BY levels DESC
LIMIT 1;


-- Q2: Which countries have the most Invoices?

SELECT billing_country, COUNT(*) AS num_invoices
FROM invoice
GROUP BY billing_country
ORDER BY num_invoices DESC;


-- Q3: What are top 3 values of total invoice?

SELECT total
FROM invoice
ORDER BY total DESC
LIMIT 3;


-- Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals


SELECT c.city, SUM(i.total) AS total_invoice_amount
FROM invoice i
JOIN customer c ON i.customer_id = c.customer_id
GROUP BY c.city
ORDER BY total_invoice_amount DESC
LIMIT 1;


-- Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. Write a query that returns the person who has spent the most money.

SELECT c.first_name, c.last_name, total_spending
FROM customer c
JOIN (
    SELECT customer_id, SUM(total) AS total_spending
    FROM invoice
    GROUP BY customer_id
) i ON c.customer_id = i.customer_id
ORDER BY total_spending DESC
LIMIT 1;


# -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Question Set 2 - Moderate

-- Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A.

SELECT DISTINCT c.email, c.first_name, c.last_name, g.name AS genre
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
ORDER BY c.email ASC;



-- Q2: Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands.

SELECT a.name AS artist_name, COUNT(t.track_id) AS total_track_count
FROM artist a
JOIN album al ON a.artist_id = al.artist_id
JOIN track t ON al.album_id = t.album_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
GROUP BY a.artist_id, a.name
ORDER BY total_track_count DESC
LIMIT 10;



-- Q3: Return all the track names that have a song length longer than the average song length. Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.

SELECT name AS track_name, milliseconds
FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) FROM track)
ORDER BY milliseconds DESC;


# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Question Set 3 - Advance 

-- Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent 


SELECT CONCAT(c.first_name, ' ', c.last_name) AS customer_name, a.name AS artist_name, SUM(il.unit_price * il.quantity) AS total_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN album al ON t.album_id = al.album_id
JOIN artist a ON al.artist_id = a.artist_id
GROUP BY c.customer_id, customer_name, a.artist_id, artist_name
ORDER BY customer_name, total_spent DESC;


-- Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres.


SELECT c.country,
       CASE
           WHEN COUNT(g.genre_id) > 1 THEN GROUP_CONCAT(DISTINCT g.name)
           ELSE MAX(g.name)
       END AS top_genre
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
GROUP BY c.country;



-- Q3: Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount.


SELECT subquery.country,
       CASE
           WHEN COUNT(DISTINCT total_spent) > 1 THEN 
               GROUP_CONCAT(DISTINCT subquery.customer_name)
           ELSE MAX(subquery.customer_name)
       END AS top_customer,
       subquery.total_spent
FROM (
    SELECT c.country, 
           concat(first_name , ' ' , c.last_name) AS customer_name,
           i.customer_id,
           SUM(il.unit_price * il.quantity) AS total_spent
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    GROUP BY c.country, i.customer_id, customer_name
) AS subquery
GROUP BY subquery.country, subquery.total_spent;



