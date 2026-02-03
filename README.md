# 📊 Synthetic Operational Data Generator & Data Warehouse Star Schema

## Overview

This repository provides a complete, end-to-end analytical foundation that combines **synthetic data generation in Python** with a **Data Warehouse implementation using a Star Schema model**.

The project simulates realistic **Sales, Production, and Inventory** operations and is designed to support:

- Data analytics projects  
- Power BI dashboards  
- Star Schema modeling  
- KPI development and validation  
- Supply Chain & Manufacturing analytics  
- Data Engineering and Analytics portfolios  

All data is synthetic, non-sensitive, and generated using controlled randomness to reflect realistic business behavior.

---

## High-Level Architecture

Python Generator → CSV Files → RAW Layer → ANALYTICS Layer → Star Schema → BI / KPIs


- **Data Generation:** Python  
- **Storage Format:** CSV  
- **Data Warehouse:** Snowflake-compatible SQL  
- **Modeling Approach:** ELT + Star Schema  
- **Consumption:** Power BI, SQL, BI tools  

---

## Python – Synthetic Operational Data Generator

### Purpose

The Python script generates synthetic operational data in CSV format for three core business domains:

- Sales
- Production
- Inventory

These datasets are coherent, reusable, and optimized for analytics and BI use cases.

---

## Generated Output Files

| File | Description |
|----|----|
| `ventas.csv` | Sales transactions |
| `produccion.csv` | Production output and scrap |
| `inventario.csv` | Inventory stock by warehouse |

---

## Libraries Used and Justification

| Library | Purpose |
|------|------|
| `csv` | Writes structured tabular data compatible with Excel, Power BI, and databases |
| `random` | Generates realistic variability in quantities, prices, stock levels, and scrap |
| `faker` | Creates realistic dates to simulate real business timelines |
| `datetime.timedelta` | Calculates delivery dates based on order dates |

---

## Script Input

```python
num_rows = int(input("Enter number of sales rows to generate: "))
```
This input allows the user to dynamically control the volume of generated sales data, making the script reusable for both small test datasets and large analytical datasets.

### Master Data Definitions
#### Customers
```python
customers = [
  "Cliente Automotriz A",
  "Cliente Construccion B",
  "Cliente Industrial C",
  "Cliente Exportacion D"
]
```
#### Products
```python
products = [
  "Vidrio Templado",
  "Vidrio Laminado",
  "Vidrio Flotado"
]
```
#### Warehouses
```python
warehouses = [
  "Planta Monterrey",
  "Planta Toluca",
  "Planta Queretaro"
]
```
### Purpose of Master Data
- Acts as dimension-like master data
- Ensures consistency across Sales, Production, and Inventory
- Enables future Star Schema relationships
- Supports dimensional modeling best practices

### Sales Data Generation – ventas.csv
#### Structure
| Column | Description |
|----|----|
| `order_id` | Unique order identifier |
| `customer` | Customer name |
| `product` | Product sold |
| `quantity` | Units sold |
| `unit_price` | Price per unit |
| `order_date` | Date when the order was placed |
| `delivery_date` | Date when the order was delivered |
| `total_sales` | Quantity × Unit Price |

#### Key Logic
- Random order quantities and prices
- Order dates generated within the last year
- Delivery dates calculated using `timedelta`
- `total_sales` calculated at row level to simplify BI calculations

### Production Data Generation – produccion.csv
#### Structure
| Column | Description |
|----|----|
| `production_id` | Production batch identifier |
| `product` | Product manufactured |
| `production_date` | Production date |
| `units_produced` | Total units produced |
| `scrap_units` | Defective or wasted units |

#### Key Logic
- Weekly production simulated (52 cycles)
- Production volume varies per product
- Scrap calculated between 2% and 8% of total production
- Enables efficiency, yield, and quality KPIs

### Inventory Data Generation – inventario.csv
#### Structure
| Column | Description |
|----|----|
| `product` | Product stored |
| `warehouse` | Storage location |
| `stock_units` | Units currently in stock |
| `last_update` | Last inventory update date |

#### Key Logic
- Inventory generated per product–warehouse combination
- Stock levels randomized to simulate overstock and shortages
- Dates limited to the last 30 days (snapshot-style inventory)

### Execution Output
After successful execution, the following CSV files are generated:

