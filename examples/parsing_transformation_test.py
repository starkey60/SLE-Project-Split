import csv



employee_data = []
with open("data.csv", newline="") as f:
    reader = csv.DictReader(f)
    for row in reader:
        employee_data.append(row)

employee_data_clean = []
for row in employee_data:
    if (
      str(row['Employment_status']).strip() != '' and
      str(row['Income']).strip() != ''
    ):
        employee_data_clean.append(row)
employee_data = employee_data_clean
 
for _row in employee_data:
    _row['Role'] = _row.pop('Employment_status')
 
employee_data.sort(key=lambda row: float(row["Income"]), reverse=True)

employee_data.sort(key=lambda row: int(row["Age"]), reverse=False)
 
filters = ["Role", "Income", "Pets", "Age"]    
filtered_employee_data = []
for row in employee_data:
    filtered_row = {k: row[k] for k in filters if k in row}
    filtered_employee_data.append(filtered_row)
employee_data = filtered_employee_data

employee_data_filtered = []
for row in employee_data:
    if (
      float(row["Income"]) >= 15000 and
      int(row["Age"]) != 26 and
      (row["Pets"].strip().lower() == "true") == True and
      str(row["Role"]) in ["employee"] and
      str(row["Role"]) == "employee"
    ):
        employee_data_filtered.append(row)
employee_data = employee_data_filtered

with open("save_path.csv", "w", newline="") as f:
    if employee_data:
        fields = employee_data[0].keys()
        writer = csv.DictWriter(f, fieldnames=fields)
        writer.writeheader()
        writer.writerows(employee_data)
