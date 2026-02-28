USE transactions;

# Comprobaciones previas
SELECT COUNT(*)
FROM transactions.company
WHERE id IS NULL;

SELECT COUNT(*)
FROM transactions.transaction
WHERE id IS NULL;

SELECT COUNT(DISTINCT company_id)
FROM transaction;


SELECT COUNT(DISTINCT id)
FROM company;

#NIVEL 1

# EJERCICIO 2 UTILIZANDO JOIN
# Listado de países que están generando ventas
SELECT DISTINCT c.country
FROM company c
JOIN transaction t
ON c.id = t.company_id;

# Desde cuántos países se generan ventas
SELECT COUNT(DISTINCT c.country) AS total_paises
FROM company c
JOIN transaction t
ON c.id = t.company_id;

# Identifica la empresa con la media más grande de ventas
SELECT c.company_name, ROUND(AVG(t.amount),2) AS media_ventas
FROM company c
JOIN transaction t
ON c.id = t.company_id
WHERE t.declined = 0
GROUP BY c.company_name
ORDER BY media_ventas DESC
LIMIT 1;

# EJERCICIO 3 UTILIZANDO SÓLO SUBCONSULTAS (SIN UTILIZAR JOIN)
# Muestra todas las transacciones realizadas por empresas de Alemania
SELECT *
FROM transaction
WHERE declined = 0
AND company_id IN (
	SELECT id
	FROM company
    WHERE country = 'Germany'
);

# Lista de las empresas que han realizado transacciones por un "amount" superior a la
# media de todas las transacciones
SELECT company_name
FROM company
WHERE EXISTS (
	SELECT company_id
    FROM transaction
    WHERE amount > (
		SELECT AVG(amount) 
        FROM transaction
        WHERE declined = 0
        )
	AND declined = 0
);

# Eliminarán del sistema las emrpesas que no tienen transacciones registradas, entrega el listado
# de estas empresas
# OPCIÓN A - Subconsulta correlacionada
SELECT *
FROM company c
WHERE NOT EXISTS (
	SELECT 1
    FROM transaction t
    WHERE t.company_id = c.id
);

# OPCIÓN B - Usando NOT IN 
SELECT *
FROM company
WHERE id NOT IN (
	SELECT company_id
    FROM transaction
);

# NIVEL 2

# EJERCICIO 1: Identifica los cinco días que se generaron la cantidad más grande de ingresos a la empresa por ventas. 
# Muestra la fecha de cada transacción junto con el total de las ventas.

SELECT DATE(timestamp) AS fecha, SUM(amount) AS total_ingresos
FROM transaction
WHERE declined = 0
GROUP BY fecha
ORDER BY total_ingresos DESC
LIMIT 5;

# EJERCICIO 2: ¿Cuál es la media de ventas por país? Presenta los resultados ordenados 
# de mayor a menor media.

SELECT c.country AS pais, AVG(t.amount) AS media_ventas
FROM transaction t
JOIN company c
ON t.company_id = c.id
WHERE t.declined = 0
GROUP BY c.country
ORDER BY media_ventas DESC;

# EJERCICIO 3: En tu empresa, se plantea un nuevo proyecto para lanzar algunas campañas publicitarias para hacer competencia a la empresa “Non Institute”.
# Para esto, te piden una lista de todas las transacciones realizadas por empresas que están situadas en el mismo país que esta empresa.
# -	Muestra el listado aplicando JOIN y subconsultas 
SELECT t.*
FROM transaction t
JOIN company c
ON t.company_id = c.id
WHERE t.declined = 0
AND c.country = (
	SELECT country
    FROM company
    WHERE company_name = 'Non Institute')
AND company_name != 'Non Institute';

# - Muestra el listado aplicando sólo subconsultas
SELECT *
FROM transaction
WHERE declined = 0
AND company_id IN (
	SELECT id
    FROM company
    WHERE country = (
		SELECT country
        FROM company
        WHERE company_name = 'Non Institute')
	AND company_name != 'Non Institute'
); 

# NIVEL 3

# EJERCICIO 1: Presenta el nombre, teléfono, país, fecha y amount, de aquellas empresas que realizaron transacciones con un valor 
# comprendido entre 350 y 400 euros y en alguna de estas fechas: 29 de abril del 2015, 20 de julio del 2018 y 13 de marzo del 2024.
# Ordena los resultados de mayor a menor cantidad.
SELECT	c.company_name AS nombre, c.phone AS telefono, c.country AS pais, 
		DATE(t.timestamp) AS fecha, t.amount AS importe 
FROM company c
JOIN transaction t
ON c.id = t.company_id
WHERE t.declined = 0
AND t.amount BETWEEN 350 AND 400 
AND DATE(t.timestamp) IN ('2015-04-29','2018-07-20','2024-03-13')
ORDER BY t.amount DESC;


# EJERCICIO 2: Necesitamos optimizar la asignación de los recursos y dependerá de la capacidad operativa que se requiera, por lo cual 
# te piden información sobre la cantidad de transacciones que realizan las empresas, pero el departamento de recursos humanos es exigente y 
# quiere un listado de las empresas donde especifiques si tienen más de 400 transacciones o menos.

SELECT	c.company_name, COUNT(t.id) AS total_transacciones,
		CASE
			WHEN COUNT(t.id) > 400 THEN 'Más de 400'
            ELSE '400 o menos'
		END AS categoria
FROM company c
LEFT JOIN transaction t
	ON t.company_id = c.id
    AND t.declined = 0
GROUP BY c.company_name;





