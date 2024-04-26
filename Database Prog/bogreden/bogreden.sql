-- ----- --
-- Notes --
-- ----- --
-- see at the end of the file: '-- Bulk Insert from csv --'
-- see at the end of the file: '-- Create [CALL insert] procedures --'
-- 
-- I have made some samples for delete, update and select procedures, 
-- but I have not made all of them, as I was running short on time.
-- I would make the select procedures differently in a production environment,
-- there i would only select what i need to select and not use the * operator.
-- Right, however, i am not entirely sure which poitns of data I'll need to 
-- extract, as I have not yet made a class diagram for the finall app.
-- I might use a JOIN between BOOK and pricem, but I would probably not,
-- as I would probably use a Price class as a property on the Book class,
-- and handle the selection of price data on the Price class.
-- 
-- If i were to Drop a procedure I would use:
-- DROP PROCEDURE IF EXISTS procedure_name;
-- I would probably never make a procedure to drop other procedures.
--
-- I would have changed the foreing keys to be named fk_, but i do not have time to do so now.
--
-- I am using COALESCE in tr_taxes_update_after. I would like to have done this in all of my triggers,
-- but I am out of time.
--
-- Performance can be measured using complex joins and measuring the time they take to execute.
-- One can also analyze the time stamps in the before and after values in the log table.
-- one could also have used EXPLAIN or EXPLAIN ANALYZE to get information about performance when executing statements.


-- ----------------- --
-- Initiate Database --
-- ----------------- --
-- Drop the database if it exists
DROP DATABASE IF EXISTS bogreden;

-- Create the database
CREATE DATABASE bogreden;

-- Select the database to use
USE bogreden;

-- --------------------------- --
-- create privileges and users --
-- --------------------------- --
-- Drop the existing user
DROP USER IF EXISTS 'Owner'@'localhost';

-- Create the user 'Owner' with a password
CREATE USER 'Owner'@'localhost' IDENTIFIED BY 'Owner!0ret';

-- Grant full privileges to the 'Owner' user for all tables in the bogreden database
GRANT ALL PRIVILEGES ON bogreden.* TO 'Owner'@'localhost';

-- Apply the changes
FLUSH PRIVILEGES;

-- --------------------------------- --
-- Create tables without forein keys --
-- --------------------------------- --
CREATE TABLE br_bogreden_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    log_table_key VARCHAR(25),
    log_time_stamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    log_message TEXT
);

-- I have defined this as a varchar because there are countries, 
-- such as canada, which use letters in the postal code.
CREATE TABLE br_city (
    city_postal_code VARCHAR(15) PRIMARY KEY,
    city_name VARCHAR(200) NOT NULL
);

CREATE TABLE br_user (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    user_first_name VARCHAR(50) NOT NULL,
    user_last_name VARCHAR(50) NOT NULL,
    user_username VARCHAR(50) UNIQUE NOT NULL,
    user_password VARCHAR(250) NOT NULL,
    user_email VARCHAR(254) UNIQUE NOT NULL,
    user_phone_number VARCHAR(25) UNIQUE NOT NULL
);

CREATE TABLE br_pricing (
    pri_id INT AUTO_INCREMENT PRIMARY KEY,
    pri_purchase_price DECIMAL(6, 2) NOT NULL,
    pri_sales_price DECIMAL(6, 2) NOT NULL,
    pri_sale_percentage DECIMAL(5, 2),
    pri_price_reduction DECIMAL(6, 2)
);

CREATE TABLE br_tax ( -- types of taxes
    tax_id INT AUTO_INCREMENT PRIMARY KEY,
    tax_rate DECIMAL(6,2) NOT NULl, -- the percentage of tax
    tax_name VARCHAR(100), -- ingoing tax, sales tax, outgoing tax
    tax_incoming BOOLEAN NOT NULL -- false if tax is outgoing
);

-- this table only contains a single row.
CREATE TABLE br_taxes (
   pri_id INT AUTO_INCREMENT PRIMARY KEY, -- id of the tax
   fk_tax_id INT NOT NULL, -- the id of the type of tax
   Accumi_tax decimal(6,2), -- the sum of the taxes paid
   last_update datetime, -- the last time the tax was updated
   last_tax_paid datetime -- the last time the tax was paid
);

CREATE TABLE br_genre (gen_value VARCHAR(100) PRIMARY KEY);

CREATE TABLE br_author (auth_name VARCHAR(100) PRIMARY KEY);

-- ------------------------------ --
-- create tables with forein keys --
-- ------------------------------ --
CREATE TABLE br_address (
    adr_id INT AUTO_INCREMENT PRIMARY KEY,
    adr_postal_code VARCHAR(15) NOT NULL,
    adr_user_id INT NOT NULL,
    adr_street_address VARCHAR(100) NOT NULL,
    adr_country varchar(60) NOT NULL,
    adr_is_billing_address BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (adr_postal_code) REFERENCES br_city(city_postal_code),
    FOREIGN KEY (adr_user_id) REFERENCES br_user(user_id) ON DELETE CASCADE
);

CREATE TABLE br_order (
    odr_id INT AUTO_INCREMENT PRIMARY KEY,
    odr_user_id INT,
    odr_shipping_date TIMESTAMP,
    odr_sold_price DECIMAL(6, 2),
    odr_status Enum(
        'Received',
        'Processed',
        'Shipped',
        'Delivered',
        'Cancelled',
        'Returned',
        'Failed',
        'On Hold'
    ),
    FOREIGN KEY (odr_user_id) REFERENCES br_user(user_id)
);

CREATE TABLE br_book (
    bk_id INT AUTO_INCREMENT PRIMARY KEY,
    bk_pricing_id INT,
    bk_titel VARCHAR(100),
    bk_weight DECIMAL(6, 4),
    bk_description TEXT,
    bk_image VARCHAR(50),
    FOREIGN KEY (bk_pricing_id) REFERENCES br_pricing(pri_id)
);

-- ------------------------------ --
-- create tables with forein keys --
-- ------------------------------ --
-- we don't delete the author with the book, because one author might have more books.
CREATE TABLE br_book_author (
    ba_id INT AUTO_INCREMENT PRIMARY KEY,
    ba_book_id INT,
    ba_author_name VARCHAR(100),
    FOREIGN KEY (ba_book_id) REFERENCES br_book(bk_id),
    FOREIGN KEY (ba_author_name) REFERENCES br_author(auth_name)
);

CREATE TABLE br_book_genre (
    bg_id INT AUTO_INCREMENT PRIMARY KEY,
    bg_book_id INT,
    bg_genre VARCHAR(100),
    FOREIGN KEY (bg_book_id) REFERENCES br_book(bk_id),
    FOREIGN KEY (bg_genre) REFERENCES br_genre(gen_value)
);

CREATE TABLE br_book_order (
    bo_id INT AUTO_INCREMENT PRIMARY KEY,
    bo_book_id INT,
    bo_ord_id INT,
    FOREIGN KEY (bo_book_id) REFERENCES br_book(bk_id),
    FOREIGN KEY (bo_ord_id) REFERENCES br_order(odr_id)
);

-- -------- --
-- Indexing --
-- -------- --

CREATE INDEX idx_city ON br_city (city_postal_code, city_name);

CREATE INDEX idx_user ON br_user (
    user_id,
    user_first_name,
    user_last_name,
    user_username,
    user_password,
    user_email,
    user_phone_number
);

