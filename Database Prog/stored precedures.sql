DELIMITER ¤

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
        INSERT INTO br_user (
            user_first_name,
            user_last_name,
            user_username,
            user_password,
            user_email,
            user_phone_number
        )
        VALUES (
            `first_name`,
            `last_name`,
            `username`,
            `password`,
            `email`,
            `phone_number`
        );
    ELSE
        SELECT 'Passwords do not match' AS ErrorMessage;
    END IF;
END¤

CREATE PROCEDURE insert_new_genre(
    IN `value` VARCHAR(100)
)
BEGIN
    INSERT INTO br_genre (
        gen_value
    )
    VALUES (
        `value`
    );
END¤

CREATE PROCEDURE insert_new_author(
    IN `name` VARCHAR(100)
)
BEGIN
    INSERT INTO br_author(
        auth_name
    )
    VALUES(
        `name`
    );
END¤

CREATE PROCEDURE insert_new_address(
    IN `postal_code` VARCHAR(15),
    IN `user_id` INT,
    IN `street_address` VARCHAR(100),
    IN `country` varchar(60),
    IN `is_billing_address` BOOLEAN
)
BEGIN
    INSERT INTO br_address(
        adr_postal_code,
        adr_user_id,
        adr_street_address,
        adr_country,
        adr_is_billing_address
    )
    VALUES(
        `postal_code`,
        `user_id`,
        `street_address`,
        `country`,
        `is_billing_address`
    );
END¤

DELIMITER ;


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
    IF `password` = `confirm_password` THEN
        UPDATE br_user
        SET user_password = `password`
        WHERE user_id = `id`
    ELSE
        SELECT 'Passwords do not match' AS ErrorMessage;
    END IF;

    IF `first_name` != user_first_name
        UPDATE br_user
        SET user_first_name = `first_name`
        WHERE user_id = `id`
    END IF;

    IF `last_name` != user_last_name
        UPDATE br_user
        SET user_last_name `last_name`
        WHERE user_id = `id`
    END IF;

    IF `username` != user_last_name
        UPDATE br_user
        SET user_last_name `username`
        WHERE user_id = `id`
    END IF;
    
    IF `email` != user_email THEN
        UPDATE br_user
        SET user_email = `email`
        WHERE user_id = `id`
    END IF;

    IF `phone_number` != user_phone_number THEN
        UPDATE br_user
        SET user_phone_number = `phone_number`
        WHERE user_id = `id`
    END IF;
END¤

CREATE PROCEDURE update_genre(
    IN `value` VARCHAR(100),
    IN `new_value` VARCHAR(100)
)
BEGIN
    IF `new_value` != NULL THEN
        UPDATE br_genre
        SET gen_value = `new_value`
        WHERE gen_value = `current_value`
    END IF;
END¤

CREATE PROCEDURE update_author(
    IN `current_name` VARCHAR(100),
    IN `new_name` VARCHAR(100)
)
BEGIN
    IF `new_name` != NULL THEN
        UPDATE br_author
        SET auth_name = `new_name`
        WHERE auth_name = `current_name`
    END IF;
END¤

CREATE PROCEDURE update_new_address(
    IN `id` INT,
    IN `postal_code` VARCHAR(15),
    IN `street_address` VARCHAR(100),
    IN `country` varchar(60),
    IN `is_billing_address` BOOLEAN
)
BEGIN
    IF `postal_code` != NULL THEN
        UPDATE br_address
        SET adr_postal_code
        WHERE adr_id = `id`
    END IF
    
    IF `street_address` != NULL THEN
        UPDATE br_address
        SET adr_street_address
        WHERE adr_id = `id`
    END IF
    
    IF `country` != NULL THEN
        UPDATE br_address
        SET adr_country
        WHERE adr_id = `id`
    END IF

    IF `is_billing_address` != NULL THEN
        UPDATE br_address
        SET adr_is_billing_address
        WHERE adr_id = `id`
    END IF
END¤

-- ----------------- --
-- Create [DELETE PROCEDURES] procedures --
-- ----------------- --

