CREATE DATABASE product_mgmt
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE product_mgmt;



-- ===== TABLES =====

-- Categories (e.g., Shoes, Dresses, Smartphones)
CREATE TABLE IF NOT EXISTS categories (
  category_id   BIGINT PRIMARY KEY AUTO_INCREMENT,
  name          VARCHAR(120) NOT NULL UNIQUE,
  description   VARCHAR(500),
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Attributes per category (e.g., Size, Color, RAM)
-- data_type is enforced by triggers below; allowed_vals is a JSON array for whitelists
CREATE TABLE IF NOT EXISTS attributes (
  attribute_id  BIGINT PRIMARY KEY AUTO_INCREMENT,
  category_id   BIGINT NOT NULL,
  name          VARCHAR(120) NOT NULL,
  data_type     ENUM('string','number','boolean','date') NOT NULL,
  is_required   TINYINT(1) NOT NULL DEFAULT 0,
  allowed_vals  JSON NULL, -- e.g., '["S","M","L","XL"]' or '["Black","Blue"]'
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_attr_category
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE CASCADE,
  CONSTRAINT uq_attr_category_name UNIQUE (category_id, name)
) ENGINE=InnoDB;

-- Products
CREATE TABLE IF NOT EXISTS products (
  product_id    BIGINT PRIMARY KEY AUTO_INCREMENT,
  category_id   BIGINT NOT NULL,
  name          VARCHAR(200) NOT NULL,
  description   TEXT,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_prod_category
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE RESTRICT,
  CONSTRAINT uq_prod_category_name UNIQUE (category_id, name)
) ENGINE=InnoDB;

-- Product <-> Attribute values (EAV)
CREATE TABLE IF NOT EXISTS product_attributes (
  product_id    BIGINT NOT NULL,
  attribute_id  BIGINT NOT NULL,
  value_raw     VARCHAR(255) NULL, -- stored as text, validated in triggers
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (product_id, attribute_id),
  CONSTRAINT fk_pa_product   FOREIGN KEY (product_id)   REFERENCES products(product_id)   ON DELETE CASCADE,
  CONSTRAINT fk_pa_attribute FOREIGN KEY (attribute_id) REFERENCES attributes(attribute_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Helpful indexes
CREATE INDEX IF NOT EXISTS idx_attributes_category ON attributes(category_id);
CREATE INDEX IF NOT EXISTS idx_products_category   ON products(category_id);

-- ===== DATA INTEGRITY TRIGGERS =====
-- Validates product_attributes.value_raw against attributes.data_type / is_required / allowed_vals

DELIMITER $$

CREATE TRIGGER trg_pa_validate_before_ins
BEFORE INSERT ON product_attributes
FOR EACH ROW
BEGIN
  DECLARE atype ENUM('string','number','boolean','date');
  DECLARE required TINYINT(1);
  DECLARE allowed JSON;

  SELECT data_type, is_required, allowed_vals
    INTO atype, required, allowed
  FROM attributes
  WHERE attribute_id = NEW.attribute_id;

  -- Required check
  IF required = 1 AND (NEW.value_raw IS NULL OR TRIM(NEW.value_raw) = '') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Attribute value is required';
  END IF;

  -- Type checks only if value provided
  IF NEW.value_raw IS NOT NULL AND TRIM(NEW.value_raw) <> '' THEN
    -- number: integer or decimal
    IF atype = 'number' AND (NEW.value_raw REGEXP '^-?[0-9]+(\\.[0-9]+)?$') = 0 THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = CONCAT('Invalid number: ', NEW.value_raw);
    END IF;

    -- boolean: true/false/1/0
    IF atype = 'boolean' AND (LOWER(NEW.value_raw) NOT IN ('true','false','1','0')) THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = CONCAT('Invalid boolean: ', NEW.value_raw);
    END IF;

    -- date: enforce YYYY-MM-DD
    IF atype = 'date' AND STR_TO_DATE(NEW.value_raw, '%Y-%m-%d') IS NULL THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = CONCAT('Invalid date (use YYYY-MM-DD): ', NEW.value_raw);
    END IF;

    -- string with whitelist
    IF atype = 'string' AND allowed IS NOT NULL AND JSON_TYPE(allowed) = 'ARRAY' THEN
      IF JSON_CONTAINS(allowed, JSON_QUOTE(NEW.value_raw), '$') = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = CONCAT('Value "', NEW.value_raw, '" not in allowed set');
      END IF;
    END IF;
  END IF;
END$$

CREATE TRIGGER trg_pa_validate_before_upd
BEFORE UPDATE ON product_attributes
FOR EACH ROW
BEGIN
  DECLARE atype ENUM('string','number','boolean','date');
  DECLARE required TINYINT(1);
  DECLARE allowed JSON;

  SELECT data_type, is_required, allowed_vals
    INTO atype, required, allowed
  FROM attributes
  WHERE attribute_id = NEW.attribute_id;

  IF required = 1 AND (NEW.value_raw IS NULL OR TRIM(NEW.value_raw) = '') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Attribute value is required';
  END IF;

  IF NEW.value_raw IS NOT NULL AND TRIM(NEW.value_raw) <> '' THEN
    IF atype = 'number' AND (NEW.value_raw REGEXP '^-?[0-9]+(\\.[0-9]+)?$') = 0 THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = CONCAT('Invalid number: ', NEW.value_raw);
    END IF;

    IF atype = 'boolean' AND (LOWER(NEW.value_raw) NOT IN ('true','false','1','0')) THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = CONCAT('Invalid boolean: ', NEW.value_raw);
    END IF;

    IF atype = 'date' AND STR_TO_DATE(NEW.value_raw, '%Y-%m-%d') IS NULL THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = CONCAT('Invalid date (use YYYY-MM-DD): ', NEW.value_raw);
    END IF;

    IF atype = 'string' AND allowed IS NOT NULL AND JSON_TYPE(allowed) = 'ARRAY' THEN
      IF JSON_CONTAINS(allowed, JSON_QUOTE(NEW.value_raw), '$') = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = CONCAT('Value "', NEW.value_raw, '" not in allowed set');
      END IF;
    END IF;
  END IF;
END$$

DELIMITER ;

CREATE TABLE IF NOT EXISTS categories (
    category_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS products (
    product_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(150) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    category_id BIGINT,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);
CREATE TABLE IF NOT EXISTS product_attributes (
    attribute_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    product_id BIGINT,
    attribute_name VARCHAR(100) NOT NULL,
    attribute_value VARCHAR(255) NOT NULL,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
CREATE TABLE IF NOT EXISTS users (
    user_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL
);
CREATE TABLE IF NOT EXISTS orders (
    order_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE IF NOT EXISTS order_items (
    order_item_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_id BIGINT,
    product_id BIGINT,
    quantity INT NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);


-- Categories
INSERT INTO categories (category_name, description) VALUES
('Electronics','Devices and gadgets'),
('Clothing','Apparel'),
('Books','Books and novels')
ON DUPLICATE KEY UPDATE description = VALUES(description);

-- Products
INSERT INTO products (product_name, price, category_id) VALUES
('Smartphone', 25000.00, (SELECT category_id FROM categories WHERE category_name='Electronics')),
('Laptop', 55000.00, (SELECT category_id FROM categories WHERE category_name='Electronics')),
('T-Shirt', 499.00, (SELECT category_id FROM categories WHERE category_name='Clothing')),
('The Alchemist', 299.00, (SELECT category_id FROM categories WHERE category_name='Books'));

-- Product attributes (example EAV)
INSERT INTO product_attributes (product_id, attribute_name, attribute_value) VALUES
((SELECT product_id FROM products WHERE product_name='Smartphone'), 'Color', 'Black'),
((SELECT product_id FROM products WHERE product_name='Smartphone'), 'RAM', '6GB'),
((SELECT product_id FROM products WHERE product_name='Laptop'), 'RAM', '16GB'),
((SELECT product_id FROM products WHERE product_name='T-Shirt'), 'Size', 'L'),
((SELECT product_id FROM products WHERE product_name='The Alchemist'), 'Author', 'Paulo Coelho');


-- A: show categories
SELECT * FROM categories;

-- B: show products with their category
SELECT p.product_id, p.product_name, p.price, c.category_name
FROM products p JOIN categories c ON p.category_id = c.category_id;

-- C: product attributes
SELECT pa.product_id, p.product_name, pa.attribute_name, pa.attribute_value
FROM product_attributes pa JOIN products p ON pa.product_id = p.product_id
ORDER BY p.product_name;





USE product_mgmt;
-- Categories
INSERT INTO categories (category_name, description) VALUES
('Electronics','Devices and gadgets'),
('Clothing','Apparel'),
('Books','Books and novels')
ON DUPLICATE KEY UPDATE description = VALUES(description);

-- Products
INSERT INTO products (product_name, price, category_id) VALUES
('Smartphone', 25000.00, (SELECT category_id FROM categories WHERE category_name='Electronics')),
('Laptop', 55000.00, (SELECT category_id FROM categories WHERE category_name='Electronics')),
('T-Shirt', 499.00, (SELECT category_id FROM categories WHERE category_name='Clothing')),
('The Alchemist', 299.00, (SELECT category_id FROM categories WHERE category_name='Books'));

-- Product attributes (example EAV)
INSERT INTO product_attributes (product_id, attribute_name, attribute_value) VALUES
((SELECT product_id FROM products WHERE product_name='Smartphone'), 'Color', 'Black'),
((SELECT product_id FROM products WHERE product_name='Smartphone'), 'RAM', '6GB'),
((SELECT product_id FROM products WHERE product_name='Laptop'), 'RAM', '16GB'),
((SELECT product_id FROM products WHERE product_name='T-Shirt'), 'Size', 'L'),
((SELECT product_id FROM products WHERE product_name='The Alchemist'), 'Author', 'Paulo Coelho');

SELECT * FROM categories;