CREATE INDEX idx_pricing ON br_pricing (
    pri_id,
    pri_purchase_price,
    pri_sales_price,
    pri_sale_percentage,
    pri_price_reduction
);

CREATE INDEX idx_genre ON br_genre (gen_value);

CREATE INDEX idx_author ON br_author (auth_name);

CREATE INDEX idx_address ON br_address (
    adr_id,
    adr_postal_code,
    adr_user_id,
    adr_street_address,
    adr_country,
    adr_is_billing_address
);

CREATE INDEX idx_order ON br_order (
    odr_id,
    odr_user_id,
    odr_shipping_date,
    odr_sold_price,
    odr_status
);

CREATE INDEX idx_book ON br_book (
    bk_id,
    bk_pricing_id,
    bk_titel,
    bk_weight
);

CREATE INDEX idx_book_author ON br_book_author (
    ba_id,
    ba_book_id,
    ba_author_name
);

CREATE INDEX idx_book_genre ON br_book_genre (bg_id, bg_book_id, bg_genre);

CREATE INDEX idx_book_order ON br_book_order (bo_id, bo_book_id, bo_ord_id);

DELIMITER ¤ 

-- ----------------------------------- --
-- create after insert trigger scripts --
-- ----------------------------------- --

CREATE TRIGGER tr_city_insert_after AFTER INSERT
    ON br_city FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES (
        NULL,
        'city_after',
        CURRENT_TIMESTAMP(),
        CONCAT(
            'city_postal_code: ',
            NEW.city_postal_code,
            ', ',
            'city_name: ',
            NEW.city_name
        )
    );
END¤

CREATE TRIGGER tr_user_insert_after AFTER INSERT
    ON br_user FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES (
        NULL,
        'user_after',
        CURRENT_TIMESTAMP(),
        CONCAT(
            'user_id: ',
            NEW.user_id,
            ', ',
            'user_first_name: ',
            NEW.user_first_name,
            ', ',
            'user_last_name: ',
            NEW.user_last_name,
            ', ',
            'user_username: ',
            NEW.user_username,
            ', ',
            'user_password: ',
            NEW.user_password,
            ', ',
            'user_email: ',
            NEW.user_email,
            ', ',
            'user_phone_number: ',
            NEW.user_phone_number
        )
    );
END¤

CREATE TRIGGER tr_pricing_insert_after AFTER INSERT
    ON br_pricing FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES
    (
        NULL,
        'pricing_after',
        CURRENT_TIMESTAMP(),
        CONCAT(
            'pri_id: ',
            NEW.pri_id,
            ', ',
            'pri_purchase_price: ',
            NEW.pri_purchase_price,
            ', ',
            'pri_sales_price: ',
            NEW.pri_sales_price,
            ', ',
            'pri_sale_percentage: ',
            NEW.pri_sale_percentage,
            ', ',
            'pri_price_reduction: ',
            NEW.pri_price_reduction,
            ', '
        )
    );
END¤

CREATE TRIGGER tr_genre_insert_after AFTER INSERT
    ON br_genre FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES
    (
        NULL,
        'genre_after',
        CURRENT_TIMESTAMP(),
        CONCAT('gen_value: ', NEW.gen_value)
    );
END¤

CREATE TRIGGER tr_author_insert_after AFTER INSERT
    ON br_author FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES
    (
        NULL,
        'author_after',
        CURRENT_TIMESTAMP(),
        CONCAT('auth_name: ', NEW.auth_name)
    );
END¤

CREATE TRIGGER tr_address_insert_after AFTER INSERT
    ON br_address FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES
    (
        NULL,
        'address_after',
        CURRENT_TIMESTAMP(),
        CONCAT(
            'adr_id: ',
            NEW.adr_id,
            ', ',
            'adr_postal_code: ',
            NEW.adr_postal_code,
            ', ',
            'adr_user_id: ',
            NEW.adr_user_id,
            ', ',
            'adr_street_address: ',
            NEW.adr_street_address,
            ', ',
            'adr_country: ',
            NEW.adr_country,
            ', ',
            'adr_is_billing_address: ',
            NEW.adr_is_billing_address,
            ', '
        )
    );
END¤

CREATE TRIGGER tr_order_insert_after AFTER INSERT
ON br_order FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (log_id, log_table_key, log_time_stamp, log_message)
    VALUES (
        NULL,
        'order_after',
        CURRENT_TIMESTAMP(),
        CONCAT(
            'odr_id: ', NEW.odr_id, ', ',
            'odr_user_id: ', NEW.odr_user_id, ', ',
            'odr_shipping_date: ', NEW.odr_shipping_date, ', ',
            'odr_sold_price: ', NEW.odr_sold_price, ', ',
            'odr_status: ', NEW.odr_status, ', '
        )
    );

    IF NEW.odr_status = 'Received' THEN 
        -- Add the final tax to the br_taxes.accumi_tax
        UPDATE br_taxes
        SET accumi_tax = accumi_tax + (
                NEW.odr_sold_price - (
                    SELECT br_pricing.pri_purchase_price
                    FROM br_book_order
                    JOIN br_book ON br_book_order.bo_book_id = br_book.bk_id
                    JOIN br_pricing ON br_book.bk_pricing_id = br_pricing.pri_id
                    WHERE br_book_order.bo_ord_id = NEW.odr_id
                )
            ) * ((SELECT tax_rate FROM br_tax WHERE tax_name = 'moms')/100),
            last_update = NOW()
        WHERE pri_id = 1;
    END IF;
END¤

CREATE TRIGGER tr_book_insert_after AFTER INSERT
    ON br_book FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES
    (
        NULL,
        'book_after',
        CURRENT_TIMESTAMP(),
        CONCAT(
            'bk_id: ',
            NEW.bk_id,
            ', ',
            'bk_pricing_id: ',
            NEW.bk_pricing_id,
            ', ',
            'bk_titel: ',
            NEW.bk_titel,
            ', ',
            'bk_weight: ',
            NEW.bk_weight,
            ', ',
            'bk_description: ',
            NEW.bk_description,
            ', ',
            'bk_image: ',
            NEW.bk_image,
            ', '
        )
    );
END¤

CREATE TRIGGER tr_book_author_insert_after AFTER INSERT
    ON br_book_author FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES
    (
        NULL,
        'book_author_after',
        CURRENT_TIMESTAMP(),
        CONCAT(
            'ba_id: ',
            NEW.ba_id,
            ', ',
            'ba_book_id: ',
            NEW.ba_book_id,
            ', ',
            'ba_author_name: ',
            NEW.ba_author_name,
            ', '
        )
    );
END¤

CREATE TRIGGER tr_book_genre_insert_after AFTER INSERT
    ON br_book_genre FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES
    (
        NULL,
        'book_genre_after',
        CURRENT_TIMESTAMP(),
        CONCAT(
            'bg_id: ',
            NEW.bg_id,
            ', ',
            'bg_book_id: ',
            NEW.bg_book_id,
            ', ',
            'bg_genre: ',
            NEW.bg_genre,
            ', '
        )
    );
END¤

CREATE TRIGGER tr_book_order_insert_after AFTER INSERT
    ON br_book_order FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES
    (
        NULL,
        'book_order_after',
        CURRENT_TIMESTAMP(),
        CONCAT(
            'bo_id: ',
            NEW.bo_id,
            ', ',
            'bo_book_id: ',
            NEW.bo_book_id,
            ', ',
            'bo_ord_id: ',
            NEW.bo_ord_id,
            ', '
        )
    );
