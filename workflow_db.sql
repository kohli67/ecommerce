CREATE DATABASE workflow_db;
USE workflow_db;

-- Drop tables if already exist (clean run)
DROP TABLE IF EXISTS request_stakeholders;
DROP TABLE IF EXISTS process_users;
DROP TABLE IF EXISTS requests;
DROP TABLE IF EXISTS processes;
DROP TABLE IF EXISTS roles;
DROP TABLE IF EXISTS users;

-- 1. Users Table
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- 2. Processes table
CREATE TABLE processes (
    process_id INT AUTO_INCREMENT PRIMARY KEY,
    process_name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Requests table (needs users + processes)
CREATE TABLE requests (
    request_id INT AUTO_INCREMENT PRIMARY KEY,
    process_id INT NOT NULL,
    requester_id INT NOT NULL,
    request_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Pending','Approved','Rejected') DEFAULT 'Pending',
    FOREIGN KEY (process_id) REFERENCES processes(process_id),
    FOREIGN KEY (requester_id) REFERENCES users(user_id)
);

-- 4. Roles table
CREATE TABLE roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(100) NOT NULL
);

-- 5. Process Users table (needs users + processes + roles)
CREATE TABLE process_users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    process_id INT NOT NULL,
    user_id INT NOT NULL,
    role_id INT NOT NULL,
    FOREIGN KEY (process_id) REFERENCES processes(process_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (role_id) REFERENCES roles(role_id)
);

-- 6. Request Stakeholders table (needs requests + users + roles)
CREATE TABLE request_stakeholders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    request_id INT NOT NULL,
    user_id INT NOT NULL,
    role_id INT NOT NULL,
    FOREIGN KEY (request_id) REFERENCES requests(request_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (role_id) REFERENCES roles(role_id)
);

-- Insert sample users
INSERT INTO users (username, email) VALUES
('Alice', 'alice@example.com'),
('Bob', 'bob@example.com'),
('Charlie', 'charlie@example.com');


-- Insert sample roles
INSERT INTO roles (role_name) VALUES
('Admin'),
('Reviewer'),
('Approver');

-- Insert sample processes
INSERT INTO processes (process_name, description) VALUES
('Onboarding', 'New employee onboarding process'),
('Procurement', 'Purchase order approval process');

-- Insert sample requests (must exist before request_stakeholders)
INSERT INTO requests (process_id, requester_id, status) VALUES
(1, 1, 'Pending'),
(2, 2, 'Approved');


-- Insert process users
INSERT INTO process_users (process_id, user_id, role_id) VALUES
(1, 1, 1),  -- Alice is Admin in Onboarding
(1, 2, 2),  -- Bob is Reviewer in Onboarding
(2, 3, 3);  -- Charlie is Approver in Procurement

--  Now insert request stakeholders (because requests 1 & 2 exist now)
INSERT INTO request_stakeholders (request_id, user_id, role_id) VALUES
(1, 2, 2),  -- Bob is Reviewer for Request 1
(1, 3, 3),  -- Charlie is Approver for Request 1
(2, 1, 1);  -- Alice is Admin for Request 2




SELECT * FROM users;
SELECT * FROM roles;
SELECT * FROM processes;
SELECT * FROM requests;
SELECT * FROM process_users;
SELECT * FROM request_stakeholders;


SELECT r.request_id, u.username AS requester, p.process_name, r.status
FROM requests r
JOIN users u ON r.requester_id = u.user_id
JOIN processes p ON r.process_id = p.process_id;


SELECT rs.request_id, u.username, ro.role_name
FROM request_stakeholders rs
JOIN users u ON rs.user_id = u.user_id
JOIN roles ro ON rs.role_id = ro.role_id
ORDER BY rs.request_id;


SELECT p.process_name, u.username, ro.role_name
FROM process_users pu
JOIN processes p ON pu.process_id = p.process_id
JOIN users u ON pu.user_id = u.user_id
JOIN roles ro ON pu.role_id = ro.role_id;

INSERT INTO request_stakeholders (request_id, user_id, role_id)
VALUES (99, 2, 2);



