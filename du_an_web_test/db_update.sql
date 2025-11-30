-- ================================================================
-- CHỈ TẠO CẤU TRÚC BẢNG (SCHEMA + GIỮ DỮ LIỆU)
-- ================================================================
SET FOREIGN_KEY_CHECKS = 0;

DROP DATABASE IF EXISTS `store_management_db`;
CREATE DATABASE `store_management_db` 
  DEFAULT CHARACTER SET utf8mb4 
  COLLATE utf8mb4_unicode_ci;
USE `store_management_db`;

-- BẢNG roles
CREATE TABLE IF NOT EXISTS `roles` (
  `role_id` INT UNSIGNED NOT NULL PRIMARY KEY,
  `role_name` VARCHAR(50) NOT NULL UNIQUE,
  `prefix` VARCHAR(10) NOT NULL UNIQUE,
  `description` VARCHAR(255) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- BẢNG users
CREATE TABLE IF NOT EXISTS `users` (
  `user_id` VARCHAR(15) NOT NULL PRIMARY KEY,
  `username` VARCHAR(50) NOT NULL UNIQUE,
  `password_hash` VARCHAR(255) NOT NULL,
  `role_id` INT UNSIGNED NOT NULL,
  `status` ENUM('Active','Inactive') NOT NULL DEFAULT 'Active',
  `must_change_password` BOOLEAN NOT NULL DEFAULT TRUE,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`role_id`) REFERENCES `roles`(`role_id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- BẢNG customers (chỉ tạo 1 lần) - có thể liên kết tới user nếu khách hàng đăng ký
CREATE TABLE IF NOT EXISTS `customers` (
  `customer_id` VARCHAR(15) NOT NULL PRIMARY KEY,
  `user_id` VARCHAR(15) NULL UNIQUE,
  `full_name` VARCHAR(100) NOT NULL,
  `email` VARCHAR(100) NULL,
  `phone` VARCHAR(20) NOT NULL UNIQUE,
  `address` VARCHAR(255) NULL,
  `date_of_birth` DATE NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- BẢNG employees
CREATE TABLE IF NOT EXISTS `employees` (
  `employee_id` VARCHAR(15) NOT NULL PRIMARY KEY,
  `user_id` VARCHAR(15) NOT NULL UNIQUE,
  `full_name` VARCHAR(100) NOT NULL,
  `email` VARCHAR(100) NOT NULL UNIQUE,
  `phone` VARCHAR(20) NULL,
  `date_of_birth` DATE NULL,
  `address` VARCHAR(255) NULL,
  `start_date` DATE NOT NULL,
  `employee_type` ENUM('Full-time','Part-time','Contract') NOT NULL,
  `department` VARCHAR(50) NOT NULL,
  `base_salary` DECIMAL(18,2) NOT NULL,
  `commission_rate` DECIMAL(5,4) NOT NULL DEFAULT 0.0000,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- BẢNG salaries: net_salary là cột GENERATED STORED để tránh sai lệch
DROP TABLE IF EXISTS `salaries`;

-- TẠO BẢNG MỚI
DROP TABLE IF EXISTS `salaries`;

-- TẠO BẢNG MỚI
CREATE TABLE IF NOT EXISTS `salaries` (
  `salary_id` VARCHAR(50) NOT NULL PRIMARY KEY,
  `employee_id` VARCHAR(15) NOT NULL,
  `month_year` DATE NOT NULL,
  `base_salary` DECIMAL(18,2) NOT NULL,
  `sales_commission` DECIMAL(18,2) NOT NULL DEFAULT 0.00,
  `bonus` DECIMAL(18,2) NOT NULL DEFAULT 0.00,
  `deductions` DECIMAL(18,2) NOT NULL DEFAULT 0.00,
  `net_salary` DECIMAL(18,2) AS (base_salary + sales_commission + bonus - deductions) STORED,
  `paid_at` DATETIME NULL,
  `paid_status` ENUM('Paid','Unpaid') NOT NULL DEFAULT 'Unpaid',
  UNIQUE KEY `uk_emp_month` (`employee_id`,`month_year`),
  FOREIGN KEY (`employee_id`) REFERENCES `employees`(`employee_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- CATEGORIES
CREATE TABLE IF NOT EXISTS `categories` (
  `category_id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `category_name` VARCHAR(100) NOT NULL UNIQUE,
  `description` VARCHAR(255) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- PRODUCTS
CREATE TABLE IF NOT EXISTS `products` (
  `product_id` VARCHAR(20) NOT NULL PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL,
  `category_id` INT UNSIGNED NULL,
  `price` DECIMAL(18,2) NOT NULL,
  `cost_price` DECIMAL(18,2) NOT NULL,
  `stock_quantity` INT NOT NULL DEFAULT 0,
  `is_active` BOOLEAN NOT NULL DEFAULT TRUE,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`category_id`) REFERENCES `categories`(`category_id`) ON DELETE SET NULL,
  INDEX idx_category_id (`category_id`),
  CONSTRAINT uq_products_name UNIQUE (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ORDERS: thêm thông tin địa chỉ giao hàng / người nhận để phục vụ đơn online
CREATE TABLE IF NOT EXISTS `orders` (
  `order_id` VARCHAR(20) NOT NULL PRIMARY KEY,
  `customer_id` VARCHAR(15) NULL,
  `order_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `completed_date` DATETIME NULL,
  `order_channel` ENUM('Trực tiếp','Online') NOT NULL,
  `direct_delivery` BOOLEAN NOT NULL DEFAULT FALSE,
  `subtotal` DECIMAL(18,2) NOT NULL DEFAULT 0,
  `shipping_cost` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `final_total` DECIMAL(18,2) NOT NULL DEFAULT 0,
  `status` ENUM('Đang Xử Lý','Đang Giao','Hoàn Thành','Đã Hủy') NOT NULL DEFAULT 'Đang xử lý',
  `payment_status` ENUM('Chưa Thanh Toán','Đã Thanh Toán','Đã Hoàn Tiền') NOT NULL DEFAULT 'Chưa Thanh Toán',
  `payment_method` ENUM('Tiền mặt','Thẻ tín dụng','Chuyển khoản') NOT NULL,
  `staff_id` VARCHAR(15) NOT NULL,
  `delivery_staff_id` VARCHAR(15) NULL,
  `note` TEXT NULL,
  FOREIGN KEY (`customer_id`) REFERENCES `customers`(`customer_id`) ON DELETE SET NULL,
  FOREIGN KEY (`staff_id`) REFERENCES `users`(`user_id`) ON DELETE RESTRICT,
  FOREIGN KEY (`delivery_staff_id`) REFERENCES `users`(`user_id`) ON DELETE SET NULL,
  INDEX idx_orders_customer (`customer_id`),
  INDEX idx_orders_staff (`staff_id`),
  INDEX idx_orders_delivery_staff (`delivery_staff_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
-- ORDER_DETAILS
CREATE TABLE IF NOT EXISTS `order_details` (
  `order_id` VARCHAR(20) NOT NULL,
  `product_id` VARCHAR(20) NOT NULL,
  `quantity` INT NOT NULL,
  `price_at_order` DECIMAL(18,2) NOT NULL,
  PRIMARY KEY (`order_id`,`product_id`),
  FOREIGN KEY (`order_id`) REFERENCES `orders`(`order_id`) ON DELETE CASCADE,
  FOREIGN KEY (`product_id`) REFERENCES `products`(`product_id`) ON DELETE RESTRICT,
  INDEX idx_od_product (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- STOCK_IN
CREATE TABLE IF NOT EXISTS `stock_in` (
  `stock_in_id` VARCHAR(20) NOT NULL PRIMARY KEY,
  `supplier_name` VARCHAR(100) NOT NULL,
  `import_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `total_cost` DECIMAL(18,2) NOT NULL,
  `user_id` VARCHAR(15) NOT NULL,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`user_id`) ON DELETE RESTRICT,
  INDEX idx_stock_user (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- STOCK_IN_DETAILS
CREATE TABLE IF NOT EXISTS `stock_in_details` (
  `stock_in_id` VARCHAR(20) NOT NULL,
  `product_id` VARCHAR(20) NOT NULL,
  `quantity` INT NOT NULL,
  `cost_price` DECIMAL(18,2) NOT NULL,
  PRIMARY KEY (`stock_in_id`,`product_id`),
  FOREIGN KEY (`stock_in_id`) REFERENCES `stock_in`(`stock_in_id`) ON DELETE CASCADE,
  FOREIGN KEY (`product_id`) REFERENCES `products`(`product_id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;

-- Dữ liệu mẫu tối thiểu cho roles
INSERT IGNORE INTO `roles` (`role_id`, `role_name`, `prefix`, `description`) VALUES
(1,'Owner','OWNER','Quản lý toàn bộ hệ thống'),
(2,'Customer','CUS','Khách hàng mua sắm trực tuyến'),
(3,'Warehouse','WH','Quản lý nhập xuất, tồn kho'),
(4,'Sales','SALES','Nhân viên bán hàng trực tiếp'),
(5,'Online Sales','OS','Nhân viên xử lý đơn hàng online'),
(6,'Shipper','SHIP','Nhân viên giao hàng');


-- Users sample data

-- Owner
INSERT IGNORE INTO `users` (`user_id`, `username`, `password_hash`, `role_id`, `status`, `must_change_password`) VALUES
('OWNER', 'OWNER', 'OWNER', 1, 'Active', TRUE);

-- Customers
INSERT IGNORE INTO `users` (`user_id`, `username`, `password_hash`, `role_id`, `status`, `must_change_password`) VALUES
('CUS1', '0900000001', '0900000001', 2, 'Active', TRUE),
('CUS2', '0900000002', '0900000002', 2, 'Active', TRUE),
('CUS3', '0900000003', '0900000003', 2, 'Active', TRUE);

-- Warehouse
INSERT IGNORE INTO `users` (`user_id`, `username`, `password_hash`, `role_id`, `status`, `must_change_password`) VALUES
('WH01', 'WH01', 'WH01', 3, 'Active', TRUE),
('WH02', 'WH02', 'WH02', 3, 'Active', TRUE),
('WH03', 'WH03', 'WH03', 3, 'Active', TRUE);

-- Sales
INSERT IGNORE INTO `users` (`user_id`, `username`, `password_hash`, `role_id`, `status`, `must_change_password`) VALUES
('SALE1', 'SALE1', 'SALE1', 4, 'Active', TRUE),
('SALE2', 'SALE2', 'SALE2', 4, 'Active', TRUE),
('SALE3', 'SALE3', 'SALE3', 4, 'Active', TRUE);

-- Online Sales
INSERT IGNORE INTO `users` (`user_id`, `username`, `password_hash`, `role_id`, `status`, `must_change_password`) VALUES
('OS01', 'OS01', 'OS01', 5, 'Active', TRUE),
('OS02', 'OS02', 'OS02', 5, 'Active', TRUE),
('OS03', 'OS03', 'OS03', 5, 'Active', TRUE);

-- Shipper
INSERT IGNORE INTO `users` (`user_id`, `username`, `password_hash`, `role_id`, `status`, `must_change_password`) VALUES
('SHIP01', 'SHIP01', 'SHIP01', 6, 'Active', TRUE),
('SHIP02', 'SHIP02', 'SHIP02', 6, 'Active', TRUE),
('SHIP03', 'SHIP03', 'SHIP03', 6, 'Active', TRUE);

INSERT IGNORE INTO `employees`
(employee_id, user_id, full_name, email, phone, date_of_birth, address, start_date, employee_type, department, base_salary, commission_rate)
VALUES
-- Warehouse
('WH01', 'WH01', 'Phạm Văn Hùng',   'wh01@store.com', '0901000001', '1990-01-01', 'Hà Nội', '2024-08-01', 'Full-time', 'Warehouse', 8000000, 0.0000),
('WH02', 'WH02', 'Đỗ Thị Lan',      'wh02@store.com', '0901000002', '1991-02-02', 'Hà Nội', '2024-08-01', 'Full-time', 'Warehouse', 8000000, 0.0000),
('WH03', 'WH03', 'Nguyễn Văn Tuấn','wh03@store.com', '0901000003', '1992-03-03', 'Hà Nội', '2024-08-01', 'Full-time', 'Warehouse', 8000000, 0.0000),

-- Sales
('SALE1', 'SALE1', 'Lê Thị Ngọc Anh', 'sa01@store.com', '0902000001', '1990-04-01', 'Hà Nội', '2024-08-01', 'Full-time', 'Sales', 7000000, 0.0500),
('SALE2', 'SALE2', 'Trần Văn Minh',   'sa02@store.com', '0902000002', '1991-05-02', 'Hà Nội', '2024-08-01', 'Full-time', 'Sales', 7000000, 0.0500),
('SALE3', 'SALE3', 'Phạm Thị Hương',  'sa03@store.com', '0902000003', '1992-06-03', 'Hà Nội', '2024-08-01', 'Full-time', 'Sales', 7000000, 0.0500),


-- Online Sales
('OS01', 'OS01', 'Nguyễn Văn Dũng', 'os01@store.com', '0903000001', '1990-07-01', 'Hà Nội', '2024-08-01', 'Full-time', 'Online Sales', 7000000, 0.0500),
('OS02', 'OS02', 'Lê Thị Thu Trang','os02@store.com', '0903000002', '1991-08-02', 'Hà Nội', '2024-08-01', 'Full-time', 'Online Sales', 7000000, 0.0500),
('OS03', 'OS03', 'Trần Văn Khánh',  'os03@store.com', '0903000003', '1992-09-03', 'Hà Nội', '2024-08-01', 'Full-time', 'Online Sales', 7000000, 0.0500),


-- Shipper
('SHIP01', 'SHIP01', 'Nguyễn Văn Hoàng', 'ship01@store.com', '0904000001', '1990-10-01', 'Hà Nội', '2024-08-01', 'Full-time', 'Shipper', 6000000, 0.0000),
('SHIP02', 'SHIP02', 'Lê Thị Kim Oanh',  'ship02@store.com', '0904000002', '1991-11-02', 'Hà Nội', '2024-08-01', 'Full-time', 'Shipper', 6000000, 0.0000),
('SHIP03', 'SHIP03', 'Trần Văn Phúc',    'ship03@store.com', '0904000003', '1992-12-03', 'Hà Nội', '2024-08-01', 'Full-time', 'Shipper', 6000000, 0.0000);

INSERT INTO `salaries` 
(salary_id, employee_id, month_year, base_salary, sales_commission, bonus, deductions, paid_at, paid_status)
VALUES
('SAL-WH01-202411','WH01','2024-11-01',8000000,0,500000,0,'2024-11-30','Paid'),
('SAL-WH02-202411','WH02','2024-11-01',8000000,0,300000,0,NULL,'Unpaid'),
('SAL-WH03-202411','WH03','2024-11-01',8000000,0,0,0,NULL,'Unpaid'),

('SAL-SALE1-202411','SALE1','2024-11-01',7000000,350000,200000,0,'2024-11-30','Paid'),
('SAL-SALE2-202411','SALE2','2024-11-01',7000000,400000,150000,0,NULL,'Unpaid'),
('SAL-SALE3-202411','SALE3','2024-11-01',7000000,300000,100000,0,NULL,'Unpaid'),

('SAL-OS01-202411','OS01','2024-11-01',7000000,300000,200000,0,'2024-11-30','Paid'),
('SAL-OS02-202411','OS02','2024-11-01',7000000,250000,150000,0,NULL,'Unpaid'),
('SAL-OS03-202411','OS03','2024-11-01',7000000,200000,100000,0,NULL,'Unpaid'),

('SAL-SHIP01-202411','SHIP01','2024-11-01',6000000,0,0,0,'2024-11-30','Paid'),
('SAL-SHIP02-202411','SHIP02','2024-11-01',6000000,0,50000,0,NULL,'Unpaid'),
('SAL-SHIP03-202411','SHIP03','2024-11-01',6000000,0,0,0,NULL,'Unpaid');
INSERT INTO `salaries` 
(salary_id, employee_id, month_year, base_salary, sales_commission, bonus, deductions, paid_at, paid_status)
VALUES
-- Warehouse
('SAL-WH01-202412','WH01','2024-12-01',8000000,0,600000,0,'2024-12-30','Paid'),
('SAL-WH02-202412','WH02','2024-12-01',8000000,0,400000,0,NULL,'Unpaid'),
('SAL-WH03-202412','WH03','2024-12-01',8000000,0,0,0,NULL,'Unpaid'),

-- Sales
('SAL-SALE1-202412','SALE1','2024-12-01',7000000,360000,250000,0,'2024-12-30','Paid'),
('SAL-SALE2-202412','SALE2','2024-12-01',7000000,420000,200000,0,NULL,'Unpaid'),
('SAL-SALE3-202412','SALE3','2024-12-01',7000000,310000,150000,0,NULL,'Unpaid'),

-- Online Sales
('SAL-OS01-202412','OS01','2024-12-01',7000000,320000,250000,0,'2024-12-30','Paid'),
('SAL-OS02-202412','OS02','2024-12-01',7000000,270000,200000,0,NULL,'Unpaid'),
('SAL-OS03-202412','OS03','2024-12-01',7000000,220000,150000,0,NULL,'Unpaid'),

-- Shipper
('SAL-SHIP01-202412','SHIP01','2024-12-01',6000000,0,0,0,'2024-12-30','Paid'),
('SAL-SHIP02-202412','SHIP02','2024-12-01',6000000,0,60000,0,NULL,'Unpaid'),
('SAL-SHIP03-202412','SHIP03','2024-12-01',6000000,0,0,0,NULL,'Unpaid');
-- DỮ LIỆU LƯƠNG NĂM 2025

-- Tháng 01
INSERT INTO `salaries` (salary_id, employee_id, month_year, base_salary, sales_commission, bonus, deductions, paid_at, paid_status)
VALUES
('SAL-WH01-202501','WH01','2025-01-01',8000000,0,500000,0,'2025-01-31','Paid'),
('SAL-WH02-202501','WH02','2025-01-01',8000000,0,300000,0,NULL,'Unpaid'),
('SAL-WH03-202501','WH03','2025-01-01',8000000,0,0,0,NULL,'Unpaid'),
('SAL-SALE1-202501','SALE1','2025-01-01',7000000,350000,200000,0,'2025-01-31','Paid'),
('SAL-SALE2-202501','SALE2','2025-01-01',7000000,400000,150000,0,NULL,'Unpaid'),
('SAL-SALE3-202501','SALE3','2025-01-01',7000000,300000,100000,0,NULL,'Unpaid'),
('SAL-OS01-202501','OS01','2025-01-01',7000000,300000,200000,0,'2025-01-31','Paid'),
('SAL-OS02-202501','OS02','2025-01-01',7000000,250000,150000,0,NULL,'Unpaid'),
('SAL-OS03-202501','OS03','2025-01-01',7000000,200000,100000,0,NULL,'Unpaid'),
('SAL-SHIP01-202501','SHIP01','2025-01-01',6000000,0,0,0,'2025-01-31','Paid'),
('SAL-SHIP02-202501','SHIP02','2025-01-01',6000000,0,50000,0,NULL,'Unpaid'),
('SAL-SHIP03-202501','SHIP03','2025-01-01',6000000,0,0,0,NULL,'Unpaid');

-- Tháng 02
INSERT INTO `salaries` (salary_id, employee_id, month_year, base_salary, sales_commission, bonus, deductions, paid_at, paid_status)
VALUES
('SAL-WH01-202502','WH01','2025-02-01',8000000,0,500000,0,'2025-02-28','Paid'),
('SAL-WH02-202502','WH02','2025-02-01',8000000,0,300000,0,NULL,'Unpaid'),
('SAL-WH03-202502','WH03','2025-02-01',8000000,0,0,0,NULL,'Unpaid'),
('SAL-SALE1-202502','SALE1','2025-02-01',7000000,350000,200000,0,'2025-02-28','Paid'),
('SAL-SALE2-202502','SALE2','2025-02-01',7000000,400000,150000,0,NULL,'Unpaid'),
('SAL-SALE3-202502','SALE3','2025-02-01',7000000,300000,100000,0,NULL,'Unpaid'),
('SAL-OS01-202502','OS01','2025-02-01',7000000,300000,200000,0,'2025-02-28','Paid'),
('SAL-OS02-202502','OS02','2025-02-01',7000000,250000,150000,0,NULL,'Unpaid'),
('SAL-OS03-202502','OS03','2025-02-01',7000000,200000,100000,0,NULL,'Unpaid'),
('SAL-SHIP01-202502','SHIP01','2025-02-01',6000000,0,0,0,'2025-02-28','Paid'),
('SAL-SHIP02-202502','SHIP02','2025-02-01',6000000,0,50000,0,NULL,'Unpaid'),
('SAL-SHIP03-202502','SHIP03','2025-02-01',6000000,0,0,0,NULL,'Unpaid');

-- Tháng 03
INSERT INTO `salaries` (salary_id, employee_id, month_year, base_salary, sales_commission, bonus, deductions, paid_at, paid_status)
VALUES
('SAL-WH01-202503','WH01','2025-03-01',8000000,0,500000,0,'2025-03-31','Paid'),
('SAL-WH02-202503','WH02','2025-03-01',8000000,0,300000,0,NULL,'Unpaid'),
('SAL-WH03-202503','WH03','2025-03-01',8000000,0,0,0,NULL,'Unpaid'),
('SAL-SALE1-202503','SALE1','2025-03-01',7000000,350000,200000,0,'2025-03-31','Paid'),
('SAL-SALE2-202503','SALE2','2025-03-01',7000000,400000,150000,0,NULL,'Unpaid'),
('SAL-SALE3-202503','SALE3','2025-03-01',7000000,300000,100000,0,NULL,'Unpaid'),
('SAL-OS01-202503','OS01','2025-03-01',7000000,300000,200000,0,'2025-03-31','Paid'),
('SAL-OS02-202503','OS02','2025-03-01',7000000,250000,150000,0,NULL,'Unpaid'),
('SAL-OS03-202503','OS03','2025-03-01',7000000,200000,100000,0,NULL,'Unpaid'),
('SAL-SHIP01-202503','SHIP01','2025-03-01',6000000,0,0,0,'2025-03-31','Paid'),
('SAL-SHIP02-202503','SHIP02','2025-03-01',6000000,0,50000,0,NULL,'Unpaid'),
('SAL-SHIP03-202503','SHIP03','2025-03-01',6000000,0,0,0,NULL,'Unpaid');

-- Tháng 04
INSERT INTO `salaries` (salary_id, employee_id, month_year, base_salary, sales_commission, bonus, deductions, paid_at, paid_status)
VALUES
('SAL-WH01-202504','WH01','2025-04-01',8000000,0,500000,0,'2025-04-30','Paid'),
('SAL-WH02-202504','WH02','2025-04-01',8000000,0,300000,0,NULL,'Unpaid'),
('SAL-WH03-202504','WH03','2025-04-01',8000000,0,0,0,NULL,'Unpaid'),
('SAL-SALE1-202504','SALE1','2025-04-01',7000000,350000,200000,0,'2025-04-30','Paid'),
('SAL-SALE2-202504','SALE2','2025-04-01',7000000,400000,150000,0,NULL,'Unpaid'),
('SAL-SALE3-202504','SALE3','2025-04-01',7000000,300000,100000,0,NULL,'Unpaid'),
('SAL-OS01-202504','OS01','2025-04-01',7000000,300000,200000,0,'2025-04-30','Paid'),
('SAL-OS02-202504','OS02','2025-04-01',7000000,250000,150000,0,NULL,'Unpaid'),
('SAL-OS03-202504','OS03','2025-04-01',7000000,200000,100000,0,NULL,'Unpaid'),
('SAL-SHIP01-202504','SHIP01','2025-04-01',6000000,0,0,0,'2025-04-30','Paid'),
('SAL-SHIP02-202504','SHIP02','2025-04-01',6000000,0,50000,0,NULL,'Unpaid'),
('SAL-SHIP03-202504','SHIP03','2025-04-01',6000000,0,0,0,NULL,'Unpaid');
-- Tháng 05/2025
INSERT INTO `salaries` (salary_id, employee_id, month_year, base_salary, sales_commission, bonus, deductions, paid_at, paid_status)
VALUES
('SAL-WH01-202505','WH01','2025-05-01',8000000,0,500000,0,'2025-05-31','Paid'),
('SAL-WH02-202505','WH02','2025-05-01',8000000,0,300000,0,NULL,'Unpaid'),
('SAL-WH03-202505','WH03','2025-05-01',8000000,0,0,0,NULL,'Unpaid'),
('SAL-SALE1-202505','SALE1','2025-05-01',7000000,350000,200000,0,'2025-05-31','Paid'),
('SAL-SALE2-202505','SALE2','2025-05-01',7000000,400000,150000,0,NULL,'Unpaid'),
('SAL-SALE3-202505','SALE3','2025-05-01',7000000,300000,100000,0,NULL,'Unpaid'),
('SAL-OS01-202505','OS01','2025-05-01',7000000,300000,200000,0,'2025-05-31','Paid'),
('SAL-OS02-202505','OS02','2025-05-01',7000000,250000,150000,0,NULL,'Unpaid'),
('SAL-OS03-202505','OS03','2025-05-01',7000000,200000,100000,0,NULL,'Unpaid'),
('SAL-SHIP01-202505','SHIP01','2025-05-01',6000000,0,0,0,'2025-05-31','Paid'),
('SAL-SHIP02-202505','SHIP02','2025-05-01',6000000,0,50000,0,NULL,'Unpaid'),
('SAL-SHIP03-202505','SHIP03','2025-05-01',6000000,0,0,0,NULL,'Unpaid');

-- Tháng 06/2025
INSERT INTO `salaries` (salary_id, employee_id, month_year, base_salary, sales_commission, bonus, deductions, paid_at, paid_status)
VALUES
('SAL-WH01-202506','WH01','2025-06-01',8000000,0,500000,0,'2025-06-30','Paid'),
('SAL-WH02-202506','WH02','2025-06-01',8000000,0,300000,0,NULL,'Unpaid'),
('SAL-WH03-202506','WH03','2025-06-01',8000000,0,0,0,NULL,'Unpaid'),
('SAL-SALE1-202506','SALE1','2025-06-01',7000000,350000,200000,0,'2025-06-30','Paid'),
('SAL-SALE2-202506','SALE2','2025-06-01',7000000,400000,150000,0,NULL,'Unpaid'),
('SAL-SALE3-202506','SALE3','2025-06-01',7000000,300000,100000,0,NULL,'Unpaid'),
('SAL-OS01-202506','OS01','2025-06-01',7000000,300000,200000,0,'2025-06-30','Paid'),
('SAL-OS02-202506','OS02','2025-06-01',7000000,250000,150000,0,NULL,'Unpaid'),
('SAL-OS03-202506','OS03','2025-06-01',7000000,200000,100000,0,NULL,'Unpaid'),
('SAL-SHIP01-202506','SHIP01','2025-06-01',6000000,0,0,0,'2025-06-30','Paid'),
('SAL-SHIP02-202506','SHIP02','2025-06-01',6000000,0,50000,0,NULL,'Unpaid'),
('SAL-SHIP03-202506','SHIP03','2025-06-01',6000000,0,0,0,NULL,'Unpaid');

-- Tháng 07/2025
INSERT INTO `salaries` (salary_id, employee_id, month_year, base_salary, sales_commission, bonus, deductions, paid_at, paid_status)
VALUES
('SAL-WH01-202507','WH01','2025-07-01',8000000,0,500000,0,'2025-07-31','Paid'),
('SAL-WH02-202507','WH02','2025-07-01',8000000,0,300000,0,NULL,'Unpaid'),
('SAL-WH03-202507','WH03','2025-07-01',8000000,0,0,0,NULL,'Unpaid'),
('SAL-SALE1-202507','SALE1','2025-07-01',7000000,350000,200000,0,'2025-07-31','Paid'),
('SAL-SALE2-202507','SALE2','2025-07-01',7000000,400000,150000,0,NULL,'Unpaid'),
('SAL-SALE3-202507','SALE3','2025-07-01',7000000,300000,100000,0,NULL,'Unpaid'),
('SAL-OS01-202507','OS01','2025-07-01',7000000,300000,200000,0,'2025-07-31','Paid'),
('SAL-OS02-202507','OS02','2025-07-01',7000000,250000,150000,0,NULL,'Unpaid'),
('SAL-OS03-202507','OS03','2025-07-01',7000000,200000,100000,0,NULL,'Unpaid'),
('SAL-SHIP01-202507','SHIP01','2025-07-01',6000000,0,0,0,'2025-07-31','Paid'),
('SAL-SHIP02-202507','SHIP02','2025-07-01',6000000,0,50000,0,NULL,'Unpaid'),
('SAL-SHIP03-202507','SHIP03','2025-07-01',6000000,0,0,0,NULL,'Unpaid');

-- Tháng 08/2025
INSERT INTO `salaries` (salary_id, employee_id, month_year, base_salary, sales_commission, bonus, deductions, paid_at, paid_status)
VALUES
('SAL-WH01-202508','WH01','2025-08-01',8000000,0,500000,0,'2025-08-31','Paid'),
('SAL-WH02-202508','WH02','2025-08-01',8000000,0,300000,0,NULL,'Unpaid'),
('SAL-WH03-202508','WH03','2025-08-01',8000000,0,0,0,NULL,'Unpaid'),
('SAL-SALE1-202508','SALE1','2025-08-01',7000000,350000,200000,0,'2025-08-31','Paid'),
('SAL-SALE2-202508','SALE2','2025-08-01',7000000,400000,150000,0,NULL,'Unpaid'),
('SAL-SALE3-202508','SALE3','2025-08-01',7000000,300000,100000,0,NULL,'Unpaid'),
('SAL-OS01-202508','OS01','2025-08-01',7000000,300000,200000,0,'2025-08-31','Paid'),
('SAL-OS02-202508','OS02','2025-08-01',7000000,250000,150000,0,NULL,'Unpaid'),
('SAL-OS03-202508','OS03','2025-08-01',7000000,200000,100000,0,NULL,'Unpaid'),
('SAL-SHIP01-202508','SHIP01','2025-08-01',6000000,0,0,0,'2025-08-31','Paid'),
('SAL-SHIP02-202508','SHIP02','2025-08-01',6000000,0,50000,0,NULL,'Unpaid'),
('SAL-SHIP03-202508','SHIP03','2025-08-01',6000000,0,0,0,NULL,'Unpaid');

-- Tháng 09/2025
INSERT INTO `salaries` (salary_id, employee_id, month_year, base_salary, sales_commission, bonus, deductions, paid_at, paid_status)
VALUES
('SAL-WH01-202509','WH01','2025-09-01',8000000,0,500000,0,'2025-09-30','Paid'),
('SAL-WH02-202509','WH02','2025-09-01',8000000,0,300000,0,NULL,'Unpaid'),
('SAL-WH03-202509','WH03','2025-09-01',8000000,0,0,0,NULL,'Unpaid'),
('SAL-SALE1-202509','SALE1','2025-09-01',7000000,350000,200000,0,'2025-09-30','Paid'),
('SAL-SALE2-202509','SALE2','2025-09-01',7000000,400000,150000,0,NULL,'Unpaid'),
('SAL-SALE3-202509','SALE3','2025-09-01',7000000,300000,100000,0,NULL,'Unpaid'),
('SAL-OS01-202509','OS01','2025-09-01',7000000,300000,200000,0,'2025-09-30','Paid'),
('SAL-OS02-202509','OS02','2025-09-01',7000000,250000,150000,0,NULL,'Unpaid'),
('SAL-OS03-202509','OS03','2025-09-01',7000000,200000,100000,0,NULL,'Unpaid'),
('SAL-SHIP01-202509','SHIP01','2025-09-01',6000000,0,0,0,'2025-09-30','Paid'),
('SAL-SHIP02-202509','SHIP02','2025-09-01',6000000,0,50000,0,NULL,'Unpaid'),
('SAL-SHIP03-202509','SHIP03','2025-09-01',6000000,0,0,0,NULL,'Unpaid');

-- Tháng 10/2025
INSERT INTO `salaries` (salary_id, employee_id, month_year, base_salary, sales_commission, bonus, deductions, paid_at, paid_status)
VALUES
('SAL-WH01-202510','WH01','2025-10-01',8000000,0,500000,0,'2025-10-31','Paid'),
('SAL-WH02-202510','WH02','2025-10-01',8000000,0,300000,0,NULL,'Unpaid'),
('SAL-WH03-202510','WH03','2025-10-01',8000000,0,0,0,NULL,'Unpaid'),
('SAL-SALE1-202510','SALE1','2025-10-01',7000000,350000,200000,0,'2025-10-31','Paid'),
('SAL-SALE2-202510','SALE2','2025-10-01',7000000,400000,150000,0,NULL,'Unpaid'),
('SAL-SALE3-202510','SALE3','2025-10-01',7000000,300000,100000,0,NULL,'Unpaid'),
('SAL-OS01-202510','OS01','2025-10-01',7000000,300000,200000,0,'2025-10-31','Paid'),
('SAL-OS02-202510','OS02','2025-10-01',7000000,250000,150000,0,NULL,'Unpaid'),
('SAL-OS03-202510','OS03','2025-10-01',7000000,200000,100000,0,NULL,'Unpaid'),
('SAL-SHIP01-202510','SHIP01','2025-10-01',6000000,0,0,0,'2025-10-31','Paid'),
('SAL-SHIP02-202510','SHIP02','2025-10-01',6000000,0,50000,0,NULL,'Unpaid'),
('SAL-SHIP03-202510','SHIP03','2025-10-01',6000000,0,0,0,NULL,'Unpaid');
-- Tháng 11 (tất cả Unpaid)
INSERT INTO `salaries` (salary_id, employee_id, month_year, base_salary, sales_commission, bonus, deductions, paid_at, paid_status)
VALUES
('SAL-WH01-202511','WH01','2025-11-01',8000000,0,500000,0,NULL,'Unpaid'),
('SAL-WH02-202511','WH02','2025-11-01',8000000,0,300000,0,NULL,'Unpaid'),
('SAL-WH03-202511','WH03','2025-11-01',8000000,0,0,0,NULL,'Unpaid'),
('SAL-SALE1-202511','SALE1','2025-11-01',7000000,350000,200000,0,NULL,'Unpaid'),
('SAL-SALE2-202511','SALE2','2025-11-01',7000000,400000,150000,0,NULL,'Unpaid'),
('SAL-SALE3-202511','SALE3','2025-11-01',7000000,300000,100000,0,NULL,'Unpaid'),
('SAL-OS01-202511','OS01','2025-11-01',7000000,300000,200000,0,NULL,'Unpaid'),
('SAL-OS02-202511','OS02','2025-11-01',7000000,250000,150000,0,NULL,'Unpaid'),
('SAL-OS03-202511','OS03','2025-11-01',7000000,200000,100000,0,NULL,'Unpaid'),
('SAL-SHIP01-202511','SHIP01','2025-11-01',6000000,0,0,0,NULL,'Unpaid'),
('SAL-SHIP02-202511','SHIP02','2025-11-01',6000000,0,50000,0,NULL,'Unpaid'),
('SAL-SHIP03-202511','SHIP03','2025-11-01',6000000,0,0,0,NULL,'Unpaid');
-- Categories
INSERT IGNORE INTO `categories` (`category_name`,`description`) VALUES
('Thực phẩm tươi sống','Thịt, cá, hải sản, trứng, gia cầm'),
('Rau củ – trái cây','Rau xanh, củ quả, trái cây theo mùa'),
('Thực phẩm chế biến sẵn / đông lạnh','Mì, phở, bánh bao, thực phẩm đông lạnh'),
('Bánh kẹo & snack','Các loại bánh, kẹo, snack, đồ ăn vặt'),
('Sữa & chế phẩm từ sữa','Sữa tươi, sữa chua, phô mai, váng sữa'),
('Đồ uống','Nước ngọt, nước suối, nước trái cây, cà phê'),
('Gia vị & thực phẩm khô','Gạo, mì gói, bột nêm, dầu ăn, nước mắm'),
('Đồ hộp & đóng gói','Thịt hộp, cá hộp, rau củ đóng hộp'),
('Hóa mỹ phẩm & chăm sóc cá nhân','Dầu gội, sữa tắm, kem đánh răng, mỹ phẩm cơ bản'),
('Đồ dùng vệ sinh & giấy','Giấy vệ sinh, khăn giấy, nước giặt, nước rửa chén'),
('Đồ gia dụng & nhà bếp','Nồi, chảo, dao, ly, bát'),
('Thiết bị điện & điện tử nhỏ','Quạt, đèn, ổ cắm, pin'),
('Văn phòng phẩm','Sổ, bút, thước, hồ'),
('Thời trang & phụ kiện','Quần áo, tất, mũ, giày dép'),
('Đồ chơi & giải trí','Đồ chơi trẻ em, sách thiếu nhi, game nhỏ'),
('Thức ăn & vật dụng cho thú cưng','Thức ăn hạt, pate, cát vệ sinh'),
('Sản phẩm chăm sóc sức khỏe','Thuốc thông thường, vitamin, thực phẩm chức năng'),
('Sản phẩm đặc sản / nhập khẩu','Mứt, snack ngoại, đồ ăn vặt cao cấp');

SET FOREIGN_KEY_CHECKS = 1;
-- Tắt kiểm tra khóa ngoại
-- Tắt kiểm tra khóa ngoại
SET FOREIGN_KEY_CHECKS = 0;


-- 1. Chèn dữ liệu bảng STOCK_IN (Phiếu nhập kho)
INSERT INTO stock_in (stock_in_id, supplier_name, import_date, total_cost, user_id)
VALUES
-- 08/2024
('SI0001','Công ty Thực phẩm A','2024-08-01 09:00:00',1200000,'WH01'),
('SI0002','Công ty Rau củ B','2024-08-10 10:00:00',950000,'WH02'),
('SI0003','Công ty Thực phẩm đông lạnh C','2024-08-20 08:30:00',1500000,'WH03'),
-- 09/2024
('SI0004','Công ty Bánh kẹo D','2024-09-01 09:00:00',800000,'WH01'),
('SI0005','Công ty Sữa E','2024-09-10 10:00:00',1100000,'WH02'),
('SI0006','Công ty Đồ uống F','2024-09-20 08:30:00',1000000,'WH03'),
-- 10/2024
('SI0007','Công ty Gia vị G','2024-10-01 09:00:00',950000,'WH01'),
('SI0008','Công ty Hộp & đóng gói H','2024-10-10 10:00:00',1200000,'WH02'),
('SI0009','Công ty Mỹ phẩm I','2024-10-20 08:30:00',800000,'WH03'),
-- 11/2024
('SI0010','Công ty Đồ dùng nhà bếp J','2024-11-01 09:00:00',1800000,'WH01'),
('SI0011','Công ty Thực phẩm A','2024-11-10 10:00:00',1200000,'WH02'),
('SI0012','Công ty Rau củ B','2024-11-20 08:30:00',950000,'WH03'),
-- 12/2024
('SI0013','Công ty Thực phẩm đông lạnh C','2024-12-01 09:00:00',1500000,'WH01'),
('SI0014','Công ty Bánh kẹo D','2024-12-10 10:00:00',800000,'WH02'),
('SI0015','Công ty Sữa E','2024-12-20 08:30:00',1100000,'WH03'),
-- 01/2025
('SI0016','Công ty Đồ uống F','2025-01-01 09:00:00',1000000,'WH01'),
('SI0017','Công ty Gia vị G','2025-01-10 10:00:00',950000,'WH02'),
('SI0018','Công ty Hộp & đóng gói H','2025-01-20 08:30:00',1200000,'WH03'),
-- 02/2025
('SI0019','Công ty Mỹ phẩm I','2025-02-01 09:00:00',800000,'WH01'),
('SI0020','Công ty Đồ dùng nhà bếp J','2025-02-10 10:00:00',1800000,'WH02'),
('SI0021','Công ty Thực phẩm A','2025-02-20 08:30:00',1200000,'WH03'),
-- 03/2025
('SI0022','Công ty Rau củ B','2025-03-01 09:00:00',950000,'WH01'),
('SI0023','Công ty Thực phẩm đông lạnh C','2025-03-10 10:00:00',1500000,'WH02'),
('SI0024','Công ty Bánh kẹo D','2025-03-20 08:30:00',800000,'WH03'),
-- 04/2025
('SI0025','Công ty Sữa E','2025-04-01 09:00:00',1100000,'WH01'),
('SI0026','Công ty Đồ uống F','2025-04-10 10:00:00',1000000,'WH02'),
('SI0027','Công ty Gia vị G','2025-04-20 08:30:00',950000,'WH03'),
-- 05/2025
('SI0028','Công ty Hộp & đóng gói H','2025-05-01 09:00:00',1200000,'WH01'),
('SI0029','Công ty Mỹ phẩm I','2025-05-10 10:00:00',800000,'WH02'),
('SI0030','Công ty Đồ dùng nhà bếp J','2025-05-20 08:30:00',1800000,'WH03'),
-- 06/2025
('SI0031','Công ty Thực phẩm A','2025-06-01 09:00:00',1200000,'WH01'),
('SI0032','Công ty Rau củ B','2025-06-10 10:00:00',950000,'WH02'),
('SI0033','Công ty Thực phẩm đông lạnh C','2025-06-20 08:30:00',1500000,'WH03'),
-- 07/2025
('SI0034','Công ty Bánh kẹo D','2025-07-01 09:00:00',800000,'WH01'),
('SI0035','Công ty Sữa E','2025-07-10 10:00:00',1100000,'WH02'),
('SI0036','Công ty Đồ uống F','2025-07-20 08:30:00',1000000,'WH03'),
-- 08/2025
('SI0037','Công ty Gia vị G','2025-08-01 09:00:00',950000,'WH01'),
('SI0038','Công ty Hộp & đóng gói H','2025-08-10 10:00:00',1200000,'WH02'),
('SI0039','Công ty Mỹ phẩm I','2025-08-20 08:30:00',800000,'WH03'),
-- 09/2025
('SI0040','Công ty Đồ dùng nhà bếp J','2025-09-01 09:00:00',1800000,'WH01'),
('SI0041','Công ty Thực phẩm A','2025-09-10 10:00:00',1200000,'WH02'),
('SI0042','Công ty Rau củ B','2025-09-20 08:30:00',950000,'WH03'),
-- 10/2025
('SI0043','Công ty Thực phẩm đông lạnh C','2025-10-01 09:00:00',1500000,'WH01'),
('SI0044','Công ty Bánh kẹo D','2025-10-10 10:00:00',800000,'WH02'),
('SI0045','Công ty Sữa E','2025-10-20 08:30:00',1100000,'WH03'),
-- 11/2025
('SI0046','Công ty Đồ uống F','2025-11-01 09:00:00',1000000,'WH01'),
('SI0047','Công ty Gia vị G','2025-11-10 10:00:00',950000,'WH02'),
('SI0048','Công ty Hộp & đóng gói H','2025-11-20 08:30:00',1200000,'WH03')
;
-- 2. Chèn dữ liệu bảng STOCK_IN_DETAILS (Chi tiết nhập kho)
-- Mỗi phiếu nhập 5 sản phẩm, bạn có thể thay product_id phù hợp với bảng products
-- ============================
-- BẢNG STOCK_IN_DETAILS (FULL 144 DÒNG)
-- ============================

INSERT INTO stock_in_details (stock_in_id, product_id, quantity, cost_price)
VALUES
-- SI0001
('SI0001','P0001',10,90000),
('SI0001','P0002',15,70000),
('SI0001','P0003',8,120000),
-- SI0002
('SI0002','P0004',12,140000),
('SI0002','P0005',30,2500),
('SI0002','P0006',5,90000),
-- SI0003
('SI0003','P0007',8,75000),
('SI0003','P0008',12,18000),
('SI0003','P0009',10,60000),
-- SI0004
('SI0004','P0010',5,150000),
('SI0004','P0011',20,10000),
('SI0004','P0012',25,8000),
-- SI0005
('SI0005','P0013',15,7000),
('SI0005','P0014',18,12000),
('SI0005','P0015',10,15000),
-- SI0006
('SI0006','P0016',8,25000),
('SI0006','P0017',12,20000),
('SI0006','P0018',10,28000),
-- SI0007
('SI0007','P0019',20,9000),
('SI0007','P0020',15,12000),
('SI0007','P0021',10,7000),
-- SI0008
('SI0008','P0022',12,8000),
('SI0008','P0023',15,10000),
('SI0008','P0024',10,15000),
-- SI0009
('SI0009','P0025',5,40000),
('SI0009','P0026',8,22000),
('SI0009','P0027',12,18000),
-- SI0010
('SI0010','P0028',10,30000),
('SI0010','P0029',5,45000),
('SI0010','P0030',12,15000),
-- SI0011
('SI0011','P0031',10,10000),
('SI0011','P0032',12,3000),
('SI0011','P0033',15,7000),
-- SI0012
('SI0012','P0034',8,20000),
('SI0012','P0035',5,18000),
('SI0012','P0036',10,15000),
-- SI0013
('SI0013','P0037',12,15000),
('SI0013','P0038',10,8000),
('SI0013','P0039',20,7000),
-- SI0014
('SI0014','P0040',5,25000),
('SI0014','P0041',10,15000),
('SI0014','P0042',12,10000),
-- SI0015
('SI0015','P0043',8,40000),
('SI0015','P0044',5,18000),
('SI0015','P0045',12,15000),
-- SI0016
('SI0016','P0046',10,30000),
('SI0016','P0047',12,10000),
('SI0016','P0048',8,22000),
-- SI0017
('SI0017','P0049',5,25000),
('SI0017','P0050',10,30000),
('SI0017','P0051',12,10000),
-- SI0018
('SI0018','P0052',8,7000),
('SI0018','P0053',15,15000),
('SI0018','P0054',10,20000),
-- SI0019
('SI0019','P0055',12,12000),
('SI0019','P0056',8,15000),
('SI0019','P0057',10,10000),
-- SI0020
('SI0020','P0058',5,20000),
('SI0020','P0059',12,22000),
('SI0020','P0060',8,10000),
-- SI0021
('SI0021','P0061',10,15000),
('SI0021','P0062',12,8000),
('SI0021','P0063',8,10000),
-- SI0022
('SI0022','P0064',5,25000),
('SI0022','P0065',10,20000),
('SI0022','P0066',12,15000),
-- SI0023
('SI0023','P0067',8,7000),
('SI0023','P0068',10,10000),
('SI0023','P0069',12,12000),
-- SI0024
('SI0024','P0070',8,9000),
('SI0024','P0071',5,25000),
('SI0024','P0072',10,28000),
-- SI0025
('SI0025','P0073',12,15000),
('SI0025','P0074',8,20000),
('SI0025','P0075',10,10000),
-- SI0026
('SI0026','P0076',5,30000),
('SI0026','P0077',12,15000),
('SI0026','P0078',10,12000),
-- SI0027
('SI0027','P0079',8,22000),
('SI0027','P0080',5,30000),
('SI0027','P0081',12,35000),
-- SI0028
('SI0028','P0082',10,28000),
('SI0028','P0083',12,18000),
('SI0028','P0084',8,10000),
-- SI0029
('SI0029','P0085',5,150000),
('SI0029','P0086',10,22000),
('SI0029','P0087',12,30000),
-- SI0030
('SI0030','P0088',8,25000),
('SI0030','P0089',10,15000),
('SI0030','P0090',12,35000),
-- SI0031
('SI0031','P0091',10,7000),
('SI0031','P0092',12,9000),
('SI0031','P0093',8,20000),
-- SI0032
('SI0032','P0094',5,30000),
('SI0032','P0095',10,25000),
('SI0032','P0096',12,10000),
-- SI0033
('SI0033','P0097',8,5000),
('SI0033','P0098',10,9000),
('SI0033','P0099',12,7000),
-- SI0034
('SI0034','P0100',8,12000),
('SI0034','P0101',5,400000),
('SI0034','P0102',10,250000),
-- SI0035
('SI0035','P0103',12,120000),
('SI0035','P0104',8,15000),
('SI0035','P0105',10,10000),
-- SI0036
('SI0036','P0106',5,60000),
('SI0036','P0107',12,300000),
('SI0036','P0108',10,40000),
-- SI0037
('SI0037','P0109',8,60000),
('SI0037','P0110',5,1200000),
('SI0037','P0111',12,280000),
-- SI0038
('SI0038','P0112',10,120000),
('SI0038','P0113',12,40000),
('SI0038','P0114',8,25000),
-- SI0039
('SI0039','P0115',5,20000),
('SI0039','P0116',10,80000),
('SI0039','P0117',12,600000),
-- SI0040
('SI0040','P0118',8,400000),
('SI0040','P0119',10,200000),
('SI0040','P0120',12,300000),
-- SI0041
('SI0041','P0121',10,20000),
('SI0041','P0122',12,3000),
('SI0041','P0123',8,7000),
-- SI0042
('SI0042','P0124',5,12000),
('SI0042','P0125',10,3000),
('SI0042','P0126',12,5000),
-- SI0043
('SI0043','P0127',8,60000),
('SI0043','P0128',10,20000),
('SI0043','P0129',12,10000),
-- SI0044
('SI0044','P0130',8,3000),
('SI0044','P0131',5,150000),
('SI0044','P0132',10,280000),
-- SI0045
('SI0045','P0133',12,120000),
('SI0045','P0134',8,100000),
('SI0045','P0135',10,600000),
-- SI0046
('SI0046','P0136',5,300000),
('SI0046','P0137',12,400000),
('SI0046','P0138',10,60000),
-- SI0047
('SI0047','P0139',8,100000),
('SI0047','P0140',10,120000),
('SI0047','P0141',12,150000),
-- SI0048
('SI0048','P0142',10,120000),
('SI0048','P0143',12,200000),
('SI0048','P0144',8,250000);


-- Bật lại kiểm tra khóa ngoại
SET FOREIGN_KEY_CHECKS = 1;
SET FOREIGN_KEY_CHECKS = 0;

-- Chèn 180 sản phẩm, 10 sản phẩm mỗi danh mục
INSERT INTO products (product_id, name, category_id, price, cost_price, stock_quantity, is_active)
VALUES
-- Danh mục 1: Thực phẩm tươi sống
('P0001','Thịt bò tươi',1,120000,90000,50,TRUE),
('P0002','Thịt heo tươi',1,90000,70000,60,TRUE),
('P0003','Cá hồi tươi',1,150000,120000,30,TRUE),
('P0004','Tôm sú',1,180000,140000,40,TRUE),
('P0005','Trứng gà ta',1,4000,2500,200,TRUE),
('P0006','Gà ta nguyên con',1,120000,90000,25,TRUE),
('P0007','Cá thu một nắng',1,100000,75000,35,TRUE),
('P0008','Hàu sống',1,25000,18000,100,TRUE),
('P0009','Mực tươi',1,80000,60000,50,TRUE),
('P0010','Cua biển',1,200000,150000,20,TRUE),

-- Danh mục 2: Rau củ – trái cây
('P0011','Rau cải xanh',2,15000,10000,100,TRUE),
('P0012','Rau muống',2,12000,8000,120,TRUE),
('P0013','Cà rốt',2,10000,7000,80,TRUE),
('P0014','Khoai tây',2,18000,12000,90,TRUE),
('P0015','Bí đỏ',2,20000,15000,70,TRUE),
('P0016','Táo đỏ',2,30000,25000,50,TRUE),
('P0017','Chuối tây',2,25000,20000,60,TRUE),
('P0018','Cam sành',2,35000,28000,40,TRUE),
('P0019','Dưa leo',2,12000,9000,100,TRUE),
('P0020','Cà chua',2,18000,12000,80,TRUE),

-- Danh mục 3: Thực phẩm chế biến sẵn / đông lạnh
('P0021','Mì ăn liền',3,10000,7000,200,TRUE),
('P0022','Phở gói',3,12000,8000,150,TRUE),
('P0023','Bánh bao đông lạnh',3,15000,10000,100,TRUE),
('P0024','Xúc xích',3,20000,15000,80,TRUE),
('P0025','Bánh pizza mini',3,50000,40000,50,TRUE),
('P0026','Chả lụa',3,30000,22000,60,TRUE),
('P0027','Nem chua',3,25000,18000,70,TRUE),
('P0028','Há cảo đông lạnh',3,40000,30000,40,TRUE),
('P0029','Thịt nguội',3,60000,45000,30,TRUE),
('P0030','Bánh mì đông lạnh',3,20000,15000,100,TRUE),

-- Danh mục 4: Bánh kẹo & snack
('P0031','Bánh quy',4,15000,10000,100,TRUE),
('P0032','Kẹo mút',4,5000,3000,200,TRUE),
('P0033','Snack khoai tây',4,10000,7000,150,TRUE),
('P0034','Socola',4,30000,20000,80,TRUE),
('P0035','Bánh bông lan',4,25000,18000,70,TRUE),
('P0036','Bánh chuối',4,20000,15000,60,TRUE),
('P0037','Bánh trứng',4,22000,15000,50,TRUE),
('P0038','Kẹo dẻo',4,12000,8000,100,TRUE),
('P0039','Snack ngô',4,10000,7000,120,TRUE),
('P0040','Bánh su kem',4,35000,25000,40,TRUE),

-- Danh mục 5: Sữa & chế phẩm từ sữa
('P0041','Sữa tươi',5,20000,15000,100,TRUE),
('P0042','Sữa chua',5,15000,10000,150,TRUE),
('P0043','Phô mai lát',5,50000,40000,60,TRUE),
('P0044','Váng sữa',5,25000,18000,80,TRUE),
('P0045','Sữa đặc có đường',5,20000,15000,100,TRUE),
('P0046','Sữa hạnh nhân',5,40000,30000,50,TRUE),
('P0047','Sữa chua uống',5,15000,10000,120,TRUE),
('P0048','Phô mai que',5,30000,22000,60,TRUE),
('P0049','Sữa chua Hy Lạp',5,35000,25000,40,TRUE),
('P0050','Bơ sữa',5,40000,30000,50,TRUE),

-- Danh mục 6: Đồ uống
('P0051','Nước ngọt Cola',6,15000,10000,200,TRUE),
('P0052','Nước suối',6,10000,7000,300,TRUE),
('P0053','Nước trái cây cam',6,20000,15000,150,TRUE),
('P0054','Cà phê hòa tan',6,25000,20000,100,TRUE),
('P0055','Trà xanh',6,18000,12000,100,TRUE),
('P0056','Nước ép táo',6,20000,15000,80,TRUE),
('P0057','Nước ngọt vị chanh',6,15000,10000,200,TRUE),
('P0058','Trà sữa',6,25000,20000,100,TRUE),
('P0059','Cacao',6,30000,22000,60,TRUE),
('P0060','Sữa đậu nành',6,15000,10000,150,TRUE),

-- Danh mục 7: Gia vị & thực phẩm khô
('P0061','Gạo tẻ',7,20000,15000,200,TRUE),
('P0062','Mì gói',7,12000,8000,300,TRUE),
('P0063','Bột nêm',7,15000,10000,150,TRUE),
('P0064','Dầu ăn',7,30000,25000,100,TRUE),
('P0065','Nước mắm',7,25000,20000,80,TRUE),
('P0066','Hạt tiêu',7,20000,15000,70,TRUE),
('P0067','Muối biển',7,10000,7000,100,TRUE),
('P0068','Đường trắng',7,15000,10000,200,TRUE),
('P0069','Bột cà ri',7,18000,12000,100,TRUE),
('P0070','Mì chính',7,12000,9000,150,TRUE),

-- Danh mục 8: Đồ hộp & đóng gói
('P0071','Thịt hộp',8,30000,25000,100,TRUE),
('P0072','Cá hộp',8,35000,28000,80,TRUE),
('P0073','Rau củ hộp',8,20000,15000,150,TRUE),
('P0074','Sữa hộp',8,25000,20000,100,TRUE),
('P0075','Đậu hũ hộp',8,15000,10000,120,TRUE),
('P0076','Ngũ cốc hộp',8,40000,30000,60,TRUE),
('P0077','Bánh mì hộp',8,20000,15000,100,TRUE),
('P0078','Trà hộp',8,15000,12000,100,TRUE),
('P0079','Cà phê hộp',8,30000,22000,50,TRUE),
('P0080','Thịt nguội hộp',8,40000,30000,70,TRUE),

-- Danh mục 9: Hóa mỹ phẩm & chăm sóc cá nhân
('P0081','Dầu gội',9,50000,35000,80,TRUE),
('P0082','Sữa tắm',9,40000,28000,100,TRUE),
('P0083','Kem đánh răng',9,25000,18000,120,TRUE),
('P0084','Xà phòng',9,15000,10000,200,TRUE),
('P0085','Nước hoa',9,200000,150000,30,TRUE),
('P0086','Mỹ phẩm cơ bản',9,30000,22000,60,TRUE),
('P0087','Tẩy trang',9,40000,30000,50,TRUE),
('P0088','Dầu dưỡng tóc',9,35000,25000,40,TRUE),
('P0089','Sơn móng tay',9,20000,15000,50,TRUE),
('P0090','Kem dưỡng da',9,50000,35000,60,TRUE),

-- Danh mục 10: Đồ dùng vệ sinh & giấy
('P0091','Giấy vệ sinh',10,10000,7000,200,TRUE),
('P0092','Khăn giấy',10,12000,9000,150,TRUE),
('P0093','Nước rửa chén',10,25000,20000,80,TRUE),
('P0094','Nước giặt',10,40000,30000,70,TRUE),
('P0095','Bột giặt',10,35000,25000,100,TRUE),
('P0096','Bàn chải đánh răng',10,15000,10000,120,TRUE),
('P0097','Bông tẩy trang',10,8000,5000,150,TRUE),
('P0098','Găng tay cao su',10,12000,9000,100,TRUE),
('P0099','Khăn lau',10,10000,7000,80,TRUE),
('P0100','Nước rửa tay',10,15000,12000,90,TRUE),

-- Danh mục 11: Đồ gia dụng & nhà bếp
('P0101','Nồi',11,500000,400000,30,TRUE),
('P0102','Chảo',11,300000,250000,40,TRUE),
('P0103','Dao',11,150000,120000,50,TRUE),
('P0104','Ly',11,20000,15000,100,TRUE),
('P0105','Bát',11,15000,10000,120,TRUE),
('P0106','Thớt',11,80000,60000,60,TRUE),
('P0107','Xoong',11,400000,300000,20,TRUE),
('P0108','Dụng cụ đánh trứng',11,50000,40000,50,TRUE),
('P0109','Khuôn bánh',11,80000,60000,40,TRUE),
('P0110','Máy xay sinh tố',11,1500000,1200000,10,TRUE),
('P0181', 'Máy rửa bát' , 11, 20000000,15000000,20,TRUE),
('P0182','Máy hút bụi mini',11,1200000,950000,25,TRUE),
('P0183','Ấm siêu tốc',11,350000,280000,40,TRUE),
('P0184','Nồi chiên không dầu 3L',11,1500000,1200000,15,TRUE),
('P0185','Bếp điện từ',11,900000,750000,20,TRUE),
('P0186','Máy lọc nước mini',11,2500000,2100000,10,TRUE),
('P0187','Bộ nồi inox 5 món',11,2000000,1600000,12,TRUE),
('P0188','Lò vi sóng 20L',11,1800000,1500000,18,TRUE),
('P0189','Máy ép trái cây',11,1300000,1050000,20,TRUE),

-- Danh mục 12: Thiết bị điện & điện tử 
('P0111','Quạt',12,350000,280000,30,TRUE),
('P0112','Đèn bàn',12,150000,120000,50,TRUE),
('P0113','Ổ cắm điện',12,50000,40000,100,TRUE),
('P0114','Pin AA',12,30000,25000,200,TRUE),
('P0115','Pin AAA',12,25000,20000,200,TRUE),
('P0116','Đèn LED',12,100000,80000,40,TRUE),
('P0117','Máy sấy tóc',12,700000,600000,15,TRUE),
('P0118','Máy cạo râu',12,500000,400000,20,TRUE),
('P0119','Chuột máy tính',12,250000,200000,50,TRUE),
('P0120','Bàn phím',12,400000,300000,40,TRUE),
('P0190','Bộ phát WiFi mini',12,450000,380000,25,TRUE),
('P0191','Adapter sạc nhanh 20W',12,220000,180000,80,TRUE),
('P0192','Cáp HDMI 2m',12,90000,70000,100,TRUE),
('P0193','Loa Bluetooth mini',12,350000,290000,40,TRUE),
('P0194','Đèn LED cảm ứng',12,180000,140000,60,TRUE),
('P0195','Bàn ủi mini',12,320000,260000,30,TRUE),
('P0196','Quạt tích điện mini',12,250000,200000,70,TRUE),
('P0197','Sạc dự phòng 20.000mAh',12,450000,380000,40,TRUE),
('P0198','Thiết bị báo khói mini',12,300000,240000,25,TRUE),
('P0199','Camera mini USB',12,500000,420000,20,TRUE),
('P0200','Ổ cắm điện thông minh',12,350000,290000,35,TRUE),
-- Danh mục 13: Văn phòng phẩm
('P0121','Sổ tay',13,25000,20000,100,TRUE),
('P0122','Bút bi',13,5000,3000,200,TRUE),
('P0123','Thước kẻ',13,10000,7000,150,TRUE),
('P0124','Hồ dán',13,15000,12000,100,TRUE),
('P0125','Tẩy',13,5000,3000,200,TRUE),
('P0126','Bút chì',13,7000,5000,150,TRUE),
('P0127','Giấy A4',13,80000,60000,50,TRUE),
('P0128','Bìa hồ sơ',13,30000,20000,100,TRUE),
('P0129','Kẹp giấy',13,15000,10000,150,TRUE),
('P0130','Gôm tẩy',13,5000,3000,200,TRUE),

-- Danh mục 14: Thời trang & phụ kiện
('P0131','Áo thun',14,200000,150000,50,TRUE),
('P0132','Quần jean',14,350000,280000,40,TRUE),
('P0133','Mũ lưỡi trai',14,150000,120000,60,TRUE),
('P0134','Tất chân',14,50000,40000,100,TRUE),
('P0135','Giày thể thao',14,800000,600000,30,TRUE),
('P0136','Váy',14,400000,300000,20,TRUE),
('P0137','Áo khoác',14,500000,400000,25,TRUE),
('P0138','Dép lê',14,80000,60000,50,TRUE),
('P0139','Khăn quàng',14,120000,100000,40,TRUE),
('P0140','Thắt lưng',14,150000,120000,30,TRUE),

-- Danh mục 15: Đồ chơi & giải trí
('P0141','Đồ chơi xếp hình',15,200000,150000,50,TRUE),
('P0142','Búp bê',15,150000,120000,40,TRUE),
('P0143','Xe ô tô mô hình',15,250000,200000,30,TRUE),
('P0144','Đồ chơi gỗ',15,300000,250000,20,TRUE),
('P0145','Trò chơi ghép hình',15,180000,150000,50,TRUE),
('P0146','Bóng',15,100000,80000,60,TRUE),
('P0147','Sách thiếu nhi',15,50000,40000,100,TRUE),
('P0148','Game nhỏ',15,150000,120000,40,TRUE),
('P0149','Đồ chơi xếp lego',15,300000,250000,30,TRUE),
('P0150','Xe đạp trẻ em',15,1500000,1200000,10,TRUE),

-- Danh mục 16: Thức ăn & vật dụng cho thú cưng
('P0151','Thức ăn hạt chó',16,150000,120000,50,TRUE),
('P0152','Thức ăn hạt mèo',16,140000,100000,50,TRUE),
('P0153','Pate chó',16,100000,80000,40,TRUE),
('P0154','Cát vệ sinh mèo',16,80000,60000,30,TRUE),
('P0155','Đồ chơi chó',16,50000,40000,20,TRUE),
('P0156','Đồ chơi mèo',16,40000,30000,20,TRUE),
('P0157','Bát ăn chó',16,50000,40000,20,TRUE),
('P0158','Bát ăn mèo',16,40000,30000,20,TRUE),
('P0159','Dây xích chó',16,30000,25000,30,TRUE),
('P0160','Nhà cho mèo',16,800000,600000,10,TRUE),

-- Danh mục 17: Sản phẩm chăm sóc sức khỏe
('P0161','Vitamin C',17,200000,150000,50,TRUE),
('P0162','Thuốc cảm',17,150000,100000,60,TRUE),
('P0163','Thuốc đau đầu',17,100000,70000,70,TRUE),
('P0164','Thuốc hạ sốt',17,120000,90000,50,TRUE),
('P0165','Thuốc ho',17,130000,100000,40,TRUE),
('P0166','Thực phẩm chức năng',17,300000,250000,30,TRUE),
('P0167','Thuốc bổ mắt',17,200000,150000,20,TRUE),
('P0168','Thuốc bổ não',17,250000,200000,20,TRUE),
('P0169','Vitamin tổng hợp',17,300000,250000,40,TRUE),
('P0170','Thuốc bổ xương',17,200000,150000,30,TRUE),

-- Danh mục 18: Sản phẩm đặc sản / nhập khẩu
('P0171','Mứt dâu',18,150000,120000,50,TRUE),
('P0172','Mứt tắc',18,150000,120000,50,TRUE),
('P0173','Snack ngoại',18,200000,150000,40,TRUE),
('P0174','Bánh quy nhập khẩu',18,250000,200000,30,TRUE),
('P0175','Chocolate nhập khẩu',18,300000,250000,20,TRUE),
('P0176','Trà nhập khẩu',18,200000,150000,40,TRUE),
('P0177','Bánh mì Pháp',18,150000,120000,30,TRUE),
('P0178','Phô mai nhập khẩu',18,400000,350000,20,TRUE),
('P0179','Rượu vang',18,1000000,800000,10,TRUE),
('P0180','Mật ong ngoại',18,250000,200000,30,TRUE);

-- Khách hàng có tài khoản (CUS1 – CUS3)
-- =========================
INSERT INTO customers (customer_id, user_id, full_name, email, phone, address, created_at, updated_at) VALUES
('CUS1', 'CUS1', 'Nguyễn Văn An', 'nguyenvanan@example.com', '0900000001', '123 Lê Lợi, Hà Nội', '2024-11-01', '2024-11-01'),
('CUS2', 'CUS2', 'Trần Thị Bình', 'tranthibinh@example.com', '0900000002', '45 Nguyễn Trãi, Hà Nội', '2024-11-02', '2024-11-02'),
('CUS3', 'CUS3', 'Lê Văn Cường', 'levancuong@example.com', '0900000003', '78 Trần Hưng Đạo, Hà Nội', '2024-11-03', '2024-11-03');

-- =========================
-- Khách hàng không có tài khoản (CUS4 – CUS117)
-- =========================
-- Khách hàng không có tài khoản (CUS4 – CUS117) có địa chỉ đầy đủ

-- Tháng 11/2024 (CUS4 – CUS12)
INSERT INTO customers (customer_id, full_name, phone, address, created_at, updated_at) VALUES
('CUS4','Phạm Thị Dung','0900000004','10 Lê Lợi, Hà Nội','2024-11-04','2024-11-04'),
('CUS5','Hoàng Văn Đông','0900000005','11 Nguyễn Trãi, Hà Nội','2024-11-05','2024-11-05'),
('CUS6','Đặng Thị Hương','0900000006','12 Trần Hưng Đạo, Hà Nội','2024-11-06','2024-11-06'),
('CUS7','Nguyễn Văn Hoàng','0900000007','13 Hai Bà Trưng, Hà Nội','2024-11-07','2024-11-07'),
('CUS8','Trần Thị Lan','0900000008','14 Bà Triệu, Hà Nội','2024-11-08','2024-11-08'),
('CUS9','Lê Văn Nam','0900000009','15 Phan Chu Trinh, Hà Nội','2024-11-09','2024-11-09'),
('CUS10','Phạm Thị Ngọc','0900000010','16 Nguyễn Du, Hà Nội','2024-11-10','2024-11-10'),
('CUS11','Hoàng Văn Phúc','0900000011','17 Trần Phú, Hà Nội','2024-11-11','2024-11-11'),
('CUS12','Đặng Văn Quang','0900000012','18 Lý Thường Kiệt, Hà Nội','2024-11-12','2024-11-12');

-- Tháng 12/2024 (CUS13 – CUS21)
INSERT INTO customers (customer_id, full_name, phone, address, created_at, updated_at) VALUES
('CUS13','Nguyễn Thị Mai','0900000013','19 Lê Lợi, Hà Nội','2024-12-01','2024-12-01'),
('CUS14','Trần Văn Nam','0900000014','20 Nguyễn Trãi, Hà Nội','2024-12-02','2024-12-02'),
('CUS15','Lê Thị Hạnh','0900000015','21 Trần Hưng Đạo, Hà Nội','2024-12-03','2024-12-03'),
('CUS16','Phạm Văn Tùng','0900000016','22 Hai Bà Trưng, Hà Nội','2024-12-04','2024-12-04'),
('CUS17','Hoàng Thị Phương','0900000017','23 Bà Triệu, Hà Nội','2024-12-05','2024-12-05'),
('CUS18','Đặng Văn Kiên','0900000018','24 Phan Chu Trinh, Hà Nội','2024-12-06','2024-12-06'),
('CUS19','Nguyễn Thị Lan','0900000019','25 Nguyễn Du, Hà Nội','2024-12-07','2024-12-07'),
('CUS20','Trần Văn Huy','0900000020','26 Trần Phú, Hà Nội','2024-12-08','2024-12-08'),
('CUS21','Lê Thị Thu','0900000021','27 Lý Thường Kiệt, Hà Nội','2024-12-09','2024-12-09');

-- Tháng 01/2025 (CUS22 – CUS30)
INSERT INTO customers (customer_id, full_name, phone, address, created_at, updated_at) VALUES
('CUS22','Phạm Văn Bình','0900000022','28 Lê Lợi, Hà Nội','2025-01-01','2025-01-01'),
('CUS23','Hoàng Thị Dung','0900000023','29 Nguyễn Trãi, Hà Nội','2025-01-02','2025-01-02'),
('CUS24','Đặng Văn Hòa','0900000024','30 Trần Hưng Đạo, Hà Nội','2025-01-03','2025-01-03'),
('CUS25','Nguyễn Thị Lan Anh','0900000025','31 Hai Bà Trưng, Hà Nội','2025-01-04','2025-01-04'),
('CUS26','Trần Văn Khoa','0900000026','32 Bà Triệu, Hà Nội','2025-01-05','2025-01-05'),
('CUS27','Lê Thị Ngọc Anh','0900000027','33 Phan Chu Trinh, Hà Nội','2025-01-06','2025-01-06'),
('CUS28','Phạm Văn Hoàng','0900000028','34 Nguyễn Du, Hà Nội','2025-01-07','2025-01-07'),
('CUS29','Hoàng Thị Mai','0900000029','35 Trần Phú, Hà Nội','2025-01-08','2025-01-08'),
('CUS30','Đặng Văn Tuấn','0900000030','36 Lý Thường Kiệt, Hà Nội','2025-01-09','2025-01-09');
-- Tháng 02/2025 (CUS31 – CUS39)
INSERT INTO customers (customer_id, full_name, phone, address, created_at, updated_at) VALUES
('CUS31','Nguyễn Văn Long','0900000031','37 Lê Lợi, Hà Nội','2025-02-01','2025-02-01'),
('CUS32','Trần Thị Hồng','0900000032','38 Nguyễn Trãi, Hà Nội','2025-02-02','2025-02-02'),
('CUS33','Lê Văn Tuấn','0900000033','39 Trần Hưng Đạo, Hà Nội','2025-02-03','2025-02-03'),
('CUS34','Phạm Thị Hương','0900000034','40 Hai Bà Trưng, Hà Nội','2025-02-04','2025-02-04'),
('CUS35','Hoàng Văn Bình','0900000035','41 Bà Triệu, Hà Nội','2025-02-05','2025-02-05'),
('CUS36','Đặng Thị Lan','0900000036','42 Phan Chu Trinh, Hà Nội','2025-02-06','2025-02-06'),
('CUS37','Nguyễn Văn Duy','0900000037','43 Nguyễn Du, Hà Nội','2025-02-07','2025-02-07'),
('CUS38','Trần Thị Phương','0900000038','44 Trần Phú, Hà Nội','2025-02-08','2025-02-08'),
('CUS39','Lê Văn Anh','0900000039','45 Lý Thường Kiệt, Hà Nội','2025-02-09','2025-02-09');

-- Tháng 03/2025 (CUS40 – CUS48)
INSERT INTO customers (customer_id, full_name, phone, address, created_at, updated_at) VALUES
('CUS40','Phạm Văn Tài','0900000040','46 Lê Lợi, Hà Nội','2025-03-01','2025-03-01'),
('CUS41','Hoàng Thị Hạnh','0900000041','47 Nguyễn Trãi, Hà Nội','2025-03-02','2025-03-02'),
('CUS42','Đặng Văn Nam','0900000042','48 Trần Hưng Đạo, Hà Nội','2025-03-03','2025-03-03'),
('CUS43','Nguyễn Thị Lan','0900000043','49 Hai Bà Trưng, Hà Nội','2025-03-04','2025-03-04'),
('CUS44','Trần Văn Hùng','0900000044','50 Bà Triệu, Hà Nội','2025-03-05','2025-03-05'),
('CUS45','Lê Thị Mai','0900000045','51 Phan Chu Trinh, Hà Nội','2025-03-06','2025-03-06'),
('CUS46','Phạm Văn Phúc','0900000046','52 Nguyễn Du, Hà Nội','2025-03-07','2025-03-07'),
('CUS47','Hoàng Thị Duyên','0900000047','53 Trần Phú, Hà Nội','2025-03-08','2025-03-08'),
('CUS48','Đặng Văn Cường','0900000048','54 Lý Thường Kiệt, Hà Nội','2025-03-09','2025-03-09');

-- Tháng 04/2025 (CUS49 – CUS57)
INSERT INTO customers (customer_id, full_name, phone, address, created_at, updated_at) VALUES
('CUS49','Nguyễn Văn Sơn','0900000049','55 Lê Lợi, Hà Nội','2025-04-01','2025-04-01'),
('CUS50','Trần Thị Hồng','0900000050','56 Nguyễn Trãi, Hà Nội','2025-04-02','2025-04-02'),
('CUS51','Lê Văn Hưng','0900000051','57 Trần Hưng Đạo, Hà Nội','2025-04-03','2025-04-03'),
('CUS52','Phạm Thị Lan','0900000052','58 Hai Bà Trưng, Hà Nội','2025-04-04','2025-04-04'),
('CUS53','Hoàng Văn Minh','0900000053','59 Bà Triệu, Hà Nội','2025-04-05','2025-04-05'),
('CUS54','Đặng Thị Phương','0900000054','60 Phan Chu Trinh, Hà Nội','2025-04-06','2025-04-06'),
('CUS55','Nguyễn Văn Quý','0900000055','61 Nguyễn Du, Hà Nội','2025-04-07','2025-04-07'),
('CUS56','Trần Thị Thu','0900000056','62 Trần Phú, Hà Nội','2025-04-08','2025-04-08'),
('CUS57','Lê Văn Khánh','0900000057','63 Lý Thường Kiệt, Hà Nội','2025-04-09','2025-04-09');

-- Tháng 05/2025 (CUS58 – CUS66)
INSERT INTO customers (customer_id, full_name, phone, address, created_at, updated_at) VALUES
('CUS58','Phạm Văn Hòa','0900000058','64 Lê Lợi, Hà Nội','2025-05-01','2025-05-01'),
('CUS59','Hoàng Thị Ngọc','0900000059','65 Nguyễn Trãi, Hà Nội','2025-05-02','2025-05-02'),
('CUS60','Đặng Văn Nam','0900000060','66 Trần Hưng Đạo, Hà Nội','2025-05-03','2025-05-03'),
('CUS61','Nguyễn Thị Mai','0900000061','67 Hai Bà Trưng, Hà Nội','2025-05-04','2025-05-04'),
('CUS62','Trần Văn Tùng','0900000062','68 Bà Triệu, Hà Nội','2025-05-05','2025-05-05'),
('CUS63','Lê Thị Hạnh','0900000063','69 Phan Chu Trinh, Hà Nội','2025-05-06','2025-05-06'),
('CUS64','Phạm Văn Bình','0900000064','70 Nguyễn Du, Hà Nội','2025-05-07','2025-05-07'),
('CUS65','Hoàng Thị Lan','0900000065','71 Trần Phú, Hà Nội','2025-05-08','2025-05-08'),
('CUS66','Đặng Văn Hưng','0900000066','72 Lý Thường Kiệt, Hà Nội','2025-05-09','2025-05-09');
-- Tháng 06/2025 (CUS67 – CUS75)
INSERT INTO customers (customer_id, full_name, phone, address, created_at, updated_at) VALUES
('CUS67','Nguyễn Văn Duy','0900000067','73 Lê Lợi, Hà Nội','2025-06-01','2025-06-01'),
('CUS68','Trần Thị Hồng','0900000068','74 Nguyễn Trãi, Hà Nội','2025-06-02','2025-06-02'),
('CUS69','Lê Văn Minh','0900000069','75 Trần Hưng Đạo, Hà Nội','2025-06-03','2025-06-03'),
('CUS70','Phạm Thị Lan','0900000070','76 Hai Bà Trưng, Hà Nội','2025-06-04','2025-06-04'),
('CUS71','Hoàng Văn Quý','0900000071','77 Bà Triệu, Hà Nội','2025-06-05','2025-06-05'),
('CUS72','Đặng Thị Thu','0900000072','78 Phan Chu Trinh, Hà Nội','2025-06-06','2025-06-06'),
('CUS73','Nguyễn Văn Khánh','0900000073','79 Nguyễn Du, Hà Nội','2025-06-07','2025-06-07'),
('CUS74','Trần Thị Mai','0900000074','80 Trần Phú, Hà Nội','2025-06-08','2025-06-08'),
('CUS75','Lê Văn Hòa','0900000075','81 Lý Thường Kiệt, Hà Nội','2025-06-09','2025-06-09');

-- Tháng 07/2025 (CUS76 – CUS84)
INSERT INTO customers (customer_id, full_name, phone, address, created_at, updated_at) VALUES
('CUS76','Phạm Văn Minh','0900000076','82 Lê Lợi, Hà Nội','2025-07-01','2025-07-01'),
('CUS77','Hoàng Thị Hạnh','0900000077','83 Nguyễn Trãi, Hà Nội','2025-07-02','2025-07-02'),
('CUS78','Đặng Văn Bình','0900000078','84 Trần Hưng Đạo, Hà Nội','2025-07-03','2025-07-03'),
('CUS79','Nguyễn Thị Lan','0900000079','85 Hai Bà Trưng, Hà Nội','2025-07-04','2025-07-04'),
('CUS80','Trần Văn Hùng','0900000080','86 Bà Triệu, Hà Nội','2025-07-05','2025-07-05'),
('CUS81','Lê Thị Thu','0900000081','87 Phan Chu Trinh, Hà Nội','2025-07-06','2025-07-06'),
('CUS82','Phạm Văn Quý','0900000082','88 Nguyễn Du, Hà Nội','2025-07-07','2025-07-07'),
('CUS83','Hoàng Thị Mai','0900000083','89 Trần Phú, Hà Nội','2025-07-08','2025-07-08'),
('CUS84','Đặng Văn Tuấn','0900000084','90 Lý Thường Kiệt, Hà Nội','2025-07-09','2025-07-09');

-- Tháng 08/2025 (CUS85 – CUS93)
INSERT INTO customers (customer_id, full_name, phone, address, created_at, updated_at) VALUES
('CUS85','Nguyễn Văn Khánh','0900000085','91 Lê Lợi, Hà Nội','2025-08-01','2025-08-01'),
('CUS86','Trần Thị Thu','0900000086','92 Nguyễn Trãi, Hà Nội','2025-08-02','2025-08-02'),
('CUS87','Lê Văn Hòa','0900000087','93 Trần Hưng Đạo, Hà Nội','2025-08-03','2025-08-03'),
('CUS88','Phạm Thị Lan','0900000088','94 Hai Bà Trưng, Hà Nội','2025-08-04','2025-08-04'),
('CUS89','Hoàng Văn Minh','0900000089','95 Bà Triệu, Hà Nội','2025-08-05','2025-08-05'),
('CUS90','Đặng Thị Hạnh','0900000090','96 Phan Chu Trinh, Hà Nội','2025-08-06','2025-08-06'),
('CUS91','Nguyễn Văn Duy','0900000091','97 Nguyễn Du, Hà Nội','2025-08-07','2025-08-07'),
('CUS92','Trần Thị Mai','0900000092','98 Trần Phú, Hà Nội','2025-08-08','2025-08-08'),
('CUS93','Lê Văn Bình','0900000093','99 Lý Thường Kiệt, Hà Nội','2025-08-09','2025-08-09');

-- Tháng 09/2025 (CUS94 – CUS102)
INSERT INTO customers (customer_id, full_name, phone, address, created_at, updated_at) VALUES
('CUS94','Phạm Văn Tùng','0900000094','100 Lê Lợi, Hà Nội','2025-09-01','2025-09-01'),
('CUS95','Hoàng Thị Thu','0900000095','101 Nguyễn Trãi, Hà Nội','2025-09-02','2025-09-02'),
('CUS96','Đặng Văn Hùng','0900000096','102 Trần Hưng Đạo, Hà Nội','2025-09-03','2025-09-03'),
('CUS97','Nguyễn Thị Lan','0900000097','103 Hai Bà Trưng, Hà Nội','2025-09-04','2025-09-04'),
('CUS98','Trần Văn Minh','0900000098','104 Bà Triệu, Hà Nội','2025-09-05','2025-09-05'),
('CUS99','Lê Thị Hạnh','0900000099','105 Phan Chu Trinh, Hà Nội','2025-09-06','2025-09-06'),
('CUS100','Phạm Văn Quý','0900000100','106 Nguyễn Du, Hà Nội','2025-09-07','2025-09-07'),
('CUS101','Hoàng Thị Mai','0900000101','107 Trần Phú, Hà Nội','2025-09-08','2025-09-08'),
('CUS102','Đặng Văn Tuấn','0900000102','108 Lý Thường Kiệt, Hà Nội','2025-09-09','2025-09-09');

-- Tháng 10/2025 (CUS103 – CUS111)
INSERT INTO customers (customer_id, full_name, phone, address, created_at, updated_at) VALUES
('CUS103','Nguyễn Văn Khánh','0900000103','109 Lê Lợi, Hà Nội','2025-10-01','2025-10-01'),
('CUS104','Trần Thị Thu','0900000104','110 Nguyễn Trãi, Hà Nội','2025-10-02','2025-10-02'),
('CUS105','Lê Văn Hòa','0900000105','111 Trần Hưng Đạo, Hà Nội','2025-10-03','2025-10-03'),
('CUS106','Phạm Thị Lan','0900000106','112 Hai Bà Trưng, Hà Nội','2025-10-04','2025-10-04'),
('CUS107','Hoàng Văn Minh','0900000107','113 Bà Triệu, Hà Nội','2025-10-05','2025-10-05'),
('CUS108','Đặng Thị Hạnh','0900000108','114 Phan Chu Trinh, Hà Nội','2025-10-06','2025-10-06'),
('CUS109','Nguyễn Văn Duy','0900000109','115 Nguyễn Du, Hà Nội','2025-10-07','2025-10-07'),
('CUS110','Trần Thị Mai','0900000110','116 Trần Phú, Hà Nội','2025-10-08','2025-10-08'),
('CUS111','Lê Văn Bình','0900000111','117 Lý Thường Kiệt, Hà Nội','2025-10-09','2025-10-09');

-- Tháng 11/2025 (CUS112 – CUS117)
INSERT INTO customers (customer_id, full_name, phone, address, created_at, updated_at) VALUES
('CUS112','Phạm Văn Hòa','0900000112','118 Lê Lợi, Hà Nội','2025-11-01','2025-11-01'),
('CUS113','Hoàng Thị Ngọc','0900000113','119 Nguyễn Trãi, Hà Nội','2025-11-02','2025-11-02'),
('CUS114','Đặng Văn Nam','0900000114','120 Trần Hưng Đạo, Hà Nội','2025-11-03','2025-11-03'),
('CUS115','Nguyễn Thị Mai','0900000115','121 Hai Bà Trưng, Hà Nội','2025-11-04','2025-11-04'),
('CUS116','Trần Văn Tùng','0900000116','122 Bà Triệu, Hà Nội','2025-11-05','2025-11-05'),
('CUS117','Lê Thị Hạnh','0900000117','123 Phan Chu Trinh, Hà Nội','2025-11-06','2025-11-06');

INSERT INTO orders (order_id, customer_id, order_date, completed_date, order_channel, direct_delivery, subtotal, shipping_cost, final_total, status, payment_status, payment_method, staff_id, delivery_staff_id)
VALUES
('ORD1','CUS1','2024-11-05 10:15:00','2024-11-06 14:20:00','Online',FALSE,6020000,20000,6040000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','SALE01','SHIP01'),
('ORD2','CUS2','2024-11-07 11:30:00','2024-11-08 16:00:00','Trực tiếp',TRUE,3050000,0,3050000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','SALE02',NULL),
('ORD3','CUS3','2024-11-10 09:45:00','2024-11-11 12:30:00','Online',FALSE,420000,15000,435000,'Hoàn Thành','Đã Thanh Toán','Thẻ tín dụng','OS03','SHIP02'),
('ORD4','CUS4','2024-11-12 14:00:00',NULL,'Trực tiếp',TRUE,3000000,0,3000000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','SALE01',NULL),
('ORD5','CUS5','2024-11-15 13:20:00',NULL,'Trực tiếp',TRUE,2500000,0,2500000,'Hoàn Thành','Đã Thanh Toán','Chuyển khoản','SALE02',NULL),
('ORD6','CUS6','2024-11-16 10:30:00','2024-11-17 15:00:00','Online',FALSE,4500000,20000,4520000,'Hoàn Thành','Đã Thanh Toán','Thẻ tín dụng','OS01','SHIP01'),
('ORD7','CUS7','2024-11-18 11:15:00',NULL,'Trực tiếp',TRUE,30200000,0,30200000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','SALE01',NULL),
('ORD8','CUS8','2024-11-20 14:20:00','2024-11-21 16:45:00','Online',FALSE,520000,25000,545000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','OS02','SHIP02'),
('ORD9','CUS9','2024-11-22 09:50:00',NULL,'Trực tiếp',TRUE,280000,0,280000,'Hoàn Thành','Đã Thanh Toán','Chuyển khoản','SALE03',NULL),
('ORD10','CUS10','2024-11-24 13:10:00','2024-11-25 14:30:00','Online',FALSE,6000000,30000,6030000,'Hoàn Thành','Đã Thanh Toán','Thẻ tín dụng','OS01','SHIP03'),
('ORD11','CUS11','2024-11-26 10:00:00',NULL,'Trực tiếp',TRUE,3100000,0,3100000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','SALE02',NULL),
('ORD12','CUS12','2024-11-28 15:30:00','2024-11-29 16:20:00','Online',FALSE,4000000,20000,4020000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','OS03','SHIP01'),

-- Tháng 12/2024 (CUS13 – CUS21)

('ORD13','CUS13','2024-12-02 09:15:00','2024-12-03 11:30:00','Online',FALSE,5000000,20000,5020000,'Hoàn Thành','Đã Thanh Toán','Thẻ tín dụng','OS01','SHIP02'),
('ORD14','CUS14','2024-12-04 10:20:00',NULL,'Trực tiếp',TRUE,3500000,0,3500000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','SALE02',NULL),
('ORD15','CUS15','2024-12-06 11:45:00','2024-12-07 14:50:00','Online',FALSE,420000,15000,435000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','OS03','SHIP03'),
('ORD16','CUS16','2024-12-08 14:10:00',NULL,'Trực tiếp',TRUE,300000,0,300000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','SALE01',NULL),
('ORD17','CUS17','2024-12-10 10:05:00','2024-12-11 13:20:00','Online',FALSE,460000,20000,480000,'Hoàn Thành','Đã Thanh Toán','Thẻ tín dụng','OS02','SHIP01'),
('ORD18','CUS18','2024-12-12 12:30:00',NULL,'Trực tiếp',TRUE,3200000,0,3200000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','SALE03',NULL),
('ORD19','CUS19','2024-12-14 09:50:00','2024-12-15 11:40:00','Online',FALSE,510000,25000,535000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','SALE01','SHIP02'),
('ORD20','CUS20','2024-12-16 15:10:00',NULL,'Trực tiếp',TRUE,28000000,0,28000000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','SALE02',NULL),
('ORD21','CUS21','2024-12-18 11:25:00','2024-12-19 13:30:00','Online',FALSE,600000,30000,630000,'Hoàn Thành','Đã Thanh Toán','Thẻ tín dụng','OS03','SHIP03'),
('ORD22','CUS22','2025-01-03 09:30:00','2025-01-04 12:00:00','Online',FALSE,5000000,20000,5020000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','OS01','SHIP01'),
('ORD23','CUS23','2025-01-05 10:45:00',NULL,'Trực tiếp',TRUE,35000000,0,35000000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','SALE02',NULL),
('ORD24','CUS24','2025-01-07 11:50:00','2025-01-08 14:20:00','Online',FALSE,420000,15000,435000,'Hoàn Thành','Đã Thanh Toán','Thẻ tín dụng','OS03','SHIP02'),
('ORD25','CUS25','2025-01-09 13:10:00',NULL,'Trực tiếp',TRUE,3000000,0,3000000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','SALE01',NULL),
('ORD26','CUS26','2025-01-11 10:25:00','2025-01-12 12:50:00','Online',FALSE,460000,20000,480000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','OS02','SHIP03'),
('ORD27','CUS27','2025-01-13 14:30:00',NULL,'Trực tiếp',TRUE,3200000,0,3200000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','SALE03',NULL),
('ORD28','CUS28','2025-01-15 09:55:00','2025-01-16 11:40:00','Online',FALSE,510000,25000,535000,'Hoàn Thành','Đã Thanh Toán','Thẻ tín dụng','OS01','SHIP01'),
('ORD29','CUS29','2025-01-17 15:05:00',NULL,'Trực tiếp',TRUE,2800000,0,2800000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','SALE02',NULL),
('ORD30','CUS30','2025-01-19 11:20:00','2025-01-20 13:10:00','Online',FALSE,6000000,30000,6030000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','OS03','SHIP02');

-- Tháng 02/2025 (CUS31 – CUS39)
INSERT INTO orders (order_id, customer_id, order_date, completed_date, order_channel, direct_delivery, subtotal, shipping_cost, final_total, status, payment_status, payment_method, staff_id, delivery_staff_id)
VALUES
('ORD31','CUS31','2025-02-01 09:00:00','2025-02-02 11:30:00','Online',FALSE,5020000,20000,5040000,'Hoàn Thành','Đã Thanh Toán','Thẻ tín dụng','OS01','SHIP01'),
('ORD32','CUS32','2025-02-03 10:10:00',NULL,'Trực tiếp',TRUE,34000000,0,34000000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','SALE02',NULL),
('ORD33','CUS33','2025-02-05 11:20:00','2025-02-06 13:50:00','Online',FALSE,480000,15000,495000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','SALE03','SHIP02'),
('ORD34','CUS34','2025-02-07 14:30:00',NULL,'Trực tiếp',TRUE,310000,0,310000,'Hoàn Thành','Đã Thanh Toán','Chuyển khoản','SALE01',NULL),
('ORD35','CUS35','2025-02-09 09:45:00','2025-02-10 12:10:00','Online',FALSE,500000,20000,520000,'Hoàn Thành','Đã Thanh Toán','Thẻ tín dụng','OS02','SHIP03'),
('ORD36','CUS36','2025-02-11 12:00:00',NULL,'Trực tiếp',TRUE,3300000,0,3300000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','SALE03',NULL),
('ORD37','CUS37','2025-02-13 10:15:00','2025-02-14 11:50:00','Online',FALSE,510000,25000,535000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','OS01','SHIP01'),
('ORD38','CUS38','2025-02-15 13:30:00',NULL,'Trực tiếp',TRUE,2900000,0,2900000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','SALE02',NULL),
('ORD39','CUS39','2025-02-17 11:40:00','2025-02-18 14:00:00','Online',FALSE,600000,30000,630000,'Hoàn Thành','Đã Thanh Toán','Thẻ tín dụng','SALE03','SHIP02'),
('ORD40','CUS40','2025-03-01 09:20:00','2025-03-02 12:10:00','Online',FALSE,530000,20000,550000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','OS01','SHIP03'),
('ORD41','CUS41','2025-03-03 10:35:00',NULL,'Trực tiếp',TRUE,3600000,0,3600000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','SALE02',NULL),
('ORD42','CUS42','2025-03-05 11:50:00','2025-03-06 13:40:00','Online',FALSE,470000,15000,485000,'Hoàn Thành','Đã Thanh Toán','Thẻ tín dụng','OS03','SHIP01'),
('ORD43','CUS43','2025-03-07 14:05:00',NULL,'Trực tiếp',TRUE,3200000,0,3200000,'Hoàn Thành','Đã Thanh Toán','Chuyển khoản','SALE01',NULL),
('ORD44','CUS44','2025-03-09 10:15:00','2025-03-10 12:50:00','Online',FALSE,500000,20000,520000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','OS02','SHIP02'),
('ORD45','CUS45','2025-03-11 12:30:00',NULL,'Trực tiếp',TRUE,3100000,0,3100000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','SALE03',NULL),
('ORD46','CUS46','2025-03-13 09:45:00','2025-03-14 11:30:00','Online',FALSE,520000,25000,545000,'Hoàn Thành','Đã Thanh Toán','Thẻ tín dụng','SALE01','SHIP03'),
('ORD47','CUS47','2025-03-15 13:00:00',NULL,'Trực tiếp',TRUE,30000000,0,30000000,'Hoàn Thành','Đã Thanh Toán','Chuyển khoản','SALE02',NULL),
('ORD48','CUS48','2025-03-17 11:20:00','2025-03-18 13:10:00','Online',FALSE,6010000,30000,6040000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','OS03','SHIP01'),

-- Tháng 04/2025 (CUS49 – CUS57

('ORD49','CUS49','2025-04-01 09:10:00','2025-04-02 12:00:00','Online',FALSE,5040000,20000,5060000,'Hoàn Thành','Đã Thanh Toán','Thẻ tín dụng','OS01','SHIP02'),
('ORD50','CUS50','2025-04-03 10:25:00',NULL,'Trực tiếp',TRUE,3500000,0,3500000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','SALE02',NULL),
('ORD51','CUS51','2025-04-05 11:40:00','2025-04-06 13:50:00','Online',FALSE,4080000,15000,4095000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','OS03','SHIP03'),
('ORD52','CUS52','2025-04-07 14:00:00',NULL,'Trực tiếp',TRUE,320000,0,320000,'Hoàn Thành','Đã Thanh Toán','Chuyển khoản','OS01',NULL),
('ORD53','CUS53','2025-04-09 10:10:00','2025-04-10 12:40:00','Online',FALSE,5000000,20000,5020000,'Hoàn Thành','Đã Thanh Toán','Thẻ tín dụng','OS02','SHIP01'),
('ORD54','CUS54','2025-04-11 12:30:00',NULL,'Trực tiếp',TRUE,3100000,0,3100000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','SALE03',NULL),
('ORD55','CUS55','2025-04-13 09:50:00','2025-04-14 11:45:00','Online',FALSE,5020000,25000,5045000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','OS01','SHIP02'),
('ORD56','CUS56','2025-04-15 13:10:00',NULL,'Trực tiếp',TRUE,300000,0,300000,'Hoàn Thành','Đã Thanh Toán','Chuyển khoản','SALE02',NULL),
('ORD57','CUS57','2025-04-17 11:25:00','2025-04-18 13:20:00','Online',FALSE,6010000,30000,6040000,'Hoàn Thành','Đã Thanh Toán','Thẻ tín dụng','OS03','SHIP03'),
('ORD58','CUS58','2025-05-01 09:15:00','2025-05-02 11:30:00','Online',FALSE,530000,20000,550000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','OS01','SHIP01'),
('ORD59','CUS59','2025-05-03 10:20:00',NULL,'Trực tiếp',TRUE,360000,0,360000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','SALE02',NULL),
('ORD60','CUS60','2025-05-05 11:45:00','2025-05-06 14:00:00','Online',FALSE,4080000,15000,4095000,'Hoàn Thành','Đã Thanh Toán','Thẻ tín dụng','OS03','SHIP02'),
('ORD61','CUS61','2025-05-07 14:00:00',NULL,'Trực tiếp',TRUE,320000,0,320000,'Hoàn Thành','Đã Thanh Toán','Chuyển khoản','SALE01',NULL),
('ORD62','CUS62','2025-05-09 10:10:00','2025-05-10 12:40:00','Online',FALSE,5000000,20000,5020000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','OS02','SHIP03'),
('ORD63','CUS63','2025-05-11 12:30:00',NULL,'Trực tiếp',TRUE,310000,0,310000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','SALE03',NULL),
('ORD64','CUS64','2025-05-13 09:50:00','2025-05-14 11:45:00','Online',FALSE,5020000,25000,5045000,'Hoàn Thành','Đã Thanh Toán','Thẻ tín dụng','OS01','SHIP01'),
('ORD65','CUS65','2025-05-15 13:10:00',NULL,'Trực tiếp',TRUE,3000000,0,3000000,'Hoàn Thành','Đã Thanh Toán','Chuyển khoản','SALE02',NULL),
('ORD66','CUS66','2025-05-17 11:25:00','2025-05-18 13:20:00','Online',FALSE,6010000,30000,6040000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','OS03','SHIP02'),
('ORD67','CUS67','2025-06-01 09:20:00','2025-06-02 12:10:00','Online',FALSE,530000,20000,550000,'Hoàn Thành','Đã Thanh Toán','Thẻ tín dụng','OS01','SHIP03'),
('ORD68','CUS68','2025-06-03 10:35:00',NULL,'Trực tiếp',TRUE,3600000,0,3600000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','SALE02',NULL),
('ORD69','CUS69','2025-06-05 11:50:00','2025-06-06 13:40:00','Online',FALSE,4070000,15000,4085000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','SALE03','SHIP01'),
('ORD70','CUS70','2025-06-07 14:05:00',NULL,'Trực tiếp',TRUE,3200000,0,3200000,'Hoàn Thành','Đã Thanh Toán','Chuyển khoản','SALE01',NULL),
('ORD71','CUS71','2025-06-09 10:15:00','2025-06-10 12:50:00','Online',FALSE,5000000,20000,5020000,'Hoàn Thành','Đã Thanh Toán','Thẻ tín dụng','OS02','SHIP02'),
('ORD72','CUS72','2025-06-11 12:30:00',NULL,'Trực tiếp',TRUE,3100000,0,3100000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','SALE03',NULL),
('ORD73','CUS73','2025-06-13 09:50:00','2025-06-14 11:45:00','Online',FALSE,5200000,25000,5045000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','OS01','SHIP03'),
('ORD74','CUS74','2025-06-15 13:10:00',NULL,'Trực tiếp',TRUE,3000000,0,3000000,'Hoàn Thành','Đã Thanh Toán','Chuyển khoản','SALE02',NULL),
('ORD75','CUS75','2025-06-17 11:25:00','2025-06-18 13:20:00','Online',FALSE,6010000,30000,6040000,'Hoàn Thành','Đã Thanh Toán','Thẻ tín dụng','OS03','SHIP01'),
('ORD76','CUS76','2025-07-01 09:15:00','2025-07-02 11:30:00','Online',FALSE,5030000,20000,5050000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','OS01','SHIP02'),
('ORD77','CUS77','2025-07-03 10:20:00',NULL,'Trực tiếp',TRUE,360000,0,360000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','SALE02',NULL),
('ORD78','CUS78','2025-07-05 11:45:00','2025-07-06 14:00:00','Online',FALSE,4800000,15000,48015000,'Hoàn Thành','Đã Thanh Toán','Thẻ tín dụng','OS03','SHIP03'),
('ORD79','CUS79','2025-07-07 14:00:00',NULL,'Trực tiếp',TRUE,3200000,0,3200000,'Hoàn Thành','Đã Thanh Toán','Chuyển khoản','SALE01',NULL),
('ORD80','CUS80','2025-07-09 10:10:00','2025-07-10 12:40:00','Online',FALSE,500000,20000,520000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','OS02','SHIP01');
INSERT INTO orders (order_id, customer_id, order_date, completed_date, order_channel, direct_delivery, subtotal, shipping_cost, final_total, status, payment_status, payment_method, staff_id, delivery_staff_id)
VALUES
('ORD81','CUS81','2025-07-11 12:30:00',NULL,'Trực tiếp',TRUE,310000,0,310000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','SALE03',NULL),
('ORD82','CUS82','2025-07-13 09:50:00','2025-07-14 11:45:00','Online',FALSE,520000,25000,545000,'Hoàn Thành','Đã Thanh Toán','Thẻ tín dụng','OS01','SHIP02'),
('ORD83','CUS83','2025-07-15 13:10:00',NULL,'Trực tiếp',TRUE,300000,0,300000,'Hoàn Thành','Đã Thanh Toán','Chuyển khoản','SALE02',NULL),
('ORD84','CUS84','2025-07-17 11:25:00','2025-07-18 13:20:00','Online',FALSE,610000,30000,640000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','OS03','SHIP03'),
('ORD85','CUS85','2025-07-18 09:20:00','2025-07-20 12:10:00','Online',FALSE,530000,20000,550000,'Hoàn Thành','Đã Thanh Toán','Thẻ tín dụng','OS01','SHIP01'),
('ORD86','CUS86','2025-07-19 10:35:00',NULL,'Trực tiếp',TRUE,360000,0,360000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','SALE02',NULL),
('ORD87','CUS87','2025-07-29 11:50:00','2025-07-30 13:40:00','Online',FALSE,470000,15000,485000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','OS03','SHIP02'),
('ORD88','CUS88','2025-07-30 14:05:00',NULL,'Trực tiếp',TRUE,320000,0,320000,'Hoàn Thành','Đã Thanh Toán','Chuyển khoản','SALE01',NULL),
('ORD89','CUS89','2025-07-30 10:15:00','2025-07-31 12:50:00','Online',FALSE,500000,20000,520000,'Hoàn Thành','Đã Thanh Toán','Thẻ tín dụng','OS02','SHIP03'),
('ORD90','CUS90','2025-07-31 12:30:00',NULL,'Trực tiếp',TRUE,310000,0,310000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','SALE03',NULL);
-- Tháng 08/2025 (CUS85 – CUS93)
INSERT INTO orders (order_id, customer_id, order_date, completed_date, order_channel, direct_delivery, subtotal, shipping_cost, final_total, status, payment_status, payment_method, staff_id, delivery_staff_id)
VALUES
('ORD91','CUS91','2025-08-13 09:50:00','2025-08-14 11:45:00','Online',FALSE,520000,25000,545000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','OS01','SHIP01'),
('ORD92','CUS92','2025-08-15 13:10:00',NULL,'Trực tiếp',TRUE,30000000,0,30000000,'Hoàn Thành','Đã Thanh Toán','Chuyển khoản','SALE02',NULL),
('ORD93','CUS93','2025-08-17 11:25:00','2025-08-18 13:20:00','Online',FALSE,610000,30000,640000,'Hoàn Thành','Đã Thanh Toán','Thẻ tín dụng','OS03','SHIP02'),
('ORD94','CUS94','2025-09-01 09:15:00','2025-09-02 11:30:00','Online',FALSE,530000,20000,550000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','OS01','SHIP03'),
('ORD95','CUS95','2025-09-03 10:20:00',NULL,'Trực tiếp',TRUE,360000,0,360000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','SALE02',NULL),
('ORD96','CUS96','2025-09-05 11:45:00','2025-09-06 14:00:00','Online',FALSE,480000,15000,495000,'Hoàn Thành','Đã Thanh Toán','Thẻ tín dụng','OS03','SHIP01'),
('ORD97','CUS97','2025-09-07 14:00:00',NULL,'Trực tiếp',TRUE,320000,0,320000,'Hoàn Thành','Đã Thanh Toán','Chuyển khoản','SALE01',NULL),
('ORD98','CUS98','2025-09-09 10:10:00','2025-09-10 12:40:00','Online',FALSE,500000,20000,520000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','OS02','SHIP02'),
('ORD99','CUS99','2025-09-11 12:30:00',NULL,'Trực tiếp',TRUE,310000,0,310000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','SALE03',NULL),
('ORD100','CUS100','2025-09-13 09:50:00','2025-09-14 11:45:00','Online',FALSE,520000,25000,545000,'Hoàn Thành','Đã Thanh Toán','Thẻ tín dụng','OS01','SHIP03'),
('ORD101','CUS101','2025-09-15 13:10:00',NULL,'Trực tiếp',TRUE,30000000,0,30000000,'Hoàn Thành','Đã Thanh Toán','Chuyển khoản','SALE02',NULL),
('ORD102','CUS102','2025-09-17 11:25:00','2025-09-18 13:20:00','Online',FALSE,610000,30000,640000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','OS03','SHIP01'),


-- Tháng 10/2025 (CUS103 – CUS111)

('ORD103','CUS103','2025-10-01 09:20:00','2025-10-02 12:10:00','Online',FALSE,530000,20000,550000,'Hoàn Thành','Đã Thanh Toán','Thẻ tín dụng','OS01','SHIP02'),
('ORD104','CUS104','2025-10-03 10:35:00',NULL,'Trực tiếp',TRUE,360000,0,360000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','SALE02',NULL),
('ORD105','CUS105','2025-10-05 11:50:00','2025-10-06 13:40:00','Online',FALSE,470000,15000,485000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','OS03','SHIP03'),
('ORD106','CUS106','2025-10-07 14:05:00',NULL,'Trực tiếp',TRUE,320000,0,320000,'Hoàn Thành','Đã Thanh Toán','Chuyển khoản','SALE01',NULL),
('ORD107','CUS107','2025-10-09 10:15:00','2025-10-10 12:50:00','Online',FALSE,500000,20000,520000,'Hoàn Thành','Đã Thanh Toán','Thẻ tín dụng','OS02','SHIP01'),
('ORD108','CUS108','2025-10-11 12:30:00',NULL,'Trực tiếp',TRUE,310000,0,310000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','SALE03',NULL),
('ORD109','CUS109','2025-10-13 09:50:00','2025-10-14 11:45:00','Online',FALSE,520000,25000,545000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','OS01','SHIP02'),
('ORD110','CUS110','2025-10-15 13:10:00',NULL,'Trực tiếp',TRUE,300000,0,300000,'Hoàn Thành','Đã Thanh Toán','Chuyển khoản','SALE02',NULL),
('ORD111','CUS111','2025-10-17 11:25:00','2025-10-18 13:20:00','Online',FALSE,610000,30000,640000,'Hoàn Thành','Đã Thanh Toán','Thẻ tín dụng','OS03','SHIP03'),
('ORD112','CUS112','2025-10-21 09:15:00','2025-10-22 11:30:00','Online',FALSE,530000,20000,550000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','OS01','SHIP01'),
('ORD113','CUS113','2025-10-23 10:20:00',NULL,'Trực tiếp',TRUE,36000000,0,36000000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','SALE02',NULL),
('ORD114','CUS114','2025-10-25 11:45:00','2025-10-26 14:00:00','Online',FALSE,480000,15000,495000,'Hoàn Thành','Đã Thanh Toán','Thẻ tín dụng','OS03','SHIP02'),
('ORD115','CUS115','2025-10-27 14:00:00',NULL,'Trực tiếp',TRUE,320000,0,320000,'Hoàn Thành','Đã Thanh Toán','Chuyển khoản','SALE01',NULL);
-- tháng 11/2025
INSERT INTO `orders` 
(order_id, customer_id, order_date, completed_date, order_channel, direct_delivery, subtotal, shipping_cost, final_total, status, payment_status, payment_method, staff_id, delivery_staff_id)
VALUES
-- Đơn tháng 11/2025
('ORD116','CUS116','2025-11-15 09:30:00',NULL,'Online',FALSE,500000,20000,520000,'Đang Giao','Chưa Thanh Toán','Tiền mặt','OS02','SHIP01'),
('ORD117','CUS117','2025-11-16 10:10:00','2025-11-16 10:10:00','Trực tiếp',TRUE,450000,0,450000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','SALE03',NULL),
('ORD118','CUS101','2025-11-17 12:20:00','2025-11-18 13:45:00','Online',FALSE,600000,25000,625000,'Hoàn Thành','Đã Thanh Toán','Thẻ tín dụng','OS01','SHIP02'),
('ORD119','CUS102','2025-11-18 09:50:00','2025-11-18 09:50:00','Trực tiếp',TRUE,30000000,0,30000000,'Hoàn Thành','Đã Thanh Toán','Chuyển khoản','SALE01',NULL),
('ORD120','CUS103','2025-11-19 11:15:00',NULL,'Online',FALSE,520000,20000,540000,'Đang Xử Lý','Chưa Thanh Toán','Tiền mặt','OS03','SHIP03'),
('ORD121','CUS104','2025-11-20 10:30:00','2025-11-20 10:30:00','Trực tiếp',TRUE,370000,0,370000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','SALE02',NULL),
('ORD122','CUS105','2025-11-21 14:10:00','2025-11-22 12:50:00','Online',FALSE,550000,15000,565000,'Hoàn Thành','Đã Thanh Toán','Chuyển khoản','OS02','SHIP01'),
('ORD123','CUS106','2025-11-22 09:05:00','2025-11-22 09:05:00','Trực tiếp',TRUE,31000000,0,31000000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','SALE03',NULL),
('ORD124','CUS107','2025-11-23 13:25:00',NULL,'Online',FALSE,480000,20000,500000,'Đang Giao','Chưa Thanh Toán','Thẻ tín dụng','OS01','SHIP02'),
('ORD125','CUS108','2025-11-24 10:45:00','2025-11-24 10:45:00','Trực tiếp',TRUE,40000000,0,40000000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','SALE01',NULL),
('ORD126','CUS109','2025-11-25 11:55:00','2025-11-26 13:30:00','Online',FALSE,6000000,25000,6025000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','OS03','SHIP03'),
('ORD127','CUS110','2025-11-26 09:40:00','2025-11-26 09:40:00','Trực tiếp',TRUE,350000,0,350000,'Hoàn Thành','Đã Thanh Toán','Chuyển khoản','SALE02',NULL),
('ORD128','CUS111','2025-11-27 10:50:00',NULL,'Online',FALSE,500000,20000,520000,'Đang Xử Lý','Chưa Thanh Toán','Tiền mặt','OS01','SHIP01'),
('ORD129','CUS112','2025-11-28 12:30:00','2025-11-28 12:30:00','Trực tiếp',TRUE,450000,0,450000,'Hoàn Thành','Đã Thanh Toán','Tiền mặt','SALE03',NULL),
('ORD130','CUS113','2025-11-29 09:15:00',NULL,'Online',FALSE,520000,20000,540000,'Đang Giao','Chưa Thanh Toán','Thẻ tín dụng','OS02','SHIP02');

INSERT INTO order_details (order_id, product_id, quantity, price_at_order) VALUES
('ORD1','P0148',2,55887),
('ORD1','P0001',2,120000),
('ORD1','P0177',5,113425),
('ORD1','P0112',4,65627),
('ORD2','P0038',1,89650),
('ORD2','P0034',1,111521),
('ORD2','P0167',2,132690),
('ORD2','P0110',4,88077),
('ORD2','P0156',4,133895),
('ORD3','P0008',1,131619),
('ORD3','P0044',5,51606),
('ORD3','P0099',2,159078),
('ORD4','P0041',5,190486),
('ORD4','P0059',2,178216),
('ORD4','P0087',1,100212),
('ORD5','P0133',1,172240),
('ORD5','P0014',3,133263),
('ORD5','P0180',4,60825),
('ORD5','P0168',3,137491),
('ORD6','P0032',4,194035),
('ORD6','P0081',5,108686),
('ORD6','P0075',4,192852),
('ORD6','P0119',4,68035),
('ORD6','P0072',5,94702),
('ORD7','P0085',3,109626),
('ORD7','P0126',3,110767),
('ORD7','P0060',5,110534),
('ORD8','P0048',3,175605),
('ORD8','P0132',5,153198),
('ORD8','P0061',2,92664),
('ORD9','P0058',1,136313),
('ORD9','P0145',4,111045),
('ORD9','P0140',3,153159),
('ORD10','P0063',5,116285),
('ORD10','P0161',4,94945),
('ORD10','P0111',3,87305),
('ORD10','P0032',1,91453),
('ORD10','P0072',4,96056),
('ORD11','P0058',3,175882),
('ORD11','P0038',1,113466),
('ORD11','P0065',1,119562),
('ORD11','P0054',4,64221),
('ORD11','P0027',5,70464),
('ORD12','P0039',4,56936),
('ORD12','P0162',5,72290),
('ORD12','P0077',5,128673),
('ORD12','P0090',2,110538),
('ORD12','P0009',1,114713),
('ORD13','P0069',5,87979),
('ORD13','P0007',1,146928),
('ORD13','P0106',2,55068),
('ORD14','P0058',3,147888),
('ORD14','P0040',4,72116),
('ORD14','P0131',3,169000),
('ORD15','P0038',4,65295),
('ORD15','P0091',2,154335),
('ORD15','P0142',4,177533),
('ORD16','P0050',2,178226),
('ORD16','P0124',5,165026),
('ORD16','P0098',4,166259),
('ORD16','P0027',5,198881),
('ORD16','P0149',5,192977),
('ORD17','P0097',5,129142),
('ORD17','P0085',4,170896),
('ORD17','P0058',3,186598),
('ORD17','P0123',4,120358),
('ORD17','P0033',1,74750),
('ORD18','P0070',4,106930),
('ORD18','P0005',1,75428),
('ORD18','P0164',2,165058),
('ORD19','P0062',2,52040),
('ORD19','P0029',5,144632),
('ORD19','P0124',2,165149),
('ORD19','P0160',5,196906),
('ORD19','P0021',4,170806),
('ORD20','P0080',2,145815),
('ORD20','P0037',2,121555),
('ORD20','P0178',5,159672),
('ORD20','P0119',2,189035),
('ORD21','P0093',3,126502),
('ORD21','P0134',3,170312),
('ORD21','P0164',4,116893),
('ORD22','P0035',4,155906),
('ORD22','P0005',1,154854),
('ORD22','P0164',2,118813),
('ORD22','P0158',2,61495),
('ORD23','P0152',5,128788),
('ORD23','P0158',4,137075),
('ORD23','P0082',4,131282),
('ORD24','P0036',4,150634),
('ORD24','P0144',3,54534),
('ORD24','P0094',4,169993),
('ORD24','P0146',5,124070),
('ORD24','P0177',3,56411),
('ORD25','P0063',3,154798),
('ORD25','P0112',1,124505),
('ORD25','P0102',1,57868),
('ORD26','P0039',5,90287),
('ORD26','P0107',2,125730),
('ORD26','P0126',1,88791),
('ORD27','P0116',4,63628),
('ORD27','P0166',5,86855),
('ORD27','P0037',3,197775),
('ORD27','P0050',3,118936),
('ORD27','P0066',5,169130),
('ORD28','P0043',3,56116),
('ORD28','P0175',5,116496),
('ORD28','P0024',5,109668),
('ORD28','P0068',1,61297),
('ORD28','P0026',3,178654),
('ORD29','P0172',3,188652),
('ORD29','P0133',5,169181),
('ORD29','P0029',3,150199),
('ORD29','P0139',2,51843),
('ORD29','P0148',2,119537),
('ORD30','P0078',3,125973),
('ORD30','P0100',2,56017),
('ORD30','P0123',3,76204),
('ORD30','P0169',5,133615),
('ORD31','P0153',1,101443),
('ORD31','P0131',5,98564),
('ORD31','P0155',3,101796),
('ORD31','P0115',1,163696),
('ORD31','P0137',4,143272),
('ORD32','P0169',5,147868),
('ORD32','P0134',1,167413),
('ORD32','P0019',5,147448),
('ORD32','P0092',5,111198),
('ORD33','P0007',3,94518),
('ORD33','P0144',2,132515),
('ORD33','P0082',5,58677),
('ORD33','P0059',5,162358),
('ORD33','P0053',1,192221),
('ORD34','P0074',2,152960),
('ORD34','P0096',5,123204),
('ORD34','P0085',4,128178),
('ORD35','P0152',3,154175),
('ORD35','P0147',2,145412),
('ORD35','P0100',1,170828),
('ORD35','P0064',2,150085),
('ORD36','P0151',3,58786),
('ORD36','P0054',2,126334),
('ORD36','P0165',1,135214),
('ORD36','P0085',5,112986),
('ORD36','P0058',4,137273),
('ORD37','P0139',2,74135),
('ORD37','P0118',1,79301),
('ORD37','P0053',1,105878),
('ORD37','P0090',4,150185),
('ORD38','P0169',5,187513),
('ORD38','P0165',3,57174),
('ORD38','P0178',5,82641),
('ORD38','P0160',5,180517),
('ORD39','P0057',1,132221),
('ORD39','P0158',1,169592),
('ORD39','P0008',3,104373),
('ORD39','P0120',3,139793),
('ORD39','P0034',4,102123),
('ORD40','P0104',4,134404),
('ORD40','P0036',1,104778),
('ORD40','P0075',4,164019),
('ORD40','P0078',5,96727),
('ORD40','P0114',1,59873),
('ORD41','P0088',3,168201),
('ORD41','P0063',3,113824),
('ORD41','P0047',4,148284),
('ORD41','P0141',3,114490),
('ORD41','P0069',5,181753),
('ORD42','P0059',1,161512),
('ORD42','P0047',3,183665),
('ORD42','P0099',5,145754),
('ORD42','P0053',5,95441),
('ORD42','P0101',5,174475),
('ORD43','P0121',5,122946),
('ORD43','P0084',1,152453),
('ORD43','P0013',5,169830),
('ORD43','P0033',5,108377),
('ORD44','P0121',5,164547),
('ORD44','P0116',1,79749),
('ORD44','P0084',3,70470),
('ORD45','P0064',2,108262),
('ORD45','P0168',4,149514),
('ORD45','P0029',1,197167),
('ORD45','P0124',1,124311),
('ORD45','P0117',5,61080),
('ORD46','P0101',1,154344),
('ORD46','P0091',5,167268),
('ORD46','P0035',2,94901),
('ORD46','P0099',5,191370),
('ORD46','P0178',1,61425),
('ORD47','P0157',2,174057),
('ORD47','P0113',3,56627),
('ORD47','P0085',2,170257),
('ORD47','P0148',1,113247),
('ORD48','P0158',4,76946),
('ORD48','P0111',1,169172),
('ORD48','P0058',2,128202),
('ORD48','P0156',1,99634),
('ORD48','P0057',3,81632),
('ORD49','P0163',2,199850),
('ORD49','P0004',1,142160),
('ORD49','P0073',4,148122),
('ORD50','P0036',4,137051),
('ORD50','P0142',1,166181),
('ORD50','P0122',1,196832),
('ORD51','P0114',4,80394),
('ORD51','P0125',5,122297),
('ORD51','P0005',3,84867),
('ORD51','P0160',2,73460),
('ORD52','P0043',1,57335),
('ORD52','P0131',1,52316),
('ORD52','P0134',2,139760),
('ORD52','P0175',5,63595),
('ORD53','P0137',3,158207),
('ORD53','P0044',2,79998),
('ORD53','P0170',5,116178),
('ORD53','P0072',4,84750),
('ORD53','P0008',3,107339),
('ORD54','P0038',3,162856),
('ORD54','P0031',2,96823),
('ORD54','P0173',2,161989),
('ORD54','P0072',5,66439),
('ORD55','P0046',5,92631),
('ORD55','P0003',4,136310),
('ORD55','P0088',2,191772),
('ORD56','P0159',4,176910),
('ORD56','P0142',1,193153),
('ORD56','P0091',5,171137),
('ORD57','P0042',3,96689),
('ORD57','P0052',5,128212),
('ORD57','P0179',1,176374),
('ORD57','P0004',5,189761),
('ORD57','P0105',3,90032),
('ORD58','P0131',5,155545),
('ORD58','P0125',3,181249),
('ORD58','P0163',3,112661),
('ORD58','P0164',1,108930),
('ORD58','P0132',1,92598),
('ORD59','P0151',1,177035),
('ORD59','P0162',4,64367),
('ORD59','P0001',2,123865),
('ORD60','P0037',2,107886),
('ORD60','P0125',2,147494),
('ORD60','P0036',5,136565),
('ORD60','P0071',1,55069),
('ORD61','P0096',3,62775),
('ORD61','P0022',4,160728),
('ORD61','P0005',4,93898),
('ORD61','P0053',5,100094),
('ORD62','P0117',1,131196),
('ORD62','P0088',4,92026),
('ORD62','P0123',2,132534),
('ORD62','P0084',3,97279),
('ORD62','P0113',3,150815),
('ORD63','P0144',2,147890),
('ORD63','P0096',3,123534),
('ORD63','P0004',2,170143),
('ORD63','P0013',2,78955),
('ORD64','P0119',3,141289),
('ORD64','P0164',1,53242),
('ORD64','P0118',2,52472),
('ORD64','P0044',5,109420),
('ORD64','P0175',5,134120),
('ORD65','P0107',5,156163),
('ORD65','P0149',3,135288),
('ORD65','P0162',4,170888),
('ORD66','P0012',1,174087),
('ORD66','P0110',1,119163),
('ORD66','P0043',2,145897),
('ORD66','P0014',4,51935),
('ORD67','P0150',4,133469),
('ORD67','P0085',1,106015),
('ORD67','P0158',1,95528),
('ORD67','P0088',1,90778),
('ORD68','P0115',3,171226),
('ORD68','P0023',1,176704),
('ORD68','P0067',3,133251),
('ORD69','P0151',5,60224),
('ORD69','P0159',1,96508),
('ORD69','P0067',4,128087),
('ORD70','P0007',3,192855),
('ORD70','P0093',1,154766),
('ORD70','P0140',3,65169),
('ORD70','P0054',2,74634),
('ORD71','P0061',4,154874),
('ORD71','P0045',1,120838),
('ORD71','P0173',4,182197),
('ORD72','P0176',4,68939),
('ORD72','P0050',3,82295),
('ORD72','P0028',5,145049),
('ORD73','P0040',1,174974),
('ORD73','P0134',4,165238),
('ORD73','P0112',1,150698),
('ORD74','P0055',5,173872),
('ORD74','P0051',3,96138),
('ORD74','P0011',4,134860),
('ORD75','P0083',3,197187),
('ORD75','P0113',4,188420),
('ORD75','P0174',1,189943),
('ORD75','P0122',2,64626),
('ORD75','P0152',3,124856),
('ORD76','P0049',2,58099),
('ORD76','P0017',3,119143),
('ORD76','P0151',5,114667),
('ORD77','P0162',2,139794),
('ORD77','P0043',4,198317),
('ORD77','P0101',5,77762),
('ORD77','P0171',1,199309),
('ORD78','P0080',2,136103),
('ORD78','P0095',1,184252),
('ORD78','P0015',1,59280),
('ORD78','P0130',3,59047),
('ORD79','P0036',4,183417),
('ORD79','P0140',3,182645),
('ORD79','P0151',3,103118),
('ORD80','P0122',1,174981),
('ORD80','P0065',1,178647),
('ORD80','P0064',3,174942),
('ORD81','P0063',2,81132),
('ORD81','P0171',1,69557),
('ORD81','P0065',2,63621),
('ORD81','P0086',3,191612),
('ORD82','P0095',2,80042),
('ORD82','P0157',3,69728),
('ORD82','P0137',3,169922),
('ORD82','P0155',4,135320),
('ORD82','P0050',5,52430),
('ORD83','P0052',3,77439),
('ORD83','P0123',5,143452),
('ORD83','P0176',1,188814),
('ORD83','P0172',3,61514),
('ORD84','P0046',2,156705),
('ORD84','P0073',1,77602),
('ORD84','P0086',5,85264),
('ORD84','P0082',5,97946),
('ORD85','P0134',2,146098),
('ORD85','P0087',3,112801),
('ORD85','P0027',3,155740),
('ORD86','P0113',5,166078),
('ORD86','P0159',3,105838),
('ORD86','P0114',4,68274),
('ORD86','P0135',3,136029),
('ORD86','P0175',5,90513),
('ORD87','P0072',2,111374),
('ORD87','P0128',1,69618),
('ORD87','P0049',1,193469),
('ORD87','P0096',4,91772),
('ORD87','P0131',3,146149),
('ORD88','P0004',5,110967),
('ORD88','P0073',5,176911),
('ORD88','P0022',4,180443),
('ORD88','P0066',5,57430),
('ORD88','P0036',5,113898),
('ORD89','P0090',4,75094),
('ORD89','P0026',4,118885),
('ORD89','P0096',1,123465),
('ORD89','P0108',3,173617),
('ORD89','P0148',2,105974),
('ORD90','P0139',5,82581),
('ORD90','P0042',1,54741),
('ORD90','P0023',5,161486),
('ORD91','P0177',4,118781),
('ORD91','P0058',5,154919),
('ORD91','P0047',4,184446),
('ORD92','P0044',4,69067),
('ORD92','P0131',2,122176),
('ORD92','P0169',2,61541),
('ORD92','P0088',3,71904),
('ORD93','P0027',4,148091),
('ORD93','P0021',5,60979),
('ORD93','P0077',2,50251),
('ORD94','P0165',2,178653),
('ORD94','P0022',1,75261),
('ORD94','P0084',1,148003),
('ORD94','P0047',2,142277),
('ORD95','P0107',3,90568),
('ORD95','P0073',1,50178),
('ORD95','P0022',3,132756),
('ORD95','P0034',3,129722),
('ORD95','P0045',3,91088),
('ORD96','P0126',2,132407),
('ORD96','P0089',4,141763),
('ORD96','P0023',4,67883),
('ORD96','P0026',3,144328),
('ORD96','P0062',3,185880),
('ORD97','P0012',5,113863),
('ORD97','P0146',4,84310),
('ORD97','P0087',1,56716),
('ORD98','P0115',5,85040),
('ORD98','P0037',2,174975),
('ORD98','P0083',1,108142),
('ORD98','P0047',1,133150),
('ORD99','P0164',2,115403),
('ORD99','P0156',1,133313),
('ORD99','P0006',4,120666),
('ORD99','P0098',5,149099),
('ORD99','P0160',5,192509),
('ORD100','P0034',5,55209),
('ORD100','P0068',1,183175),
('ORD100','P0079',2,169819),
('ORD100','P0175',1,89985),
('ORD101','P0036',5,146594),
('ORD101','P0026',1,163783),
('ORD101','P0158',5,158123),
('ORD101','P0083',3,60785),
('ORD101','P0134',1,135067),
('ORD102','P0153',2,89627),
('ORD102','P0130',4,78429),
('ORD102','P0029',4,175488),
('ORD103','P0118',1,53609),
('ORD103','P0162',1,65476),
('ORD103','P0160',3,118162),
('ORD104','P0164',4,195182),
('ORD104','P0136',2,56139),
('ORD104','P0055',4,152753),
('ORD104','P0123',4,146480),
('ORD105','P0173',5,196078),
('ORD105','P0101',2,93665),
('ORD105','P0128',1,160783),
('ORD106','P0166',4,101562),
('ORD106','P0093',1,153079),
('ORD106','P0046',2,123791),
('ORD106','P0045',4,126532),
('ORD107','P0042',1,114247),
('ORD107','P0165',4,120368),
('ORD107','P0089',4,107718),
('ORD108','P0092',1,96662),
('ORD108','P0178',3,87968),
('ORD108','P0061',2,147334),
('ORD109','P0075',3,62038),
('ORD109','P0020',3,60070),
('ORD109','P0137',4,63726),
('ORD109','P0033',4,161675),
('ORD110','P0087',1,170386),
('ORD110','P0118',2,126459),
('ORD110','P0082',3,50817),
('ORD110','P0048',1,176512),
('ORD110','P0147',5,190219),
('ORD111','P0148',4,178708),
('ORD111','P0162',3,129716),
('ORD111','P0092',3,113479),
('ORD111','P0165',4,187558),
('ORD112','P0143',2,117773),
('ORD112','P0081',2,96309),
('ORD112','P0166',2,87462),
('ORD112','P0064',2,112210),
('ORD112','P0025',5,134817),
('ORD113','P0087',3,58573),
('ORD113','P0056',4,140648),
('ORD113','P0168',4,80031),
('ORD113','P0017',5,181655),
('ORD113','P0005',3,121637),
('ORD114','P0148',4,175296),
('ORD114','P0066',2,196644),
('ORD114','P0065',3,161542),
('ORD114','P0069',3,108976),
('ORD115','P0146',2,80982),
('ORD115','P0091',4,131068),
('ORD115','P0139',4,171701),
('ORD115','P0120',1,87525),
('ORD115','P0140',1,55024),
('ORD115','P0156',1,154663),
('ORD115','P0160',1,96422),
('ORD116','P0028',1,81088),
('ORD116','P0094',1,101760),
('ORD116','P0022',1,104351),
('ORD116','P0046',1,137854),
('ORD116','P0061',2,170510),
('ORD116','P0167',2,64306),
-- ORD117
('ORD117','P0011',1,150000),
-- ORD118
('ORD118','P0010',2,1200000),
('ORD118','P0009',1,80000),
-- ORD119
('ORD119','P0001',1,100000),
-- ORD120
('ORD120','P0003',2,120000),
('ORD120','P0012',1,120000),
-- ORD121
('ORD121','P0006',1,60000),
-- ORD122
('ORD122','P0014',2,80000),
('ORD122','P0015',1,20000),
-- ORD123
('ORD123','P0016',1,100000),
-- ORD124
('ORD124','P0017',2,700000),
('ORD124','P0018',1,500000),
-- ORD125
('ORD125','P0004',1,15000),
-- ORD126
('ORD126','P0008',2,50000),
('ORD126','P0009',1,80000),
-- ORD127
('ORD127','P0011',1,150000),
-- ORD128
('ORD128','P0012',2,120000),
('ORD128','P0013',1,150000),
-- ORD129
('ORD129','P0002',1,300000),
-- ORD130
('ORD130','P0005',2,15000),
('ORD130','P0006',1,60000);
-- Bật lại kiểm tra khóa ngoại
-- 1. Thêm cột full_name vào bảng users
SET SQL_SAFE_UPDATES = 0;

ALTER TABLE `users` 
ADD COLUMN `full_name` VARCHAR(100) NULL AFTER `role_id`;

-- 2. Cập nhật dữ liệu tên cho tài khoản OS01 (để đăng nhập không bị lỗi hiển thị)

-- 3. Cập nhật tên cho các tài khoản khác (lấy tạm username làm tên)
UPDATE `users` 
SET `full_name` = `username` 
WHERE `full_name` IS NULL;
SET SQL_SAFE_UPDATES = 1;
SET FOREIGN_KEY_CHECKS = 1;



DELETE FROM order_details WHERE order_id = 'ORD100';
DELETE FROM orders WHERE order_id = 'ORD100';
