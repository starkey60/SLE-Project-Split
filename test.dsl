/*
    this is a block comment 
*/ 

Load "data.csv" as employee_data // inline
Constrain employee_data as cleaned_employee_data {
    Region (string) in ["NL", "BE"]
    Income (float) dropna
    Employment_status (string) dropna
    Income (float) >= 30000
    Employment_status (string) == "employee"
    Age (int) < 30
    Pets (bool) keep
}
Visualise cleaned_employee_data
Visualise cleaned_employee_data using table_image
//another inline