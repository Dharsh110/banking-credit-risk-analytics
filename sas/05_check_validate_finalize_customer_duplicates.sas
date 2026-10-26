
/* ============================================================
   Program: 05_check_customer_duplicates.sas
   Purpose: Investigate repeated customer IDs
   ============================================================ */

/* Step 1: Count occurrences of each customer ID */

proc sql;
    create table work.customer_id_counts as
    select
        customer_id,
        count(*) as id_count
    from work.customers_clean
    group by customer_id
    having count(*) > 1
    order by id_count desc, customer_id;
quit;


/* Step 2: Display duplicate ID summary */

proc sql;
    select
        count(*) as Repeated_ID_Groups,
        sum(id_count) as Rows_In_Repeated_Groups,
        sum(id_count - 1) as Rows_Beyond_First_Occurrence
    from work.customer_id_counts;
quit;


/* Step 3: Display repeated customer IDs */

proc print data=work.customer_id_counts(obs=30);
run;


/* Step 4: Review the full customer records for repeated IDs */

proc sql;
    create table work.customer_duplicate_details as
    select c.*
    from work.customers_clean as c
    inner join work.customer_id_counts as d
        on c.customer_id = d.customer_id
    order by c.customer_id;
quit;

proc print data=work.customer_duplicate_details(obs=50);
run;



/* Compare all customer columns to identify exact duplicate rows */

proc sort data=work.customers_clean
          out=work.customers_unique
          noduprecs
          dupout=work.customer_duplicate_rows;
    by _all_;
run;

/* Compare row counts */

proc sql;
    select count(*) as Clean_Rows
    from work.customers_clean;

    select count(*) as Unique_Rows
    from work.customers_unique;

    select count(*) as Exact_Duplicate_Rows
    from work.customer_duplicate_rows;
quit;

/* Confirm distinct customer IDs in the unique dataset */

proc sql;
    select
        count(*) as Total_Rows,
        count(distinct customer_id_clean) as Unique_Customer_IDs
    from work.customers_unique;
quit;


/* Banking Credit Risk & Loan Default Analytics */
/* Finalize cleaned customer dataset */

/* Save the deduplicated dataset in the project folder */

libname project "/home/u64620803/Bank_credit_risk_analytics";

data project.customers_clean;
    set work.customers_unique;
run;

/* Final validation */

proc sql;
    select
        count(*) as Total_Customer_Rows,
        count(distinct customer_id_clean) as Unique_Customer_IDs
    from project.customers_clean;
quit;

/* Review final dataset structure */

proc contents data=project.customers_clean;
run;

