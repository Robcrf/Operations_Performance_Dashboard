📊 Synthetic Operational Data Generator (Python)
Overview

This Python script generates synthetic operational data in CSV format for Sales, Production, and Inventory domains.
The generated datasets are designed to support:

Data analytics projects

Power BI dashboards

Star Schema modeling

KPI development and testing

Supply Chain & Manufacturing analytics

The output files simulate realistic business scenarios using controlled randomness and fake but coherent dates.

📁 Output Files

The script generates the following CSV files:

ventas.csv → Sales transactions

produccion.csv → Production output and scrap

inventario.csv → Inventory stock by warehouse

🛠️ Libraries Used and Justification
import csv
import random
from faker import Faker
from datetime import timedelta

Why these libraries were used:
Library	Purpose
csv	Writes structured tabular data into CSV files compatible with Excel, Power BI, and databases
random	Generates variability in quantities, prices, stock levels, and scrap
Faker	Creates realistic dates to simulate real business timelines
datetime.timedelta	Calculates delivery dates based on order dates
⚙️ Script Inputs
num_rows = int(input("Enter number of sales rows to generate: "))


Allows the user to dynamically control the volume of sales data

Makes the script reusable for small or large datasets

🧱 Master Data Definition
Customers
customers = [
    "Cliente Automotriz A",
    "Cliente Construccion B",
    "Cliente Industrial C",
    "Cliente Exportacion D"
]

Products
products = [
    "Vidrio Templado",
    "Vidrio Laminado",
    "Vidrio Flotado"
]

Warehouses
warehouses = [
    "Planta Monterrey",
    "Planta Toluca",
    "Planta Queretaro"
]


Purpose:

Acts as dimension-like master data

Ensures consistency across Sales, Production, and Inventory datasets

Supports future Star Schema relationships

1️⃣ Sales Data Generation (ventas.csv)
Structure
Column	Description
order_id	Unique order identifier
customer	Customer name
product	Product sold
quantity	Units sold
unit_price	Price per unit
order_date	Date when the order was placed
delivery_date	Date when the order was delivered
total_sales	Quantity × Unit Price
Key Logic

Random order quantities and prices

Order dates within the last year

Delivery dates calculated using timedelta

total_sales calculated at row level to simplify BI calculations

2️⃣ Production Data Generation (produccion.csv)
Structure
Column	Description
production_id	Production batch identifier
product	Product manufactured
production_date	Production date
units_produced	Total units produced
scrap_units	Defective or wasted units
Key Logic

Weekly production simulated (52 cycles)

Production volume varies per product

Scrap calculated as 2%–8% of total production

Enables efficiency and quality KPIs

3️⃣ Inventory Data Generation (inventario.csv)
Structure
Column	Description
product	Product stored
warehouse	Storage location
stock_units	Units currently in stock
last_update	Last inventory update date
Key Logic

Inventory generated per product–warehouse combination

Stock levels randomized to simulate overstock and shortages

Dates limited to the last 30 days (snapshot-style inventory)

🧩 Data Modeling Intent

This script supports a Star Schema analytical model:

Fact Tables

Sales → ventas.csv

Production → produccion.csv

Inventory → inventario.csv

Dimensions (implicit)

Product

Customer

Date

Warehouse

The data is optimized for:

Power BI

SQL-based analytics

KPI calculations

Supply Chain dashboards

✅ Execution Output
CSV files generated successfully:
- ventas.csv
- produccion.csv
- inventario.csv


Confirms successful data generation.

🚀 Use Cases

Power BI dashboard prototyping

KPI formula validation

SQL practice with fact/dimension tables

Supply Chain & Manufacturing analytics simulations

Interview or portfolio projects

📌 Notes

Data is synthetic and non-sensitive

Fully reusable and scalable

Easy to extend with additional dimensions or fact tables

If you want, next I can:

🔹 Add primary/foreign keys for full Star Schema

🔹 Convert this into a Python package

🔹 Add unit tests

🔹 Create a Power BI-ready data model

🔹 Document KPIs linked to this data


---


🧱 Data Warehouse & Star Schema Implementation (SQL)
Overview

This document explains the SQL implementation of a Data Warehouse (DWH) using a layered architecture and a Star Schema model.

The objective of this setup is to:

Ingest raw CSV data

Separate raw and analytics layers

Prepare clean analytical views

Build dimension and fact tables

Enable KPI calculations and BI consumption (Power BI, Tableau, etc.)

🗄️ Database Initialization
CREATE DATABASE IF NOT EXISTS DWH;
USE DATABASE DWH;

