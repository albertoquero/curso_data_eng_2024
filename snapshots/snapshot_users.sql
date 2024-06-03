{% snapshot snapshot_users %}

{{
    config(
      unique_key='user_id',
      strategy='timestamp',
      updated_at='_fivetran_synced',
    )
}}

with src_users as (
    select * from {{ source('sql_server_dbo', 'users') }}

    {% if is_incremental() %}
    where _fivetran_synced > (select max(date_load) from {{ this }} )
    {% endif %}
),

renamed as (
    select
        user_id,
        updated_at AS updated_at_utc,
        address_id,
        last_name,
        created_at AS created_at_utc,
        phone_number,
        total_orders,
        first_name,
        email,
        _fivetran_synced as date_load
    from src_users

)

select * from renamed

{% endsnapshot %}