with source as (
    select * from {{ source('curated', 'weather') }}
),

renamed as (
    select
        event_timestamp,
        event_date,
        temperature_c,
        precipitation_mm,
        wind_speed_kmh,
        weather_code,
        latitude,
        longitude,
        timezone,

        -- human-readable WMO code classification
        case
            when weather_code = 0               then 'clear'
            when weather_code between 1  and 3  then 'partly_cloudy'
            when weather_code between 45 and 48 then 'fog'
            when weather_code between 51 and 67 then 'rain'
            when weather_code between 71 and 77 then 'snow'
            when weather_code between 80 and 82 then 'showers'
            when weather_code between 95 and 99 then 'thunderstorm'
            else 'unknown'
        end as weather_condition_label,

        precipitation_mm >= 1.0 as is_rainy,
        temperature_c >= 35.0   as is_extreme_heat

    from source
)

select * from renamed
