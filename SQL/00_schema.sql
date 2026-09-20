CREATE DATABASE IF NOT EXISTS pharma_supply_chain;
USE pharma_supply_chain;

CREATE TABLE dim_drug (
    drug_id INT PRIMARY KEY,
    drug_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    unit_cost DECIMAL(10,2) NOT NULL,
    avg_daily_demand INT NOT NULL,
    criticality VARCHAR(20) NOT NULL,
    safety_stock INT NOT NULL
);

CREATE TABLE dim_location (
    location_id INT PRIMARY KEY,
    location_name VARCHAR(100) NOT NULL,
    region VARCHAR(50) NOT NULL
);

CREATE TABLE dim_supplier (
    supplier_id INT PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    avg_lead_time_days INT NOT NULL,
    reliability DECIMAL(5,2) NOT NULL
);

CREATE TABLE fact_sales (
    date DATE NOT NULL,
    drug_id INT NOT NULL,
    location_id INT NOT NULL,
    demand_qty INT NOT NULL,
    fulfilled_qty INT NOT NULL,
    stockout_flag TINYINT NOT NULL,
    PRIMARY KEY (date, drug_id, location_id)
);

CREATE TABLE fact_inventory (
    date DATE NOT NULL,
    drug_id INT NOT NULL,
    location_id INT NOT NULL,
    opening_stock INT NOT NULL,
    received_qty INT NOT NULL,
    dispensed_qty INT NOT NULL,
    closing_stock INT NOT NULL,
    stockout_flag TINYINT NOT NULL,
    PRIMARY KEY (date, drug_id, location_id)
);

CREATE TABLE fact_purchase_orders (
    po_id INT PRIMARY KEY,
    order_date DATE NOT NULL,
    drug_id INT NOT NULL,
    location_id INT NOT NULL,
    supplier_id INT NOT NULL,
    ordered_qty INT NOT NULL,
    received_qty INT NOT NULL,
    planned_lead_time INT NOT NULL,
    actual_lead_time INT NOT NULL,
    expected_date DATE NOT NULL,
    actual_date DATE NOT NULL,
    late_flag TINYINT NOT NULL
);

CREATE TABLE fact_expiry (
    batch_id INT PRIMARY KEY,
    drug_id INT NOT NULL,
    location_id INT NOT NULL,
    expiry_date DATE NOT NULL,
    quantity INT NOT NULL,
    inventory_value DECIMAL(12,2) NOT NULL
);
