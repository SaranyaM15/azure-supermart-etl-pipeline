CREATE TABLE dbo.supermart_sales
(
    order_id        VARCHAR(50) PRIMARY KEY,
    customer_name   VARCHAR(100),
    category        VARCHAR(100),
    sub_category    VARCHAR(100),
    city            VARCHAR(100),
    order_date      DATE,
    region          VARCHAR(50),
    sales           DECIMAL(12,2),
    discount        DECIMAL(10,2),
    profit          DECIMAL(12,2),
    state           VARCHAR(100)
);