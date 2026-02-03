
-- Base de datos
CREATE DATABASE IF NOT EXISTS DWH;
USE DATABASE DWH;

-- Capas
CREATE SCHEMA IF NOT EXISTS RAW;
CREATE SCHEMA IF NOT EXISTS ANALYTICS;



USE SCHEMA RAW;

-- Ventas
CREATE OR REPLACE TABLE ventas (
    order_id INTEGER,
    customer STRING,
    product STRING,
    quantity INTEGER,
    unit_price FLOAT,
    order_date DATE,
    delivery_date DATE,
    total_sales FLOAT
);

-- Producción
CREATE OR REPLACE TABLE produccion (
    production_id STRING,
    product STRING,
    production_date DATE,
    units_produced INTEGER,
    scrap_units INTEGER
);


-- Inventario
CREATE OR REPLACE TABLE inventario (
    product STRING,
    warehouse STRING,
    stock_units INTEGER,
    last_update DATE
);



CREATE OR REPLACE STAGE csv_stage;


COPY INTO RAW.ventas
FROM @RAW.csv_stage/ventas.csv
FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1);

COPY INTO RAW.produccion
FROM @RAW.csv_stage/produccion.csv
FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1);

COPY INTO RAW.inventario
FROM @RAW.csv_stage/inventario.csv
FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1);


SELECT * FROM RAW.ventas LIMIT 5;

SELECT * FROM RAW.produccion LIMIT 5;

SELECT * FROM RAW.inventario LIMIT 5;



USE DATABASE DWH;
USE SCHEMA ANALYTICS;


CREATE OR REPLACE VIEW ANALYTICS.vw_sales AS
SELECT
    order_id,
    customer,
    product,
    quantity,
    unit_price,
    order_date,
    delivery_date,
    total_sales
FROM RAW.ventas;



CREATE OR REPLACE VIEW ANALYTICS.vw_production AS
SELECT
    production_id,
    product,
    production_date,
    units_produced,
    scrap_units
FROM RAW.produccion;



CREATE OR REPLACE VIEW ANALYTICS.vw_inventory AS
SELECT
    product,
    warehouse,
    stock_units,
    last_update
FROM RAW.inventario;




SELECT * FROM ANALYTICS.vw_sales LIMIT 5;

SELECT * FROM ANALYTICS.vw_production LIMIT 5;

SELECT * FROM ANALYTICS.vw_inventory LIMIT 5;


---- DO STAR SCHEMA ----

-- DIM PRODUCT
CREATE OR REPLACE TABLE ANALYTICS.dim_product AS
SELECT DISTINCT product
FROM RAW.ventas
UNION
SELECT DISTINCT product FROM RAW.produccion
UNION
SELECT DISTINCT product FROM RAW.inventario;

-- DIM CUSTOMER
CREATE OR REPLACE TABLE ANALYTICS.dim_customer AS
SELECT DISTINCT customer
FROM RAW.ventas;


--- DIM DATE
CREATE OR REPLACE TABLE ANALYTICS.dim_date AS
SELECT DISTINCT order_date AS date_value,
       YEAR(order_date) AS year,
       MONTH(order_date) AS month,
       DAY(order_date) AS day,
       WEEK(order_date) AS week
FROM RAW.ventas
UNION
SELECT DISTINCT production_date AS date_value,
       YEAR(production_date),
       MONTH(production_date),
       DAY(production_date),
       WEEK(production_date)
FROM RAW.produccion;

-- DIM WAREHOUSE
CREATE OR REPLACE TABLE ANALYTICS.dim_warehouse AS
SELECT DISTINCT warehouse
FROM RAW.inventario;


-- PREPARE FACT TABLE
--- FACT SALES

CREATE OR REPLACE VIEW ANALYTICS.fact_sales AS
SELECT
    order_id,
    customer AS customer_key,
    product AS product_key,
    order_date AS date_key,
    quantity,
    unit_price,
    total_sales,
    DATEDIFF(day, order_date, delivery_date) AS delivery_days
FROM RAW.ventas;



--- FACT PRODUCTION

CREATE OR REPLACE VIEW ANALYTICS.fact_production AS
SELECT
    production_id,
    product AS product_key,
    production_date AS date_key,
    units_produced,
    scrap_units
FROM RAW.produccion;


--FACT INVENTORY

CREATE OR REPLACE VIEW ANALYTICS.fact_inventory AS
SELECT
    product AS product_key,
    warehouse AS warehouse_key,
    stock_units,
    last_update AS date_key
FROM RAW.inventario;




