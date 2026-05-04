-- models/staging/stg_traffic_hourly.sql
with source as (
    select * from {{ source('curated', 'traffic') }}
),

renamed as (
    select
        center_id,
        event_timestamp,
        event_date,
        visitors_count,
        day_of_week,
        is_holiday,
        weather_condition,
        temperature_c
    from source
)

select * from renamed
