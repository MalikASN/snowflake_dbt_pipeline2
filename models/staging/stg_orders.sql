{{ config(materialized='view') }}

WITH raw_orders AS (
    SELECT * FROM {{ source('brazil', 'orders') }}
)

SELECT 
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp AS purchased_at,
    order_approved_at  AS approved_at,
    order_delivered_carrier_date AS delivered_to_carrier_at,
    order_delivered_customer_date AS delivered_to_customer_at,
    order_estimated_delivery_date AS estimated_delivery_at,

    CASE WHEN order_delivered_carrier_date IS NOT NULL THEN TRUE ELSE FALSE END AS is_delivered_to_carrier,
    CASE WHEN order_delivered_customer_date IS NOT NULL THEN TRUE ELSE FALSE END AS is_delivered_to_customer,
    DATEDIFF(day, order_purchase_timestamp::TIMESTAMP, order_delivered_customer_date::TIMESTAMP) AS days_to_deliver


FROM raw_orders