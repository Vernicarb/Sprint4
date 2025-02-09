-- Nivell 1 
-- Exercici 1  
-- Descàrrega els arxius CSV, estudia'ls i dissenya una base de dades amb un esquema d'estrella que contingui, almenys 4 taules de les quals puguis realitzar les següents consultes:
-- Primer he creat la nova base de dades: empresa

CREATE DATABASE IF NOT EXISTS empresa;
USE empresa;
-- Després he creat totes les taules abans d'incorporar les dades dels arxius .csv:

CREATE TABLE Companies (
    company_id VARCHAR(250) PRIMARY KEY,
    company_name VARCHAR(100),
    phone VARCHAR(50),
    email VARCHAR(150),
    country VARCHAR(50),
    website VARCHAR(255)
);

CREATE TABLE Credit_cards (
    id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50),
    iban VARCHAR(34),
    pan VARCHAR(34),
    pin VARCHAR(4),
    cvv VARCHAR(3),
    track1 VARCHAR(100),
    track2 VARCHAR(100),
    expiring_date DATE,
    FOREIGN KEY (user_id) REFERENCES Users(id)
);

ALTER TABLE Credit_cards 
MODIFY COLUMN expiring_date VARCHAR(200);

CREATE TABLE IF NOT EXISTS users (
    id SMALLINT UNSIGNED PRIMARY KEY,
    name VARCHAR (100 ), 
    surname VARCHAR(100),
    phone VARCHAR(50),
    email VARCHAR (100),
    birth_date  VARCHAR (50),
    country VARCHAR(50),
    city VARCHAR(50),
    postal_code VARCHAR (15),
    address VARCHAR (255)
);
CREATE TABLE IF NOT EXISTS transactions (
        id VARCHAR(40) PRIMARY KEY,
        card_id VARCHAR(15),
        business_id VARCHAR(15), 
        timestamp TIMESTAMP,
        amount DECIMAL(10, 2),
        declined TINYINT NOT NULL DEFAULT 0,
        product_ids VARCHAR(150),
        user_id SMALLINT UNSIGNED,
        lat DECIMAL(15,10),
        longitude DECIMAL(15,10),
        FOREIGN KEY (business_id) REFERENCES companies(company_id),
        FOREIGN KEY (card_id) REFERENCES credit_cards(id),
        FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Borro la foreign key duplicada de la taula credit_cards:

SELECT CONSTRAINT_NAME, TABLE_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME 
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_NAME = 'credit_cards' AND TABLE_SCHEMA = DATABASE();

ALTER TABLE credit_cards DROP FOREIGN KEY credit_cards_ibfk_1; 

-- Cargo els arxius .csv de les diferents taules:

-- Comprobació de que local_infile está ON: 

SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile =1;

-- Comprobacions per sapiguer a quina carpeta he de guardar els arxius per tal de fer la importació:

SHOW GLOBAL VARIABLES LIKE 'secure_file_priv';

SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transactions.csv'
INTO TABLE empresa.transactions
FIELDS TERMINATED BY ';' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_usa.csv'
INTO TABLE empresa.users
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(@col1, @col2, @col3, @col4, @col5, @col6, @col7, @col8, @col9, @col10, @extra)
SET 
    id = @col1,
    name = @col2,
    surname = @col3,
    phone = @col4,
    email = @col5,
    birth_date = @col6,
    country = @col7,
    city = @col8,
    postal_code = @col9,
    address = @col10;
    
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_uk.csv'
INTO TABLE empresa.users
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(@col1, @col2, @col3, @col4, @col5, @col6, @col7, @col8, @col9, @col10, @extra)
SET 
    id = @col1,
    name = @col2,
    surname = @col3,
    phone = @col4,
    email = @col5,
    birth_date = @col6,
    country = @col7,
    city = @col8,
    postal_code = @col9,
    address = @col10;
    
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_ca.csv'
INTO TABLE empresa.users
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(@col1, @col2, @col3, @col4, @col5, @col6, @col7, @col8, @col9, @col10, @extra)
SET 
    id = @col1,
    name = @col2,
    surname = @col3,
    phone = @col4,
    email = @col5,
    birth_date = @col6,
    country = @col7,
    city = @col8,
    postal_code = @col9,
    address = @col10;
    
ALTER TABLE empresa.companies 
MODIFY phone VARCHAR(50) NULL,
MODIFY email VARCHAR(150) NULL,
MODIFY country VARCHAR(50) NULL,
MODIFY website VARCHAR(255) NULL;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/companies.csv'
INTO TABLE empresa.companies
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/credit_cards.csv'
INTO TABLE empresa.credit_cards
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Exercici 1
--  Realitza una subconsulta que mostri tots els usuaris amb més de 30 transaccions utilitzant almenys 2 taules.

SELECT * 
FROM users 
WHERE id IN (
    SELECT user_id 
    FROM transactions 
    GROUP BY user_id 
    HAVING COUNT(*) > 30
);

-- Exercici 2
-- Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.

SELECT credit_cards.iban, AVG(transactions.amount) AS mitjana_amount
FROM credit_cards 
JOIN transactions ON credit_cards.id = transactions.card_id
JOIN companies ON transactions.business_id = companies.company_id
WHERE companies.company_name = 'Donec Ltd'
GROUP BY credit_cards.iban;



