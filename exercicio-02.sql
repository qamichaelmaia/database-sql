---Número de registros para a lista de filmes e suas categorias correspondentes:
SELECT COUNT(*) AS total_films_with_categories
FROM film f
INNER JOIN film_category fc ON f.film_id = fc.film_id
INNER JOIN category c ON fc.category_id = c.category_id;

---Número de registros para a lista de todos os atores com o número de filmes que cada ator participou:
SELECT COUNT(DISTINCT a.actor_id) AS total_actors
FROM actor a
INNER JOIN film_actor fa ON a.actor_id = fa.actor_id;

---Número de registros para a lista de atores que atuaram em filmes com mais de duas horas de duração:
SELECT COUNT(DISTINCT a.actor_id) AS total_actors_in_long_films
FROM actor a
INNER JOIN film_actor fa ON a.actor_id = fa.actor_id
INNER JOIN film f ON fa.film_id = f.film_id
WHERE f.length > 120;

