/*
    this is a block comment
*/

Load "data.csv" as employee_data // inline
Constrain employee_data as cleaned_employee_data {
    Region (string) in ["NL", "BE"]
    Income (float) >= 30000
    Employment_status (string) == "employee"
    Age (int) < 30
}
//another inline