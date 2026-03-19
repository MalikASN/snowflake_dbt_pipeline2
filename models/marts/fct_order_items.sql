{{
  config(
    materialized='incremental',
    unique_key='order_item_id',
    on_schema_change='fail'
  )
}}

WITH order_items AS (
    SELECT * FROM {{ ref('stg_order_items') }}
),

orders AS  (
    SELECT * FROM {{ ref('stg_orders') }}
)

SELECT 
    order_items.order_item_id,
    order_items.order_id,          
    order_items.product_id, 
    order_items.seller_id,
    order_items.shipping_limit_date,
    order_items.price,
    order_items.freight_value,
    
    orders.customer_id,
    orders.approved_at,
    orders.purchased_at,
    orders.delivered_to_carrier_at,
    orders.delivered_to_customer_at,
    orders.estimated_delivery_at,
    orders.is_delivered_to_carrier,
    orders.is_delivered_to_customer,
    orders.days_to_deliver   
    
FROM order_items
LEFT JOIN orders 
    ON order_items.order_id = orders.order_id

{% if is_incremental() %}

  WHERE orders.purchased_at > (SELECT MAX(purchased_at) FROM {{ this }})

{% endif %}