# Creación Base de DAtos venta_toys

CREATE DATABASE IF NOT EXISTS ventas_toys;

USE ventas_toys;

# Creación de las tablas american_users y european_users

CREATE TABLE IF NOT EXISTS american_users (
	id INT PRIMARY KEY,
    name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(50),
    email VARCHAR(100),
    birth_date DATE,
    country VARCHAR(100),
    city VARCHAR(100),
    postal_code VARCHAR(20),
    address TEXT
);

CREATE TABLE IF NOT EXISTS european_users (
	id INT PRIMARY KEY,
    name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(50),
    email VARCHAR(100),
    birth_date DATE,
    country VARCHAR(100),
    city VARCHAR(100),
    postal_code VARCHAR(20),
    address TEXT
);

# Comprobación 'local_infile' está ON
#SHOW VARIABLES LIKE 'local_infile';

# Carga de datos desde los archivos CSV en las tablas american_users y european_users
# Correcciones de entrada de los datos para mayor compatibiidad

LOAD DATA LOCAL INFILE 'C:/Users/ivan_/Documents/MySQL/Uploads/american_users.csv'	-- se añade LOCAL porque hemos desactivado la ruta predeterminada para UPLOADS
INTO TABLE american_users
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'		-- se usa OPTIONALLY porque sólo algunas columnas están entre comillas 
LINES TERMINATED BY '\n'		-- marca de salto de línea
IGNORE 1 ROWS					-- la primera fila se ignora porque son los nombre de las columnas
(id, name, surname, phone, email, @v_birth_date, country, city, postal_code, address)
SET birth_date = STR_TO_DATE(@v_birth_date, '%b %e, %Y');					-- @v_birth_date es una variable temporal para poder transformar el formato de fecha
-- %b nombre del mes abreviado (Jan, Feb, Mar...)
-- %e día del mes del 1 al 31, diferencia con %d no añade 0 a la izquierda
-- %Y año completo con 4 dígitos ej.2026

LOAD DATA LOCAL INFILE 'C:/Users/ivan_/Documents/MySQL/Uploads/european_users.csv'
INTO TABLE european_users
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, name, surname, phone, email, @v_birth_date, country, city, postal_code, address)
SET birth_date = STR_TO_DATE(@v_birth_date, '%b %e, %Y');

# Creación de la tabla users

CREATE TABLE IF NOT EXISTS users (
	id INT PRIMARY KEY,
    name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(50),
    email VARCHAR(100),
    birth_date DATE,
    country VARCHAR(100),
    city VARCHAR(100),
    postal_code VARCHAR(20),
    address TEXT,
    region ENUM('US', 'EU') NOT NULL	-- para definir una columna que sólo puede guardar un valor específico, se limitan a los valores 'US' y 'EU'
);

# Unificar las tablas american_users y european_users en la nueva tabla users con UNION ALL
# Migración de datos

INSERT IGNORE INTO users
SELECT id, name, surname, phone, email, birth_date, country, city, postal_code, address, 'US'
FROM american_users
UNION ALL
SELECT id, name, surname, phone, email, birth_date, country, city, postal_code, address, 'EU'
FROM european_users; 

# Creación de la tabla credit_cards

CREATE TABLE IF NOT EXISTS credit_cards (
	id VARCHAR(50) PRIMARY KEY,			-- se usa VARCHAR porque contiene letras 
    user_id INT NOT NULL,				-- se define explícitamente NOT NULL porque será una FK
    iban VARCHAR(50),
    pan VARCHAR(50),
    pin VARCHAR(4),
    cvv VARCHAR(3),
    track1 VARCHAR(100),
    track2 VARCHAR(100),
    expiring_date DATE,
    
    CONSTRAINT fk_cards_users
		FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Se modifica el tipo de atributos de pin y cvv de INT a VARCHAR
-- Si se usa INT es posible que ceros a la izquierda ej. PIN 0012 se guardarían como 12

#DESCRIBE credit_cards;

# Carga de datos desde el archivo csv a la tabla credit_cards

LOAD DATA LOCAL INFILE 'C:/Users/ivan_/Documents/MySQL/Uploads/credit_cards.csv'
INTO TABLE credit_cards
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, user_id, iban, pan, pin, cvv, track1, track2, @v_expiring_date)
SET expiring_date = STR_TO_DATE(@v_expiring_date, '%m/%d/%y');

