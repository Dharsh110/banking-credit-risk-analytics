
/*========================================================
  PROJECT: Banking Credit Risk & Loan Default Analytics
  PROGRAM: 11_final_data_quality_audit.sas
  PURPOSE: Audit missing, blank and negative values
========================================================*/

libname project
    "/home/u64620803/Bank_credit_risk_analytics";


/* STEP 1: CUSTOMER DATA AUDIT */

title "Customer Missing and Blank Value Audit";

proc sql;
    select
        count(*) as Total_Rows,

        sum(missing(customer_id_clean))
            as Missing_Customer_ID,

        sum(missing(gender_clean))
            as Missing_Gender,

        sum(missing(annual_income))
            as Missing_Annual_Income,

        sum(missing(credit_score))
            as Missing_Credit_Score,

        sum(missing(age_clean))
            as Missing_Cleaned_Age,

        sum(case
            when not missing(annual_income)
             and annual_income < 0 then 1
            else 0
        end) as Negative_Annual_Income,

        sum(case
            when not missing(credit_score)
             and (credit_score < 0 or credit_score > 850)
            then 1 else 0
        end) as Credit_Score_Out_Of_Range

    from project.customers_clean;
quit;


/* STEP 2: LOAN DATA AUDIT */

title "Loan Missing and Negative Value Audit";

proc sql;
    select
        count(*) as Total_Rows,

        sum(missing(loan_id_clean))
            as Missing_Loan_ID,

        sum(missing(customer_id_clean))
            as Missing_Customer_ID,

        sum(missing(loan_status_clean))
            as Missing_Loan_Status,

        sum(missing(loan_amount_clean))
            as Missing_Loan_Amount,

        sum(missing(interest_rate))
            as Missing_Interest_Rate,

        sum(missing(default_flag))
            as Missing_Default_Flag,

        sum(case
            when loan_amount_clean < 0 then 1
            else 0
        end) as Negative_Loan_Amounts,

        sum(case
            when interest_rate < 0 then 1
            else 0
        end) as Negative_Interest_Rates,

        sum(case
            when outstanding_balance < 0 then 1
            else 0
        end) as Negative_Outstanding_Balances,

        sum(case
            when overdue_amount < 0 then 1
            else 0
        end) as Negative_Overdue_Amounts,

        sum(case
            when days_past_due < 0 then 1
            else 0
        end) as Negative_Days_Past_Due

    from project.loans_clean;
quit;


/* STEP 3: PAYMENT DATA AUDIT */

title "Payment Missing and Negative Value Audit";

proc sql;
    select
        count(*) as Total_Rows,

        sum(missing(payment_id_clean))
            as Missing_Payment_ID,

        sum(missing(loan_id_clean))
            as Missing_Loan_ID,

        sum(missing(payment_status_clean))
            as Missing_Payment_Status,

        sum(missing(amount_due))
            as Missing_Amount_Due,

        sum(missing(amount_paid))
            as Missing_Amount_Paid,

        sum(missing(payment_date))
            as Missing_Payment_Date,

        sum(case
            when amount_due < 0 then 1
            else 0
        end) as Negative_Amount_Due,

        sum(case
            when amount_paid < 0 then 1
            else 0
        end) as Negative_Amount_Paid,

        sum(case
            when days_late < 0 then 1
            else 0
        end) as Negative_Days_Late,

        sum(case
            when late_fee < 0 then 1
            else 0
        end) as Negative_Late_Fee,

        sum(case
            when not missing(amount_paid)
             and not missing(amount_due)
             and amount_paid > amount_due
            then 1 else 0
        end) as Payments_Exceeding_Due

    from project.payments_clean;
quit;


/* STEP 4: Review payment status and blank categories */

title "Payment Status Distribution";

proc freq data=project.payments_clean;
    tables payment_status_clean / missing;
run;


/* STEP 5: Review loan status and blank categories */

title "Loan Status Distribution";

proc freq data=project.loans_clean;
    tables loan_status_clean / missing;
run;

title;
