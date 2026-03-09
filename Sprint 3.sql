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
ALTER TABLE transactions
ADD CONSTRAINT fk_creditcard

