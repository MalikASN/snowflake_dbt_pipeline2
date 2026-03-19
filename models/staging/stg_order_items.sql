{{ config(materialized='view') }}

WITH raw_order_items AS (
    SELECT * FROM {{ source('brazil', 'order_items') }}
)

SELECT * FROM raw_order_items