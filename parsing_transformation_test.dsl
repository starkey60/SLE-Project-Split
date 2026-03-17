/*
    This test file should cover all possible AST transformation paths:
*/

// inline comment
Load "data.csv" as employee_data // inline comment

Filter employee_data {
    "Income" (float) in [2000, 25000]

    "Income" (float) >= 20000
    "Income" (float) > 20000
    "Income" (float) < 20000
    "Income" (float) <= 20000
    "Age" (int) == 40

    "Pets" (bool) == true
    "Pets" (bool) != false

    "Employment_status" (string) in ["employee"]
    "Employment_status" (string) == "employee"
}

Transform employee_data {
    dropna "Region"
    dropna "Income" 
    keep "Pets" 
    dropna "Employment_status" 

    rename "Employment_status" to "Role"
    sort "Income" (float) descending
    sort "Age" (int) ascending
}

Visualise employee_data

GroupBy employee_data by "Region" count

GroupBy employee_data by "Region" avg "Income" (float)

Visualise employee_data using table_image

Save employee_data as "save_path.csv"