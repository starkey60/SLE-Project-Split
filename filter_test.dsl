/*
    This test file covers filteriing a dataset
*/

// inline comment
Load "data.csv" as employee_data // inline comment

Transform employee_data {
    dropna "Income"
    dropna "Employment_status"
    keep "Age"
    keep "Pets"
    keep "Region"
}

Filter employee_data {
    "Income" (float) >= 20000
    "Age" (int) <= 40
    "Pets" (bool) != false
    "Employment_status" (string) == "employee"
    "Region" (string) in ["NL", "BE"]
}

Save employee_data as "save.csv" // inline comment