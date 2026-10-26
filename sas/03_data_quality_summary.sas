
/* Banking Credit Risk & Loan Default Analytics */
/* Program: 03_data_quality_summary.sas */
/* Purpose: Summarize data quality issues */

/* 1. CUSTOMER SUMMARY */

proc sql;
    select
        count(*) as Total_Rows,
        count(distinct customer_id) as Unique_Customers,
        sum(missing(annual_income)) as Missing_Income,
        sum(missing(credit_score)) as Missing_Credit_Score,
        sum(age < 18 or age > 100) as Invalid_Age_Rows
    from work.customers_raw;
quit;


/* 2. LOAN SUMMARY */

proc sql;
    select
        count(*) as Total_Rows,
        count(distinct loan_id) as Unique_Loans,
        sum(missing(loan_amount)) as Missing_Loan_Amount,
        sum(missing(interest_rate)) as Missing_Interest_Rate,
        sum(missing(default_flag)) as Missing_Default_Flag
    from work.loans_raw;
quit;


/* 3. PAYMENT SUMMARY */

proc sql;
    select
        count(*) as Total_Rows,
        count(distinct payment_id) as Unique_Payment_IDs,
        sum(missing(amount_paid)) as Missing_Amount_Paid,
        sum(missing(payment_date)) as Missing_Payment_Date
    from work.payments_raw;
quit;


/* 4. CHECK CUSTOMER GENDER CATEGORIES */

proc freq data=work.customers_raw;
    tables gender / missing;
run;


/* 5. CHECK LOAN STATUS CATEGORIES */

proc freq data=work.loans_raw;
    tables loan_status default_flag / missing;
run;


/* 6. CHECK PAYMENT STATUS CATEGORIES */

proc freq data=work.payments_raw;
    tables payment_status / missing;
run;
