{{
  config(
    materialized='incremental'
  )
}}

with source as (

    select * from {{ source('sql_server_dbo', 'order_items') }}

    {% if is_incremental() %}
    where _fivetran_synced > (select max(_fivetran_synced) from {{ this }} )
    {% endif %}
),

renamed as (
    select
          order_id
        , product_id
        , quantity
        , _fivetran_synced AS date_load
    from source
)

select * from renamed
