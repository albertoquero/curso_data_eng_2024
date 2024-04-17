WITH conteo_tipo_eventos AS (
  
  SELECT session_id,user_id,event_type,count(event_type) conteos
    FROM  {{ ref('stg_sql_server_dbo__events') }}
    group by session_id,user_id,event_type
  
),pivotar_tipo_eventos as(
     SELECT *
    FROM conteo_tipo_eventos
        PIVOT(sum(conteos) FOR event_type IN ('checkout', 'package_shipped', 'add_to_cart', 'page_view'))
      AS p (SESSION_ID, USER_ID, checkout, package_shipped, add_to_cart,page_view)

)    
SELECT
          e.SESSION_ID
            ,e.user_id
            ,first_name
            ,email
            ,min(e.created_at) first_event_time
            ,max(e.created_at) last_event_time
            ,(DATEDIFF(DAY, MIN(e.created_at)::timestamp, max(e.created_at)::timestamp) * 24 +
            DATEDIFF(HOUR, MIN(e.created_at)::timestamp, max(e.created_at)::timestamp)) * 60 +
            DATEDIFF(MINUTE, MIN(e.created_at)::timestamp, max(e.created_at)::timestamp) AS session_length_minutes
            ,p.add_to_cart
            ,p.checkout
            ,p.package_shipped
            ,p.page_view
            
    FROM   {{ ref('stg_sql_server_dbo__events') }} e
    left join
     {{ ref('stg_sql_server_dbo__users') }} u
    on e.user_id = u.user_id
    left join 
    pivotar_tipo_eventos p
    on p.session_id=e.session_id and p.user_id=e.user_id
    group by e.session_id,e.user_id,first_name,email,p.add_to_cart
            ,p.checkout
            ,p.package_shipped
            ,p.page_view