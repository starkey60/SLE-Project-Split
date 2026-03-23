/*
    Test file for visualisations
*/

// step 1: load the dataset
Load "data.csv" as employee_data

// step 2: clean - drop nulls first
Transform employee_data {
    dropna "Region"
    dropna "Income"
}

// step 4: show the cleaned, renamed, sorted data
Visualise employee_data

// step 5: save as image
Visualise employee_data using table_image

// step 6: aggregate - count per region
GroupBy employee_data by "Region" count

// step 6: pie chart
Visualise employee_data using pie_chart
