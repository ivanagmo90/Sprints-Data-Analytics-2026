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