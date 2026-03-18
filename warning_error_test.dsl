/*
    This test should contain all possible LSP Errors and Warnings
*/

// inline comment
Load "data.txt" as employee_data // inline comment
Load "data.csv" as employee_data // inline comment

Filter employee_dat {
    "Income" (float) >= "20000"
    "Age" (int) <= 40.555
    "Pets" (bool) == false
    "Employment status" (string) >= "employee"
    "Region" (string) in [20, "200"]
    "Region" (string) in [20, 200]
}

Save employee_data as "save.csv" // inline comment