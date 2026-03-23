# Brazil Orders dbt Pipeline

dbt project for transforming raw Brazil orders data in Snowflake into analytics-ready staging and mart models.

## 1) What this project does

- Ingests raw source tables from `BRAZIL_ORDERS.PUBLIC` via dbt `sources`.
- Builds a **staging layer** (cleaned, lightly standardized views).
- Builds a **mart layer** (incremental dimensions + fact table).
- Runs schema tests and a custom data quality test.
- Supports CI runs on pushes to the `dev` branch.

## 2) Tech stack

- dbt Core
- Adapter: `dbt-snowflake`
- Warehouse: Snowflake
- CI: GitHub Actions

## 3) Project structure

```text
brazil_orders_pipeline/
	dbt_project.yml
	profiles.yml
	models/
		staging/
			sources.yml
			schema.yml
			stg_customers.sql
			stg_orders.sql
			stg_order_items.sql
			stg_payments.sql
			stg_sellers.sql
		marts/
			schema.yml
			dim_customers.sql
			dim_sellers.sql
			dim_payments.sql
			fct_order_items.sql
	tests/
		assert_delivery_after_approval.sql
	.github/workflows/
		dbt_ci.yml
```

## 4) Data model overview

### Sources (raw)

Defined in `models/staging/sources.yml`:

- `orders`
- `order_items`
- `customers`
- `sellers`
- `payments`

### Staging models (views)

Configured as views in `dbt_project.yml`.

- `stg_customers`: customer source passthrough
- `stg_sellers`: seller source passthrough
- `stg_order_items`: order items source passthrough
- `stg_payments`: filtered to `payment_type = 'credit_card'`
- `stg_orders`: renamed timestamps + delivery flags + delivery duration (`days_to_deliver`), with date consistency filtering

### Mart models

Folder default in `dbt_project.yml` is `table`, but each mart model currently sets `materialized='incremental'`.

- `dim_customers`: customer dimension from `stg_customers`
- `dim_sellers`: seller dimension from `stg_sellers`
- `dim_payments`: payment dimension-like model from `stg_payments`
- `fct_order_items`: joins order items with order lifecycle attributes; incremental on `purchased_at`

## 5) Prerequisites

Install:

- Python 3.10+
- dbt Core + Snowflake adapter

```bash
pip install dbt-snowflake
```

## 6) Configuration

The project profile name is `brazil_orders_pipeline`.

`profiles.yml` expects these environment variables:

- `SNOWFLAKE_ACCOUNT`
- `SNOWFLAKE_USER`
- `SNOWFLAKE_PASSWORD`
- `SNOWFLAKE_ROLE`
- `SNOWFLAKE_WAREHOUSE`
- `SNOWFLAKE_DATABASE`
- `GITHUB_RUN_ID` (used for the CI schema name)

Target used in this repository: `ci`.

## 7) Local development workflow

From `brazil_orders_pipeline/`:

1. Install dependencies (if any package dependencies are added later):

```bash
dbt deps --profiles-dir .
```

2. Parse the project:

```bash
dbt parse --target ci --profiles-dir .
```

3. Build everything (models + tests):

```bash
dbt build --target ci --profiles-dir .
```

Useful selective runs:

```bash
dbt run --select staging --target ci --profiles-dir .
dbt run --select marts --target ci --profiles-dir .
dbt test --target ci --profiles-dir .
```

## 8) Tests and quality checks

This project includes:

- Standard schema tests in:
	- `models/staging/schema.yml`
	- `models/marts/schema.yml`
- Custom SQL test in:
	- `tests/assert_delivery_after_approval.sql`

The custom test is intended to catch impossible delivery timelines.

## 9) CI behavior

GitHub Actions workflow: `.github/workflows/dbt_ci.yml`

On every push to `dev`, CI will:

1. Checkout repository
2. Setup Python 3.10
3. Install `dbt-snowflake`
4. Run:

```bash
dbt deps --profiles-dir .
dbt build --target ci --profiles-dir .
```

Snowflake credentials are injected from GitHub secrets.

## 10) Common troubleshooting

### Profile not found / parse fails

- Ensure `profile` in `dbt_project.yml` is `brazil_orders_pipeline`.
- Ensure `profiles.yml` exists and is passed with `--profiles-dir .`.

### Snowflake authentication errors

- Verify all `SNOWFLAKE_*` environment variables are set.
- Validate role/warehouse/database permissions in Snowflake.

### Incremental model behavior

- If logic changes significantly, use:

```bash
dbt run --full-refresh --select marts --target ci --profiles-dir .
```

## 11) Helpful commands reference

```bash
dbt debug --target ci --profiles-dir .
dbt parse --target ci --profiles-dir .
dbt build --target ci --profiles-dir .
dbt docs generate --target ci --profiles-dir .
dbt docs serve
```

## 12) Documentation links

- dbt docs: https://docs.getdbt.com/docs/introduction
- dbt Snowflake setup: https://docs.getdbt.com/docs/core/connect-data-platform/snowflake-setup
