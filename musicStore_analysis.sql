--                                  Question Set 1 - Easy 

--1. Who is the senior most employee based on job title? 

Select * From employee 
Order by levels DESC 
limit 1;


--2. Which countries have the most Invoices? 

Select count(*) as a, billing_country
From invoice
group by billing_country
Order by a DESC;


--3. What are top 3 values of total invoice? 

Select total From invoice
Order by total DESC
limit 3;


--4. Which city has the best customers? We would like to throw a promotional Music 
--   Festival in the city we made the most money. 
--  Write a query that returns one city that has the highest sum of invoice totals. 
--  Return both the city name & sum of all invoice totals.

Select sum(total) as invoice_total, billing_city
From invoice
Group by billing_city
Order by invoice_total DESC;


--5. Who is the best customer? The customer who has spent the most money will be 
--   declared the best customer. 
--  Write a query that returns the person who has spent the most money.

Select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as total
From customer
JOIN invoice on customer.customer_id=invoice.customer_id
Group by customer.customer_id
Order by total DESC
limit 1;


--                          Question Set 2 – Moderate 

--1. Write query to return the email, first name, last name, & Genre of all Rock Music 
--   listeners. Return your list ordered alphabetically by email starting with A 

Select DISTINCT first_name, last_name, email from customer
Join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
Where track_id IN (
Select track_id from track
Join genre on genre.genre_id = track.genre_id
Where genre.name Like 'Rock')
Order by email;


--2. Let's invite the artists who have written the most rock music in our dataset. Write a 
--   query that returns the Artist name and total track count of the top 10 rock bands.

Select artist.artist_id, artist.name, Count(artist.artist_id) As number_of_songs
from track
JOin album on album.album_id = track.album_id
Join artist on artist.artist_id = album.artist_id
Join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
Group by artist.artist_id
Order by number_of_songs DESC
LIMIT 10;

-- 3. Return all the track names that have a song length longer than the average song length. 
--   Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first 

Select name, milliseconds From track 
where milliseconds >
(Select AVG(milliseconds) from track)
Order by milliseconds DESC;


--                               Question Set 3 – Advance 

--1. Find how much amount spent by each customer on artists? Write a query to return 
--  customer name, artist name and total spent 

WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;


--2. We want to find out the most popular music Genre for each country. We determine the 
--  most popular genre as the genre with the highest amount of purchases. Write a query 
--  that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres 

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1;


--3. Write a query that determines the customer that has spent the most on music for each country. 
--  Write a query that returns the country along with the top customer and how much they spent. 
--  For countries where the top amount spent is shared, provide all customers who spent this amount.

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1;

