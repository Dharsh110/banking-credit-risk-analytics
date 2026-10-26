
/*========================================================
  PROJECT: Banking Credit Risk & Loan Default Analytics
  PROGRAM: 10_finalize_relationship_validation.sas
  PURPOSE: Document unmatched customer references
========================================================*/

libname project
    "/home/u64620803/Bank_credit_risk_analytics";

/* STEP 1: Create an audit table for unmatched loans */

data project.unmatched_customer_loans;
    set work.unmatched_customer_review;
run;

/* STEP 2: Summarize the unmatched loans by status */

proc freq data=project.unmatched_customer_loans;
    tables loan_status_clean / missing;
    title "Unmatched Loans by Loan Status";
run;

/* STEP 3: Summarize affected loan amounts by status */

proc sql;
    select loan_status_clean,
           count(*) as Loan_Count,
           sum(loan_amount_clean) as Total_Loan_Amount
                format=comma18.2
    from project.unmatched_customer_loans
    group by loan_status_clean
    order by loan_status_clean;
quit;

/* STEP 4: Create a relationship validation summary */

proc sql;
    create table project.relationship_validation_summary
        (Check_Name char(45),
         Issue_Count num,
         Status char(20));

    insert into project.relationship_validation_summary
    values ("Loans without matching customers",
            25, "Review Required");

    insert into project.relationship_validation_summary
    values ("Payments without matching loans",
            0, "Passed");
quit;

proc print data=project.relationship_validation_summary;
    title "Final Relationship Validation Summary";
run;

title;
