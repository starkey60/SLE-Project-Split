import csv
from tabulate import tabulate
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# Step 1: Load dataset
employee_data = []
with open("data.csv", newline="") as f:
    reader = csv.DictReader(f)
    for row in reader:
        employee_data.append(row)

# Step 2: Clean — dropna + filter + keep
cleaned_data = []
for row in employee_data:
    if (
        str(row["Region"]).strip() != '' and
        str(row["Income"]).strip() != '' and
        str(row["Employment_status"]).strip() != '' and
        float(row["Income"]) >= 20000 and
        int(row["Age"]) < 40
    ):
        filtered_row = {
            "Region": row["Region"],
            "Income": row["Income"],
            "Employment_status": row["Employment_status"],
            "Age": row["Age"],
            "Pets": row["Pets"]
        }
        cleaned_data.append(filtered_row)

# Step 3: Rename column
for _row in cleaned_data:
    _row['Role'] = _row.pop('Employment_status')

# Step 4: Sort by Income descending
cleaned_data.sort(key=lambda row: float(row["Income"]), reverse=True)

# Step 5: Visualise as terminal table
if cleaned_data:
    _headers = list(cleaned_data[0].keys())
    _rows = [list(row.values()) for row in cleaned_data]
    print(tabulate(_rows, headers=_headers, tablefmt='grid'))
else:
    print('No data to display for cleaned_data.')

# Step 6: GroupBy Region count
_groups = {}
for _row in cleaned_data:
    _key = _row['Region']
    _groups[_key] = _groups.get(_key, 0) + 1
print('GroupBy Region (count):')
for _key in sorted(_groups.keys()):
    print(f'  {_key}: {_groups[_key]}')

# Step 7: GroupBy Region avg Income
_groups = {}
_counts = {}
for _row in cleaned_data:
    _key = _row['Region']
    _val = float(_row['Income'])
    _groups[_key] = _groups.get(_key, 0) + _val
    _counts[_key] = _counts.get(_key, 0) + 1
print('GroupBy Region (avg Income):')
for _key in sorted(_groups.keys()):
    print(f'  {_key}: {_groups[_key] / _counts[_key]}')

# Step 8: Visualise as table image
if cleaned_data:
    _headers = list(cleaned_data[0].keys())
    _rows = [list(row.values()) for row in cleaned_data]
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
    plt.title('cleaned_data', fontsize=14, fontweight='bold', pad=20)
    plt.tight_layout()
    plt.savefig('cleaned_data_table_reference.png', dpi=150, bbox_inches='tight')
    plt.close()
    print('Table image saved to cleaned_data_table_reference.png')
else:
    print('No data to display for cleaned_data.')