import csv

from tabulate import tabulate
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
   
filters = ["Region", "Income"]    
filtered_employee_data = []
for row in employee_data:
    filtered_row = {k: row[k] for k in filters if k in row}
    filtered_employee_data.append(filtered_row)
employee_data = filtered_employee_data

# visualise employee_data as table
if employee_data:
    _headers = list(employee_data[0].keys())
    _rows = [list(row.values()) for row in employee_data]
    print(tabulate(_rows, headers=_headers, tablefmt='grid'))
else:
    print('No data to display for employee_data.')

# visualise employee_data as table image
if employee_data:
    _headers = list(employee_data[0].keys())
    _rows = [list(row.values()) for row in employee_data]
    _num_cols = len(_headers)
    _num_rows = len(_rows)
    _fig_width = max(8, _num_cols * 2.0)
    _fig_height = max(2, (_num_rows + 1) * 0.5)
    _fig, _ax = plt.subplots(figsize=(_fig_width, _fig_height))
    _ax.axis('off')
    _ax.axis('tight')
    _tbl = _ax.table(
        cellText=_rows,
        colLabels=_headers,
        cellLoc='center',
        loc='center'
    )
    _tbl.auto_set_font_size(False)
    _tbl.set_fontsize(10)
    _tbl.auto_set_column_width(col=list(range(_num_cols)))
    for (row_idx, col_idx), cell in _tbl.get_celld().items():
        if row_idx == 0:
            cell.set_facecolor('#4472C4')
            cell.set_text_props(color='white', fontweight='bold')
        elif row_idx % 2 == 0:
            cell.set_facecolor('#D9E2F3')
        else:
            cell.set_facecolor('#FFFFFF')
        cell.set_edgecolor('#BFBFBF')
    plt.title('employee_data', fontsize=14, fontweight='bold', pad=20)
    plt.tight_layout()
    plt.savefig('employee_data_table.png', dpi=150, bbox_inches='tight')
    plt.close()
    print('Table image saved to employee_data_table.png')
else:
    print('No data to display for employee_data.')

_groups = {}
_counts = {}
for _row in employee_data:
    _key = _row['Region']
    _val = float(_row['Income'])
    _groups[_key] = _groups.get(_key, 0) + _val
    _counts[_key] = _counts.get(_key, 0) + 1
employee_data = [{'Region': _key, 'Income': _groups[_key] / _counts[_key]} for _key in sorted(_groups.keys())]
print('GroupBy Region (avg Income):')
for _key in sorted(_groups.keys()):
    print(f'  {_key}: {_groups[_key] / _counts[_key]}')

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
