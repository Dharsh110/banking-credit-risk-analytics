
libname project "/home/u64620803/Bank_credit_risk_analytics";

/* Export cleaned customers: 4,000 rows */
proc export data=project.customers_clean
    outfile="/home/u64620803/Bank_credit_risk_analytics/processed data/customers_clean.csv"
    dbms=csv replace;
run;

/* Export cleaned loans: 6,000 rows */
proc export data=project.loans_clean
    outfile="/home/u64620803/Bank_credit_risk_analytics/processed data/loans_clean.csv"
    dbms=csv replace;
run;

/* Export cleaned payments: 174,596 rows */
proc export data=project.payments_clean
    outfile="/home/u64620803/Bank_credit_risk_analytics/processed data/payments_clean.csv"
    dbms=csv replace;
run;

/* Verify the source datasets */
proc sql;
    select "Customers" as Dataset, count(*) as Total_Rows
    from project.customers_clean;

    select "Loans" as Dataset, count(*) as Total_Rows
    from project.loans_clean;

    select "Payments" as Dataset, count(*) as Total_Rows
    from project.payments_clean;
quit;





/* Verify the exported CSV files */

%let folder=/home/u64620803/Bank_credit_risk_analytics/processed data;

proc import datafile="&folder/customers_clean.csv"
    out=work.export_customers
    dbms=csv replace;
    guessingrows=max;
    getnames=yes;
run;

proc import datafile="&folder/loans_clean.csv"
    out=work.export_loans
    dbms=csv replace;
    guessingrows=max;
    getnames=yes;
run;

proc import datafile="&folder/payments_clean.csv"
    out=work.export_payments
    dbms=csv replace;
    guessingrows=max;
    getnames=yes;
run;

/* Customer CSV checks */
proc sql;
    select
        count(*) as Total_Rows,
        sum(missing(annual_income)) as Missing_Income,
        sum(case when not missing(annual_income)
                  and annual_income < 0 then 1 else 0 end)
            as Negative_Income,
        sum(missing(credit_score)) as Missing_Credit_Score,
        sum(case when not missing(credit_score)
                  and (credit_score < 0 or credit_score > 850)
                 then 1 else 0 end)
            as Credit_Score_Out_Of_Range,
        sum(missing(age_clean)) as Missing_Cleaned_Age
    from work.export_customers;
quit;

/* Loan CSV checks */
proc sql;
    select
        count(*) as Total_Rows,
        sum(missing(loan_amount_original)) as Missing_Original_Loan_Amount,
        sum(case when not missing(loan_amount_original)
                  and loan_amount_original < 0 then 1 else 0 end)
            as Negative_Original_Loan_Amount,
        sum(missing(interest_rate_original)) as Missing_Original_Interest_Rate,
        sum(missing(default_flag_original)) as Missing_Original_Default_Flag
    from work.export_loans;
quit;

/* Payment CSV checks */
proc sql;
    select
        count(*) as Total_Rows,
        sum(missing(amount_paid)) as Missing_Amount_Paid,
        sum(case when not missing(amount_paid)
                  and amount_paid < 0 then 1 else 0 end)
            as Negative_Amount_Paid,
        sum(missing(payment_date)) as Missing_Payment_Date
    from work.export_payments;
quit;
