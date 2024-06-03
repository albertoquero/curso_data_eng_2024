{{
  config(
    materialized='incremental'
  )
}}

with source as (
    select * from {{ source('sql_server_dbo', 'orders') }}
    
    {% if is_incremental() %}
    where _fivetran_synced > (select max(_fivetran_synced) from {{ this }} )
    {% endif %}
),

renamed as (
    select
          order_id 
        , user_id 
        , promo_id
        , address_id
        , created_at AS created_at_utc
        , order_cost AS item_order_cost_usd
        , shipping_cost AS shipping_cost_usd
        , order_total AS total_order_cost_usd
        , tracking_id
        , shipping_service
        , estimated_delivery_at AS estimated_delivery_at_utc
        , delivered_at AS delivered_at_utc
        , status AS status_order
        , _fivetran_synced as date_load
    from source
)

select * from renamed
