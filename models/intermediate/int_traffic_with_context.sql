with traffic as (
    select * from {{ ref('stg_traffic_hourly') }}
),

weather as (
    select * from {{ ref('stg_weather_hourly') }}
),

holidays as (
    select * from {{ ref('stg_holidays') }}
),

joined as (
    select
        -- identifiers
        t.center_id,
        t.event_timestamp,
        t.event_date,

        -- traffic
        t.visitors_count,
        t.day_of_week,

        -- weather from the source table, which is more reliable than the simulation
        w.temperature_c,
        w.precipitation_mm,
        w.wind_speed_kmh,
        w.weather_code,
        w.weather_condition_label,
        w.is_rainy,
        w.is_extreme_heat,

        -- holidays
        case
            when h.event_date is not null then true
            else false
        end                     as is_holiday,
        h.local_name            as holiday_name,

        -- flag for days with an expected negative traffic impact
        case
            when w.is_rainy or w.is_extreme_heat then true
            else false
        end                     as is_adverse_weather

    from traffic t
    left join weather  w on t.event_timestamp = w.event_timestamp
    left join holidays h on t.event_date      = h.event_date
)

select * from joined
--run the CD pipeline