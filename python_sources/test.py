import csv


employee_data = []
with open("data.csv", newline="") as f:
    reader = csv.DictReader(f)
    for row in reader:
        employee_data.append(row)

cleaned_employee_data_filters = ["Region", "Income", "Employment_status", "Age", "Pets"]
cleaned_employee_data = []
for row in employee_data:
    if (
      row["Region"] in ["NL", "BE"] and
      float(row["Income"]) >= 30000 and
      row["Employment_status"] == "employee" and
      int(row["Age"]) < 30
    ):
        filtered_row = {col:row[col] for col in cleaned_employee_data_filters}
        cleaned_employee_data.append(filtered_row)
# VISUALISE IS NOT YET IMPLEMENTED (vizType = template, name = employee_data)

print("Original data:")
for row in employee_data:
    print(row)

print("Filtered results:")
for row in cleaned_employee_data:
    print(row)