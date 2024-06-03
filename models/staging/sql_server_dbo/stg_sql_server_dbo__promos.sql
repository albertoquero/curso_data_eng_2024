with 

src_promos  as (

    select * from {{ source('sql_server_dbo', 'promos') }}

),

renamed as (
SELECT
    promo_id
    , name_promo
    , total_discount_usd
    , status_promo
    , date_load
    FROM src_promos

)

select * from renamed
