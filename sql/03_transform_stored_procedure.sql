CREATE OR ALTER PROCEDURE dbo.usp_load_supermart_sales
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE dbo.supermart_sales;

    INSERT INTO dbo.supermart_sales
    (
        order_id,
        customer_name,
        category,
        sub_category,
        city,
        order_date,
        region,
        sales,
        discount,
        profit,
        state
    )
    SELECT
        LTRIM(RTRIM(order_id)),
        LTRIM(RTRIM(customer_name)),
        LTRIM(RTRIM(category)),
        LTRIM(RTRIM(sub_category)),
        LTRIM(RTRIM(city)),

        TRY_CONVERT(DATE, order_date, 110),

        LTRIM(RTRIM(region)),
        TRY_CAST(sales AS DECIMAL(12,2)),
        TRY_CAST(discount AS DECIMAL(10,2)),
        TRY_CAST(profit AS DECIMAL(12,2)),
        LTRIM(RTRIM(state))

    FROM dbo.stg_supermart_sales
    WHERE order_id IS NOT NULL;
END;
