{{
  config(
    materialized='view'
  )
}}

WITH src_budget AS (
    SELECT * 
    FROM {{ source('google_sheets', 'budget') }}
    ),

renamed_casted AS (
    SELECT
          _row
        , product_id
        , quantity
        , month
        ,  '{{ var('budget_date')}}' AS date_load
    FROM src_budget
    )

SELECT * FROM renamed_casted