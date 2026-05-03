with base as (
    select
        center_id,
        event_date,
        day_of_week,
        sum(visitors_count)                             as daily_visitors,
        avg(temperature_c)                              as avg_temperature_c,
        avg(precipitation_mm)                           as avg_precipitation_mm,
        max(case when is_rainy        then 1 else 0 end) as had_rain,
        max(case when is_extreme_heat then 1 else 0 end) as had_extreme_heat,
        max(case when is_holiday      then 1 else 0 end) as is_holiday
    from {{ ref('int_traffic_with_context') }}
    group by center_id, event_date, day_of_week
),

averages as (
    select
        center_id,
        day_of_week,
        avg(case when had_rain = 0 and had_extreme_heat = 0
                 then daily_visitors end)               as avg_visitors_normal,
        avg(case when had_rain = 1
                 then daily_visitors end)               as avg_visitors_rainy,
        avg(case when had_extreme_heat = 1
                 then daily_visitors end)               as avg_visitors_extreme_heat
    from base
    group by center_id, day_of_week
)

select
    center_id,
    day_of_week,
    round(avg_visitors_normal,       0)                 as avg_visitors_normal,
    round(avg_visitors_rainy,        0)                 as avg_visitors_rainy,
    round(avg_visitors_extreme_heat, 0)                 as avg_visitors_extreme_heat,

    -- relative impact (% reduction vs normal day)
    round(
        100.0 * (avg_visitors_rainy - avg_visitors_normal)
        / nullif(avg_visitors_normal, 0),
    1)                                                  as rain_impact_pct,
    round(
        100.0 * (avg_visitors_extreme_heat - avg_visitors_normal)
        / nullif(avg_visitors_normal, 0),
    1)                                                  as heat_impact_pct

from averages
order by center_id, day_of_week
