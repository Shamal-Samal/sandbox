WITH orders AS 
(
    SELECT *
    FROM UK_DDW.FCT_SALES_ORDER_LINE
),
products AS 
(
        SELECT 
            a.D_PRODUCT_SK,
            b.D_PRODUCT_HISTORY_SK,
            a.PRODUCT_CODE,
            c.D_PRODUCT_INTERNAL_HIER_SK,
            a.PRODUCT_EFFECTIVE_DATE,
            TO_CHAR(a.PRODUCT_END_DATE,'DD-MON-RRRR') AS PRODUCT_END_DATE,
            a.CR_PRODUCT_STATUS,
            a.PRODUCT_NAME,
            a.ITEM_SIZE_QUANTITY,
            a.PROD_CONTROLLED_DRUG_SCHEDULE
        FROM UK_DDW.DIM_PRODUCT a
        JOIN UK_DDW.DIM_PRODUCT_HISTORY b
            ON a.D_PRODUCT_SK = b.D_PRODUCT_SK
        JOIN UK_DDW.DIM_PRODUCT_INTERNAL_HIER c
            ON c.D_PRODUCT_SK = a.D_PRODUCT_SK
        WHERE b.DPH_CURRENT_Y_NULL = 'Y'
        AND c.PIH_CURRENT_Y_NULL = 'Y'
),
customers AS 
(
        SELECT 
            c.D_CUSTOMER_SK,
            d.CUSTOMER_ACCOUNT_CODE,
            d.CUSTOMER_COMPANY_NAME,
            c.CUSTOMER_INVOICE_ADDR_LINE_1,
            c.CUSTOMER_INVOICE_ADDR_LINE_2,
            c.CUSTOMER_INVOICE_ADDR_LINE_3,
            c.CUSTOMER_INVOICE_ADDR_LINE_4,
            c.CUSTOMER_INVOICE_POSTCODE_ZIP,
            c.CUSTOMER_TELEPHONE_NUMBER,
            d.D_CUSTOMER_IDENT_HISTORY_SK
        FROM UK_DDW.DIM_CUSTOMER c
        JOIN UK_DDW.DIM_CUSTOMER_IDENT_HISTORY d
            ON c.D_CUSTOMER_SK = d.D_CUSTOMER_SK
        WHERE d.CIH_CURRENT_Y_NULL = 'Y'
),
suppliers AS
(
	SELECT g2.SUPPLIER_CODE
	      ,g2.SUPPLIER_NAME
	      ,g1.D_PRODUCT_SK
	      ,g1.d_primary_supplier_hier_sk
	FROM UK_DDW.DIM_SUPPLIER_PRIMARY_HIER g1
	      ,UK_DDW.DIM_SUPPLIER g2
	WHERE g1.PRIMARY_SUPPLIER_HIER_L2_CODE = g2.SUPPLIER_CODE
	AND g2.DS_CURRENT_Y_NULL = 'Y'
),
dates AS
(
	SELECT * 
	FROM UK_DDW.DIM_DATE
)
SELECT *
FROM orders
LEFT JOIN products ON products.d_product_sk = orders.d_product_sk
LEFT JOIN customers ON customers.d_customer_sk = orders.d_customer_sk
LEFT JOIN suppliers ON suppliers.d_primary_supplier_hier_sk = orders.d_primary_supplier_hier_sk
LEFT JOIN dates dates1 ON dates1.D_DATE_SK = orders.D_CUSTOMER_TRANSACTION_DATE_SK
LEFT JOIN dates dates2 ON dates2.D_DATE_SK = orders.D_BUS_PROC_DATE_SK
LEFT JOIN dates dates3 ON dates3.D_DATE_SK = orders.D_CUSTOMER_ORDER_DATE_SK
LEFT JOIN dates dates4 ON dates4.D_DATE_SK = orders.D_BILLING_DATE_SK
WHERE ROW_NUM <= 100;





