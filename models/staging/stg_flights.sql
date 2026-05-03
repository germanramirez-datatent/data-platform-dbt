with source as (
    select * from {{ source('curated', 'flights') }}
),

renamed as (
    select
        -- identifiers
        icao24,
        trim(callsign) as callsign,
        origin_country,

        -- timestamps (unix epoch to readable timestamp)
        event_date,
        from_unixtime(snapshot_time) as snapshot_timestamp,
        from_unixtime(time_position) as position_timestamp,
        from_unixtime(last_contact)  as last_contact_timestamp,

        -- position
        latitude,
        longitude,
        baro_altitude,
        geo_altitude,
        on_ground,

        -- movement
        velocity,
        true_track,
        vertical_rate,

        -- transponder
        squawk,
        spi,
        position_source

    from source
)

select * from renamed
