
/* Banking Credit Risk & Loan Default Analytics */
/* Step 1: Inspect raw loan data */

proc contents data=work.loans_raw;
run;

proc sql;
    select count(*) as Raw_Loan_Rows
    from work.loans_raw;

    select
        count(*) as Unique_Loan_IDs,
        count(*) - count(distinct loan_id) as Rows_Beyond_Unique_IDs
    from work.loans_raw;
quit;

/* Step 2: Check missing values */

proc means data=work.loans_raw n nmiss min max;
    var loan_amount interest_rate default_flag;
run;

/* Step 3: Inspect loan status variations */

proc freq data=work.loans_raw;
    tables loan_status default_flag / missing;
run;

/* Step 4: Check repeated loan IDs */

proc sql;
    create table work.loan_id_counts as
    select
        loan_id,
        count(*) as id_count
    from work.loans_raw
    group by loan_id
    having count(*) > 1
    order by id_count desc, loan_id;
quit;

proc print data=work.loan_id_counts(obs=30);
run;



/* ============================================================
   Project: Banking Credit Risk & Loan Default Analytics
   Program: 06_clean_loans.sas
   Purpose:
   1. Standardize loan IDs and statuses
   2. Validate loan amounts, interest rates and default flags
   3. Convert dates into SAS date values
   4. Remove exact duplicate rows only
   5. Save the cleaned loan dataset permanently
   ============================================================ */

libname project "/home/u64620803/Bank_credit_risk_analytics";


/* STEP 1: Clean and standardize loan records */

data work.loans_clean_pre;

    set work.loans_raw;

    length
        loan_id_clean $9
        customer_id_clean $9
        loan_status_clean $12
        loan_amount_quality_flag $12
        interest_rate_quality_flag $12
        default_flag_quality $12
        default_date_quality_flag $12
        origination_date_quality_flag $12
        maturity_date_quality_flag $12
        snapshot_date_quality_flag $12
        default_date_original $11
        origination_date_original $11
        maturity_date_original $11
        snapshot_date_original $11
        default_consistency_flag $25
    ;

    /* Preserve original loan values */

    loan_amount_original = loan_amount;
    interest_rate_original = interest_rate;
    default_flag_original = default_flag;

    default_date_original = default_date;
    origination_date_original = origination_date;
    maturity_date_original = maturity_date;
    snapshot_date_original = snapshot_date;


    /* Standardize IDs */

    loan_id_clean = upcase(strip(loan_id));
    customer_id_clean = upcase(strip(customer_id));


    /* Standardize loan status */

    select (upcase(strip(loan_status)));

        when ('CLOSED')
            loan_status_clean = 'Closed';

        when ('CURRENT')
            loan_status_clean = 'Current';

        when ('DEFAULT', 'DEFAULTED')
            loan_status_clean = 'Defaulted';

        when ('LATE')
            loan_status_clean = 'Late';

        when ('OVERDUE')
            loan_status_clean = 'Overdue';

        otherwise
            loan_status_clean = 'Unknown';

    end;


    /* Validate loan amount */

    loan_amount_clean = loan_amount;

    if missing(loan_amount) then
        loan_amount_quality_flag = 'Missing';

    else if loan_amount < 0 then do;
        loan_amount_quality_flag = 'Review';
        loan_amount_clean = .;
    end;

    else
        loan_amount_quality_flag = 'Valid';


    /* Validate interest rate */

    if missing(interest_rate) then
        interest_rate_quality_flag = 'Missing';

    else if interest_rate < 0 or interest_rate > 100 then
        interest_rate_quality_flag = 'Review';

    else
        interest_rate_quality_flag = 'Valid';


    /* Validate default flag */

    if missing(default_flag) then
        default_flag_quality = 'Missing';

    else if default_flag not in (0, 1) then do;
        default_flag_quality = 'Review';
        default_flag = .;
    end;

    else
        default_flag_quality = 'Valid';


    /* Convert origination date */

    if missing(strip(origination_date)) then
        origination_date_sas = .;

    else if lengthn(strip(origination_date)) = 10
         and substr(strip(origination_date), 5, 1) = '-' then
        origination_date_sas =
            input(strip(origination_date), ?? yymmdd10.);

    else if index(strip(origination_date), '/') > 0 then
        origination_date_sas =
            input(strip(origination_date), ?? ddmmyy10.);

    else if index(strip(origination_date), '.') > 0 then
        origination_date_sas =
            input(strip(origination_date), ?? ddmmyy10.);

    else
        origination_date_sas =
            input(strip(origination_date), ?? date11.);

    format origination_date_sas date9.;


    /* Convert maturity date */

    if missing(strip(maturity_date)) then
        maturity_date_sas = .;

    else if lengthn(strip(maturity_date)) = 10
         and substr(strip(maturity_date), 5, 1) = '-' then
        maturity_date_sas =
            input(strip(maturity_date), ?? yymmdd10.);

    else if index(strip(maturity_date), '/') > 0 then
        maturity_date_sas =
            input(strip(maturity_date), ?? ddmmyy10.);

    else if index(strip(maturity_date), '.') > 0 then
        maturity_date_sas =
            input(strip(maturity_date), ?? ddmmyy10.);

    else
        maturity_date_sas =
            input(strip(maturity_date), ?? date11.);

    format maturity_date_sas date9.;


    /* Convert default date */

    if missing(strip(default_date)) then
        default_date_sas = .;

    else if lengthn(strip(default_date)) = 10
         and substr(strip(default_date), 5, 1) = '-' then
        default_date_sas =
            input(strip(default_date), ?? yymmdd10.);

    else if index(strip(default_date), '/') > 0 then
        default_date_sas =
            input(strip(default_date), ?? ddmmyy10.);

    else if index(strip(default_date), '.') > 0 then
        default_date_sas =
            input(strip(default_date), ?? ddmmyy10.);

    else
        default_date_sas =
            input(strip(default_date), ?? date11.);

    format default_date_sas date9.;


    /* Convert snapshot date */

    if missing(strip(snapshot_date)) then
        snapshot_date_sas = .;

    else if lengthn(strip(snapshot_date)) = 10
         and substr(strip(snapshot_date), 5, 1) = '-' then
        snapshot_date_sas =
            input(strip(snapshot_date), ?? yymmdd10.);

    else if index(strip(snapshot_date), '/') > 0 then
        snapshot_date_sas =
            input(strip(snapshot_date), ?? ddmmyy10.);

    else if index(strip(snapshot_date), '.') > 0 then
        snapshot_date_sas =
            input(strip(snapshot_date), ?? ddmmyy10.);

    else
        snapshot_date_sas =
            input(strip(snapshot_date), ?? date11.);

    format snapshot_date_sas date9.;


    /* Flag missing or unconverted dates */

    if missing(strip(origination_date)) then
        origination_date_quality_flag = 'Missing';
    else if missing(origination_date_sas) then
        origination_date_quality_flag = 'Review';
    else
        origination_date_quality_flag = 'Valid';

    if missing(strip(maturity_date)) then
        maturity_date_quality_flag = 'Missing';
    else if missing(maturity_date_sas) then
        maturity_date_quality_flag = 'Review';
    else
        maturity_date_quality_flag = 'Valid';

    if missing(strip(default_date)) then
        default_date_quality_flag = 'Missing';
    else if missing(default_date_sas) then
        default_date_quality_flag = 'Review';
    else
        default_date_quality_flag = 'Valid';

    if missing(strip(snapshot_date)) then
        snapshot_date_quality_flag = 'Missing';
    else if missing(snapshot_date_sas) then
        snapshot_date_quality_flag = 'Review';
    else
        snapshot_date_quality_flag = 'Valid';


    /* Check whether default flag and loan status agree */

    if missing(default_flag) then
        default_consistency_flag = 'Cannot Confirm';

    else if default_flag = 1
         and loan_status_clean = 'Defaulted' then
        default_consistency_flag = 'Consistent';

    else if default_flag = 0
         and loan_status_clean ne 'Defaulted' then
        default_consistency_flag = 'Consistent';

    else
        default_consistency_flag = 'Review';

