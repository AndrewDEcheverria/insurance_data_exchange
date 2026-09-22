SELECT *
FROM employees;

SELECT COUNT(*) AS dependent_count
FROM dependents;

SELECT COUNT(*) AS plan_count
FROM benefit_plans;

SELECT COUNT(*) AS enrollment_count
FROM enrollments;

SELECT *
FROM employees
LIMIT 100;

SELECT *
FROM dependents
LIMIT 100;

SELECT *
FROM enrollments
LIMIT 100;

SELECT *
FROM benefit_plans;

SELECT *
FROM data_quality_errors;
