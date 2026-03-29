import csv
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

na_sales = []
with open("global_ecommerce_sales.csv", newline="") as f:
    reader = csv.DictReader(f)
    for row in reader:
        na_sales.append(row)

na_sales_clean = []
for row in na_sales:
    if (
      str(row['Customer_Segment']).strip() != '' and
      str(row['Region']).strip() != '' and
      str(row['Product_Category']).strip() != '' and
      str(row['Quantity']).strip() != ''
    ):
        na_sales_clean.append(row)
na_sales = na_sales_clean

filters = ["Product_Name", "Customer_Segment", "Region", "Product_Category", "Quantity"]
filtered_na_sales = []
for row in na_sales:
    filtered_row = {k: row[k] for k in filters if k in row}
    filtered_na_sales.append(filtered_row)
na_sales = filtered_na_sales

na_sales_filtered = []
for row in na_sales:
    if (
      str(row["Customer_Segment"]) != "Corporate" and
      str(row["Region"]) in ["North America", "Asia Pacific"] and
      str(row["Product_Category"]) == "Technology" and
      int(row["Quantity"]) >= 2
    ):
        na_sales_filtered.append(row)
na_sales = na_sales_filtered

groups = {}
for row in na_sales:
    key = row['Product_Name']
    val = int(row['Quantity'])
    groups[key] = groups.get(key, 0) + val
na_sales = [{'Product_Name': k, 'Quantity': v} for k, v in sorted(groups.items())]
print('GroupBy Product_Name (sum Quantity):')
for key in sorted(groups.keys()):
    print(f'  {key}: {groups[key]}')

if na_sales:
    labels = [row['Product_Name'] for row in na_sales]
    values = [float(row['Quantity']) for row in na_sales]
    fig, ax = plt.subplots()
    ax.pie(values, labels=labels, autopct='%1.1f%%', startangle=140)
    ax.axis('equal')
    plt.title('na_sales', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('na_sales_pie.png', dpi=150, bbox_inches='tight')
    plt.close()
    print('Pie chart saved to na_sales_pie.png')
else:
    print('No data to display for na_sales.')

uae_customers = []
with open("global_ecommerce_sales.csv", newline="") as f:
    reader = csv.DictReader(f)
    for row in reader:
        uae_customers.append(row)

uae_customers.sort(key=lambda row: float(row["Profit"]), reverse=True)

filters = ["Customer_Name", "Profit", "Country"]
filtered_uae_customers = []
for row in uae_customers:
    filtered_row = {k: row[k] for k in filters if k in row}
    filtered_uae_customers.append(filtered_row)
uae_customers = filtered_uae_customers

uae_customers_filtered = []
for row in uae_customers:
    if (
      str(row["Country"]) == "UAE"
    ):
        uae_customers_filtered.append(row)
uae_customers = uae_customers_filtered

if uae_customers:
    headers = list(uae_customers[0].keys())
    rows = [list(row.values()) for row in uae_customers]
    num_cols = len(headers)
    num_rows = len(rows)
    fig_width = max(8, num_cols * 2.0)
    fig_height = max(2, (num_rows + 1) * 0.5)
    fig, ax = plt.subplots(figsize=(fig_width, fig_height))
    ax.axis('off')
    ax.axis('tight')
    tbl = ax.table(cellText=rows, colLabels=headers, cellLoc='center', loc='center')
    tbl.auto_set_font_size(False)
    tbl.set_fontsize(10)
    tbl.auto_set_column_width(col=list(range(num_cols)))
    for (row_idx, col_idx), cell in tbl.get_celld().items():
        if row_idx == 0:
            cell.set_facecolor('#4472C4')
            cell.set_text_props(color='white', fontweight='bold')
        elif row_idx % 2 == 0:
            cell.set_facecolor('#D9E2F3')
        else:
            cell.set_facecolor('#FFFFFF')
        cell.set_edgecolor('#BFBFBF')
    plt.title('uae_customers', fontsize=14, fontweight='bold', pad=20)
    plt.tight_layout()
    plt.savefig('uae_customers_table.png', dpi=150, bbox_inches='tight')
    plt.close()
    print('Table image saved to uae_customers_table.png')
else:
    print('No data to display for uae_customers.')