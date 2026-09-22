CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    date_of_birth DATE,
    hire_date DATE,
    employment_status VARCHAR(20),
    email VARCHAR(150),
    zip_code VARCHAR(10)
);

CREATE TABLE dependents (
    dependent_id INT PRIMARY KEY,
    employee_id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    relationship VARCHAR(20),
    date_of_birth DATE,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

CREATE TABLE benefit_plans (
    plan_code VARCHAR(30) PRIMARY KEY,
    benefit_type VARCHAR(30),
    plan_name VARCHAR(50),
    employee_cost_pct DECIMAL(5,2),
    min_coverage DECIMAL(12,2),
    max_coverage DECIMAL(12,2)
);

CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY,
    employee_id INT,
    plan_code VARCHAR(30),
    coverage_start_date DATE,
    coverage_amount DECIMAL(12,2),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (plan_code) REFERENCES benefit_plans(plan_code)
);

CREATE TABLE data_quality_errors (
    error_id INT AUTO_INCREMENT PRIMARY KEY,
    record_id INT,
    source_table VARCHAR(50),
    field_name VARCHAR(50),
    error_type VARCHAR(100),
    severity VARCHAR(20),
    error_message VARCHAR(255),
    detected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