END¤

CREATE TRIGGER tr_tax_insert_after AFTER INSERT
    ON br_tax FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES
    (
        NULL,
        'tax_after',
        CURRENT_TIMESTAMP(),
        CONCAT(
            'tax_id: ',
            NEW.tax_id,
            ', ',
            'tax_rate: ',
            NEW.tax_rate,
            ', ',
            'tax_name: ',
            NEW.tax_name,
            ', ',
            'tax_incoming: ',
            NEW.tax_incoming
        )
    );
END¤

CREATE TRIGGER tr_taxes_insert_after AFTER INSERT
    ON br_taxes FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES
    (
        NULL,
        'taxes_after',
        CURRENT_TIMESTAMP(),
        CONCAT(
            'pri_id: ',
            NEW.pri_id,
            ', ',
            'fk_tax_id: ',
            NEW.fk_tax_id,
            ', ',
            'Accumi_tax: ',
            NEW.Accumi_tax,
            ', ',
            'last_update: ',
            NEW.last_update,
            ', ',
            'last_tax_paid: ',
            NEW.last_tax_paid
        )
    );
END¤


-- ------------------------------------ --
-- create before insert trigger scripts --
-- ------------------------------------ --
CREATE TRIGGER tr_city_before_insert BEFORE INSERT
    ON br_city FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES (
        NULL,
        'city_before',
        CURRENT_TIMESTAMP(),
        'Insert New Row'
    );
END¤

CREATE TRIGGER tr_user_before_insert BEFORE INSERT
    ON br_user FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES (
        NULL,
        'user_before',
        CURRENT_TIMESTAMP(),
        'Insert New Row'
    );
END¤

CREATE TRIGGER tr_pricing_before_insert BEFORE INSERT
    ON br_pricing FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES (
        NULL,
        'pricing_before',
        CURRENT_TIMESTAMP(),
        'Insert New Row'
    );
END¤

CREATE TRIGGER tr_genre_before_insert BEFORE INSERT
    ON br_genre FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES (
        NULL,
        'genre_before',
        CURRENT_TIMESTAMP(),
        CONCAT('gen_value: ', NEW.gen_value)
    );
END¤

CREATE TRIGGER tr_author_before_insert BEFORE INSERT
    ON br_author FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES (
        NULL,
        'author_before',
        CURRENT_TIMESTAMP(),
        CONCAT('auth_name: ', NEW.auth_name)
    );
END¤

CREATE TRIGGER tr_address_before_insert BEFORE INSERT
    ON br_address FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES (
        NULL,
        'address_before',
        CURRENT_TIMESTAMP(),
        'Insert New Row'
    );
END¤

CREATE TRIGGER tr_order_before_insert BEFORE INSERT
    ON br_order FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES (
        NULL,
        'order_before',
        CURRENT_TIMESTAMP(),
        'Insert New Row'
    );
END¤

CREATE TRIGGER tr_book_before_insert BEFORE INSERT
    ON br_book FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES (
        NULL,
        'book_before',
        CURRENT_TIMESTAMP(),
        'Insert New Row'
    );
END¤

CREATE TRIGGER tr_book_author_before_insert BEFORE INSERT
    ON br_book_author FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES (
        NULL,
        'book_author_before',
        CURRENT_TIMESTAMP(),
        'Insert New Row'
    );
END¤

CREATE TRIGGER tr_tax_before_insert BEFORE INSERT
    ON br_tax FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES
    (
        NULL,
        'tax_before',
        CURRENT_TIMESTAMP(),
        'Insert New Row'
    );
END¤

CREATE TRIGGER tr_taxes_before_insert BEFORE INSERT
    ON br_taxes FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES
    (
        NULL,
        'taxes_before',
        CURRENT_TIMESTAMP(),
        'Insert New Row'
    );
END¤


-- ----------------------------------- --
-- create after update trigger scripts --
-- ----------------------------------- --

CREATE TRIGGER tr_cityupdate__after AFTER UPDATE
ON br_city FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES
    (
        NULL,
        'city_after',
        CURRENT_TIMESTAMP(),
        CONCAT(
            'city_postal_code: ',
            NEW.city_postal_code,
            ', ',
            'city_name: ',
            NEW.city_name
        )
    );
END¤

CREATE TRIGGER tr_userupdate__after AFTER UPDATE
ON br_user FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES
    (
        NULL,
        'user_after',
        CURRENT_TIMESTAMP(),
        CONCAT(
            'user_id: ',
            NEW.user_id,
            ', ',
            'user_first_name: ',
            NEW.user_first_name,
            ', ',
            'user_last_name: ',
            NEW.user_last_name,
            ', ',
            'user_username: ',
            NEW.user_username,
            ', ',
            'user_password: ',
            NEW.user_password,
            ', ',
            'user_email: ',
            NEW.user_email,
            ', ',
            'user_phone_number: ',
            NEW.user_phone_number
        )
    );
END¤

CREATE TRIGGER tr_pricingupdate__after AFTER UPDATE
ON br_pricing FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES
    (
        NULL,
        'pricing_after',
        CURRENT_TIMESTAMP(),
        CONCAT(
            'pri_id: ',
            NEW.pri_id,
            ', ',
            'pri_purchase_price: ',
            NEW.pri_purchase_price,
            ', ',
            'pri_sales_price: ',
            NEW.pri_sales_price,
            ', ',
            'pri_sale_percentage: ',
            NEW.pri_sale_percentage,
            ', ',
            'pri_price_reduction: ',
            NEW.pri_price_reduction,
            ', '
        )
    );
END¤

CREATE TRIGGER tr_genreupdate__after AFTER UPDATE
ON br_genre FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES
    (
        NULL,
        'genre_after',
        CURRENT_TIMESTAMP(),
        CONCAT('gen_value: ', NEW.gen_value)
    );
END¤

CREATE TRIGGER tr_authorupdate__after AFTER UPDATE
ON br_author FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES
    (
        NULL,
        'author_after',
        CURRENT_TIMESTAMP(),
        CONCAT('auth_name: ', NEW.auth_name)
    );
END¤

CREATE TRIGGER tr_addressupdate__after AFTER UPDATE
ON br_address FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES
    (
        NULL,
        'address_after',
        CURRENT_TIMESTAMP(),
        CONCAT(
            'adr_id: ',
            NEW.adr_id,
            ', ',
            'adr_postal_code: ',
            NEW.adr_postal_code,
            ', ',
            'adr_user_id: ',
            NEW.adr_user_id,
            ', ',
            'adr_street_address: ',
            NEW.adr_street_address,
            ', ',
            'adr_country: ',
            NEW.adr_country,
            ', ',
            'adr_is_billing_address: ',
            NEW.adr_is_billing_address,
            ', '
        )
    );
END¤

CREATE TRIGGER tr_orderupdate__after AFTER UPDATE
ON br_order FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES
    (
        NULL,
        'order_after',
        CURRENT_TIMESTAMP(),
        CONCAT(
            'odr_id: ',
            NEW.odr_id,
            ', ',
            'odr_user_id: ',
            NEW.odr_user_id,
            ', ',
            'odr_shipping_date: ',
            NEW.odr_shipping_date,
            ', ',
            'odr_sold_price: ',
            NEW.odr_sold_price,
            ', ',
            'odr_status: ',
            NEW.odr_status,
            ', '
        )
    );
