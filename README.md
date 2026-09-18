
# Insurance Customer Data Exchange
### Business Scenario
I have created a scenario where a company receives data from corporate customers with files containing Employees, Dependents, and Benefit Enrollments

The files contain errors and invalid data, so we will identify each error tailored to the company's requirements so that they may be entered into the downstream insurance administration system. We will follow rules from our company that the data must meet the requirements of the business. As we go we are designing the pipeline as well as the code that we can use repeatedly when the next data set comes in.

The process will look like this:

<b>Customer files → Intake → Validation → Error log → Correction →
Re-validation → Reconciliation → Production load</b>

## Business requirements
1) Employee ID must be unique and non-null 
2) Required employee demographic fields must be populated 
3) Date of birth cannot be in the future 
4) Employment status must match approved reference values 
5) Dependent records must reference an existing employee 
6) Benefit plan codes must exist in the approved reference table 
7) Coverage start date cannot precede employee hire date 
8) Coverage amount must fall within plan limits | Medium 
9) Each data load must produce an auditable error report
10) Source and target record counts must be reconciled 
<img width="858" height="883" alt="insurance_data_exchange_schema (1)" src="https://github.com/user-attachments/assets/e12d5188-167a-4251-a12a-34274ab2ad15" />










