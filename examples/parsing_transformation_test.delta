/*
    This test file should cover all possible AST transformation paths:
*/

// inline comment
Load "data.csv" as employee_data // inline comment

// ordering should be: Role -> Income -> Pets -> Age
Transform employee_data {
    dropna "Employment_status"
    dropna "Income" 
    keep "Pets" 

    rename "Employment_status" to "Role"
    sort "Income" (float) descending
    sort "Age" (int) ascending
}

Filter employee_data {
    "Income" (float) >= 15000
    "Age" (int) != 26

    "Pets" (bool) == true

    "Role" (string) in ["employee"]
    "Role" (string) == "employee"
}

Save employee_data as "save_path.csv"