with base as (
    select
        center_id,
        event_timestamp,
        event_date,
        visitors_count,
        day_of_week,
        is_holiday,
        temperature_c,
        weather_condition_label,

        -- time slot
        hour(event_timestamp)                           as hour_of_day,
        case
            when hour(event_timestamp) between 9  and 11 then 'morning'
            when hour(event_timestamp) between 12 and 14 then 'midday'
            when hour(event_timestamp) between 15 and 17 then 'afternoon'
            when hour(event_timestamp) between 18 and 21 then 'evening'
            else 'off_hours'
        end                                             as time_slot,

        -- season
        case
            when month(event_date) in (12, 1, 2)  then 'winter'
            when month(event_date) in (3, 4, 5)   then 'spring'
            when month(event_date) in (6, 7, 8)   then 'summer'
            when month(event_date) in (9, 10, 11) then 'autumn'
        end                                             as season,

        -- day type
        case
            when is_holiday                        then 'holiday'
            when day_of_week in ('saturday',
                                 'sunday')         then 'weekend'
            else 'weekday'
        end                                             as day_type

    from {{ ref('int_traffic_with_context') }}
),

profile as (
    select
        center_id,
        time_slot,
        hour_of_day,
        day_type,
        season,

        count(*)                                        as data_points,
        sum(visitors_count)                             as total_visitors,
        round(avg(visitors_count), 0)                   as avg_visitors,
        max(visitors_count)                             as peak_visitors,
        min(visitors_count)                             as min_visitors

    from base
    group by
        center_id,
        time_slot,
        hour_of_day,
        day_type,
        season
)

select * from profile
order by center_id, hour_of_day, day_type, season
