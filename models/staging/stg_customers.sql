{{ config(materialized='view' ) }}

WITH raw_customers AS (
    SELECT * FROM {{ source('brazil', 'customers') }}
)

SELECT * FROM raw_customers