END¤

CREATE TRIGGER tr_bookupdate__after AFTER UPDATE
ON br_book FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES
    (
        NULL,
        'book_after',
        CURRENT_TIMESTAMP(),
        CONCAT(
            'bk_id: ',
            NEW.bk_id,
            ', ',
            'bk_pricing_id: ',
            NEW.bk_pricing_id,
            ', ',
            'bk_titel: ',
            NEW.bk_titel,
            ', ',
            'bk_weight: ',
            NEW.bk_weight,
            ', ',
            'bk_description: ',
            NEW.bk_description,
            ', ',
            'bk_image: ',
            NEW.bk_image,
            ', '
        )
    );
END¤

CREATE TRIGGER tr_book_authorupdate__after AFTER UPDATE
ON br_book_author FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES
    (
        NULL,
        'book_author_after',
        CURRENT_TIMESTAMP(),
        CONCAT(
            'ba_id: ',
            NEW.ba_id,
            ', ',
            'ba_book_id: ',
            NEW.ba_book_id,
            ', ',
            'ba_author_name: ',
            NEW.ba_author_name,
            ', '
        )
    );
END¤

CREATE TRIGGER tr_book_genreupdate__after AFTER UPDATE
ON br_book_genre FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES
    (
        NULL,
        'book_genre_after',
        CURRENT_TIMESTAMP(),
        CONCAT(
            'bg_id: ',
            NEW.bg_id,
            ', ',
            'bg_book_id: ',
            NEW.bg_book_id,
            ', ',
            'bg_genre: ',
            NEW.bg_genre,
            ', '
        )
    );
END¤

CREATE TRIGGER tr_book_orderupdate__after AFTER UPDATE
ON br_book_order FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES
    (
        NULL,
        'book_order_after',
        CURRENT_TIMESTAMP(),
        CONCAT(
            'bo_id: ',
            NEW.bo_id,
            ', ',
            'bo_book_id: ',
            NEW.bo_book_id,
            ', ',
            'bo_ord_id: ',
            NEW.bo_ord_id,
            ', '
        )
    );
END¤

CREATE TRIGGER tr_tax_update_after AFTER UPDATE
    ON br_tax FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES
    (
        NULL,
        'tax_after',
        CURRENT_TIMESTAMP(),
        CONCAT(
            'tax_id: ',
            NEW.tax_id,
            ', ',
            'tax_rate: ',
            NEW.tax_rate,
            ', ',
            'tax_name: ',
            NEW.tax_name,
            ', ',
            'tax_incoming: ',
            NEW.tax_incoming
        )
    );
END¤

CREATE TRIGGER tr_taxes_update_after AFTER UPDATE
    ON br_taxes FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES
    (
        NULL,
        'taxes_after',
        CURRENT_TIMESTAMP(),
        CONCAT(
            'pri_id: ', COALESCE(NEW.pri_id, 'NULL'), ', ',
            'fk_tax_id: ', COALESCE(NEW.fk_tax_id, 'NULL'), ', ',
            'Accumi_tax: ', COALESCE(NEW.Accumi_tax, 'NULL'), ', ',
            'last_update: ', COALESCE(NEW.last_update, 'NULL'), ', ',
            'last_tax_paid: ', COALESCE(NEW.last_tax_paid, 'NULL')
        )
    );
END¤


-- ------------------------------------ --
-- create before update trigger scripts --
-- ------------------------------------ --

CREATE TRIGGER tr_city_update_before BEFORE UPDATE
ON br_city FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES
    (
        NULL,
        'city_after',
        CURRENT_TIMESTAMP(),
        CONCAT(
            'city_postal_code: ',
            OLD.city_postal_code,
            ', ',
            'city_name: ',
            OLD.city_name
        )
    );
END¤

CREATE TRIGGER tr_user_update_before BEFORE UPDATE
ON br_user FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES
    (
        NULL,
        'user_after',
        CURRENT_TIMESTAMP(),
        CONCAT(
            'user_id: ',
            OLD.user_id,
            ', ',
            'user_first_name: ',
            OLD.user_first_name,
            ', ',
            'user_last_name: ',
            OLD.user_last_name,
            ', ',
            'user_username: ',
            OLD.user_username,
            ', ',
            'user_password: ',
            OLD.user_password,
            ', ',
            'user_email: ',
            OLD.user_email,
            ', ',
            'user_phone_number: ',
            OLD.user_phone_number
        )
    );
END¤

CREATE TRIGGER tr_pricing_update_before BEFORE UPDATE
ON br_pricing FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES
    (
        NULL,
        'pricing_after',
        CURRENT_TIMESTAMP(),
        CONCAT(
            'pri_id: ',
            OLD.pri_id,
            ', ',
            'pri_purchase_price: ',
            OLD.pri_purchase_price,
            ', ',
            'pri_sales_price: ',
            OLD.pri_sales_price,
            ', ',
            'pri_sale_percentage: ',
            OLD.pri_sale_percentage,
            ', ',
            'pri_price_reduction: ',
            OLD.pri_price_reduction,
            ', '
        )
    );
END¤

CREATE TRIGGER tr_genre_update_before BEFORE UPDATE
ON br_genre FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES
    (
        NULL,
        'genre_after',
        CURRENT_TIMESTAMP(),
        CONCAT('gen_value: ', NEW.gen_value)
    );
END¤

CREATE TRIGGER tr_author_update_before BEFORE UPDATE
ON br_author FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES
    (
        NULL,
        'author_after',
        CURRENT_TIMESTAMP(),
        CONCAT('auth_name: ', NEW.auth_name)
    );
END¤

CREATE TRIGGER tr_address_update_before BEFORE UPDATE
ON br_address FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES
    (
        NULL,
        'address_after',
        CURRENT_TIMESTAMP(),
        CONCAT(
            'adr_id: ',
            OLD.adr_id,
            ', ',
            'adr_postal_code: ',
            OLD.adr_postal_code,
            ', ',
            'adr_user_id: ',
            OLD.adr_user_id,
            ', ',
            'adr_street_address: ',
            OLD.adr_street_address,
            ', ',
            'adr_country: ',
            OLD.adr_country,
            ', ',
            'adr_is_billing_address: ',
            OLD.adr_is_billing_address,
            ', '
        )
    );
END¤

CREATE TRIGGER tr_order_update_before BEFORE UPDATE
ON br_order FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES
    (
        NULL,
        'order_after',
        CURRENT_TIMESTAMP(),
        CONCAT(
            'odr_id: ',
            OLD.odr_id,
            ', ',
            'odr_user_id: ',
            OLD.odr_user_id,
            ', ',
            'odr_shipping_date: ',
            OLD.odr_shipping_date,
            ', ',
            'odr_sold_price: ',
            OLD.odr_sold_price,
            ', ',
            'odr_status: ',
            OLD.odr_status,
            ', '
        )
    );
END¤

CREATE TRIGGER tr_book_update_before BEFORE UPDATE
ON br_book FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES
    (
        NULL,
        'book_after',
        CURRENT_TIMESTAMP(),
        CONCAT(
            'bk_id: ',
            OLD.bk_id,
            ', ',
            'bk_pricing_id: ',
            OLD.bk_pricing_id,
            ', ',
            'bk_titel: ',
            OLD.bk_titel,
            ', ',
            'bk_weight: ',
            OLD.bk_weight,
            ', ',
            'bk_description: ',
            OLD.bk_description,
            ', ',
            'bk_image: ',
            OLD.bk_image,
            ', '
        )
    );
