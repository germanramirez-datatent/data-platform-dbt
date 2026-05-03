with daily as (
    select
        center_id,
        event_date,
        day_of_week,
        is_holiday,
        is_adverse_weather,
        sum(visitors_count)     as daily_visitors,
        avg(temperature_c)      as avg_temperature_c,
        max(case when is_rainy then 1 else 0 end) as had_rain
    from {{ ref('int_traffic_with_context') }}
    group by
        center_id,
        event_date,
        day_of_week,
        is_holiday,
        is_adverse_weather
),

weekly as (
    select
        center_id,
        date_trunc('week', event_date)              as week_start,
        year(event_date)                            as year,
        week(event_date)                            as week_of_year,
        sum(daily_visitors)                         as weekly_visitors,
        avg(daily_visitors)                         as avg_daily_visitors,
        avg(avg_temperature_c)                      as avg_temperature_c,
        sum(had_rain)                               as rainy_days,
        sum(case when is_holiday then 1 else 0 end) as holiday_days,
        count(*)                                    as days_with_data
    from daily
    group by
        center_id,
        date_trunc('week', event_date),
        year(event_date),
        week(event_date)
),

scored as (
    select
        *,
        -- 0-100 score: low-traffic weeks are ideal for works
        -- logic: invert normalized traffic between the center's min and max
        round(
            100.0 * (1.0 - (
                (weekly_visitors - min(weekly_visitors) over (partition by center_id))
                / nullif(
                    max(weekly_visitors) over (partition by center_id)
                    - min(weekly_visitors) over (partition by center_id),
                  0)
            )),
        1)                                          as works_suitability_score
    from weekly
)

select * from scored
order by week_start
