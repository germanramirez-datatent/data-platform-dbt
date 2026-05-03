with weekly as (
    select * from {{ ref('mart_traffic_weekly') }}
),

calendar as (
    select
        center_id,
        week_start,
        year,
        week_of_year,
        weekly_visitors,
        avg_daily_visitors,
        avg_temperature_c,
        rainy_days,
        holiday_days,
        days_with_data,
        works_suitability_score,

        -- works suitability classification
        case
            when works_suitability_score >= 75 then 'optimal'
            when works_suitability_score >= 50 then 'suitable'
            when works_suitability_score >= 25 then 'marginal'
            when works_suitability_score is not null then 'not_recommended'
            else 'insufficient_data'
        end                                         as works_recommendation,

        -- reasons that support the recommendation
        case
            when holiday_days >= 2              then true
            else false
        end                                         as has_multiple_holidays,

        case
            when rainy_days >= 3                then true
            else false
        end                                         as is_typically_rainy,

        case
            when avg_temperature_c >= 30        then true
            else false
        end                                         as is_typically_hot

    from weekly
)

select * from calendar
order by center_id, week_start