END¤

CREATE TRIGGER tr_book_author_update_before BEFORE UPDATE
ON br_book_author FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES
    (
        NULL,
        'book_author_after',
        CURRENT_TIMESTAMP(),
        CONCAT(
            'ba_id: ',
            OLD.ba_id,
            ', ',
            'ba_book_id: ',
            OLD.ba_book_id,
            ', ',
            'ba_author_name: ',
            OLD.ba_author_name,
            ', '
        )
    );
END¤

CREATE TRIGGER tr_book_genre_update_before BEFORE UPDATE
ON br_book_genre FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES
    (
        NULL,
        'book_genre_after',
        CURRENT_TIMESTAMP(),
        CONCAT(
            'bg_id: ',
            OLD.bg_id,
            ', ',
            'bg_book_id: ',
            OLD.bg_book_id,
            ', ',
            'bg_genre: ',
            OLD.bg_genre,
            ', '
        )
    );
END¤

CREATE TRIGGER tr_book_order_update_before BEFORE UPDATE
ON br_book_order FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES
    (
        NULL,
        'book_order_after',
        CURRENT_TIMESTAMP(),
        CONCAT(
            'bo_id: ',
            OLD.bo_id,
            ', ',
            'bo_book_id: ',
            OLD.bo_book_id,
            ', ',
            'bo_ord_id: ',
            OLD.bo_ord_id,
            ', '
        )
    );
END¤


CREATE TRIGGER tr_tax_update_before BEFORE UPDATE
ON br_tax FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES
    (
        NULL,
        'tax_after',
        CURRENT_TIMESTAMP(),
        CONCAT(
            'tax_id: ',
            OLD.tax_id,
            ', ',
            'tax_rate: ',
            OLD.tax_rate,
            ', ',
            'tax_name: ',
            OLD.tax_name,
            ', ',
            'tax_incoming: ',
            OLD.tax_incoming
        )
    );
END¤

CREATE TRIGGER tr_taxes_update_before BEFORE UPDATE
ON br_taxes FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES
    (
        NULL,
        'taxes_before',
        CURRENT_TIMESTAMP(),
        CONCAT(
            'pri_id: ',
            OLD.pri_id,
            ', ',
            'fk_tax_id: ',
            OLD.fk_tax_id,
            ', ',
            'Accumi_tax: ',
            OLD.Accumi_tax,
            ', ',
            'last_update: ',
            OLD.last_update,
            ', ',
            'last_tax_paid: ',
            OLD.last_tax_paid
        )
    );
END¤

-- ----------------------------------- --
-- create after delete trigger scripts --
-- ----------------------------------- --

CREATE TRIGGER tr_city_delete_after AFTER DELETE
ON br_city FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES (
        NULL,
        'city_after',
        CURRENT_TIMESTAMP(),
        'Row Deleted'
    );
END¤

CREATE TRIGGER tr_user_delete_after AFTER DELETE
ON br_user FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES (
        NULL,
        'user_after',
        CURRENT_TIMESTAMP(),
        'Row Deleted'
    );
END¤ 

CREATE TRIGGER tr_pricing_delete_after AFTER DELETE
ON br_pricing FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES (
        NULL,
        'pricing_after',
        CURRENT_TIMESTAMP(),
        'Row Deleted'
    );
END¤ 

CREATE TRIGGER tr_genre_delete_after AFTER DELETE
ON br_genre FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES (
        NULL,
        'genre_after',
        CURRENT_TIMESTAMP(),
        'Row Deleted'
    );
END¤ 

CREATE TRIGGER tr_author_delete_after AFTER DELETE
ON br_author FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES (
        NULL,
        'author_after',
        CURRENT_TIMESTAMP(),
        'Row Deleted'
    );
    UPDATE br_book_author
    SET ba_author_name = (SELECT auth_name FROM br_author WHERE auth_name = 'unknown')
    WHERE ba_author_name = `ba_author_name`;
END¤

CREATE TRIGGER tr_address_delete_after AFTER DELETE
ON br_address FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES (
        NULL,
        'address_after',
        CURRENT_TIMESTAMP(),
        'Row Deleted'
    );
END¤ 

CREATE TRIGGER tr_order_delete_after AFTER DELETE
ON br_order FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES (
        NULL,
        'order_after',
        CURRENT_TIMESTAMP(),
        'Row Deleted'
    );
END¤ 

CREATE TRIGGER tr_book_delete_after AFTER DELETE
ON br_book FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES (
        NULL,
        'book_after',
        CURRENT_TIMESTAMP(),
        'Row Deleted'
    );
END¤

CREATE TRIGGER tr_book_author_delete_after AFTER DELETE
ON br_book_author FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES (
        NULL,
        'book_author_after',
        CURRENT_TIMESTAMP(),
        'Row Deleted'
    );
END¤

CREATE TRIGGER tr_book_genre_delete_after AFTER DELETE
ON br_book_genre FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES (
        NULL,
        'book_genre_after',
        CURRENT_TIMESTAMP(),
        'Row Deleted'
    );
END¤

CREATE TRIGGER tr_book_order_delete_after AFTER DELETE
ON br_book_order FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES (
        NULL,
        'book_order_after',
        CURRENT_TIMESTAMP(),
        'Row Deleted'
    );
END¤ 

CREATE TRIGGER tr_tax_delete_before AFTER DELETE
    ON br_tax FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES
    (
        NULL,
        'tax_after',
        CURRENT_TIMESTAMP(),
        'Row Deleted'

    );
END¤

CREATE TRIGGER tr_taxes_delete_before AFTER DELETE
    ON br_taxes FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES
    (
        NULL,
        'taxes_after',
        CURRENT_TIMESTAMP(),
        'Row Deleted'
    );
END¤

-- ------------------------------------ --
-- create before delete trigger scripts --
-- ------------------------------------ --

CREATE TRIGGER tr_city_before_delete BEFORE DELETE
ON br_city FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES (
        NULL,
        'city_after',
        CURRENT_TIMESTAMP(),
        'Deleting Row'
    );
END¤

CREATE TRIGGER tr_user_before_delete BEFORE DELETE
ON br_user FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES (
        NULL,
        'user_after',
        CURRENT_TIMESTAMP(),
        'Deleting Row'
    );
END¤

CREATE TRIGGER tr_pricing_before_delete BEFORE DELETE
ON br_pricing FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES (
        NULL,
        'pricing_after',
        CURRENT_TIMESTAMP(),
        'Deleting Row'
    );
END¤

CREATE TRIGGER tr_genre_before_delete BEFORE DELETE
ON br_genre FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES (
        NULL,
        'genre_after',
        CURRENT_TIMESTAMP(),
        'Delete Row'
    );
END¤

CREATE TRIGGER tr_author_before_delete BEFORE DELETE
ON br_author FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES (
        NULL,
        'author_after',
        CURRENT_TIMESTAMP(),
        'Delete Row'
    );
END¤

CREATE TRIGGER tr_address_before_delete BEFORE DELETE
ON br_address FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES (
        NULL,
        'address_after',
        CURRENT_TIMESTAMP(),
        'Deleting Row'
    );
