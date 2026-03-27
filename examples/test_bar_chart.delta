/*
    This test file covers building a bar chart
*/
Load "data.csv" as employee_data
Transform employee_data {
    dropna "Region"
    dropna "Income"
    keep "Region"
    keep "Income"
}
GroupBy employee_data by "Region" count
Visualise employee_data using bar_chart
Save employee_data as "save.csv"