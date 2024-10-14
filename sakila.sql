-- Conexão ativa ao banco de dados: usuário e endereço IP
-- Active: 1728765177437@@127.0.0.1@3306@sakila

-- Seleciona os atores cujo sobrenome começa com 'C'
SELECT first_name, last_name
FROM actor
WHERE
    last_name LIKE 'C%'
ORDER BY first_name ASC;

-- Seleciona categorias e títulos de filmes
SELECT film_category.category_id, film.title
FROM film_category
    INNER JOIN film ON film_category.film_id = film.film_id
ORDER BY film.title ASC;

-- Conta o número de filmes por categoria
SELECT category_id, COUNT(film_id) as numberFilms
FROM film_category
GROUP BY
    category_id
ORDER BY numberFilms DESC;

-- Seleciona categorias com mais de 49 filmes
SELECT b.name, COUNT(a.film_id) AS numberFilms
FROM film_category a
    INNER JOIN category b ON a.category_id = b.category_id
GROUP BY
    a.category_id,
    b.name
HAVING
    COUNT(a.film_id) > 49
ORDER BY numberFilms DESC;

-- Seleciona filmes que não estão no inventário
SELECT a.film_id, a.title
FROM film as a
WHERE
    a.film_id NOT IN(
        SELECT b.film_id
        FROM inventory b
    );

-- Conta o número de filmes por categoria
SELECT c.name, COUNT(f.film_id) AS numberOfFilms
FROM
    film f
    INNER JOIN film_category fc ON f.film_id = fc.film_id
    LEFT JOIN category c ON c.category_id = fc.category_id
GROUP BY
    c.name
ORDER BY numberOfFilms DESC;

-- Cria tabela 'country' se não existir
CREATE TABLE IF NOT EXISTS country (
    country_id SMALLINT NOT NULL AUTO_INCREMENT,
    country VARCHAR(50) NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (country_id)
);

-- Cria tabela 'city' se não existir
CREATE TABLE IF NOT EXISTS city (
    city_id SMALLINT NOT NULL AUTO_INCREMENT,
    city VARCHAR(50) NOT NULL,
    country_id SMALLINT NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (city_id),
    KEY idx_fk_country_id (country_id),
    CONSTRAINT fk_city_country FOREIGN KEY (country_id) REFERENCES country (country_id)
);

-- Seleciona todos os registros da view 'film_list'
SELECT * FROM film_list;

-- Cria função 'inventory_in_stock' para verificar se um item está disponível
DROP FUNCTION IF EXISTS inventory_in_stock;

CREATE FUNCTION inventory_in_stock(p_inventory_id INT) RETURNS BOOLEAN
    READS SQL DATA
BEGIN
    DECLARE v_rentals INT;
    DECLARE v_out INT;

    -- Verifica se o item já foi alugado
    SELECT COUNT(rental_id) INTO v_rentals
    FROM rental
    WHERE inventory_id = p_inventory_id;

    IF v_rentals = 0 THEN
      RETURN TRUE;
    END IF;

    -- Verifica se o item ainda está alugado
    SELECT COUNT(rental_id) INTO v_out
    FROM inventory LEFT JOIN rental USING(inventory_id)
    WHERE inventory.inventory_id = p_inventory_id
    AND rental.return_date IS NULL;

    IF v_out > 0 THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
END;

-- Testa a função 'inventory_in_stock'
SELECT inventory_in_stock (1);

-- Cria procedimento 'film_in_stock' para contar filmes disponíveis
DROP PROCEDURE IF EXISTS film_in_stock;

CREATE PROCEDURE film_in_stock(IN p_film_id INT, IN p_store_id INT, OUT p_film_count INT)
    READS SQL DATA
BEGIN
    -- Seleciona o número de inventários disponíveis
    SELECT COUNT(*)
    INTO p_film_count
    FROM inventory
    WHERE film_id = p_film_id
    AND store_id = p_store_id
    AND inventory_in_stock(inventory_id);
END;

-- Chama o procedimento 'film_in_stock' e armazena o resultado
CALL film_in_stock (5, 2, @film_count);

SELECT @film_count;

-- Cria gatilho 'ins_film' para inserir dados na tabela 'film_text' após novo filme ser adicionado
DROP TRIGGER IF EXISTS ins_film;

CREATE TRIGGER ins_film
AFTER INSERT ON film
FOR EACH ROW
BEGIN
    INSERT INTO film_text (film_id, title, description)
    VALUES (NEW.film_id, NEW.title, NEW.description);
END;