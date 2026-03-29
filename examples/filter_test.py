import csv



employee_data = []
with open("data.csv", newline="") as f:
    reader = csv.DictReader(f)
    for row in reader:
        employee_data.append(row)

employee_data_clean = []
for row in employee_data:
    if (
      str(row['Income']).strip() != '' and
      str(row['Employment_status']).strip() != ''
    ):
        employee_data_clean.append(row)
employee_data = employee_data_clean
   
filters = ["Income", "Employment_status", "Age", "Pets", "Region"]    
filtered_employee_data = []
for row in employee_data:
    filtered_row = {k: row[k] for k in filters if k in row}
    filtered_employee_data.append(filtered_row)
employee_data = filtered_employee_data

employee_data_filtered = []
for row in employee_data:
    if (
      float(row["Income"]) >= 20000 and
      int(row["Age"]) <= 40 and
      (row["Pets"].strip().lower() == "true") != False and
      str(row["Employment_status"]) == "employee" and
      str(row["Region"]) in ["NL", "BE"]
    ):
        employee_data_filtered.append(row)
employee_data = employee_data_filtered

with open("save.csv", "w", newline="") as f:
    if employee_data:
        fields = employee_data[0].keys()
        writer = csv.DictWriter(f, fieldnames=fields)
        writer.writeheader()
        writer.writerows(employee_data)
