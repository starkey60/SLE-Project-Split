/*
    Test file for preprocessing features:
    - dropna
    - Rename
    - Sort
    - GroupBy
*/

// step 1: load the dataset
Load "data.csv" as employee_data

// step 2: clean - drop nulls first
Transform employee_data {
    dropna "Income"
    dropna "Employment_status"
    keep "Region"
    keep "Income"
    keep "Employment_status"
    keep "Age"
    keep "Pets"
    rename "Employment_status" to "Role"
    sort "Income" (float) descending
}

// step 3: filter the data
Filter employee_data {
    "Region" (string) in ["NL", "BE"]
    "Income" (float) >= 20000
    "Age" (int) < 40
}

// step 4: show the cleaned, renamed, sorted data
Visualise employee_data

// step 5: aggregate - count per region
GroupBy employee_data by "Region" count

// step 6: aggregate - average income per region
GroupBy employee_data by "Region" avg "Income" (float)

// step 7: save as image too
Visualise employee_data using table_image