# Creación de la tabla companies

CREATE TABLE IF NOT EXISTS companies (
	company_id VARCHAR(20) PRIMARY KEY,
    company_name VARCHAR(150),
    phone VARCHAR(30),
    email VARCHAR(150),
    country VARCHAR(100),
    website VARCHAR(255)
);

LOAD DATA LOCAL INFILE 'C:/Users/ivan_/Documents/MySQL/Uploads/companies.csv'
INTO TABLE companies
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(company_id, company_name, phone, email, country, website);

# Creación de la tabla products

CREATE TABLE IF NOT EXISTS products (
	id INT PRIMARY KEY,
    product_name VARCHAR(100),
    price DECIMAL(10,2),
    colour CHAR(7),
    weight DECIMAL(4,2),
    warehouse_id VARCHAR(10)   
);

LOAD DATA LOCAL INFILE 'C:/Users/ivan_/Documents/MySQL/Uploads/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, product_name, @price_raw, colour, weight, warehouse_id)
SET price = CAST(SUBSTRING(@price_raw, 2) AS DECIMAL(10,2));

-- Se usa SUBSTRING para extraer los números ya que en el archivos csv figura como ej.$161.11
-- SUBSTRING(@price_raw, 2) el número dos hace referencia la posición inicial
-- También se utiliza una variable temporal: @price_raw

# Creación de la tabla transactions
# Modelo final y creación de relaciones

DROP TABLE transactions;

CREATE TABLE IF NOT EXISTS transactions (
	id VARCHAR(50) PRIMARY KEY,
    card_id VARCHAR(50) NOT NULL,
    company_id VARCHAR(50) NOT NULL,	-- aquí cambiamos el nombre del atributo buisness_id del csv por company_id para homogeneizar criterios
    timestamp DATETIME,
    amount DECIMAL(10,2) NOT NULL,		-- NOT NULL porque una transacción sin importe no tiene sentido
    declined BOOLEAN,
    product_ids TEXT,
    user_id INT NOT NULL,
    lat DOUBLE,
    longitude DOUBLE,
    
    CONSTRAINT fk_transactions_card
		FOREIGN KEY (card_id)
        REFERENCES credit_cards(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
	
    CONSTRAINT fk_transactions_user
		FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE RESTRICT				-- Se usa RESTRICT porque no se quiere borrar el usuario y conservar el histórico de transacciones
        ON UPDATE CASCADE,
        
	CONSTRAINT fk_transactions_company
		FOREIGN KEY (company_id)
        REFERENCES companies(company_id)
        ON DELETE RESTRICT				-- Igual que con users no se quiere perder el histórico de compras de las empresas
        ON UPDATE CASCADE
);

# Carga de datos desde el archivo csv a la tabla transactions

LOAD DATA LOCAL INFILE 'C:/Users/ivan_/Documents/MySQL/Uploads/transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ';'				-- En este csv las columnas están separadas por ; y no por comas como en el resto de archivos
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, card_id, company_id, @v_timestamp, amount, declined, product_ids, user_id, @v_lat, @v_longitude)
SET
	timestamp = STR_TO_DATE(@v_timestamp, '%Y-%m-%d %H:%i:%s'),
    lat = CAST(@v_lat AS DECIMAL(18,15)),
    longitude = CAST(@v_longitude AS DECIMAL(18,15));
    
# Creación de tabla intermedia para separar varios productos en una misma transaction product_ids    

