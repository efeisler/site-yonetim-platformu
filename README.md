# Site Management Platform (Site Yönetim Platformu)

A relational database design for managing a residential site / apartment complex (blocks, units, residents, dues, facility reservations, maintenance work orders, staff, and materials).

## Contents

- **`databasecreate.sql`** — SQL Server DDL script that creates the database and all tables, including primary/foreign keys and check constraints.
- **`databaseselect.sql`** — Example analytical queries demonstrating joins, subqueries, and aggregation over the schema.

## Domain Overview

The schema models a typical residential site management system:

- **Property structure**: `BLOK` (block/building) → `DAIRE` (unit), with `DAIRE_TIPI` (unit type) defining base dues.
- **Residents**: `SAKIN` (resident) linked to units through `IKAMET` (residency), with location reference via `IL_ILCE` (province/district).
- **Billing**: `FATURA` (invoice/dues), `GIDER_KALEMI` / `GIDER_TIPI` (expense line items and categories), and `TAHSILAT` / `ODEME_TIPI` (payments and payment methods).
- **Facilities**: `TESIS` (shared facilities such as pool/tennis court) and `TESIS_KULLANIM` (facility reservations/usage) tied to `KULLANICI` (system users).
- **Maintenance**: `IS_EMRI` (work orders), `COZUM` (resolutions) performed by `CALISAN` (staff), with `MALZEME` / `MALZEME_KULLANIMI` tracking materials consumed.
- **Feedback**: `DEGERLENDIRME` (ratings/reviews) for facilities or work orders.

## Example Queries

`databaseselect.sql` includes:

1. For each block, the resident(s) with the highest total outstanding dues balance in the current year.
2. Active residents who meet multiple facility-usage conditions (minimum reservation counts at specific facilities, plus having used every active facility at least once).

## Usage

Run against Microsoft SQL Server:

```sql
-- 1. Create the schema
:r databasecreate.sql

-- 2. Run example queries
:r databaseselect.sql
```
