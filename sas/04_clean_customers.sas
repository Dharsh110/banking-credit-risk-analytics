
/* ============================================================
   Banking Credit Risk & Loan Default Analytics
   Program: 04_clean_customers.sas
   Purpose: Clean and standardize customer data
   Input:   WORK.CUSTOMERS_RAW
   Output:  WORK.CUSTOMERS_CLEAN
   ============================================================ */


/* STEP 1: CREATE CLEANED CUSTOMER DATASET */

data work.customers_clean;

    set work.customers_raw;


    /* --------------------------------------------------------
       1. STANDARDIZE CUSTOMER ID
       -------------------------------------------------------- */

    customer_id_clean = upcase(strip(customer_id));


    /* --------------------------------------------------------
       2. STANDARDIZE GENDER
       -------------------------------------------------------- */

    length gender_clean $10;

    if upcase(strip(gender)) in ('F', 'FEMALE') then
        gender_clean = 'Female';

    else if upcase(strip(gender)) in ('M', 'MALE') then
        gender_clean = 'Male';

    else if missing(strip(gender)) then
        gender_clean = 'Unknown';

    else
        gender_clean = propcase(strip(gender));


    /* --------------------------------------------------------
       3. CONVERT DATE OF BIRTH
       Supports YYYY-MM-DD, DD/MM/YYYY, DD.MM.YYYY,
       and DD-Mon-YYYY formats.
       -------------------------------------------------------- */

    length dob_date customer_since_date 8;

    if not missing(strip(date_of_birth)) then do;

        if substr(strip(date_of_birth), 5, 1) = '-'
           and lengthn(strip(date_of_birth)) = 10 then
            dob_date = input(
                strip(date_of_birth), ?? yymmdd10.
            );

        else if index(strip(date_of_birth), '/') > 0 then
            dob_date = input(
                strip(date_of_birth), ?? ddmmyy10.
            );

        else if index(strip(date_of_birth), '.') > 0 then
            dob_date = input(
                strip(date_of_birth), ?? ddmmyy10.
            );

        else
            dob_date = input(
                strip(date_of_birth), ?? date11.
            );

    end;

    else dob_date = .;


    /* --------------------------------------------------------
       4. CONVERT CUSTOMER SINCE DATE
       -------------------------------------------------------- */

    if not missing(strip(customer_since)) then do;

        if substr(strip(customer_since), 5, 1) = '-'
           and lengthn(strip(customer_since)) = 10 then
            customer_since_date = input(
                strip(customer_since), ?? yymmdd10.
            );

        else if index(strip(customer_since), '/') > 0 then
            customer_since_date = input(
                strip(customer_since), ?? ddmmyy10.
            );

        else if index(strip(customer_since), '.') > 0 then
            customer_since_date = input(
                strip(customer_since), ?? ddmmyy10.
            );

        else
            customer_since_date = input(
                strip(customer_since), ?? date11.
            );

    end;

    else customer_since_date = .;

    format dob_date customer_since_date date9.;


    /* --------------------------------------------------------
       5. PRESERVE ORIGINAL AGE AND FLAG SUSPICIOUS VALUES
       -------------------------------------------------------- */

    age_original = age;
    age_clean = age;

    length age_quality_flag $12;

    if missing(age) then do;
        age_clean = .;
        age_quality_flag = 'Missing';
    end;

    else if age < 18 or age > 100 then do;
        age_clean = .;
        age_quality_flag = 'Review';
    end;

    else
        age_quality_flag = 'Valid';


    /* --------------------------------------------------------
       6. STANDARDIZE CITY AND STATE
       -------------------------------------------------------- */

    length city_clean $18 state_clean $13;

    city_clean = propcase(strip(city));
    state_clean = propcase(strip(state));


    /* --------------------------------------------------------
       7. STANDARDIZE EMAIL
       -------------------------------------------------------- */

    length email_clean $35;

    email_clean = lowcase(strip(email));


    /* --------------------------------------------------------
       8. CONVERT PHONE TO CHARACTER
       Note: Source phone values are numeric, so any leading
       zeros already lost during import cannot be recovered.
       -------------------------------------------------------- */

    length phone_clean $20;

    if not missing(phone) then
        phone_clean = strip(put(phone, 32.));
    else
        phone_clean = '';


    /* --------------------------------------------------------
       9. FLAG MISSING OR SUSPICIOUS INCOME
       -------------------------------------------------------- */

    length income_quality_flag $12;

    if missing(annual_income) then
        income_quality_flag = 'Missing';

    else if annual_income < 0 then
        income_quality_flag = 'Review';

    else
        income_quality_flag = 'Valid';


    /* --------------------------------------------------------
       10. FLAG CREDIT SCORES OUTSIDE SCREENING RANGE
       -------------------------------------------------------- */

    length credit_score_quality_flag $12;

    if missing(credit_score) then
        credit_score_quality_flag = 'Missing';

    else if credit_score < 300 or credit_score > 850 then
        credit_score_quality_flag = 'Review';

    else
        credit_score_quality_flag = 'Valid';

run;


/* STEP 2: CHECK CLEANED DATASET STRUCTURE */

proc contents data=work.customers_clean;
run;


/* STEP 3: VERIFY STANDARDIZED GENDER */

proc freq data=work.customers_clean;
    tables gender_clean / missing;
run;


/* STEP 4: REVIEW AGE QUALITY FLAGS */

proc freq data=work.customers_clean;
    tables age_quality_flag / missing;
run;


/* STEP 5: VALIDATE DATE CONVERSION */

proc sql;

    select
        count(*) as Total_Rows,

        sum(
            not missing(strip(date_of_birth))
            and missing(dob_date)
        ) as DOB_Conversion_Failures,

        sum(
            not missing(strip(customer_since))
            and missing(customer_since_date)
        ) as Cust_Since_Conversion_Failures

    from work.customers_clean;

quit;


/* STEP 6: REVIEW SAMPLE DATE CONVERSIONS */

proc print data=work.customers_clean(obs=20);

    var customer_id
        date_of_birth
        dob_date
        customer_since
        customer_since_date;

run;


/* STEP 7: VERIFY MISSING INCOME AND CREDIT SCORES */

proc freq data=work.customers_clean;
    tables income_quality_flag
           credit_score_quality_flag / missing;
run;


/* STEP 8: CONFIRM RAW AND CLEANED ROW COUNTS */

proc sql;

    select count(*) as Raw_Rows
    from work.customers_raw;

    select count(*) as Cleaned_Rows
    from work.customers_clean;

quit;


/* END OF CUSTOMER CLEANING PROGRAM */
