---Consulta que retorna a lista de filmes e suas categorias correspondentes:
SELECT f.title, c.name AS category
FROM film f
INNER JOIN film_category fc ON f.film_id = fc.film_id
INNER JOIN category c ON fc.category_id = c.category_id
ORDER BY f.title ASC;

---Consulta que retorna a lista de todos os atores com o número de filmes que cada ator participou, ordenada pelos atores que mais atuaram:
SELECT a.actor_id, CONCAT(a.first_name, ' ', a.last_name) AS actor_name, COUNT(fa.film_id) AS number_of_films
FROM actor a
INNER JOIN film_actor fa ON a.actor_id = fa.actor_id
GROUP BY a.actor_id, actor_name
ORDER BY number_of_films DESC;

---Consulta que retorna a lista de atores que atuaram em filmes com mais de duas horas de duração, ordenada pelo número de filmes que cada ator participou:
SELECT a.actor_id, CONCAT(a.first_name, ' ', a.last_name) AS actor_name, COUNT(fa.film_id) AS number_of_films
FROM actor a
INNER JOIN film_actor fa ON a.actor_id = fa.actor_id
INNER JOIN film f ON fa.film_id = f.film_id
WHERE f.length > 120
GROUP BY a.actor_id, actor_name
ORDER BY number_of_films DESC;
