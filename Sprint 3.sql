USE transactions;

# NIVEL 1

#EJERCICIO 1
CREATE TABLE credit_card (
	id VARCHAR(20) PRIMARY KEY,
    iban VARCHAR(50) NOT NULL,
    pan VARCHAR(20) NOT NULL,
    pin VARCHAR(4) NOT NULL,
    cvv INT NOT NULL,
    expiring_date VARCHAR(20) NOT NULL
);

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
SELECT id
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
-- Comprobación si alguna tabla la usa como foreign key
SELECT     
	table_name, 
    column_name, 
    constraint_name, 
    referenced_table_name, 
    referenced_column_name
FROM information_schema.KEY_COLUMN_USAGE
WHERE referenced_table_schema = 'transactions'
AND referenced_table_name = 'transaction'; -- borrar directamente la columna 'pan'?





