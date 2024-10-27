-- Este snapshot es para checkear columnas cuando tengo muchas. Se propone usar una clave subrrogada
{% snapshot budget_snapshot_check_multiples %}

{{
    config(
      target_schema='snapshots',
      unique_key='_row',
      strategy='check',
      check_cols=['subrogate_key'],
        )
}}

select * from {{ ref('base_google_sheets__budget') }}

{% endsnapshot %}