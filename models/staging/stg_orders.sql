{{ config(materialized='view') }}

WITH raw_orders AS (
    SELECT * FROM {{ source('brazil', 'orders') }}
),

renamed AS (
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
)

SELECT *
FROM renamed
WHERE 
    -- On ne garde que les données dont les dates sont logiques
    -- Si une date est NULL, la condition est ignorée (ce qui est correct ici)
    NOT (delivered_to_carrier_at < approved_at) 
    AND NOT (delivered_to_customer_at < delivered_to_carrier_at)