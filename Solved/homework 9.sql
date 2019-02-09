use sakila;

-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select concat(first_name, ' ', last_name) AS "actor name" from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name 
FROM actor 
WHERE first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT first_name, last_name
FROM actor
WHERE last_name like "%GEN%";

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT last_name, first_name
FROM actor
WHERE last_name LIKE "%LI%";

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ("Afghanistan", "Bangladesh", "China");

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE country
ADD COLUMN description BLOB(1000);

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE country
DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, count(*) AS count
FROM actor
GROUP BY last_name
ORDER BY count DESC;

--  To count the number of instances of one item in column
SELECT last_name, COUNT(*) as count
FROM actor
WHERE last_name LIKE "KILMER"
GROUP BY last_name DESC;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, count(last_name) as "mumber of actores" FROM actor
GROUP BY last_name
HAVING count(last_name) >=2:

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO' AND last_name = 'WILLIAMS';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
SHOW CREATE TABLE ADDRESS;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT first_name, last_name, address
FROM staff
JOIN address
ON staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT concat(staff.first_name, " ", staff.last_name) as staff_member, sum(payment.amount) as total_sales_August_2005
FROM staff
JOIN payment
ON staff.staff_id = payment.staff_id
WHERE payment_date between '2005-8-01 00:00:00' AND '2005-08-31 23:59:59'
GROUP BY staff.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT film.title, count(film_actor.actor_id) as "Number of Actors"
FROM film 
INNER JOIN film_actor
ON film.film_id = film_actor.film_id
GROUP BY film.film_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT film.title, count(inventory.inventory_id) AS "copies"
FROM film
JOIN inventory
ON film.film_id = inventory.film_id
GROUP BY film.film_id
HAVING film.title = 'Hunchback Impossible';

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT customer.first_name, customer.last_name, sum(payment.amount) AS 'Total Paid'
FROM customer 
JOIN payment
ON customer.customer_id = payment.customer_id
GROUP BY customer.customer_id
ORDER BY customer.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the 
-- letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose 
-- language is English.
SELECT title FROM film
WHERE title LIKE 'K%' or title LIKE 'Q%'
and LANGUAGE_ID = (SELECT language_id FROM language WHERE name = 'English');

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name FROM actor
WHERE actor_id IN (SELECT actor_id FROM film_actor WHERE film_id = (SELECT film_id FROM film WHERE title = 'Alone Trip'));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
SELECT customer.first_name, customer.last_name, customer.email
FROM customer
JOIN address
ON customer.address_id = address.address_id
JOIN city
ON address.city_id = city.city_id
JOIN country
ON city.country_id = country.country_id
WHERE country.country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized 
-- as family films.
SELECT title AS "Family Films" FROM film
WHERE film_id in(SELECT film_id FROM film_category WHERE category_id =(SELECT category_id FROM category WHERE neme = "Family"));

-- 7e. Display the most frequently rented movies in descending order.
SELECT film.title, count(rental.rental_id) as "Rental Freq Count"
FROM film
JOIN inventory
ON film.film_id = inventory.film_id
JOIN rental
ON inventory.inventory_id = rental.inventory_id
GROUP BY film.film_id
ORDER BY count(rental.rental_id) desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select store.store_id, concat('$', format(sum(payment.amount), 2)) as total_sales
from payment
join rental on payment.rental_id = rental.rental_id
join inventory on rental.inventory_id = inventory.inventory_id
join store on inventory.store_id = store.store_id
group by store.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
 select s.store_id, c.city, co.country
 from store as  s
 join address as a on s.address_id = a.address_id
 join city as c on a.city_id = c.city_id
 join country as co on c.country_id = co.country_id;
-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select  category.name, sum(payment.amount) as total_sales
from payment
join rental on payment.rental_id = rental.rental_id
join inventory on rental.inventory_id = inventory.inventory_id
join film_category on inventory.film_id = film_category.film_id
join category on film_category.category_id = category.category_id
group by category.category_id
order by sum(payment.amount) desc limit 5;
-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
create algorithm=undefined definer=`root`@`localhost` sql security definer view `sakila`.`top_five_genres` as 
select  category.name, sum(payment.amount) as total_sales
from payment
join rental on payment.rental_id = rental.rental_id
join inventory on rental.inventory_id = inventory.inventory_id
join film_category on inventory.film_id = film_category.film_id
join category on film_category.category_id = category.category_id
group by category.category_id
order by sum(payment.amount) desc limit 5;
-- 8b. How would you display the view that you created in 8a?
select * from top_five_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

drop view top_five_genres;





