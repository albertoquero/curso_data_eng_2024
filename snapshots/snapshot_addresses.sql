{% snapshot snapshot_addresses %}

{{
    config(
      unique_key='address_id',
      strategy='timestamp',
      updated_at='_fivetran_synced',
    )
}}

with source as (
    select * from {{ source('sql_server_dbo', 'addresses') }}

    {% if is_incremental() %}
    where _fivetran_synced > (select max(date_load) from {{ this }} )
    {% endif %}
),

renamed as (

    select
        address_id,
        zipcode,
        country,
        address,
        state,
        _fivetran_synced AS date_load
    from source

)

select * from renamed

{% endsnapshot %}