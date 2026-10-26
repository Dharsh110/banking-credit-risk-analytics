
/*========================================================
  PROJECT: Banking Credit Risk & Loan Default Analytics
  PROGRAM: 08_validate_dataset_relationships.sas
  PURPOSE: Validate relationships between customers,
           loans and payments
========================================================*/

libname project
    "/home/u64620803/Bank_credit_risk_analytics";


/* STEP 1: Check loans without matching customers */

proc sql;
    create table work.unmatched_loans as
    select l.*
    from project.loans_clean as l
    left join project.customers_clean as c
        on strip(l.customer_id_clean)
         = strip(c.customer_id_clean)
    where missing(c.customer_id_clean);
quit;


/* STEP 2: Check payments without matching loans */

proc sql;
    create table work.unmatched_payments as
    select p.*
    from project.payments_clean as p
    left join project.loans_clean as l
        on strip(p.loan_id_clean)
         = strip(l.loan_id_clean)
    where missing(l.loan_id_clean);
quit;


/* STEP 3: Summarize relationship validation results */

proc sql;
    select
        "Loans without matching customers" as Check_Name
            length=45,
        count(*) as Issue_Count
    from work.unmatched_loans;

    select
        "Payments without matching loans" as Check_Name
            length=45,
        count(*) as Issue_Count
    from work.unmatched_payments;
quit;


/* STEP 4: Display sample unmatched loan records */

title "Loans Without Matching Customers";

proc print data=work.unmatched_loans(obs=20);
run;


/* STEP 5: Display sample unmatched payment records */

title "Payments Without Matching Loans";

proc print data=work.unmatched_payments(obs=20);
run;


/* STEP 6: Validate key uniqueness */

proc sql;
    select count(*) as Customer_Rows,
           count(distinct customer_id_clean)
               as Unique_Customer_IDs
    from project.customers_clean;

    select count(*) as Loan_Rows,
           count(distinct loan_id_clean)
               as Unique_Loan_IDs
    from project.loans_clean;

    select count(*) as Payment_Rows,
           count(distinct payment_id_clean)
               as Unique_Payment_IDs
    from project.payments_clean;
quit;

title;
