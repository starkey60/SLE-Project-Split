Load "other_path" as some_data
Load "path" as employee_data 
Constrain employee_data as cleaned_employee_data { 
    Region (int) >= 32
    Region (int) > 42
    Region (string) == "test"
    Region (float) <= 32.20
    Region (float) < 42.45
    Region (string) in ["test", "test2"]
}
Visualise cleaned_employee_data
Visualise cleaned_employee_data using some_random_graph