USE transactions;

# NIVEL 1

#EJERCICIO 1

CREATE TABLE IF NOT EXISTS credit_card (
	id VARCHAR(20) PRIMARY KEY,
    iban VARCHAR(50) NOT NULL,
    pan VARCHAR(20) NOT NULL,
    pin VARCHAR(4) NOT NULL,
    cvv INT NOT NULL,
    expiring_date VARCHAR(20) NOT NULL
);


DESCRIBE transaction;

ALTER TABLE transaction
ADD CONSTRAINT fk_creditcard
FOREIGN KEY (credit_card_id)
REFERENCES credit_card(id);

#EJERCICIO 2
-- Comprobación del valor antes del cambio
SELECT id, iban
FROM credit_card
WHERE id = 'CcU-2938';

UPDATE credit_card
SET iban = 'TR323456312213576817699999'
WHERE id = 'CcU-2938';

SELECT id, iban
FROM credit_card
WHERE id = 'CcU-2938';

#EJERCICIO 3
INSERT INTO transaction
(id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
VALUES
('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', 9999, 829.999, -117.999, 111.11, 0);
#ERROR

-- Comprobar si la empresa existe
SELECT *
FROM company
WHERE id = 'b-9999'; -- la empresa no existe

-- Crear company "b-9999"
INSERT INTO company (id)
VALUES ('b-9999');

-- Se vuelve a insertar los datos de la nueva transacción
INSERT INTO transaction
(id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
VALUES
('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', 9999, 829.999, -117.999, 111.11, 0);
#ERROR, no existe la id de la credit card 'Ccu-9999' en la tabla credit_card

-- Se comprueba si existe la credit_card 'Ccu-9999'
SELECT *
FROM credit_card
WHERE id = 'CcU-9999'; -- No existe, devuelve NULL

-- Crear credit_card 'Ccu-9999', además se crean valores ficticios en el resto de
-- parámetros ya que no pueden ser NULL según la tabla creada
INSERT INTO credit_card (id, iban, pan, pin, cvv, expiring_date)
VALUES ('CcU-9999', 'XX0000000000000000000000', '0000000000000000', '0000', '000', '00/00/00');  
												 
-- Comprobaciones 

DESCRIBE transaction;

DESCRIBE credit_card;

ALTER TABLE credit_card MODIFY id VARCHAR(15);
#ERROR no permite hacer el cambio porque existe una foreign key constraint 'fk_creditcard'

-- Eliminar la foreign key
ALTER TABLE transaction
DROP FOREIGN KEY fk_creditcard;

-- Modificar tabla credit_card:
ALTER TABLE credit_card
MODIFY id VARCHAR(15);

-- Se vuelve a crear la foreign key
ALTER TABLE transaction
ADD CONSTRAINT fk_creditcard
FOREIGN KEY (credit_card_id)
REFERENCES credit_card(id);

-- FINALMENTE se vuelve a crear la transacción del enunciado
INSERT INTO transaction
(id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
VALUES
('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', 9999, 829.999, -117.999, 111.11, 0);

-- Comprobar que la transacciónse creó correctamente
SELECT *
FROM transaction
WHERE id = '108B1D1D-5B23-A76C-55EF-C568E49A99DD'; -- Se ha creado correctamente

#EJERCICIO 4
-- Comprobación si alguna tabla usa 'pan' como foreign key
SELECT *
FROM information_schema.KEY_COLUMN_USAGE
WHERE COLUMN_NAME = 'pan'
AND TABLE_SCHEMA = DATABASE();

-- Eliminar columna 'pan'
ALTER TABLE credit_card
DROP COLUMN pan;

-- Comprobación
DESCRIBE credit_card;

#NIVEL 2

#EJERCICIO 1
-- Comprobar el registro
SELECT *
FROM transaction
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

-- Se elimina el registro
DELETE FROM transaction
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

-- Mostrar que el cambio se realizó
SELECT *
FROM transaction
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

#EJERCICIO 2
-- Crear vista VistaMarketing

CREATE VIEW VistaMarketing AS
SELECT	c.company_name AS Empresa, c.phone AS Teléfono, 
		c.country AS País, AVG(t.amount) AS media_compra
FROM company c
JOIN transaction t
ON c.id = t.company_id
GROUP BY c.id, c.company_name, c.phone, c.country;

-- Mostrar la vista ordeanada. Por buenas prácticas, se separa la consulta ordenada ORDER BY
SELECT *
FROM VistaMarketing
ORDER BY media_compra DESC;

-- Mostrar la estructura de la vista
SHOW CREATE VIEW VistaMarketing;

#EJERCICIO 3
-- Empresas con residencia en 'Germany'
SELECT *
FROM VistaMarketing
WHERE País = 'Germany'
ORDER BY media_compra DESC;

#NIVEL 3

#EJERCICIO 1

-- 1.Se ejecuta el script de la estructura de la tabla user
-- 2.Se ejecuta el scrtip de los datos de la tabla user
-- 3.Se cambia el nombre de la tabla user por data_user (así figura en el diagrama) y porque 
-- de lo contrario podría haber problemas con las tablas y las consultas 
-- ya que user es una palabra reservada en MySQL.
RENAME TABLE user TO data_user;

-- 4.Cambiar tipo de valor del id CHAR por INT de la tabla data_user para crear la relación
ALTER TABLE data_user
MODIFY id INT;

/*
-- 5.Crear FOREIGN KEY para relacionar las tablas transaction y data_user
ALTER TABLE transaction
ADD CONSTRAINT fk_user
FOREIGN KEY (user_id)
REFERENCES data_user(id);
#Devuelve ERROR. Posiblemente porque no existe el 'user_id 9999'
*/

-- Se crea el 'user_id 9999'
INSERT INTO data_user (id)
VALUES (9999);

-- 5.Crear FOREIGN KEY para relacionar las tablas transaction y data_user
ALTER TABLE transaction
ADD CONSTRAINT fk_user
FOREIGN KEY (user_id)
REFERENCES data_user(id);

-- 6.Cambiar longitud del tipo del id de la tabla credit_card y credit_card_id de la tabla transaction
ALTER TABLE transaction 
MODIFY credit_card_id VARCHAR(20);

ALTER TABLE credit_card 
MODIFY id VARCHAR(20);

-- 7.Eliminar columna website de la tabla company
ALTER TABLE company
DROP COLUMN website;

-- 8.Cambiar nombre columna email por personal_email en la tabla data_user
ALTER TABLE data_user
RENAME COLUMN email TO personal_email;

-- 9.Crear columna fecha_actual en la tabla credit_card
ALTER TABLE credit_card
ADD COLUMN fecha_actual DATE;

#EJERCICIO 2
-- Crear vista InformeTecnico
CREATE VIEW InformeTecnico AS
SELECT	t.id AS ID_transaccion, u.name AS nombre_usuario, u.surname AS apellido_usuario,
		cc.iban AS IBAN_tarjeta, c.company_name AS nombre_empresa
FROM transaction t
JOIN data_user u ON t.user_id = u.id
JOIN credit_card cc ON t.credit_card_id = cc.id
JOIN company c ON t.company_id = c.id
WHERE t.declined = 0;

-- Mostrar los resultados ordenados en función de la variable ID_transaccion en forma descendente
SELECT *
FROM InformeTecnico
ORDER BY ID_transaccion DESC;