Purpose

Creates a dedicated Data Warehouse database

Ensures isolation from transactional systems

Centralizes analytical data

🧩 Schema (Layer) Design
CREATE SCHEMA IF NOT EXISTS RAW;
CREATE SCHEMA IF NOT EXISTS ANALYTICS;

Purpose

Implements a layered architecture:

Schema	Purpose
RAW	Stores raw, untransformed data exactly as received
ANALYTICS	Contains cleaned, modeled, and analytics-ready data

This separation:

Improves data governance

Enables traceability

Simplifies debugging and reprocessing

📥 RAW Layer – Table Creation
Sales Table
CREATE OR REPLACE TABLE ventas (...)


Objective

Stores raw sales transactions

Mirrors the CSV structure without transformations

Production Table
CREATE OR REPLACE TABLE produccion (...)


Objective

Stores raw production output

Includes total units and scrap for quality analysis

Inventory Table
CREATE OR REPLACE TABLE inventario (...)


Objective

Stores current inventory snapshots

Enables stock and warehouse-level analysis

📂 External Stage for CSV Loading
CREATE OR REPLACE STAGE csv_stage;

Purpose

Defines a staging area to load external CSV files

Acts as the ingestion entry point into Snowflake

⬆️ Data Ingestion (COPY INTO)
COPY INTO RAW.ventas FROM @RAW.csv_stage/ventas.csv;

Purpose

Loads CSV data into RAW tables

SKIP_HEADER = 1 avoids column headers

No transformations applied (ELT approach)

This is repeated for:

produccion.csv

inventario.csv

🔍 Data Validation Queries
SELECT * FROM RAW.ventas LIMIT 5;

Purpose

Verifies successful data ingestion

Confirms schema and data types

Prevents downstream modeling errors

📊 ANALYTICS Layer – Base Views
Sales View
CREATE OR REPLACE VIEW ANALYTICS.vw_sales AS ...


Objective

Abstracts raw tables

Provides a stable interface for analytics

Simplifies future transformations without touching RAW data

Same logic applies to:

vw_production

vw_inventory

⭐ Star Schema Design

The Star Schema separates dimensions (descriptive data) from facts (measurable events).

🧱 Dimension Tables
DIM_PRODUCT
CREATE OR REPLACE TABLE ANALYTICS.dim_product AS ...


Objective

Centralizes product master data

Ensures consistency across Sales, Production, and Inventory

Uses UNION to capture all existing products

DIM_CUSTOMER
CREATE OR REPLACE TABLE ANALYTICS.dim_customer AS ...


Objective

Stores unique customers

Used for customer-based analytics and segmentation

DIM_DATE
CREATE OR REPLACE TABLE ANALYTICS.dim_date AS ...


Objective

Central date dimension for time-based analysis

Supports:

Year

Month

Week

Day

This enables:

Time intelligence

Trend analysis

KPI aggregation by period

DIM_WAREHOUSE
CREATE OR REPLACE TABLE ANALYTICS.dim_warehouse AS ...


Objective

Centralizes warehouse locations

Supports inventory distribution analysis

📦 Fact Tables (Analytical Core)
FACT_SALES
CREATE OR REPLACE VIEW ANALYTICS.fact_sales AS ...


Objective

Stores measurable sales events

Connects to:

dim_customer

dim_product

dim_date

Key Feature

DATEDIFF(day, order_date, delivery_date) AS delivery_days


Pre-calculates delivery time

Improves BI performance

Simplifies KPI logic

FACT_PRODUCTION
CREATE OR REPLACE VIEW ANALYTICS.fact_production AS ...


Objective

Stores production metrics

Enables:

Output analysis

Scrap analysis

Efficiency KPIs

FACT_INVENTORY
CREATE OR REPLACE VIEW ANALYTICS.fact_inventory AS ...


Objective

Stores inventory levels

Connects products with warehouses and dates

Supports stock, coverage, and turnover KPIs


🧠 Architectural Summary

ELT approach (Load first, transform later)

Layered architecture (RAW → ANALYTICS)

Star Schema modeling

BI-optimized fact views

Scalable and maintainable design

🚀 Intended Use Cases

Power BI dashboards

KPI frameworks

Supply Chain analytics

Manufacturing performance analysis

Data Engineering portfolios

📌 Notes

Views are used for flexibility and performance

Can be extended with surrogate keys

Ready for incremental loads and automation


---

# 📊 Operational Performance Dashboard

