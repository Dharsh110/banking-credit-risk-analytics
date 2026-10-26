
/*========================================================
  PROJECT: Banking Credit Risk & Loan Default Analytics
  PROGRAM: 09_investigate_unmatched_customers.sas
  PURPOSE: Investigate the 25 unmatched loan customers
========================================================*/

libname project
    "/home/u64620803/Bank_credit_risk_analytics";

/* STEP 1: Get distinct customer IDs from raw data */

proc sql;
    create table work.raw_customer_ids as
    select distinct
        upcase(strip(customer_id)) as customer_id_key length=32
    from work.customers_raw
    where not missing(customer_id);
quit;

/* STEP 2: Check whether unmatched IDs exist in raw data */

proc sql;
    create table work.unmatched_customer_review as
    select
        l.loan_id_clean,
        l.customer_id_clean,
        l.loan_status_clean,
        l.loan_amount_clean,
        case
            when not missing(r.customer_id_key)
                then "Found in raw customers"
            else "Not found in raw customers"
        end as raw_customer_check length=30
    from project.loans_clean as l

    left join project.customers_clean as c
        on upcase(strip(l.customer_id_clean))
         = upcase(strip(c.customer_id_clean))

    left join work.raw_customer_ids as r
        on upcase(strip(l.customer_id_clean))
         = r.customer_id_key

    where missing(c.customer_id_clean);
quit;

/* STEP 3: Summarize findings */

proc freq data=work.unmatched_customer_review;
    tables raw_customer_check / missing;
    title "Unmatched Customer ID Investigation";
run;

/* STEP 4: Display the affected loans */

proc print data=work.unmatched_customer_review;
    title "Loans With Unmatched Customer IDs";
run;

title;
