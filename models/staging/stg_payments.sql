{{ config(materialized='view') }}

WITH raw_payments AS (
    SELECT * FROM {{ source('brazil', 'payments') }}
)


SELECT * FROM raw_payments WHERE PAYMENT_TYPE  = 'credit_card'