
# Banking Credit Risk & Loan Default Analytics

An end-to-end data analytics project using **SAS and Microsoft Power BI** to analyze banking customers, loan portfolios, default risk, payment performance, and data quality.
<p align="center">
  <strong>SAS | Power BI | DAX | Power Query | Data Cleaning | Data Visualization</strong>
</p>

## Project Overview

The **Banking Credit Risk & Loan Default Analytics** project focuses on understanding loan portfolio performance, identifying potential credit-risk patterns, and evaluating customer payment behavior through data analysis and interactive reporting.

The project uses SAS for data preparation, data-quality assessment, validation, and export. Microsoft Power BI is used to build the data model, create DAX measures, and develop an interactive dashboard.

The analysis covers three primary datasets:

- Customers
- Loans
- Payments

The final dashboard brings together key indicators related to loan amounts, outstanding balances, defaults, payment behavior, loan distribution, and data consistency.

## Business Objectives

The main objectives of this project are to:

- Analyze the overall loan portfolio and loan distribution.
- Measure the number of loans and identify defaulted loans.
- Calculate and monitor the loan default rate.
- Examine outstanding loan balances and loan amounts.
- Analyze payments received, amounts due, and payment performance.
- Identify late payments and evaluate late fees.
- Explore loan origination and payment trends over time.
- Compare loan performance across loan types, purposes, regions, and statuses.
- Detect and document missing values, duplicate records, invalid dates, and unmatched customer records.
- Present the analysis through an interactive Power BI dashboard.

## Tools and Technologies

| Tool | Purpose |
|---|---|
| SAS | Data import, cleaning, quality assessment, validation, and data export |
| Microsoft Power BI Desktop | Data modeling, dashboard development, and reporting |
| DAX | Measures, KPI calculations, and analytical expressions |
| Power Query | Data import and transformation within Power BI |
| GitHub | Project version control, documentation, and portfolio presentation |

**Note:** This project uses SAS and Power BI. SQL was not used as part of the project workflow.

## Dataset Overview

The project contains three datasets representing different parts of the banking process.

### 1. Customers

Customer-level information used to analyze the customer base and support regional and customer-related comparisons.

Examples of analytical areas:

- Customer distribution
- Customer region
- Annual income
- Credit score
- Customer data quality

### 2. Loans

Loan-level information used to analyze the loan portfolio and credit-risk indicators.

Examples of analytical areas:

- Loan amount
- Interest rate
- Loan term
- Loan status
- Outstanding balance
- Overdue amount
- Days past due
- Default indicators
- Origination and maturity dates

### 3. Payments

Payment-level information used to analyze repayment behavior and payment performance.

Examples of analytical areas:

- Amount due
- Amount paid
- Payment status
- Payment date
- Due date
- Days late
- Late fees

The raw and processed CSV files are stored separately in the `data/` directory.

## Project Workflow

### Step 1: Data Import

Imported the original customer, loan, and payment datasets into SAS.

The initial import programs establish the source datasets for subsequent analysis and validation.

### Step 2: Data Quality Assessment

Performed data-quality checks to investigate issues such as:

- Missing values
- Duplicate identifiers
- Invalid or unusual dates
- Negative or unexpected numeric values
- Inconsistent records
- Unmatched customer and loan identifiers

### Step 3: Data Cleaning

Created SAS programs to clean and prepare the customer, loan, and payment datasets.

The process includes examining problematic records, applying appropriate cleaning logic, and preparing the data for further analysis.

### Step 4: Validation

Validated the cleaned datasets and investigated potential relationship issues between customers, loans, and payments.

Data-quality exceptions were documented rather than automatically deleting every record containing a missing, unusual, or invalid value.

### Step 5: Export

Exported the processed datasets to CSV files for use in Power BI.

### Step 6: Power BI Data Modeling

Loaded the processed datasets into Power BI and configured the data model to support analysis across customer, loan, payment, and date information.

### Step 7: DAX Measures and Dashboard Development

Created KPI measures and visualizations to summarize the loan portfolio, default risk, payment behavior, and data quality.

Added interactive slicers to explore results across relevant categories and dates.

The project retains a distinction between identifying a data-quality issue and deciding how it should be handled. Values are not automatically removed simply because they are missing, negative, or unusual.

## Power BI Dashboard

