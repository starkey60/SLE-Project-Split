import csv



employee_data = []
with open("data.csv", newline="") as f:
    reader = csv.DictReader(f)
    for row in reader:
        employee_data.append(row)

employee_data_clean = []
for row in employee_data:
    if (
      str(row['Pets']).strip() != '' and
      str(row['Income']).strip() != '' and
      str(row['Region']).strip() != ''
    ):
        employee_data_clean.append(row)
employee_data = employee_data_clean
 
for _row in employee_data:
    _row['Animals'] = _row.pop('Pets')
  
filters = ["Animals", "Region", "Income"]    
filtered_employee_data = []
for row in employee_data:
    filtered_row = {k: row[k] for k in filters if k in row}
    filtered_employee_data.append(filtered_row)
employee_data = filtered_employee_data

with open("save.csv", "w", newline="") as f:
    if employee_data:
        fields = employee_data[0].keys()
        writer = csv.DictWriter(f, fieldnames=fields)
        writer.writeheader()
        writer.writerows(employee_data)
