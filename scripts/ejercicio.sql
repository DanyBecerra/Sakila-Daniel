use sakila;

SELECT
    rental_id,
    MONTH(rental_date) AS mes,
    Year(rental_date) AS anno,
    CONCAT(customer.first_name,' ',customer.last_name) AS customer,
    title as film,
    CONCAT(district,' ',city) AS store,
    concat(staff.first_name,' ',staff.last_name) AS staff
from rental
    join customer using (customer_id)
    join inventory using (inventory_id)
    join film using (film_id)
    join staff using (staff_id)
    join store on inventory.store_id = store.store_id
    join address on store.address_id = address.address_id
    join city using (city_id)
limit 5;





USE sakila;

WITH prestamos AS (
    SELECT
        CONCAT(city, ',', country) AS tienda,
        CONCAT(staff.first_name, ' ', staff.last_name) AS empleado,
        YEAR(rental_date) AS anno,
        MONTH(rental_date) AS mes,
        COUNT(rental_id) AS total_prestamos
    FROM country
        INNER JOIN city USING(country_id)
        INNER JOIN address USING(city_id)
        INNER JOIN store USING(address_id)
        INNER JOIN staff USING(store_id)
        INNER JOIN rental USING(staff_id)
        INNER JOIN customer USING(customer_id)
    WHERE YEAR(rental_date) = 2005 AND (MONTH(rental_date) = 5 OR MONTH(rental_date) = 6)
    GROUP BY tienda, empleado, anno, mes
),
pivote AS (
    SELECT
        tienda,
        empleado,
        SUM(CASE WHEN anno=2005 AND mes=5 THEN total_prestamos ELSE 0 END) AS mayo,
        SUM(CASE WHEN anno=2005 AND mes=6 THEN total_prestamos ELSE 0 END) AS junio
    FROM prestamos
    GROUP BY tienda, empleado
)
SELECT 
    tienda,
    empleado,
    mayo,
    junio,
    (junio-mayo) AS dif,
    ((junio-mayo)/mayo) * 100 AS perc
FROM pivote
LIMIT 5;


--2 punto
USE sakila;

WITH prestamosPelicula AS (
    SELECT
        film.title AS pelicula,
        CONCAT(city, ',', country) AS tienda,
        YEAR(rental_date) AS anno,
        MONTH(rental_date) AS mes,
        COUNT(rental_id) AS total_prestamos
    FROM country
        INNER JOIN city USING(country_id)
        INNER JOIN address USING(city_id)
        INNER JOIN store USING(address_id)
        INNER JOIN inventory USING(store_id)
        INNER JOIN film USING(film_id)
        INNER JOIN rental USING(inventory_id)
    WHERE YEAR(rental_date) = 2005 AND (MONTH(rental_date) = 5 OR MONTH(rental_date) = 6)
    GROUP BY pelicula, tienda, anno, mes
),
pivote AS (
    SELECT
        pelicula,
        tienda,
        SUM(CASE WHEN anno=2005 AND mes=5 THEN total_prestamos ELSE 0 END) AS mayo,
        SUM(CASE WHEN anno=2005 AND mes=6 THEN total_prestamos ELSE 0 END) AS junio
    FROM prestamosPelicula
    GROUP BY pelicula, tienda
)
SELECT 
    pelicula,
    tienda,
    mayo,
    junio,
    (junio-mayo) AS dif,
    ((junio-mayo)/mayo) * 100 AS perc
FROM pivote
LIMIT 20;

