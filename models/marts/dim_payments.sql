{{ config(materialized='incremental') }}

WITH payments AS (
    SELECT * FROM {{ ref('stg_payments') }}
)

select * from payments