The dashboard is designed to provide an overview of credit risk, loan portfolio performance, payment behavior, and data quality.

### Dashboard Preview

![Banking Credit Risk Analytics Dashboard](powerbi/Dashboard%20screenshot.png)

---

## Key Performance Indicators

### Default Rate

The default rate is calculated as:

**Default Rate = (Number of Defaulted Loans / Total Loans) × 100**

For the dashboard's reported counts:

- Defaulted Loans: 600
- Total Loans: 6,000
- Default Rate: 10%

The calculation above uses the displayed loan counts. The precise definition of a default should remain consistent with the measure used in the Power BI model.

### Total Outstanding Balance

Represents the aggregated outstanding balance for the loan records included in the analysis.

### Total Amount Paid

Represents the sum of recorded payment amounts used by the corresponding Power BI measure.

### Total Amount Due

Represents the sum of recorded payment amounts due, according to the dashboard's measure definition.

### Average Days Late

Used to examine payment delays and compare payment performance across payment-status categories.

**Metric validation:** KPI values should be checked against the underlying data and the definitions used in their DAX measures. Aggregated totals can differ depending on missing values, filters, duplicate records, and the level of aggregation.

## Project Structure

```text
banking-credit-risk-analytics/
│
├── data/
│   ├── raw/
│   │   ├── customers_raw.csv
│   │   ├── loans_raw.csv
│   │   └── payments_raw.csv
│   │
│   └── processed/
│       ├── customers_clean.csv
│       ├── loans_clean.csv
│       └── payments_clean.csv
│
├── documentation/
│   └── README.md
│
├── powerbi/
│   ├── Bank credit risk analytics.pbix
│   └── Dashboard screenshot.png
│
├── sas/
│   ├── 01_import_.sas
│   ├── 02_data_quality_checks.sas
│   ├── 03_data_quality_summary.sas
│   ├── 04_clean_customers.sas
│   ├── 05_check_validate_finalize_customer_duplicates.sas
│   ├── 06_clean_loans.sas
│   ├── 07_clean_payments.sas
│   ├── 08_validate_dataset_relationships.sas
│   ├── 09_investigate_unmatched_customers.sas
│   ├── 10_finalize_relationship_validation.sas
│   ├── 11_final_data_quality_audit.sas
│   ├── 12_export_cleaned_data.sas
│   │
│   └── result/
│       ├── 01_import_-results.html
│       ├── 02_data_quality_checks-results.html
│       ├── 03_data_quality_summary-results.html
│       ├── 04_clean_customers-results.html
│       ├── 05_check_validate_finalize_customer_duplicates-results.html
│       ├── 06_clean_loans-results.html
│       ├── 07_clean_payments-results.html
│       ├── 08_validate_dataset_relationships-results.html
│       ├── 09_investigate_unmatched_customers-results.html
│       ├── 10_finalize_relationship_validation-results.html
│       ├── 11_final_data_quality_audit-results.html
│       └── 12_export_cleaned_data-results.html
│
└── README.md
```

### Review the Data

The `data/raw/` directory contains the source CSV files, while `data/processed/` contains the cleaned CSV files produced by the workflow.

Use these files to understand the transformation from source data to the datasets used in the dashboard.

## Skills Demonstrated

- Data cleaning and preparation
- Data-quality assessment
- Duplicate and missing-value investigation
- Data validation and relationship checks
- SAS programming
- CSV data import and export
- Power Query transformations
- Data modeling in Power BI
- DAX measures and KPI calculations
- Interactive dashboard development
- Data visualization
- Analytical reporting
- Documentation and version control with GitHub

## Limitations and Notes

- The dashboard provides descriptive analysis of the available datasets.
- Data-quality findings should be considered when interpreting aggregated metrics.
- Missing, invalid, or unmatched values may affect individual calculations.
- A relationship or correlation in the data does not establish causation.
- This project does not implement a machine-learning model or predictive credit-risk scoring system.
- Publicly shared datasets must not contain sensitive or identifiable customer information.
- The results depend on the contents of the source data and the definitions used in the Power BI measures.

## Author

**Dharshini V**

Computer Science and Engineering Graduate | Aspiring Data Analyst
- Project Repository: [Banking Credit Risk & Loan Default Analytics](https://github.com/Dharsh110/banking-credit-risk-analytics)
