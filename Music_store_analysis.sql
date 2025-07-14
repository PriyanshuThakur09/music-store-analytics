-- Q1: Who is the senior most employee based on the job title?
-- The senior most employee based on the job title is the one having the highest level
select * from employee
order by levels desc
limit 1;

-- Q2. What is the number of invoices for each country ?
select billing_country as country,count(*) as number_of_invoices
from 
invoice 
group by billing_country
order by number_of_invoices;

-- Q3. What are top three values of total invoices?
select total from invoice
order by total desc 
limit 3;

-- Another way to do it using cte and window functions 
with total_cte as (select total,
row_number()over(order by total desc) as row_num
from 
invoice)

select total from total_cte 
order by total_cte.total desc
limit 3;

/* Q4.Which city has the best customers?.Write a query that returns one city that 
has the highest sum of invoice totals. Return both the city name & sum of all invoice 
totals */

select billing_city as city, sum(total) as invoice_total
from 
invoice 
group by billing_city 
order by invoice_total desc
limit 1;

/* Q5.Who is the best customer? The customer who has spent the most money will be 
declared the best customer. Write a query that returns the person who has spent the 
most money*/
select c.customer_id,c.first_name,c.last_name,sum(i.total) as total
from 
customer c
join 
invoice i
on 
c.customer_id = i.customer_id
group by c.customer_id 
order by total desc
limit 1;

/*Q6.Write query to return the email, first name, last name, & Genre of all Rock Music 
listeners. Return your list ordered alphabetically by email starting with A*/

select distinct c.email,c.first_name,c.last_name
from customer c
join 
invoice i 
on 
c.customer_id = i.customer_id
join
invoice_line il
on
i.invoice_id = il.invoice_id
where track_id in 
 (select track_id
 from track t
 join genre g
 on
 t.genre_id = g.genre_id
 where
 g.name like 'Rock')
order by c.email asc;

/*Q7. Write a query that returns the Artist name and total track count of the top 10 rock bands*/

select 
a.artist_id,
a.name,
count(t.track_id)
as number_of_songs
from track t
join album al
on 
al.album_id = t.album_id
join
artist a 
on
a.artist_id = al.artist_id
join
genre g
on 
g.genre_id = t.genre_id 
where
g.name = 'Rock'
group by a.artist_id,a.name
order by 
number_of_songs desc
limit 10;

/*Q8. Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the 
longest songs listed first*/

select t.name,t.milliseconds as track_length 
from track t
where 
t.milliseconds > (select avg(t.milliseconds) as avg_track_length
                       from track t)
order by t.milliseconds desc;

/*Q9.Find how much amount spent by each customer on the top selling artist? Write a query to return
customer name, artist name and total spent*/

with best_selling_artist as ( 
       select a.artist_id, a.name, sum(il.unit_price*il.quantity) as total_sales
       from invoice_line il
	   join  
	   track t
	   on 
	   il.track_id = t.track_id
	   join
	   album al
	   on
	   t.album_id = al.album_id
	   join
	   artist a
	   on 
	   al.artist_id = a.artist_id
	   group by a.artist_id
	   order by total_sales desc
	   limit 1)

select c.customer_id, c.first_name, c.last_name,bsa.name as artist_name,
sum(il.unit_price*il.quantity) as total_spend
from 
customer c
join
invoice i
on
c.customer_id = i.customer_id
join
invoice_line il
on 
i.invoice_id = il.invoice_id
join 
track t
on
il.track_id = t.track_id
join
album al 
on
t.album_id = al.album_id
join
best_selling_artist bsa
on
al.artist_id = bsa.artist_id 
group by c.customer_id, c.first_name, c.last_name,bsa.name
order by total_spend desc;



/*Q10.We want to find out the most popular music Genre for each country. We determine the 
most popular genre as the genre with the highest amount of purchases. Write a query 
that returns each country along with the top Genre*/

with popular_genre as (
      select c.country,g.genre_id,g.name,count(il.quantity) as purchases,
	  row_number()over w as row_num
	  from
	  customer c
	  join 
	  invoice i 
	  on 
	  c.customer_id = i.customer_id
	  join
	  invoice_line il 
	  on 
	  il.invoice_id = i.invoice_id
	  join 
	  track t 
	  on
	  il.track_id = t.track_id
	  join
	  genre g
	  on
	  t.genre_id = g.genre_id
	  group by 
	  c.country,g.genre_id,g.name
	  Window w as (partition by c.country order by count(il.quantity) desc) 
	  order by c.country asc,count(il.quantity) desc
)

select pg.country,pg.genre_id,pg.purchases,pg.name as genre_name 
from 
popular_genre pg
where row_num = 1;


/*Q11.Write a query that determines the customer that has spent the most on music for each 
country. Write a query that returns the country along with the top customer and how
much they spent.*/


with customer_spending as (
 select c.country,c.customer_id,c.first_name,c.last_name,
 sum(il.unit_price*il.quantity) as total_spend,
 row_number()over(partition by c.country order by  sum(il.unit_price*il.quantity) desc)
 as row_num
 from 
 customer c
 join
 invoice i 
 on 
 c.customer_id = i.customer_id
 join 
 invoice_line il 
 on
 i.invoice_id = il.invoice_id
 group by c.country,c.customer_id,c.first_name,c.last_name
 order by c.country asc,sum(il.unit_price*il.quantity) desc
 )
 select cs.country,cs.customer_id,cs.first_name,cs.last_name,cs.total_spend
 from customer_spending cs
 where row_num = 1
 order by cs.country asc;



