SELECT order_id 
FROM {{ ref('stg_orders') }} so 
WHERE 
so.delivered_to_carrier_at IS NOT NULL AND 
so.delivered_to_customer_at IS NOT NULL AND
so.estimated_delivery_at IS NOT NULL AND
(so.delivered_to_carrier_at < so.approved_at OR
so.delivered_to_customer_at < so.delivered_to_carrier_at OR
so.estimated_delivery_at < so.delivered_to_customer_at)
