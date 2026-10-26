
/*========================================================
  PROJECT: Banking Credit Risk & Loan Default Analytics
  PROGRAM: 11_final_data_quality_audit.sas
  PURPOSE: Correct missing vs negative value counts
========================================================*/

libname project
    "/home/u64620803/Bank_credit_risk_analytics";


/* STEP 1: Customer audit */

proc sql;
    select
        count(*) as Total_Rows,
        sum(missing(annual_income)) as Missing_Income,
        sum(case
            when not missing(annual_income)
             and annual_income < 0 then 1 else 0
        end) as Negative_Income,
        sum(missing(credit_score)) as Missing_Credit_Score,
        sum(case
            when not missing(credit_score)
             and (credit_score < 0 or credit_score > 850)
            then 1 else 0
        end) as Credit_Score_Out_Of_Range,
        sum(missing(age_clean)) as Missing_Cleaned_Age
    from project.customers_clean;
quit;


/* STEP 2: Loan audit
   Original fields distinguish missing from invalid values. */

proc sql;
    select
        count(*) as Total_Rows,

        sum(missing(loan_amount_original))
            as Missing_Original_Loan_Amount,

        sum(case
            when not missing(loan_amount_original)
             and loan_amount_original < 0 then 1
            else 0
        end) as Actual_Negative_Loan_Amounts,

        sum(missing(interest_rate_original))
            as Missing_Original_Interest_Rate,

        sum(case
            when not missing(interest_rate_original)
             and interest_rate_original < 0 then 1
            else 0
        end) as Actual_Negative_Interest_Rates,

        sum(missing(default_flag_original))
            as Missing_Original_Default_Flag,

        sum(case
            when not missing(outstanding_balance)
             and outstanding_balance < 0 then 1
            else 0
        end) as Actual_Neg_Outstanding_Balances,

        sum(case
            when not missing(overdue_amount)
             and overdue_amount < 0 then 1
            else 0
        end) as Actual_Negative_Overdue_Amounts,

        sum(case
            when not missing(days_past_due)
             and days_past_due < 0 then 1
            else 0
        end) as Actual_Negative_Days_Past_Due

    from project.loans_clean;
quit;


/* STEP 3: Payment audit */

proc sql;
    select
        count(*) as Total_Rows,
        sum(missing(amount_due)) as Missing_Amount_Due,
        sum(missing(amount_paid)) as Missing_Amount_Paid,

        sum(case
            when not missing(amount_due)
             and amount_due < 0 then 1
            else 0
        end) as Actual_Negative_Amount_Due,

        sum(case
            when not missing(amount_paid)
             and amount_paid < 0 then 1
            else 0
        end) as Actual_Negative_Amount_Paid,

        sum(missing(payment_date)) as Missing_Payment_Date,

        sum(case
            when not missing(days_late)
             and days_late < 0 then 1
            else 0
        end) as Actual_Negative_Days_Late,

        sum(case
            when not missing(late_fee)
             and late_fee < 0 then 1
            else 0
        end) as Actual_Negative_Late_Fee,

        sum(case
            when not missing(amount_paid)
             and not missing(amount_due)
             and amount_paid > amount_due then 1
            else 0
        end) as Payments_Exceeding_Due

    from project.payments_clean;
quit;















/*==========================================================
  PROJECT: Banking Credit Risk & Loan Default Analytics
  PROGRAM: 11_final_data_quality_audit.sas
  PURPOSE: Create a consolidated data-quality issue summary
==========================================================*/

libname project "/home/u64620803/Bank_credit_risk_analytics";

/* 1. Customer data-quality issues */
data work.customer_audit;
    length dataset $20 issue $45 severity $15 action $80;
    set project.customers_clean;

    if missing(annual_income) then do;
        dataset = "Customers";
        issue = "Missing annual income";
        severity = "Review";
        action = "Retain missing value and investigate";
        output;
    end;

    if not missing(annual_income) and annual_income < 0 then do;
        dataset = "Customers";
        issue = "Negative annual income";
        severity = "High";
        action = "Check source value and retain original";
        output;
    end;

    if missing(credit_score) then do;
        dataset = "Customers";
        issue = "Missing credit score";
        severity = "Review";
        action = "Retain missing value and investigate";
        output;
    end;

    if not missing(credit_score)
       and (credit_score < 0 or credit_score > 850) then do;
        dataset = "Customers";
        issue = "Credit score outside 0-850";
        severity = "High";
        action = "Verify expected score range";
        output;
    end;

    if missing(age_clean) then do;
        dataset = "Customers";
        issue = "Missing cleaned age";
        severity = "Review";
        action = "Investigate original age value";
        output;
    end;
run;

/* 2. Loan data-quality issues */
data work.loan_audit;
    length dataset $20 issue $45 severity $15 action $80;
    set project.loans_clean;

    if missing(loan_amount_original) then do;
        dataset = "Loans";
        issue = "Missing original loan amount";
        severity = "Review";
        action = "Retain missing value and investigate";
        output;
    end;

    if not missing(loan_amount_original)
       and loan_amount_original < 0 then do;
        dataset = "Loans";
        issue = "Negative original loan amount";
        severity = "High";
        action = "Review source value; do not assume zero";
        output;
    end;

    if missing(interest_rate_original) then do;
        dataset = "Loans";
        issue = "Missing original interest rate";
        severity = "Review";
        action = "Retain missing value and investigate";
        output;
    end;

    if missing(default_flag_original) then do;
        dataset = "Loans";
        issue = "Missing original default flag";
        severity = "Review";
        action = "Keep default classification unknown";
        output;
    end;
run;

/* 3. Payment data-quality issues */
data work.payment_audit;
    length dataset $20 issue $45 severity $15 action $80;
    set project.payments_clean;

    if missing(amount_paid) then do;
        dataset = "Payments";
        issue = "Missing amount paid";
        severity = "Review";
        action = "Retain missing value and investigate";
        output;
    end;

    if not missing(amount_paid) and amount_paid < 0 then do;
        dataset = "Payments";
        issue = "Negative amount paid";
        severity = "High";
        action = "Review source value and cleaning flag";
        output;
    end;

    if missing(payment_date) then do;
        dataset = "Payments";
        issue = "Missing payment date";
        severity = "Review";
        action = "Check payment status and source rules";
        output;
    end;
run;

/* 4. Combine issue records */
data project.final_data_quality_issues;
    set work.customer_audit
        work.loan_audit
        work.payment_audit;
run;

/* 5. Summarize issue counts */
proc sql;
    create table project.final_data_quality_summary as
    select
        dataset,
        issue,
        severity,
        action,
        count(*) as affected_rows
    from project.final_data_quality_issues
    group by dataset, issue, severity, action
    order by dataset, severity desc, issue;
quit;

/* 6. Display final summary */
title "Final Data Quality Issue Summary";

proc print data=project.final_data_quality_summary noobs;
run;

title;
