/*
    Test file for preprocessing features:
    - dropna
    - Rename
    - Sort
    - GroupBy
*/

// step 1: load the dataset
Load "data.csv" as employee_data

// step 2: clean - filter + drop nulls
Constrain employee_data as cleaned_data {
    Region (string) dropna
    Income (float) dropna
    Employment_status (string) dropna
    Income (float) >= 20000
    Age (int) < 40
    Pets (bool) keep
}

// step 3: rename a column
Rename cleaned_data column "Employment_status" to "Role"

// step 4: sort by income descending
Sort cleaned_data by Income (float) descending

// step 5: show the cleaned, renamed, sorted data
Visualise cleaned_data

// step 6: aggregate- count per region
GroupBy cleaned_data by Region count

// step 7: sggregate- average income per region
GroupBy cleaned_data by Region avg Income (float)

// step 8: save as image too
Visualise cleaned_data using table_image