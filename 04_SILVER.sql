USE WAREHOUSE WH_SALES_ANALYTICS_2026;
USE DATABASE DB_SALES_2026;

CREATE SCHEMA IF NOT EXISTS SILVER;

CREATE OR REPLACE TABLE DB_SALES_2026.SILVER.SUPERSTORE (
    row_id            INTEGER         NOT NULL,
    order_id          VARCHAR(20)     NOT NULL,
    order_date        DATE            NOT NULL,
    ship_date         DATE            NOT NULL,
    ship_mode         VARCHAR(50)     NOT NULL,
    customer_id       VARCHAR(20)     NOT NULL,
    customer_name     VARCHAR(100)    NOT NULL,
    segment           VARCHAR(50)     NOT NULL,
    country_region    VARCHAR(100)    NOT NULL,
    city              VARCHAR(100)    NOT NULL,
    state_province    VARCHAR(100)    NOT NULL,
    postal_code       VARCHAR(10),
    region            VARCHAR(50)     NOT NULL,
    product_id        VARCHAR(20)     NOT NULL,
    category          VARCHAR(50)     NOT NULL,
    sub_category      VARCHAR(50)     NOT NULL,
    product_name      VARCHAR(500)    NOT NULL,
    sales             NUMBER(10,4)    NOT NULL,
    quantity          NUMBER(4,0)     NOT NULL,
    discount          NUMBER(3,2)     NOT NULL,
    profit            NUMBER(12,4)    NOT NULL,
    _loaded_at        TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),
    _source_file      VARCHAR(200),
    CONSTRAINT pk_superstore PRIMARY KEY (order_id, product_id)
)



INSERT INTO DB_SALES_2026.SILVER.SUPERSTORE (
    row_id, order_id, order_date, ship_date, ship_mode,
    customer_id, customer_name, segment, country_region, city,
    state_province, postal_code, region, product_id, category,
    sub_category, product_name, sales, quantity, discount, profit,
    _source_file
)
SELECT
    "Row ID",
    TRIM("Order ID"),
    TO_DATE("Order Date", 'DD/MM/YYYY'),
    TO_DATE("Ship Date", 'DD/MM/YYYY'),
    TRIM("Ship Mode"),
    TRIM("Customer ID"),
    TRIM("Customer Name"),
    TRIM("Segment"),
    TRIM("Country/Region"),
    TRIM("City"),
    TRIM("State/Province"),
    TRIM("Postal Code"),
    TRIM("Region"),
    TRIM("Product ID"),
    TRIM("Category"),
    TRIM("Sub-Category"),
    TRIM("Product Name"),
    "Sales",
    "Quantity",
    "Discount",
    "Profit",
    '01_superstore.csv'
FROM DB_SALES_2026.PUBLIC.RAW_SUPERSTORE;


SELECT *
FROM DB_SALES_2026.SILVER.SUPERSTORE
LIMIT 10;

DESC TABLE DB_SALES_2026.SILVER.SUPERSTORE


SELECT
    COUNT(*)                                      AS total_filas,
    COUNT(DISTINCT order_id || '-' || product_id) AS combinaciones_unicas
FROM DB_SALES_2026.SILVER.SUPERSTORE;



SELECT order_id, product_id, COUNT(*) AS repeticiones
FROM DB_SALES_2026.SILVER.SUPERSTORE
GROUP BY order_id, product_id
HAVING COUNT(*) > 1
ORDER BY repeticiones DESC;


SELECT *
FROM DB_SALES_2026.SILVER.SUPERSTORE
WHERE (order_id, product_id) IN (
    ('US-2025-129714', 'OFF-PA-10001970'),
    ('CA-2023-123625', 'OFF-FA-10000089'),
    ('US-2025-123750', 'TEC-AC-10004659'),
    ('US-2026-118017', 'TEC-AC-10002006'),
    ('CA-2023-123625', 'FUR-FU-10004093'),
    ('US-2024-103135', 'OFF-BI-10000069'),
    ('US-2025-137043', 'FUR-FU-10003664'),
    ('US-2026-152912', 'OFF-ST-10003208'),
    ('US-2025-140571', 'OFF-PA-10001954')
)
ORDER BY order_id, product_id, row_id;



ALTER TABLE DB_SALES_2026.SILVER.SUPERSTORE
DROP CONSTRAINT pk_superstore;

ALTER TABLE DB_SALES_2026.SILVER.SUPERSTORE
ADD CONSTRAINT pk_superstore PRIMARY KEY (row_id);






ALTER TABLE DB_SALES_2026.SILVER.SUPERSTORE
SET COMMENT = 'Grano: una fila por línea de pedido (line item). Un mismo producto puede aparecer más de una vez en la misma orden como líneas separadas (ej. distinta cantidad capturada por separado). La PK real es row_id.';
