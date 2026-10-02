# 🚀 Azure Supermart ETL Pipeline

> End-to-end batch ETL project built with **Azure Data Factory, Azure Data Lake Storage Gen2, Azure SQL Database, and SQL Stored Procedures**.

---

## 📌 Project Overview

This project demonstrates a practical Azure Data Engineering workflow using a retail sales dataset with **9,994 records**.

The pipeline ingests the source CSV into **ADLS Gen2**, preserves the original file in a **Raw** layer, loads the data into an **Azure SQL staging table**, transforms it through a reusable **stored procedure**, and writes clean analytics-ready data into a final SQL table.

### 🎯 Main Goals

- Build an end-to-end ETL pipeline from scratch
- Understand ADF Linked Services, Datasets, Pipelines, and Activities
- Implement Landing and Raw storage zones in ADLS Gen2
- Load structured CSV data into Azure SQL
- Use staging and final tables correctly
- Perform transformations with T-SQL stored procedures
- Validate row counts, nulls, duplicates, and data types
- Monitor and troubleshoot ADF pipeline runs

---

## 🏗️ Architecture

```text
Kaggle Retail CSV
        ↓
ADLS Gen2 - Landing
        ↓
Azure Data Factory
Copy_Landing_To_Raw
        ↓
ADLS Gen2 - Raw
        ↓
Azure Data Factory
Copy_Raw_To_SQL_Staging
        ↓
Azure SQL - Staging Table
        ↓
Stored Procedure
Transform_Supermart_Sales
        ↓
Azure SQL - Final Table
        ↓
Data Quality Validation
```

> Add the visual diagram here when available:

```markdown
![Architecture](architecture/architecture-diagram.png)
```

---

## ⚙️ Technology Stack

| Technology | Usage |
|---|---|
| **Azure Data Factory** | Orchestration and data movement |
| **Azure Data Lake Storage Gen2** | Landing and Raw storage |
| **Azure SQL Database** | Staging and final relational tables |
| **T-SQL** | Transformations and validation |
| **Stored Procedures** | Reusable SQL transformation logic |
| **CSV** | Source data format |
| **Git & GitHub** | Version control and portfolio documentation |
| **VS Code** | Local development |

---

## 📂 Repository Structure

```text
azure-supermart-etl-pipeline/
│
├── README.md
├── .gitignore
│
├── architecture/
│   ├── architecture-diagram.png
│   └── architecture-animation.gif
│
├── sql/
│   ├── 01_create_staging_table.sql
│   ├── 02_create_final_table.sql
│   ├── 03_transform_stored_procedure.sql
│   └── 04_validation_queries.sql
│
├── data/
│   └── sample_supermart_sales.csv
│
├── screenshots/
│   ├── 01-adls-landing.png
│   ├── 02-adls-raw.png
│   ├── 03-adf-pipeline.png
│   ├── 04-adf-monitor-success.png
│   └── 05-sql-validation.png
│
└── docs/
    └── project-notes.md
```

---

## 📊 Dataset

The project uses the **Supermart Grocery Sales** retail dataset.

### Source Columns

```text
Order ID
Customer Name
Category
Sub Category
City
Order Date
Region
Sales
Discount
Profit
State
```

### Dataset Profile

```text
Rows    : 9,994
Columns : 11
```

A small sample can be stored in:

```text
data/sample_supermart_sales.csv
```

> ⚠️ The full dataset does not need to be committed to GitHub. A small sample is enough to demonstrate the schema.

---

## 🔄 ETL Workflow

### 1️⃣ Landing Zone

The source file is uploaded to ADLS Gen2:

```text
supermart-data/
└── landing/
    └── sales/
        └── supermart_sales.csv
```

The Landing layer represents the location where source data first arrives.

---

### 2️⃣ Landing → Raw

ADF activity:

```text
Copy_Landing_To_Raw
```

moves the source file into:

```text
supermart-data/
└── raw/
    └── sales/
        └── supermart_sales.csv
```

The Raw layer keeps an unchanged copy of the source for traceability and reprocessing.

---

### 3️⃣ Raw → SQL Staging

ADF activity:

```text
Copy_Raw_To_SQL_Staging
```

reads the CSV as structured rows and loads the data into:

```text
dbo.stg_supermart_sales
```

### Source-to-Target Mapping

| Source CSV | SQL Staging |
|---|---|
| Order ID | order_id |
| Customer Name | customer_name |
| Category | category |
| Sub Category | sub_category |
| City | city |
| Order Date | order_date |
| Region | region |
| Sales | sales |
| Discount | discount |
| Profit | profit |
| State | state |

A pre-copy script clears the staging table before each full load:

