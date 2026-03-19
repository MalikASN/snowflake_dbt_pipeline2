{{ config(materialized='incremental') }}

WITH customers AS (
    SELECT * FROM {{ ref('stg_customers') }}
)


SELECT *

FROM customers ;
