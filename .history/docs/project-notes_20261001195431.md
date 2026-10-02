# Project Notes

## Objective

Build an end-to-end batch ETL pipeline using Azure Data Factory,
Azure Data Lake Storage Gen2, Azure SQL Database and SQL stored procedures.

## Source

Supermart Grocery Sales dataset.

## Pipeline

Landing → Raw → SQL Staging → Transformation → Final Table

## Issue Encountered

The first SQL transformation resulted in NULL order dates.

The source dates were MM-DD-YYYY, but the original transformation
used SQL conversion style 105, which expects DD-MM-YYYY.

The issue was corrected using:

TRY_CONVERT(DATE, order_date, 110)

After rerunning the pipeline, validation returned zero invalid dates.

## Validation

- Source rows: 9,994
- Staging rows: 9,994
- Final rows: 9,994
- Invalid transformed rows: 0