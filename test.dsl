Load "path" as employee_data 
Constrain employee_data as cleaned_employee_data { 
    Region (string) in ["NL", "BE"]
    Income (float) >= 30000.00
    Employment_status (string) == "employee"
    Age (int) < 30
}
Visualise cleaned_employee_data