END¤

CREATE TRIGGER tr_order_before_delete BEFORE DELETE
ON br_order FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES (
        NULL,
        'order_after',
        CURRENT_TIMESTAMP(),
        'Deleting Row'
    );
END¤

CREATE TRIGGER tr_book_before_delete BEFORE DELETE
ON br_book FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES (
        NULL,
        'book_after',
        CURRENT_TIMESTAMP(),
        'Deleting Row'
    );
END¤

CREATE TRIGGER tr_book_author_before_delete BEFORE DELETE
ON br_book_author FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES (
        NULL,
        'book_author_after',
        CURRENT_TIMESTAMP(),
        'Deleting Row'
    );
END¤

CREATE TRIGGER tr_book_genre_before_delete BEFORE DELETE
ON br_book_genre FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES (
        NULL,
        'book_genre_after',
        CURRENT_TIMESTAMP(),
        'Deleting Row'
    );
END¤

CREATE TRIGGER tr_book_order_before_delete BEFORE DELETE
ON br_book_order FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES (
        NULL,
        'book_order_after',
        CURRENT_TIMESTAMP(),
        'Deleting Row'
    );
END¤

CREATE TRIGGER tr_tax_insert_before BEFORE DELETE
    ON br_tax FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES
    (
        NULL,
        'tax_after',
        CURRENT_TIMESTAMP(),
        'Deleting Row'

    );
END¤

CREATE TRIGGER tr_taxes_insert_before BEFORE DELETE
    ON br_taxes FOR EACH ROW BEGIN
    INSERT INTO br_bogreden_log (
        log_id,
        log_table_key,
        log_time_stamp,
        log_message
    )
    VALUES
    (
        NULL,
        'taxes_after',
        CURRENT_TIMESTAMP(),
        'Deleting Row'
    );
END¤

-- ------------------------------------- --
-- Create [insert procedures] procedures --
-- ------------------------------------- --

CREATE PROCEDURE insert_new_user(
    IN `first_name` VARCHAR(50),
    IN `last_name` VARCHAR(50),
    IN `username` VARCHAR(50),
    IN `password` VARCHAR(250),
    IN `confirm_password` VARCHAR(250),
    IN `email` VARCHAR(254),
    IN `phone_number` VARCHAR(25)
)
BEGIN
    IF `password` = `confirm_password` THEN
        SET @sql = 'INSERT INTO br_user (user_first_name, user_last_name, user_username, user_password, user_email, user_phone_number) VALUES (?, ?, ?, ?, ?, ?)';
        PREPARE stmt FROM @sql;
        EXECUTE stmt USING `first_name`, `last_name`, `username`, `password`, `email`, `phone_number`;
        DEALLOCATE PREPARE stmt;
    ELSE
        SELECT 'Passwords do not match' AS ErrorMessage;
    END IF;
END¤

CREATE PROCEDURE insert_new_pricing(
    IN `purchase_price` DECIMAL(6, 2),
    IN `sales_price` DECIMAL(6, 2),
    IN `sale_percentage` DECIMAL(5, 2),
    IN `price_reduction` DECIMAL(6, 2)
)
BEGIN
    SET @sql = 'INSERT INTO br_pricing (pri_purchase_price, pri_sales_price, pri_sale_percentage, pri_price_reduction) VALUES (?, ?, ?, ?)';
    PREPARE stmt FROM @sql;
    EXECUTE stmt USING `purchase_price`, `sales_price`, `sale_percentage`, `price_reduction`;
    DEALLOCATE PREPARE stmt;
END¤

CREATE PROCEDURE insert_new_genre(
    IN `value` VARCHAR(100)
)
BEGIN
    SET @sql = 'INSERT INTO br_genre (gen_value) VALUES (?)';
    PREPARE stmt FROM @sql;
    EXECUTE stmt USING `value`;
    DEALLOCATE PREPARE stmt;
END¤

CREATE PROCEDURE insert_new_author(
    IN `name` VARCHAR(100)
)
BEGIN
    SET @sql = 'INSERT INTO br_author (auth_name) VALUES (?)';
    PREPARE stmt FROM @sql;
    EXECUTE stmt USING `name`;
    DEALLOCATE PREPARE stmt;
END¤

CREATE PROCEDURE insert_new_address(
    IN `postal_code` VARCHAR(15),
    IN `user_id` INT,
    IN `street_address` VARCHAR(100),
    IN `country` varchar(60),
    IN `is_billing_address` BOOLEAN
)
BEGIN
    SET @sql = 'INSERT INTO br_address (adr_postal_code, adr_user_id, adr_street_address, adr_country, adr_is_billing_address) VALUES (?, ?, ?, ?, ?)';
    PREPARE stmt FROM @sql;
    EXECUTE stmt USING `postal_code`, `user_id`, `street_address`, `country`, `is_billing_address`;
    DEALLOCATE PREPARE stmt;
END¤

CREATE PROCEDURE insert_new_order(
    IN `user_id` INT,
    IN `shipping_date` TIMESTAMP,
    IN `sold_price` DECIMAL(6, 2),
    IN `status` ENUM('Received', 'Processed', 'Shipped', 'Delivered', 'Cancelled', 'Returned', 'Failed', 'On Hold')
)
BEGIN
    SET @sql = 'INSERT INTO br_order(odr_user_id, odr_shipping_date, odr_sold_price, odr_status) VALUES (?, ?, ?, ?)';
    PREPARE stmt FROM @sql;
    EXECUTE stmt USING `user_id`, `shipping_date`, `sold_price`, `status`;
    DEALLOCATE PREPARE stmt;
END¤

CREATE PROCEDURE insert_new_book(
    IN `pricing_id` INT,
    IN `title` VARCHAR(100),
    IN `weight` DECIMAL(6, 4),
    IN `description` TEXT,
    IN `image` VARCHAR(50)
)
BEGIN
    SET @sql = 'INSERT INTO br_book (bk_pricing_id, bk_titel, bk_weight, bk_description, bk_image) VALUES (?, ?, ?, ?, ?)';
    PREPARE stmt FROM @sql;
    EXECUTE stmt USING `pricing_id`, `title`, `weight`, `description`, `image`;
    DEALLOCATE PREPARE stmt;
END¤

CREATE PROCEDURE insert_new_book_author(
    IN `book_id` INT,
    IN `author_name` VARCHAR(100)
)
BEGIN
    SET @sql = 'INSERT INTO br_book_author (ba_book_id, ba_author_name) VALUES (?, ?)';
    PREPARE stmt FROM @sql;
    EXECUTE stmt USING `book_id`, `author_name`;
    DEALLOCATE PREPARE stmt;
END¤

CREATE PROCEDURE insert_new_book_genre(
    IN `book_id` INT,
    IN `genre` VARCHAR(100)
)
BEGIN
    SET @sql = 'INSERT INTO br_book_genre (bg_book_id, bg_genre) VALUES (?, ?)';
    PREPARE stmt FROM @sql;
    EXECUTE stmt USING `book_id`, `genre`;
    DEALLOCATE PREPARE stmt;
END¤

CREATE PROCEDURE insert_new_book_order(
    IN `book_id` INT,
    IN `order_id` INT
)
BEGIN
    SET @sql = 'INSERT INTO br_book_order (bo_book_id, bo_ord_id) VALUES (?, ?)';
    PREPARE stmt FROM @sql;
    EXECUTE stmt USING `book_id`, `order_id`;
    DEALLOCATE PREPARE stmt;
