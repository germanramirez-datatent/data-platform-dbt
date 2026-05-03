with weekly as (
    select * from {{ ref('mart_traffic_weekly') }}
),

indexed as (
    select
        center_id,
        week_start,
        year,
        week_of_year,
        weekly_visitors,
        avg_daily_visitors,
        days_with_data,

        -- 0-100 index normalized against the center's historical maximum
        -- 100 = highest-traffic week, 0 = lowest-traffic week
        round(
            100.0 * weekly_visitors
            / nullif(max(weekly_visitors) over (partition by center_id), 0),
        1)                                          as seasonality_index,

        -- banded classification for easier business readability
        case
            when round(
                100.0 * weekly_visitors
                / nullif(max(weekly_visitors) over (partition by center_id), 0),
            1) >= 80                                then 'peak'
            when round(
                100.0 * weekly_visitors
                / nullif(max(weekly_visitors) over (partition by center_id), 0),
            1) >= 60                                then 'high'
            when round(
                100.0 * weekly_visitors
                / nullif(max(weekly_visitors) over (partition by center_id), 0),
            1) >= 40                                then 'medium'
            when round(
                100.0 * weekly_visitors
                / nullif(max(weekly_visitors) over (partition by center_id), 0),
            1) >= 20                                then 'low'
            else 'very_low'
        end                                         as traffic_band

    from weekly
)

select * from indexed
order by center_id, week_start
