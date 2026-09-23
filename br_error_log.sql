-- Business requirements error log check

-- 1: Employee ID must be unique and non-null

SELECT COUNT(*) AS total_records
FROM staging_employees;

SELECT COUNT(DISTINCT employee_id) AS unique_employee_ids
FROM staging_employees;

SELECT
    employee_id,
    COUNT(*) AS record_count
FROM staging_employees
GROUP BY employee_id
HAVING COUNT(*) > 1;

-- the count of them
SELECT
    COUNT(*) AS duplicate_employee_ids
FROM (
    SELECT employee_id
    FROM staging_employees
    GROUP BY employee_id
    HAVING COUNT(*) > 1
) AS duplicates;

SELECT
    employee_id,
    COUNT(*) AS record_count
FROM staging_employees
GROUP BY employee_id
HAVING COUNT(*) > 1
ORDER BY record_count DESC;

SELECT *
FROM staging_employees
WHERE employee_id IN (
    SELECT employee_id
    FROM staging_employees
    GROUP BY employee_id
    HAVING COUNT(*) > 1
)
ORDER BY employee_id;

INSERT INTO data_quality_errors (
    record_id,
    source_table,
    field_name,
    error_type,
    severity,
    error_message
)
SELECT
    employee_id,
    'staging_employees',
    'employee_id',
    'Duplicate Employee ID',
    'High',
    'Employee ID appears more than once in the incoming file.'
FROM staging_employees
GROUP BY employee_id
HAVING COUNT(*) > 1;

-- 2: Required employee demographic fields must be populated

SELECT
    SUM(CASE WHEN employee_id IS NULL THEN 1 ELSE 0 END) AS missing_employee_id,
    SUM(CASE WHEN NULLIF(TRIM(first_name), '') IS NULL THEN 1 ELSE 0 END) AS missing_first_name,
    SUM(CASE WHEN NULLIF(TRIM(last_name), '') IS NULL THEN 1 ELSE 0 END) AS missing_last_name,
    SUM(CASE WHEN date_of_birth IS NULL THEN 1 ELSE 0 END) AS missing_dob,
    SUM(CASE WHEN hire_date IS NULL THEN 1 ELSE 0 END) AS missing_hire_date,
    SUM(CASE WHEN NULLIF(TRIM(employment_status), '') IS NULL THEN 1 ELSE 0 END) AS missing_status,
    SUM(CASE WHEN NULLIF(TRIM(email), '') IS NULL THEN 1 ELSE 0 END) AS missing_email,
    SUM(CASE WHEN NULLIF(TRIM(zip_code), '') IS NULL THEN 1 ELSE 0 END) AS missing_zip
FROM staging_employees;

SELECT
    employee_id,
    first_name,
    last_name,
    email
FROM staging_employees
WHERE NULLIF(TRIM(email), '') IS NULL;

INSERT INTO data_quality_errors (
    record_id,
    source_table,
    field_name,
    error_type,
    severity,
    error_message
)
SELECT
    employee_id,
    'staging_employees',
    'email',
    'Missing Required Field',
    'High',
    'Email address is required.'
FROM staging_employees
WHERE NULLIF(TRIM(email), '') IS NULL;

SELECT
    error_type,
    severity,
    COUNT(*) AS error_count
FROM data_quality_errors
GROUP BY error_type, severity;
