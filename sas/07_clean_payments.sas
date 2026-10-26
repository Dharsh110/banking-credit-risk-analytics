
/*========================================================
  PROJECT: Banking Credit Risk & Loan Default Analytics
  PROGRAM: 07_clean_payments.sas
  PURPOSE: Inspect, clean and validate payment data
========================================================*/

libname project
    "/home/u64620803/Bank_credit_risk_analytics";


/* STEP 1: Inspect raw payment data */

proc contents data=work.payments_raw;
    title "Raw Payment Dataset Structure";
run;

proc sql;
    select count(*) as Raw_Payment_Rows
    from work.payments_raw;

    select count(distinct payment_id) as Unique_Payment_IDs,
           count(*) - count(distinct payment_id)
               as Rows_Beyond_Unique_IDs
    from work.payments_raw;
quit;


/* STEP 2: Check numeric ranges and payment statuses */

proc means data=work.payments_raw
    n nmiss min p25 median p75 max;
    var amount_due amount_paid days_late late_fee;
    title "Payment Numeric Data Quality Summary";
run;

proc freq data=work.payments_raw;
    tables payment_status / missing;
    title "Raw Payment Status Distribution";
run;


/* STEP 3: Inspect duplicate payment IDs */

proc sql;
    create table work.payment_id_counts as
    select payment_id,
           count(*) as id_count
    from work.payments_raw
    group by payment_id
    having count(*) > 1;

    create table work.payment_duplicate_details as
    select a.*
    from work.payments_raw as a
    inner join work.payment_id_counts as b
        on a.payment_id = b.payment_id
    order by a.payment_id;
quit;


/* STEP 4: Identify data-quality issues before cleaning */

data work.payment_quality_check;
    set work.payments_raw;

    length payment_date_quality $12
           amount_paid_quality $12
           amount_due_quality $12
           payment_amount_review $24;

    if missing(payment_date) then
        payment_date_quality = "Missing";
    else payment_date_quality = "Present";

    if missing(amount_paid) then
        amount_paid_quality = "Missing";
    else if amount_paid < 0 then
        amount_paid_quality = "Negative";
    else amount_paid_quality = "Valid";

    if missing(amount_due) then
        amount_due_quality = "Missing";
    else if amount_due < 0 then
        amount_due_quality = "Negative";
    else amount_due_quality = "Valid";

    if missing(amount_paid) then
        payment_amount_review = "Missing amount";
    else if amount_paid < 0 then
        payment_amount_review = "Negative payment";
    else if not missing(amount_due)
        and amount_paid > amount_due then
        payment_amount_review = "Paid exceeds due";
    else payment_amount_review = "No initial issue";
run;

proc freq data=work.payment_quality_check;
    tables payment_status*payment_date_quality
           amount_paid_quality
           amount_due_quality
           payment_amount_review / missing;
    title "Payment Data Quality Checks";
run;


/* STEP 5: Inspect unusual records */

proc print data=work.payment_quality_check(obs=50);
    where amount_paid < 0
       or amount_due < 0
       or days_late < 0
       or late_fee < 0
       or (not missing(amount_paid)
           and not missing(amount_due)
           and amount_paid > amount_due);

    var payment_id loan_id installment_no
        due_date payment_date amount_due
        amount_paid payment_status days_late late_fee;

    title "Payment Anomalies Requiring Review";
run;


/* STEP 6: Remove exact duplicate rows only
   Preserve the removed rows for audit. */

proc sort data=work.payments_raw
          out=work.payments_unique
          noduprecs
          dupout=project.payment_exact_duplicates;
    by _all_;
run;


/* STEP 7: Standardize fields and create quality flags */

data work.payments_clean;
    set work.payments_unique;

    length payment_id_clean $11
           loan_id_clean $9
           payment_status_clean $12
           payment_date_quality $12
           amount_paid_quality $12
           amount_due_quality $12
           days_late_quality $12
           late_fee_quality $12
           payment_date_status_check $20
           payment_amount_review $24;

    /* Standardize identifiers and status */
    payment_id_clean = upcase(strip(payment_id));
    loan_id_clean = upcase(strip(loan_id));
    payment_status_clean = propcase(strip(payment_status));

    format due_date payment_date yymmdd10.;

    /* Payment date quality */
    if missing(payment_date) then
        payment_date_quality = "Missing";
    else payment_date_quality = "Valid";

    /* Amount paid: preserve original; flag invalid values */
    if missing(amount_paid) then do;
        amount_paid_quality = "Missing";
        amount_paid_clean = .;
    end;
    else if amount_paid < 0 then do;
        amount_paid_quality = "Review";
        amount_paid_clean = .;
    end;
    else do;
        amount_paid_quality = "Valid";
        amount_paid_clean = amount_paid;
    end;

    /* Amount due */
    if missing(amount_due) then
        amount_due_quality = "Missing";
    else if amount_due < 0 then
        amount_due_quality = "Review";
    else amount_due_quality = "Valid";

    /* Days late */
    if missing(days_late) then
        days_late_quality = "Missing";
    else if days_late < 0 then
        days_late_quality = "Review";
    else days_late_quality = "Valid";

    /* Late fee */
    if missing(late_fee) then
        late_fee_quality = "Missing";
    else if late_fee < 0 then
        late_fee_quality = "Review";
    else late_fee_quality = "Valid";

    /* Compare payment status with payment date */
    if payment_status_clean = "Missed"
       and missing(payment_date) then
        payment_date_status_check = "Consistent";
    else if payment_status_clean = "Missed"
       and not missing(payment_date) then
        payment_date_status_check = "Review";
    else if payment_status_clean ne "Missed"
       and missing(payment_date) then
        payment_date_status_check = "Review";
    else payment_date_status_check = "Consistent";

    /* Flag unusual amounts */
    if missing(amount_paid) then
        payment_amount_review = "Missing amount";
    else if amount_paid < 0 then
        payment_amount_review = "Negative amount";
    else if not missing(amount_due)
        and amount_paid > amount_due then
        payment_amount_review = "Exceeds amount due";
    else payment_amount_review = "No initial issue";

    label
        amount_paid_clean = "Payment Amount for Analysis"
        payment_amount_review = "Payment Amount Review Flag"
        payment_date_status_check = "Payment Date and Status Check";
run;


/* STEP 8: Save the permanent cleaned dataset */

data project.payments_clean;
    set work.payments_clean;
run;


/* STEP 9: Validate final row counts and identifiers */

proc sql;
    select count(*) as Raw_Rows
    from work.payments_raw;

    select count(*) as Clean_Rows
    from project.payments_clean;

    select count(distinct payment_id_clean) as Unique_Payment_IDs
    from project.payments_clean;

    select count(*) as Missing_Payment_IDs
    from project.payments_clean
    where missing(payment_id_clean);

    select count(*) as Exact_Duplicate_Rows_Removed
    from project.payment_exact_duplicates;
quit;


/* STEP 10: Final quality validation */

proc freq data=project.payments_clean;
    tables payment_status_clean
           amount_paid_quality
           amount_due_quality
           days_late_quality
           late_fee_quality
           payment_date_quality
           payment_date_status_check
           payment_amount_review / missing;
    title "Final Payment Data Quality Validation";
run;

proc contents data=project.payments_clean;
    title "Final Clean Payments Dataset";
run;

title;