## KPI Formula Dictionary (Star Schema – Power BI)

This repository documents the **15 core KPIs** used in the **Operational Performance Dashboard**, designed under a **Star Schema data model** and consumed in **Power BI**.

All KPIs are calculated from **fact tables** and filtered via **dimension tables**, ensuring:

* Scalability
* High performance
* Analytical consistency

---

## ⭐ KPI MASTER TABLE (15 KPIs)

| #  | KPI Name                     | Technical Name            | KPI Type                 | Fact Table        | Dimension(s)            | Objective                                                                       | DAX Formula                                                                                                              |
| -- | ---------------------------- | ------------------------- | ------------------------ | ----------------- | ----------------------- | ------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| 1  | 💰 Total Sales               | `Total_Sales`             | Financial                | `fact_sales`      | Date, Product, Customer | Measures total revenue generated by finished goods sold in the selected period. | `SUM(fact_sales[total_sales])`                                                                                           |
| 2  | 🧾 Total Orders              | `Total_Orders`            | Operational              | `fact_sales`      | Date, Customer          | Counts unique customer orders processed.                                        | `DISTINCTCOUNT(fact_sales[order_id])`                                                                                    |
| 3  | 👥 Active Customers          | `Active_Customers`        | Customer                 | `fact_sales`      | Customer                | Counts customers with at least one purchase in the period.                      | `DISTINCTCOUNT(fact_sales[customer_key])`                                                                                |
| 4  | 🎟️ Average Ticket           | `Average_Ticket`          | Financial                | Derived           | —                       | Measures average revenue per order.                                             | `DIVIDE([Total_Sales], [Total_Orders])`                                                                                  |
| 5  | 📦 Sales by Product          | `Sales_By_Product`        | Financial                | `fact_sales`      | Product                 | Identifies products generating the highest revenue.                             | `SUM(fact_sales[total_sales])`                                                                                           |
| 6  | 🏭 Total Units Produced      | `Total_Units_Produced`    | Production               | `fact_production` | Date, Product           | Measures total manufactured units (good + scrap).                               | `SUM(fact_production[units_produced])`                                                                                   |
| 7  | ♻️ Total Scrap               | `Total_Scrap`             | Quality                  | `fact_production` | Date, Product           | Measures defective or wasted production units.                                  | `SUM(fact_production[scrap_units])`                                                                                      |
| 8  | ⚙️ Production Efficiency (%) | `Production_Efficiency`   | Quality / Efficiency     | `fact_production` | Date, Product           | Measures percentage of usable (non-scrap) production.                           | `DIVIDE(SUM(fact_production[units_produced]) - SUM(fact_production[scrap_units]), SUM(fact_production[units_produced]))` |
| 9  | 🧱 Production by Product     | `Production_By_Product`   | Production               | `fact_production` | Product                 | Shows products with highest production volume.                                  | `SUM(fact_production[units_produced])`                                                                                   |
| 10 | 📦 Total Stock               | `Total_Stock`             | Inventory                | `fact_inventory`  | Product, Warehouse      | Measures total finished goods inventory.                                        | `SUM(fact_inventory[stock_units])`                                                                                       |
| 11 | 🏷️ Stock by Product         | `Stock_By_Product`        | Inventory                | `fact_inventory`  | Product                 | Identifies overstock or shortages per product.                                  | `SUM(fact_inventory[stock_units])`                                                                                       |
| 12 | 🚨 Demand Score (Stock Risk) | `Demand_Score`            | Operational Risk         | Derived           | Product                 | Identifies products with high demand and low inventory.                         | `DIVIDE([Total_Sales], [Total_Stock])`                                                                                   |
| 13 | 📆 Inventory Coverage (Days) | `Inventory_Coverage_Days` | Supply Chain             | Sales + Inventory | Date                    | Estimates how many days inventory will last.                                    | `DIVIDE(SUM(fact_inventory[stock_units]), DIVIDE(SUM(fact_sales[quantity]), DISTINCTCOUNT(dim_date[date_value])))`       |
| 14 | 🔄 Inventory Turnover        | `Inventory_Turnover`      | Financial / Supply Chain | Derived           | —                       | Measures how efficiently inventory is sold and replenished.                     | `DIVIDE([Total_Sales], [Total_Stock])`                                                                                   |
| 15 | 🚚 Average Delivery Time     | `Average_Delivery_Time`   | Logistics                | `fact_sales`      | Date                    | Measures average days between order and delivery.                               | `AVERAGE(fact_sales[delivery_days])`                                                                                     |

---