CREATE TABLE IF NOT EXISTS transaction_products (
	transaction_id VARCHAR(50),
    product_id INT,
    PRIMARY KEY (transaction_id, product_id),
    
    CONSTRAINT fk_tp_transaction
		FOREIGN KEY (transaction_id)
        REFERENCES transactions(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
	
    CONSTRAINT fk_tp_product
		FOREIGN KEY (product_id)
        REFERENCES products(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

INSERT INTO transaction_products (transaction_id, product_id)
SELECT
	t.id,
	CAST(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(t.product_ids, ',', n.n), ',', -1)) AS UNSIGNED)
FROM transactions t
JOIN (
	SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
) n
ON CHAR_LENGTH(t.product_ids) - CHAR_LENGTH(REPLACE(t.product_ids, ',', '')) >= n.n -1
WHERE t.product_ids IS NOT NULL
AND t.product_ids != '';

# Eliminar columna product_ids de la tabla transactions porque puede dar problemas con JOIN

ALTER TABLE transactions DROP COLUMN product_ids;

DROP TABLE american_users;

DROP TABLE european_users;
 
# MODELO NORMALIZADO Y FINALIZADO

# CONSULTAS

# NIVEL 1

# EJERCICIO 1
# Realiza una subconsulta que muestre todos los usarios con más de 80 transacciones 
# utilizando al menos 2 tablas.

SELECT u.id, u.name, u.surname, COUNT(t.id) AS total_transacciones
FROM users u
JOIN transactions t
ON t.user_id = u.id
GROUP BY u.id
HAVING COUNT(t.id) > 80;

# EJERCICIO 2
# Muestra la media de amount por IBAN de las tarjetas de crédito en la empresa Donec Ltd, 
# usa al menos dos tablas.

SELECT cc.iban, AVG(t.amount) AS media_amount
FROM transactions t
JOIN credit_cards cc ON t.card_id = cc.id
JOIN companies c ON t.company_id = c.company_id
WHERE c.company_name = 'Donec Ltd'
GROUP BY cc.iban;

# NIVEL 2

# EJERCICIO 1
# Crea una nueva tabla que muestre el estado de las tarjetas de crédito basado en si las tres últimas
# transacciones ha sido rechazadas entonces es inactiva, si al menos una no es rechazada entonces es activa.
# Partiendo de esta tabla responde: ¿Cuántas tarjetas están activas?

-- Para este ejercicio se opta por crear una VISTA (VIEW) card_status en vez de una TABLA ya que
-- una VIEW siempre se mantiene actualizada y es más dinámica

CREATE VIEW card_status AS					-- aquí se crea la vista card_status
WITH ultimas AS (							-- en este punto se utiliza una CTE temporal
    SELECT
        t.card_id,
        t.declined,
        ROW_NUMBER() OVER (					-- se usa una window function 
            PARTITION BY t.card_id
            ORDER BY t.timestamp DESC
        ) AS rn
    FROM transactions t
)
SELECT										-- se sigue creando la VIEW 
    u.card_id,
    CASE									-- se crea la lógica condicional y la columna status
        WHEN SUM(u.declined) = COUNT(*) THEN 'INACTIVA'	-- si al contar todas son declined entonces inactiva
        ELSE 'ACTIVA'
    END AS status							-- columna status
FROM ultimas u								-- tabla temporal creada la CTE
JOIN credit_cards cc						-- se usa inner join para obtener sólo las tarjetas con transacciones
    ON cc.id = u.card_id
WHERE u.rn <= 3								-- se filtra por las 3 últimas transacciones 
GROUP BY u.card_id;							-- y se agrupan por id de tarjeta

-- Una vez creada la VIEW card_status se procede a hacer la consulta: ¿Cuántas tarjetas están activas? 

SELECT COUNT(*) AS tarjetas_activas
FROM card_status
WHERE status = 'ACTIVA';

# NIVEL 3

# Crea una tabla con la que podamos unir los datos del nuevo archivo products.csv con la base de datos creada,
# teniendo en cuenta que desde transaction tienes product_ids. Genera la siguiente consulta:

# EJERCICIO 1
# Necesitamos conocer el número de veces que se ha vendido cada producto

-- Para este ejercicio, la normalización ya se ha realizado en los pasos previos durante la creación de las tablas
-- para este caso se creó la tabla transaction_products donde se desgranan los productos por transaction_id

SELECT 
	p.id AS product_id,
    p.product_name,
    COUNT(tp.product_id) AS veces_vendido
FROM products p
JOIN transaction_products tp
ON p.id = tp.product_id
GROUP BY p.id, p.product_name
ORDER BY veces_vendido DESC;


