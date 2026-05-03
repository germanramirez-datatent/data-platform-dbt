with source as (
    select * from {{ source('curated', 'holidays') }}
),

renamed as (
    select
        event_date,
        country_code,
        local_name,
        name            as holiday_name_en,
        is_fixed,
        is_global,
        launch_year,
        holiday_types,
        ingest_date
    from source
)

select * from renamed