run;


/* STEP 2: Remove exact duplicate rows only */

/* All columns are compared.
   Rows with differences are retained for investigation. */

proc sort data=work.loans_clean_pre
          out=work.loans_clean
          noduprecs
          dupout=work.loan_exact_duplicates;
    by _all_;
run;


/* STEP 3: Save cleaned data permanently */

data project.loans_clean;
    set work.loans_clean;
run;


/* STEP 4: Compare row counts */

title "Loan Cleaning Row Count Validation";

proc sql;
    select count(*) as Raw_Rows
    from work.loans_raw;

    select count(*) as Rows_Before_Deduplication
    from work.loans_clean_pre;

    select count(*) as Final_Clean_Rows
    from work.loans_clean;

    select count(*) as Exact_Duplicate_Rows
    from work.loan_exact_duplicates;

    select
        count(*) as Final_Rows,
        count(distinct loan_id_clean) as Unique_Loan_IDs
    from work.loans_clean;
quit;


/* STEP 5: Review standardized loan statuses */

title "Standardized Loan Status";

proc freq data=work.loans_clean;
    tables loan_status_clean / missing;
run;


/* STEP 6: Review quality flags */

title "Loan Amount Quality";

proc freq data=work.loans_clean;
    tables loan_amount_quality_flag / missing;
run;

title "Interest Rate Quality";

proc freq data=work.loans_clean;
    tables interest_rate_quality_flag / missing;
run;

title "Default Flag Quality";

proc freq data=work.loans_clean;
    tables default_flag_quality / missing;
run;


/* STEP 7: Check date conversion results */

title "Loan Date Conversion Quality";

proc freq data=work.loans_clean;
    tables
        origination_date_quality_flag
        maturity_date_quality_flag
        default_date_quality_flag
        snapshot_date_quality_flag
        / missing;
run;


/* STEP 8: Review default flag and status consistency */

title "Default Flag and Loan Status Consistency";

proc freq data=work.loans_clean;
    tables
        default_consistency_flag
        * loan_status_clean
        / missing;
run;


/* STEP 9: Inspect suspicious loan amounts and rates */

title "Loan Amounts Requiring Review";

proc print data=work.loans_clean;
    where loan_amount_quality_flag = 'Review';
    var loan_id loan_amount loan_amount_clean
        loan_amount_quality_flag loan_status_clean;
run;

title "Interest Rates Requiring Review";

proc print data=work.loans_clean;
    where interest_rate_quality_flag = 'Review';
    var loan_id interest_rate interest_rate_quality_flag;
run;

title;
