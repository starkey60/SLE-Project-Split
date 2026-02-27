Load "path" as employee_data 
Constrain employee_data as cleaned_employee_data { 
    Region in ["NL", "BE"]
    Income >= 30000
    Employment_status == "employee"
    Age < 30
}
Visualise cleaned_employee_data