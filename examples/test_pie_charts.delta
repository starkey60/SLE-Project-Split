/*
    This test file covers building a pie chart 
*/

// inline comment
Load "data.csv" as employee_data // inline comment

//output ordering should be Region->Income
Transform employee_data {
    dropna "Region"
    dropna "Income"
    keep "Pets"
}

GroupBy employee_data by "Region" count

Visualise employee_data using pie_chart

Save employee_data as "save.csv" // inline comment