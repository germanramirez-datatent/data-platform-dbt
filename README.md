# Data Platform dbt

dbt project for the analytics layer of the shopping center data platform. It reads curated datasets from AWS Glue Catalog through Athena and builds documented marts for operations, leasing, and seasonality analysis.

## What This Project Builds

The project follows a simple medallion-style structure:

- `models/staging`: one-to-one views over curated Glue tables for traffic, weather, holidays, and flights.
- `models/intermediate`: shared enrichment logic, currently `int_traffic_with_context`, which joins hourly traffic with weather and holiday context.
- `models/marts`: table materializations for business-facing analytics.

Main mart outputs:

- `mart_works_calendar`: weekly construction works recommendation calendar for center `EUR_MAD_001`.
- `mart_traffic_weekly`: weekly visitor aggregation with a normalized works suitability score.
- `mart_weather_impact`: day-of-week weather impact metrics for rain and extreme heat.
- `mart_visitor_profile`: visitor distribution by time slot, day type, and season.
- `mart_seasonality_index`: normalized weekly seasonality index and traffic banding.

## Sources

The project expects these Glue Catalog source tables in `awsdatacatalog.data-platform_dev_curated`:

- `traffic`
- `weather`
- `holidays`
- `flights`

These tables are produced by the ingestion and Glue transformation flow from the sibling repositories:

- `data-platform-images`
- `data-platform-workflows`
- `data-platform-infra`

## Requirements

- Python 3.11
- dbt Core `1.11.8`
- `dbt-athena-community` `1.10.0`
- AWS credentials with Athena, Glue Catalog, and S3 access
- Curated data available in the Glue Catalog

## Configuration

Copy or mount `profiles_template.yml` as your dbt profile. It is designed to be configured through environment variables:

| Variable | Purpose |
| --- | --- |
| `DBT_TARGET` | dbt target name. Defaults to `dev`. |
| `DBT_REGION` | AWS region. Defaults to `eu-west-1`. |
| `DBT_S3_STAGING_DIR` | S3 path for Athena query results. |
| `DBT_S3_DATA_DIR` | S3 path where dbt writes Athena-managed data. |
| `DBT_SCHEMA` | Glue/Athena schema for dbt models. |
| `DBT_WORK_GROUP` | Athena workgroup name. |
| `AWS_ACCESS_KEY_ID` | AWS access key used by Athena. |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key used by Athena. |

Example:

```bash
export DBT_REGION=eu-west-1
export DBT_S3_STAGING_DIR=s3://data-platform-dev-athena-results/query-results/
export DBT_S3_DATA_DIR=s3://data-platform-dev-curated/
export DBT_SCHEMA=data_platform_dev_curated
export DBT_WORK_GROUP=data-platform-dev-analytics
```

## Running Locally

Install dependencies:

```bash
pip install dbt-core==1.11.8 dbt-athena-community==1.10.0
cp profiles_template.yml profiles.yml
```

Run and test the project:

```bash
dbt debug --profiles-dir .
dbt run --profiles-dir .
dbt test --profiles-dir .
```

Run a focused model selection while developing:

```bash
dbt build --select mart_works_calendar --profiles-dir .
```

## Docker

The repository includes a dbt runner image that copies the project and installs the Athena adapter.

Build:

```bash
docker build -t dbt-runner:local .
```

Run:

```bash
docker run --rm \
  -e DBT_REGION \
  -e DBT_S3_STAGING_DIR \
  -e DBT_S3_DATA_DIR \
  -e DBT_SCHEMA \
  -e DBT_WORK_GROUP \
  -e DBT_TARGET=dev \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  dbt-runner:local
```

The Argo workflow template in `data-platform-workflows` runs:

```bash
dbt run --profiles-dir /root/.dbt && dbt test --profiles-dir /root/.dbt
```

after ingestion validation and Glue transformations complete.

## Project Layout

```text
.
|-- dbt_project.yml
|-- profiles_template.yml
|-- Dockerfile
`-- models
    |-- staging
    |-- intermediate
    `-- marts
```

## Notes

- Staging and intermediate models are materialized as views.
- Mart models are materialized as tables.
- Model and column documentation lives in the layer-specific YAML files.
- Tests cover key not-null, uniqueness, and accepted-value expectations used by the marts.
