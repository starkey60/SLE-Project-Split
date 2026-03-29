import csv

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


employee_data = []
with open("data.csv", newline="") as f:
    reader = csv.DictReader(f)
    for row in reader:
        employee_data.append(row)

employee_data_clean = []
for row in employee_data:
    if (
      str(row['Region']).strip() != '' and
      str(row['Income']).strip() != ''
    ):
        employee_data_clean.append(row)
employee_data = employee_data_clean
   
filters = ["Region", "Income", "Pets"]    
filtered_employee_data = []
for row in employee_data:
    filtered_row = {k: row[k] for k in filters if k in row}
    filtered_employee_data.append(filtered_row)
employee_data = filtered_employee_data

_groups = {}
for _row in employee_data:
    _key = _row['Region']
    _groups[_key] = _groups.get(_key, 0) + 1
employee_data = [{'Region': _key, 'count': _count} for _key, _count in sorted(_groups.items())]
print('GroupBy Region (count):')
for _key in sorted(_groups.keys()):
    print(f'  {_key}: {_groups[_key]}')

if employee_data:
    _keys = list(employee_data[0].keys())
    _labelCol = _keys[0]
    _valueCol = _keys[1]
    _labels = [row[_labelCol] for row in employee_data]
    _values = [float(row[_valueCol]) for row in employee_data]
    _fig, _ax = plt.subplots()
    _ax.pie(
        _values,
        labels=_labels,
        autopct='%1.1f%%',
        startangle=140
    )
    _ax.axis('equal')
    plt.title('employee_data', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('employee_data_pie.png', dpi=150, bbox_inches='tight')
    plt.close()
    print('Pie chart saved to employee_data_pie.png')
else:
    print('No data to display for employee_data.')

with open("save.csv", "w", newline="") as f:
    if employee_data:
        fields = employee_data[0].keys()
        writer = csv.DictWriter(f, fieldnames=fields)
        writer.writeheader()
        writer.writerows(employee_data)
