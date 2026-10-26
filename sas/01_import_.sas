
/* Banking Credit Risk & Loan Default Analytics */
/* Step 1: Import customer data */

proc import
    datafile="/home/u64620803/Bank_credit_risk_analytics/raw/customers_raw.csv"
    out=work.customers_raw
    dbms=csv
    replace;
    guessingrows=max;
    getnames=yes;
run;

/* Step 2: Check the dataset structure */

proc contents data=work.customers_raw;
run;

/* Step 3: Display the first 10 records */

proc print data=work.customers_raw(obs=10);
run;

/* Step 4: Check the number of records */

proc sql;
    select count(*) as Total_Rows
    from work.customers_raw;
quit;



/* =========================================
   STEP 2: IMPORT LOANS DATA
   ========================================= */

proc import
    datafile="/home/u64620803/Bank_credit_risk_analytics/raw/loans_raw.csv"
    out=work.loans_raw
    dbms=csv
    replace;
    guessingrows=max;
    getnames=yes;
run;

/* Check loan dataset structure */
proc contents data=work.loans_raw;
run;

/* Count loan records */
proc sql;
    select count(*) as Total_Loan_Rows
    from work.loans_raw;
quit;

/* Preview first 10 loan records */
proc print data=work.loans_raw(obs=10);
run;


/* =========================================
   STEP 3: IMPORT PAYMENTS DATA
   ========================================= */

proc import
    datafile="/home/u64620803/Bank_credit_risk_analytics/raw/payments_raw.csv"
    out=work.payments_raw
    dbms=csv
    replace;
    guessingrows=max;
    getnames=yes;
run;

/* Check payment dataset structure */
proc contents data=work.payments_raw;
run;

/* Count payment records */
proc sql;
    select count(*) as Total_Payment_Rows
    from work.payments_raw;
quit;

/* Preview first 10 payment records */
proc print data=work.payments_raw(obs=10);
run;
