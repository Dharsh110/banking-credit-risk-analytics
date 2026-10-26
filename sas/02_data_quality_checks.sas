
/* Banking Credit Risk & Loan Default Analytics */
/* Program: 02_data_quality_checks.sas */
/* Purpose: Check data quality before cleaning */


/* ==========================================
   1. CUSTOMER DATA QUALITY CHECKS
   ========================================== */

/* Check missing values in important columns */
proc means data=work.customers_raw n nmiss;
    var age annual_income credit_score dependents;
run;

/* Check customer ID duplicates */
proc sql;
    select customer_id,
           count(*) as Record_Count
    from work.customers_raw
    group by customer_id
    having count(*) > 1;
quit;

/* Check gender variations */
proc freq data=work.customers_raw;
    tables gender / missing;
run;

/* Check age values */
proc means data=work.customers_raw
    min max mean median;
    var age;
run;

/* Check date formats */
proc freq data=work.customers_raw;
    tables date_of_birth customer_since / missing;
run;


/* ==========================================
   2. LOAN DATA QUALITY CHECKS
   ========================================== */

/* Check missing numeric values */
proc means data=work.loans_raw n nmiss;
    var loan_amount interest_rate;
run;

/* Check duplicate loan IDs */
proc sql;
    select loan_id,
           count(*) as Record_Count
    from work.loans_raw
    group by loan_id
    having count(*) > 1;
quit;

/* Check loan status variations */
proc freq data=work.loans_raw;
    tables loan_status default_flag / missing;
run;


/* ==========================================
   3. PAYMENT DATA QUALITY CHECKS
   ========================================== */

/* Check missing payment amounts */
proc means data=work.payments_raw n nmiss;
    var amount_paid;
run;

/* Check duplicate payment IDs */
proc sql;
    select payment_id,
           count(*) as Record_Count
    from work.payments_raw
    group by payment_id
    having count(*) > 1;
quit;

/* Check payment status variations */
proc freq data=work.payments_raw;
    tables payment_status / missing;
run;


/* ==========================================
   4. VALIDATE CUSTOMER AGES
   ========================================== */

/* Display records with suspicious ages */
proc print data=work.customers_raw;
    where age < 18 or age > 100;
    var customer_id age date_of_birth;
run;


/* ==========================================
   5. CHECK DATASET ROW COUNTS
   ========================================== */

proc sql;
    select "Customers" as Dataset,
           count(*) as Total_Rows
    from work.customers_raw

    union all

    select "Loans" as Dataset,
           count(*) as Total_Rows
    from work.loans_raw

    union all

    select "Payments" as Dataset,
           count(*) as Total_Rows
    from work.payments_raw;
quit;
