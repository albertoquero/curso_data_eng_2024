WITH dim_users AS (
    SELECT * 
    FROM {{ ref('stg_sql_server_dbo__users') }}
    ),

dim_addresses AS (
    SELECT * 
    FROM {{ ref('stg_sql_server_dbo__addresses') }}
    ),
dim_promos AS (
    SELECT * 
    FROM {{ ref('stg_sql_server_dbo__promos') }}
    ),
fact_orders AS (
    SELECT * 
    FROM {{ ref('stg_sql_server_dbo__orders') }}
    ),
stg_order_items AS (
    SELECT * 
    FROM {{ ref('stg_sql_server_dbo__order_items') }}
    ),
fact_orders_products AS (
    SELECT
        O.order_id 
        , O.user_id 
        , O.promo_id
        , O.address_id
        , OI.product_id
        , O.order_placed_date
        , OI.quantity
        , O.status
        , O._fivetran_synced 
    FROM fact_orders O
    LEFT JOIN stg_order_items OI
      ON O.order_id = OI.order_id
    ),
users_orders_agg AS (
    SELECT 
        user_id
        ,COUNT(o.order_id) AS total_number_orders
        ,SUM(o.order_total ) AS total_order_cost_usd
        ,SUM(o.shipping_cost ) AS total_shipping_cost_usd
        ,SUM(p.discount ) AS total_discount_usd
    FROM fact_orders O
    LEFT JOIN dim_promos P
    ON o.promo_id = p.promo_id
    GROUP BY 1
    ),
users_orders_products_agg AS (
    SELECT
        user_id
        , SUM (quantity) AS total_quantity_product
        , COUNT(DISTINCT product_id ) AS total_different_product_purchased
    FROM fact_orders_products
    GROUP BY 1
    ),    
agg_users_orders AS (
    SELECT 
        u.user_id
        ,u.first_name
        ,u.last_name
        ,u.email
        ,u.phone_number
        ,u.created_at
        ,u.updated_at
        ,a.address
        ,a.zipcode
        ,a.state
        ,a.country
        ,COALESCE(oa.total_number_orders,0) AS total_number_orders
        ,COALESCE(oa.total_order_cost_usd,0) AS total_order_cost_usd
        ,COALESCE(oa.total_shipping_cost_usd,0) AS total_shipping_cost_usd
        ,COALESCE(oa.total_discount_usd,0) AS total_discount_usd
        ,COALESCE(pa.total_quantity_product,0) AS total_quantity_product
        ,COALESCE(pa.total_different_product_purchased,0) AS total_different_product_purchased
    FROM dim_users U
    LEFT JOIN dim_addresses A
        ON u.address_id = a.address_id
    LEFT JOIN users_orders_agg OA
        ON U.user_id = OA.user_id
    LEFT JOIN users_orders_products_agg PA
        ON U.user_id = PA.user_id
    )

SELECT * FROM agg_users_orders