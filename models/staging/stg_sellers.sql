{{ config(materialized='view') }}

WITH raw_sellers AS (
    SELECT * FROM {{ source('brazil', 'sellers') }}
)

SELECT * FROM raw_sellers