END¤


CREATE PROCEDURE insert_new_taxes()
BEGIN
    INSERT INTO br_taxes(
        fk_tax_id,
        Accumi_tax,
        last_update,
        last_tax_paid
    )
    VALUES(
        1,
        0,
        NOW(),
        NOW()
    );
END¤

CREATE PROCEDURE insert_new_tax(
    IN `rate` DECIMAL(6,2),
    IN `name` VARCHAR(100),
    IN `incoming` BOOLEAN
)
BEGIN
    SET @sql = 'INSERT INTO br_tax(tax_rate, tax_name, tax_incoming) VALUES (?, ?, ?)';
    PREPARE stmt FROM @sql;
    EXECUTE stmt USING `rate`, `name`, `incoming`;
    DEALLOCATE PREPARE stmt;
END¤

-- -------------------------------------- --
-- Create [UPDATE PROCEEDURES] procedures --
-- -------------------------------------- --
-- note that we only update entities which have a value.
-- If they are set to NULL they are not updated.
-- I have chosen this aproach because I do not want 
-- the database to contain invalid addresses.
--

CREATE PROCEDURE update_user(
    IN `id` INT,
    IN `first_name` VARCHAR(50),
    IN `last_name` VARCHAR(50),
    IN `username` VARCHAR(50),
    IN `password` VARCHAR(250),
    IN `confirm_password` VARCHAR(250),
    IN `email` VARCHAR(254),
    IN `phone_number` VARCHAR(25)
)
BEGIN
    IF `password` IS NOT NULL THEN
        IF `password` = `confirm_password` THEN
            SET @sql = 'UPDATE br_user SET user_password = ?, user_first_name = ?, user_last_name = ?, user_username = ?, user_email = ?, user_phone_number = ? WHERE user_id = ?';
            PREPARE stmt FROM @sql;
            EXECUTE stmt USING `password`, `first_name`, `last_name`, `username`, `email`, `phone_number`, `id`;
            DEALLOCATE PREPARE stmt;
        ELSE
            SELECT 'Passwords do not match' AS ErrorMessage;
        END IF;
    ELSE
        SELECT 'Password cannot be empty' AS ErrorMessage;
    END IF;
END¤

CREATE PROCEDURE update_genre(
    IN `current_value` VARCHAR(100),
    IN `new_value` VARCHAR(100)
)
BEGIN
    SET @sql = 'UPDATE br_genre SET gen_value = ? WHERE gen_value = ?';
    PREPARE stmt FROM @sql;
    EXECUTE stmt USING `new_value`, `current_value`;
    DEALLOCATE PREPARE stmt;
END¤

CREATE PROCEDURE update_author(
    IN `current_name` VARCHAR(100),
    IN `new_name` VARCHAR(100)
)
BEGIN
    SET @sql = 'UPDATE br_author SET auth_name = ? WHERE auth_name = ?';
    PREPARE stmt FROM @sql;
    EXECUTE stmt USING `new_name`, `current_name`;
    DEALLOCATE PREPARE stmt;
END¤

CREATE PROCEDURE update_address(
    IN `id` INT,
    IN `postal_code` VARCHAR(15),
    IN `street_address` VARCHAR(100),
    IN `country` VARCHAR(60),
    IN `is_billing_address` BOOLEAN
)
BEGIN
    SET @sql = 'UPDATE br_address SET adr_postal_code = ?, adr_street_address = ?, adr_country = ?, adr_is_billing_address = ? WHERE adr_id = ?';
    PREPARE stmt FROM @sql;
    EXECUTE stmt USING `postal_code`, `street_address`, `country`, `is_billing_address`, `id`;
    DEALLOCATE PREPARE stmt;
END¤
-- ------------------------------------- --
-- Create [DELETE PROCEDURES] procedures --
-- ------------------------------------- --

CREATE PROCEDURE delete_user(IN `id` INT) BEGIN
    SET @sql = 'DELETE FROM br_user WHERE user_id = ?';
    PREPARE stmt FROM @sql;
    EXECUTE stmt USING `id`;
    DEALLOCATE PREPARE stmt;
END¤

CREATE PROCEDURE delete_genre(IN `value` VARCHAR(100)) BEGIN
    SET @sql = 'DELETE FROM br_genre WHERE gen_value = ?';
    PREPARE stmt FROM @sql;
    EXECUTE stmt USING `value`;
    DEALLOCATE PREPARE stmt;
END¤

CREATE PROCEDURE delete_author(IN `name` VARCHAR(100)) BEGIN
    SET @sql = 'DELETE FROM br_author WHERE auth_name = ?';
    PREPARE stmt FROM @sql;
    EXECUTE stmt USING `name`;
    DEALLOCATE PREPARE stmt;
END¤

CREATE PROCEDURE delete_address(IN `id` INT) BEGIN
    SET @sql = 'DELETE FROM br_address WHERE adr_id = ?';
    PREPARE stmt FROM @sql;
    EXECUTE stmt USING `id`;
    DEALLOCATE PREPARE stmt;
END¤

CREATE PROCEDURE delete_book(IN `id` INT) BEGIN
    SET @sql = 'DELETE FROM br_book WHERE bk_id = ?';
    PREPARE stmt FROM @sql;
    EXECUTE stmt USING `id`;
    DEALLOCATE PREPARE stmt;
END¤

CREATE PROCEDURE delete_order(IN `id` INT)BEGIN
    SET @sql = 'DELETE FROM br_order WHERE order_id = ?';
    PREPARE stmt FROM @sql;
    EXECUTE stmt USING `id`;
    DEALLOCATE PREPARE stmt;
END¤

DELIMITER ;

-- -------------------- --
-- Bulk Insert from csv --
-- -------------------- --

LOAD DATA INFILE 'D:\\Skole\\H2\\Database Prog\\postnumre.csv'
INTO TABLE br_city
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(city_postal_code,city_name);

-- ------------------------------- --
-- Create [CALL insert] procedures --
-- ------------------------------- --

-- Call insert_new_user procedure 10 times with sample data
CALL insert_new_user('John', 'Doe', 'johndoe', 'password123', 'password123', 'john@example.com', '1234567890');
CALL insert_new_user('Jane', 'Smith', 'janesmith', 'password456', 'password456', 'jane@example.com', '9876543210');
CALL insert_new_user('Alice', 'Johnson', 'alicej', 'password789', 'password789', 'alice@example.com', '5555555555');
CALL insert_new_user('Bob', 'Brown', 'bobb', 'passwordabc', 'passwordabc', 'bob@example.com', '7777777777');
CALL insert_new_user('Emma', 'White', 'emmaw', 'passwordxyz', 'passwordxyz', 'emma@example.com', '9999999999');
CALL insert_new_user('Michael', 'Lee', 'michaell', 'pass123word', 'pass123word', 'michael@example.com', '1111111111');
CALL insert_new_user('Sarah', 'Taylor', 'saraht', 'pass456word', 'pass456word', 'sarah@example.com', '2222222222');
CALL insert_new_user('David', 'Martinez', 'davidm', 'pass789word', 'pass789word', 'david@example.com', '3333333333');
CALL insert_new_user('Sophia', 'Garcia', 'sophiag', 'passabcword', 'passabcword', 'sophia@example.com', '4444444444');
CALL insert_new_user('Daniel', 'Lopez', 'daniell', 'passxyzword', 'passxyzword', 'daniel@example.com', '6666666666');