- `ventas.csv`
- `produccion.csv`
- `inventario.csv`

This confirms correct data generation and readiness for ingestion.

---

## Data Warehouse & Star Schema Implementation (SQL)

### Objective
The SQL implementation builds a Data Warehouse (DWH) using a layered architecture and a Star Schema model to:

- Ingest raw CSV data
- Separate raw and analytical layers
- Prepare clean, analytics-ready structures
- Enable KPI calculation and BI consumption

### Database Initialization
```sql
CREATE DATABASE IF NOT EXISTS DWH;
USE DATABASE DWH;
```
#### Purpose
- Creates a dedicated Data Warehouse
- Isolates analytical workloads from transactional systems
- Centralizes all analytical data

### Schema (Layer) Design
```sql
CREATE SCHEMA IF NOT EXISTS RAW;
CREATE SCHEMA IF NOT EXISTS ANALYTICS;
```
| Schema | Purpose |
|----|----|
| `RAW` | Stores raw, untransformed data exactly as received |
| `ANALYTICS` | Contains cleaned, modeled, analytics-ready data |

This layered approach improves governance, traceability, and maintainability.

### RAW Layer – Tables
#### Sales Table (RAW.ventas)
- Stores raw sales transactions
- Mirrors the CSV structure
- No transformations applied

#### Production Table (RAW.produccion)
- Stores production output and scrap
- Supports quality and efficiency analysis

#### Inventory Table (RAW.inventario)
- Stores inventory snapshots
- Enables stock and warehouse-level analysis

### External Stage for CSV Loading
```sql
CREATE OR REPLACE STAGE csv_stage;
```
#### Purpose
- Defines a staging area for external CSV files
- Acts as the ingestion entry point into Snowflake
- Supports an ELT approach

### Data Ingestion (COPY INTO)
```sql
COPY INTO RAW.ventas
FROM @RAW.csv_stage/ventas.csv;
```
- Loads CSV data into RAW tables
- `SKIP_HEADER = 1` avoids column headers
- No transformations applied

This process is repeated for:
- `produccion.csv`
- `inventario.csv`

### Data Validation
```sql
SELECT * FROM RAW.ventas LIMIT 5;
```
#### Purpose
- Verifies successful data ingestion
- Confirms schema and data integrity
- Prevents downstream modeling errors

### ANALYTICS Layer – Base Views
Base views abstract the RAW tables and provide a stable interface for analytics:

- `vw_sales`
- `vw_production`
- `vw_inventory`

These views simplify transformations and protect RAW data from direct consumption.

### Star Schema Design
The Star Schema separates dimensions (descriptive data) from facts (measurable events).

#### Dimension Tables
- **dim_product**: Centralizes product master data, ensures consistency.
- **dim_customer**: Stores unique customers for segmentation.
- **dim_date**: Central date dimension for time intelligence.
- **dim_warehouse**: Centralizes warehouse locations.

#### Fact Tables
- **fact_sales**: Stores sales events, connects to dimensions, pre-calculates lead time.
- **fact_production**: Stores production metrics for efficiency KPIs.
- **fact_inventory**: Stores inventory levels, connects to products and warehouses.

### Architectural Summary
- ELT methodology (Load first, transform later)
- Layered architecture (RAW → ANALYTICS)
- Star Schema modeling
- BI-optimized fact views
- Scalable and maintainable design

---

## Intended Use Cases
- Power BI dashboard prototyping
- KPI framework development
- SQL practice with fact and dimension tables
- Supply Chain analytics
- Manufacturing performance analysis
- Data Engineering and Analytics portfolios

---

## Notes
- All data is synthetic and non-sensitive
- Fully reusable and scalable
- Easily extendable with surrogate keys, incremental loads, and automation

---

## Possible Extensions
- Add primary and foreign keys for a full Star Schema
- Convert the Python script into a package
- Add unit tests
- Create a Power BI semantic model
- Document KPIs linked directly to fact tables

---

**📊 Designed for analytics. Built for learning. Ready for BI.**

Si quieres, el siguiente nivel sería:
- 🔥 **README con KPIs documentados (15–20 KPIs)**
- 🔥 **Estructura de proyecto tipo Data Engineer**
- 🔥 **Power BI model + DAX**
- 🔥 **Versión “enterprise-ready” para entrevistas**

Dime cuál y lo llevamos a nivel pro 🚀
