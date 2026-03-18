/*
    This test file currently covers keep of transformation (ordering plus keeping cols):
*/

// inline comment
Load "data.csv" as employee_data // inline comment

Transform employee_data {
    keep "Pets"
    keep "Region"
    keep "Income"
}

Save employee_data as "save.csv" // inline comment