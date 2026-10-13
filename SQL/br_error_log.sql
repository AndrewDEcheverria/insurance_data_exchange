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

-- 3: Date and birth must be valid

SELECT
    employee_id,
    first_name,
    last_name,
    date_of_birth
FROM staging_employees
WHERE date_of_birth > CURRENT_DATE;

SELECT
    employee_id,
    first_name,
    last_name,
    hire_date
FROM staging_employees
WHERE hire_date > CURRENT_DATE;

SELECT
    employee_id,
    first_name,
    last_name,
    date_of_birth,
    hire_date
FROM staging_employees
WHERE hire_date < date_of_birth;

SELECT
    employee_id,
    first_name,
    last_name,
    hire_date
FROM staging_employees
WHERE hire_date > CURRENT_DATE;

SELECT
    employee_id,
    first_name,
    last_name,
    date_of_birth,
    hire_date
FROM staging_employees
WHERE hire_date < date_of_birth
AND date_of_birth <= CURRENT_DATE;

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
    'date_of_birth',
    'Future Date of Birth',
    'High',
    'Date of birth cannot be in the future.'
FROM staging_employees
WHERE date_of_birth > CURRENT_DATE;

SELECT
    error_type,
    severity,
    COUNT(*) AS error_count
FROM data_quality_errors
GROUP BY error_type, severity;

-- 4: Validate employee status

SELECT
    employment_status,
    COUNT(*) AS record_count
FROM staging_employees
GROUP BY employment_status
ORDER BY record_count DESC;

SELECT
    employee_id,
    first_name,
    last_name,
    employment_status
FROM staging_employees
WHERE employment_status IS NOT NULL
  AND TRIM(employment_status) <> ''
  AND LOWER(TRIM(employment_status)) NOT IN (
      'active',
      'inactive',
      'terminated'
  );

SELECT
    COUNT(*) AS invalid_status_records
FROM staging_employees
WHERE employment_status IS NOT NULL
  AND TRIM(employment_status) <> ''
  AND LOWER(TRIM(employment_status)) NOT IN (
      'active',
      'inactive',
      'terminated'
  );
  
  -- 5: Dependents must reference existing employee
SELECT
    relationship,
    COUNT(*) AS record_count
FROM staging_dependents
GROUP BY relationship
ORDER BY record_count DESC;

SELECT
    dependent_id,
    employee_id,
    relationship
FROM staging_dependents
WHERE relationship IS NULL
   OR TRIM(relationship) = ''
   OR LOWER(TRIM(relationship)) NOT IN (
       'spouse',
       'child'
   );
   
SELECT
    d.dependent_id,
    d.employee_id,
    d.first_name,
    d.last_name
FROM staging_dependents AS d
LEFT JOIN staging_employees AS e
    ON d.employee_id = e.employee_id
WHERE d.employee_id IS NULL
   OR e.employee_id IS NULL;
   
INSERT INTO data_quality_errors (
    record_id,
    source_table,
    field_name,
    error_type,
    severity,
    error_message
)
SELECT
    d.dependent_id,
    'staging_dependents',
    'employee_id',
    'Orphan Dependent',
    'High',
    CONCAT(
        'Dependent references employee ID ',
        d.employee_id,
        ', which does not exist in staging_employees.'
    )
FROM staging_dependents AS d
LEFT JOIN staging_employees AS e
    ON d.employee_id = e.employee_id
WHERE d.employee_id IS NULL
   OR e.employee_id IS NULL;
   
SELECT
    error_type,
    severity,
    COUNT(*) AS error_count
FROM data_quality_errors
GROUP BY error_type, severity
ORDER BY error_type;

-- 6: Benefit plan codes

SELECT
    plan_code,
    COUNT(*) AS record_count
FROM staging_enrollments
GROUP BY plan_code
ORDER BY record_count DESC;
 
SELECT
    e.enrollment_id,
    e.employee_id,
    e.plan_code
FROM staging_enrollments AS e
LEFT JOIN benefit_plans AS p
    ON e.plan_code = p.plan_code
WHERE p.plan_code IS NULL;

SELECT
    COUNT(*) AS invalid_plan_records
FROM staging_enrollments AS e
LEFT JOIN benefit_plans AS p
    ON e.plan_code = p.plan_code
WHERE p.plan_code IS NULL;

