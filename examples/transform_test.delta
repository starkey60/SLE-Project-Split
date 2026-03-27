/*
    This test file currently covers keep of transformation (ordering plus keeping cols):
*/

// inline comment
Load "data.csv" as employee_data // inline comment

//output ordering should be Animals-Region-Income
Transform employee_data {
    keep "Pets"
    keep "Region"
    keep "Income"
    dropna "Pets"
    dropna"Income"
    dropna "Region"
    rename "Pets" to "Animals" //should keep Pets position in the dataset
}

Save employee_data as "save.csv" // inline comment