-- Call insert_new_tax procedure 1 tax type
CALL insert_new_tax(25, 'moms', TRUE);

-- Call insert_new_tax procedure 1 tax type
CALL insert_new_taxes();

-- Call insert_new_pricing procedure 10 times with sample data
CALL insert_new_pricing(50.00, 75.00, 20.00, 10.00);
CALL insert_new_pricing(60.00, 90.00, 25.00, 15.00);
CALL insert_new_pricing(70.00, 100.00, 30.00, 20.00);
CALL insert_new_pricing(80.00, 110.00, 35.00, 25.00);
CALL insert_new_pricing(90.00, 120.00, 40.00, 30.00);
CALL insert_new_pricing(100.00, 130.00, 45.00, 35.00);
CALL insert_new_pricing(110.00, 140.00, 50.00, 40.00);
CALL insert_new_pricing(120.00, 150.00, 55.00, 45.00);
CALL insert_new_pricing(130.00, 160.00, 60.00, 50.00);
CALL insert_new_pricing(140.00, 170.00, 65.00, 55.00);

-- Call insert_new_genre procedure 10 times with sample data
CALL insert_new_genre('Horror');
CALL insert_new_genre('Fantasy');
CALL insert_new_genre('Mystery');
CALL insert_new_genre('Thriller');
CALL insert_new_genre('Romance');
CALL insert_new_genre('Science Fiction');
CALL insert_new_genre('Historical Fiction');
CALL insert_new_genre('Biography');
CALL insert_new_genre('Self-Help');
CALL insert_new_genre('Adventure');

-- Call insert_new_author procedure 10 times with sample data
CALL insert_new_author('Stephen King');
CALL insert_new_author('J.K. Rowling');
CALL insert_new_author('Agatha Christie');
CALL insert_new_author('Dan Brown');
CALL insert_new_author('Jane Austen');
CALL insert_new_author('George Orwell');
CALL insert_new_author('Harper Lee');
CALL insert_new_author('J.R.R. Tolkien');
CALL insert_new_author('Charles Dickens');
CALL insert_new_author('Leo Tolstoy');

-- Call insert_new_address procedure 10 times with sample data
CALL insert_new_address('4180', 1, 'Strandboulevarden 1', 'Denmark', TRUE);
CALL insert_new_address('4180', 2, 'Vesterbrogade 2', 'Denmark', FALSE);
CALL insert_new_address('4180', 3, 'Nørrebrogade 3', 'Denmark', TRUE);
CALL insert_new_address('4180', 4, 'Sønderboulevard 4', 'Denmark', FALSE);
CALL insert_new_address('4180', 5, 'Hovedvejen 5', 'Denmark', TRUE);
CALL insert_new_address('4180', 6, 'Strandvejen 6', 'Denmark', FALSE);
CALL insert_new_address('4180', 7, 'Parkvej 7', 'Denmark', TRUE);
CALL insert_new_address('4180', 8, 'Bakkevej 8', 'Denmark', FALSE);
CALL insert_new_address('4180', 9, 'Skovvej 9', 'Denmark', TRUE);
CALL insert_new_address('4180', 10, 'Engvej 10', 'Denmark', FALSE);

-- Call insert_new_order procedure 10 times with sample data
CALL insert_new_order(1, '2024-04-25 12:00:00', 100.00, 'Shipped');
CALL insert_new_order(2, '2024-04-26 12:00:00', 150.00, 'Processed');
CALL insert_new_order(3, '2024-04-27 12:00:00', 200.00, 'Shipped');
CALL insert_new_order(4, '2024-04-28 12:00:00', 250.00, 'Delivered');
CALL insert_new_order(5, '2024-04-29 12:00:00', 300.00, 'Cancelled');
CALL insert_new_order(6, '2024-04-30 12:00:00', 350.00, 'Returned');
CALL insert_new_order(7, '2024-05-01 12:00:00', 400.00, 'Failed');
CALL insert_new_order(8, '2024-05-02 12:00:00', 450.00, 'On Hold');
CALL insert_new_order(9, '2024-05-03 12:00:00', 500.00, 'Shipped');
CALL insert_new_order(10, '2024-05-04 12:00:00', 550.00, 'Processed');

-- Call insert_new_book procedure 10 times with sample data
CALL insert_new_book(1, 'Sample Book 1', 0.5, 'This is a sample book description.', 'sample1.jpg');
CALL insert_new_book(2, 'Sample Book 2', 0.6, 'This is another sample book description.', 'sample2.jpg');
CALL insert_new_book(3, 'Sample Book 3', 0.7, 'Yet another sample book description.', 'sample3.jpg');
CALL insert_new_book(4, 'Sample Book 4', 0.8, 'One more sample book description.', 'sample4.jpg');
CALL insert_new_book(5, 'Sample Book 5', 0.9, 'Final sample book description.', 'sample5.jpg');
CALL insert_new_book(6, 'Sample Book 6', 1.0, 'Another final sample book description.', 'sample6.jpg');
CALL insert_new_book(7, 'Sample Book 7', 1.1, 'Almost final sample book description.', 'sample7.jpg');
CALL insert_new_book(8, 'Sample Book 8', 1.2, 'Nearly there sample book description.', 'sample8.jpg');
CALL insert_new_book(9, 'Sample Book 9', 1.3, 'Nearly there sample book description.', 'sample9.jpg');
CALL insert_new_book(10, 'Sample Book 10', 1.4, 'Nearly there sample book description.', 'sample10.jpg');

-- Call insert_new_book_author procedure 10 times with sample data
CALL insert_new_book_author(1, 'Stephen King');
CALL insert_new_book_author(2, 'J.K. Rowling');
CALL insert_new_book_author(3, 'Agatha Christie');
CALL insert_new_book_author(4, 'Dan Brown');
CALL insert_new_book_author(5, 'Jane Austen');
CALL insert_new_book_author(6, 'George Orwell');
CALL insert_new_book_author(7, 'Harper Lee');
CALL insert_new_book_author(8, 'J.R.R. Tolkien');
CALL insert_new_book_author(9, 'Charles Dickens');
CALL insert_new_book_author(10, 'Leo Tolstoy');

-- Call insert_new_book_genre procedure 10 times with sample data
CALL insert_new_book_genre(1, 'Horror');
CALL insert_new_book_genre(2, 'Fantasy');
CALL insert_new_book_genre(3, 'Mystery');
CALL insert_new_book_genre(4, 'Thriller');
CALL insert_new_book_genre(5, 'Romance');
CALL insert_new_book_genre(6, 'Science Fiction');
CALL insert_new_book_genre(7, 'Historical Fiction');
CALL insert_new_book_genre(8, 'Biography');
CALL insert_new_book_genre(9, 'Self-Help');
CALL insert_new_book_genre(10, 'Adventure');

-- Call insert_new_book_order procedure 10 times with sample data
CALL insert_new_book_order(1, 1);
CALL insert_new_book_order(2, 2);
CALL insert_new_book_order(3, 3);
CALL insert_new_book_order(4, 4);
CALL insert_new_book_order(5, 5);
CALL insert_new_book_order(6, 6);
CALL insert_new_book_order(7, 7);
CALL insert_new_book_order(8, 8);
CALL insert_new_book_order(9, 9);
CALL insert_new_book_order(10, 10);