INSERT INTO data_quality_errors (
    record_id,
    source_table,
    field_name,
    error_type,
    severity,
    error_message
)
SELECT
    e.enrollment_id,
    'staging_enrollments',
    'plan_code',
    'Invalid Plan Code',
    'High',
    CONCAT(
        'Plan code ',
        e.plan_code,
        ' does not exist in the approved benefit_plans reference table.'
    )
FROM staging_enrollments AS e
LEFT JOIN benefit_plans AS p
    ON e.plan_code = p.plan_code
WHERE p.plan_code IS NULL;

SELECT
    error_type,
    severity,
    COUNT(*) AS error_count
FROM data_quality_errors
GROUP BY error_type, severity
ORDER BY error_type;

-- 7: coverage date validation

SELECT
    e.enrollment_id,
    e.employee_id,
    emp.hire_date,
    e.coverage_start_date
FROM staging_enrollments AS e
JOIN staging_employees AS emp
    ON e.employee_id = emp.employee_id
WHERE e.coverage_start_date < emp.hire_date;

INSERT INTO data_quality_errors (
    record_id,
    source_table,
    field_name,
    error_type,
    severity,
    error_message
)
SELECT
    e.enrollment_id,
    'staging_enrollments',
    'coverage_start_date',
    'Coverage Before Hire Date',
    'High',
    'Coverage start date cannot precede the employee hire date.'
FROM staging_enrollments AS e
JOIN staging_employees AS emp
    ON e.employee_id = emp.employee_id
WHERE e.coverage_start_date < emp.hire_date;

SELECT
    error_type,
    severity,
    COUNT(*) AS error_count
FROM data_quality_errors
GROUP BY error_type, severity
ORDER BY error_type;

-- 8: Covereage amounts validated

SELECT
    e.enrollment_id,
    e.employee_id,
    e.plan_code,
    e.coverage_amount,
    p.min_coverage,
    p.max_coverage
FROM staging_enrollments AS e
JOIN benefit_plans AS p
    ON e.plan_code = p.plan_code
WHERE e.coverage_amount < p.min_coverage
   OR e.coverage_amount > p.max_coverage;
   
SELECT
    CASE
        WHEN e.coverage_amount < p.min_coverage
            THEN 'Below Minimum'
        WHEN e.coverage_amount > p.max_coverage
            THEN 'Above Maximum'
    END AS violation_type,
    COUNT(*) AS record_count
FROM staging_enrollments AS e
JOIN benefit_plans AS p
    ON e.plan_code = p.plan_code
WHERE e.coverage_amount < p.min_coverage
   OR e.coverage_amount > p.max_coverage
GROUP BY violation_type;

SELECT
    e.enrollment_id,
    e.employee_id,
    e.plan_code,
    e.coverage_amount,
    p.min_coverage,
    p.max_coverage
FROM staging_enrollments AS e
JOIN benefit_plans AS p
    ON e.plan_code = p.plan_code
WHERE e.coverage_amount < p.min_coverage
   OR e.coverage_amount > p.max_coverage
LIMIT 10;

INSERT INTO data_quality_errors (
    record_id,
    source_table,
    field_name,
    error_type,
    severity,
    error_message
)
SELECT
    e.enrollment_id,
    'staging_enrollments',
    'coverage_amount',
    CASE
        WHEN e.coverage_amount < p.min_coverage
            THEN 'Coverage Below Minimum'
        WHEN e.coverage_amount > p.max_coverage
            THEN 'Coverage Above Maximum'
    END,
    'Medium',
    CASE
        WHEN e.coverage_amount < p.min_coverage
            THEN CONCAT(
                'Coverage amount ',
                e.coverage_amount,
                ' is below the plan minimum of ',
                p.min_coverage,
                '.'
            )
        WHEN e.coverage_amount > p.max_coverage
            THEN CONCAT(
                'Coverage amount ',
                e.coverage_amount,
                ' exceeds the plan maximum of ',
                p.max_coverage,
                '.'
            )
    END
FROM staging_enrollments AS e
JOIN benefit_plans AS p
    ON e.plan_code = p.plan_code
WHERE e.coverage_amount < p.min_coverage
   OR e.coverage_amount > p.max_coverage;
   
SELECT
    error_type,
    severity,
    COUNT(*) AS error_count
FROM data_quality_errors
WHERE error_type IN (
    'Coverage Below Minimum',
    'Coverage Above Maximum'
)
GROUP BY error_type, severity
ORDER BY error_type;