```sql
TRUNCATE TABLE dbo.stg_supermart_sales;
```

---

## 🗃️ SQL Staging Table

```sql
CREATE TABLE dbo.stg_supermart_sales
(
    order_id        VARCHAR(50),
    customer_name   VARCHAR(150),
    category        VARCHAR(100),
    sub_category    VARCHAR(100),
    city            VARCHAR(100),
    order_date      VARCHAR(50),
    region          VARCHAR(50),
    sales           VARCHAR(50),
    discount        VARCHAR(50),
    profit          VARCHAR(50),
    state           VARCHAR(100)
);
```

### Why use staging?

The staging table helps:

- Load source-shaped data safely
- Separate ingestion from transformation
- Inspect malformed values before strict conversion
- Simplify troubleshooting
- Support repeatable ETL processing

---

## ✅ Final Clean Table

```sql
CREATE TABLE dbo.supermart_sales
(
    order_id        VARCHAR(50) PRIMARY KEY,
    customer_name   VARCHAR(150) NOT NULL,
    category        VARCHAR(100),
    sub_category    VARCHAR(100),
    city            VARCHAR(100),
    order_date      DATE,
    region          VARCHAR(50),
    sales           DECIMAL(12,2),
    discount        DECIMAL(10,2),
    profit          DECIMAL(12,2),
    state           VARCHAR(100)
);
```

The final table stores clean, strongly typed, analytics-ready data.

---

## 🧹 Transformation Logic

ADF executes:

```text
dbo.usp_load_supermart_sales
```

through the activity:

```text
Transform_Supermart_Sales
```

The procedure performs:

- Trimming
- Date conversion
- Numeric conversion
- Source-to-target transformation
- Final-table refresh

Examples:

```sql
TRY_CONVERT(DATE, order_date, 110)
```

```sql
TRY_CAST(sales AS DECIMAL(12,2))
```

```sql
TRY_CAST(discount AS DECIMAL(10,2))
```

```sql
TRY_CAST(profit AS DECIMAL(12,2))
```

---

## 🧩 ADF Pipeline

The complete pipeline contains three sequential activities:

```text
Copy_Landing_To_Raw
        ↓
Copy_Raw_To_SQL_Staging
        ↓
Transform_Supermart_Sales
```

| Activity | Responsibility |
|---|---|
| `Copy_Landing_To_Raw` | Preserve source data in Raw |
| `Copy_Raw_To_SQL_Staging` | Load structured CSV data into SQL staging |
| `Transform_Supermart_Sales` | Execute SQL transformation procedure |

All activities use **success dependencies**, so downstream processing starts only after the previous step succeeds.

---

## 🔁 Full-Load Pattern

This version uses a **full refresh** strategy.

```text
Run 1 → 9,994 rows
Run 2 → 9,994 rows
Run 3 → 9,994 rows
```

The pipeline avoids duplicate accumulation by truncating staging before loading and refreshing the final table during transformation.

---

## 🔍 Data Quality & Reconciliation

### Row Count Validation

```sql
SELECT COUNT(*) AS staging_rows
FROM dbo.stg_supermart_sales;

SELECT COUNT(*) AS final_rows
FROM dbo.supermart_sales;
```

Expected:

```text
Staging Rows : 9,994
Final Rows   : 9,994
```

### Null Validation

```sql
SELECT *
FROM dbo.supermart_sales
WHERE order_date IS NULL
   OR sales IS NULL
   OR discount IS NULL
   OR profit IS NULL;
```

Expected:

```text
0 invalid rows
```

### Duplicate Validation

```sql
SELECT
    order_id,
    COUNT(*) AS record_count
FROM dbo.supermart_sales
GROUP BY order_id
HAVING COUNT(*) > 1;
```

Expected:

```text
0 duplicate Order IDs
```

---

## 🐞 Troubleshooting Case: Date Conversion

One of the most important lessons from this project was that a pipeline can show:

```text
✅ Succeeded
```

while the transformed data is still incorrect.

### Problem

Validation showed thousands of `NULL` values in `order_date`.

### Root Cause

The original transformation used:

```sql
TRY_CONVERT(DATE, order_date, 105)
```

Style `105` expects:

```text
DD-MM-YYYY
```

but the dataset used:

```text
MM-DD-YYYY
```

### Fix

The transformation was corrected to:

```sql
TRY_CONVERT(DATE, order_date, 110)
```

### Result

```text
Invalid Order Dates: 0
```

### 💡 Key Lesson

> Pipeline success must be combined with data-quality validation and source-to-target reconciliation.

---

## 📈 Monitoring

Azure Data Factory Monitor was used to validate pipeline execution.

Final activity status:

```text
Copy_Landing_To_Raw          ✅ Succeeded
Copy_Raw_To_SQL_Staging      ✅ Succeeded
Transform_Supermart_Sales    ✅ Succeeded
```

Monitoring provides visibility into:

- Pipeline status
- Activity status
- Duration
- Rows read
- Rows written
- Integration runtime
- Failure details
- Triggered and Debug runs

---

## 📸 Screenshots

### ADF Pipeline

![ADF Pipeline](screenshots/03-adf-pipeline.png)

### Successful ADF Run

![ADF Monitor](screenshots/04-adf-monitor-success.png)

### SQL Validation

![SQL Validation](screenshots/05-sql-validation.png)

> 🔐 Crop or hide subscription IDs, credentials, access keys, personal email addresses, and other sensitive information before uploading screenshots.

---

## 🎞️ Animated Pipeline Flow

An animated architecture can be added to the repository:

```markdown
![Azure ETL Flow](architecture/architecture-animation.gif)
```

Suggested animation:

```text
CSV
 ↓
Landing
 ↓
ADF
 ↓
Raw
 ↓
ADF
 ↓
SQL Staging
 ↓
Stored Procedure
 ↓
Final Table
 ↓
Validation ✅
```

---

## 🎯 Skills Demonstrated

- ✅ Azure Data Factory
- ✅ ADLS Gen2
- ✅ Azure SQL Database
- ✅ ETL pipeline design
- ✅ Linked Services
- ✅ Datasets
- ✅ Copy Activities
- ✅ Source-to-target mapping
- ✅ SQL staging patterns
- ✅ Stored procedures
- ✅ SQL transformations
- ✅ Data type conversion
- ✅ Full-load processing
- ✅ Data validation
- ✅ Duplicate checking
- ✅ Row-count reconciliation
- ✅ Pipeline monitoring
- ✅ Debugging and troubleshooting

---

## 🧠 What I Learned

This project strengthened my understanding of how Azure data engineering components work together:

- **ADF** handles orchestration and data movement
- **ADLS Gen2** stores landing and raw data
- **Staging tables** isolate ingestion from trusted data
- **Stored procedures** provide reusable transformation logic
- **Explicit mappings** connect source fields to target schema
- **Validation** is required even after successful pipeline execution
- **Monitoring** is essential for production ETL operations
- **Repeatable loads** require careful duplicate prevention

---

## 🚧 Roadmap

### ✅ Phase 1 — Full-Load ETL

- [x] Create ADLS Gen2 storage
- [x] Create Landing and Raw zones
- [x] Upload source CSV
- [x] Create ADF Linked Service
- [x] Build Landing → Raw copy
- [x] Create Azure SQL staging table
- [x] Create Azure SQL final table
- [x] Build Raw → SQL staging copy
- [x] Configure source-to-target mappings
- [x] Create transformation stored procedure
- [x] Execute stored procedure from ADF
- [x] Validate row counts
- [x] Validate nulls
- [x] Validate duplicates
- [x] Publish pipeline
- [x] Monitor successful runs

### 🔜 Phase 2 — Data Quality & Reliability

- [ ] Rejected-record handling
- [ ] Audit tables
- [ ] Error logging
- [ ] Pipeline failure handling
- [ ] Data-quality rules
- [ ] Notifications

### 🔜 Phase 3 — Incremental Loading

- [ ] Watermark table
- [ ] Incremental ingestion
- [ ] Upsert logic
- [ ] SQL MERGE
- [ ] Metadata-driven pipelines

### 🔜 Phase 4 — Lakehouse Implementation

- [ ] Azure Databricks
- [ ] PySpark
- [ ] Delta Lake
- [ ] Bronze / Silver / Gold
- [ ] Delta MERGE
- [ ] Databricks orchestration

---

 
## 🔐 Security

Never commit:

```text
Storage Account Keys
SQL Passwords
Connection Strings
Subscription IDs
Service Principal Secrets
Private Keys
.env files
```

For production systems, prefer:

- Azure Managed Identity
- Azure Key Vault
- Role-Based Access Control (RBAC)

---

## 👩‍💻 Author

**Saranya Madala**

**Data Engineer | AI/ML Engineer**

Interested in building scalable ETL/ELT pipelines, cloud data platforms, Lakehouse architectures, and AI/ML data solutions.

---

## ⭐ Support

If you found this project useful, consider giving the repository a **⭐ star**.

---

## 🚀 Project Status

```text
Phase 1: Full-Load Azure ETL              ✅ Complete
Phase 2: Data Quality & Reliability       🚧 Planned
Phase 3: Incremental Processing           📋 Planned
Phase 4: Databricks Lakehouse             📋 Planned
```
