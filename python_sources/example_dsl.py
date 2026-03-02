import csv

employee_data = []
with open("data.csv", newline="") as f:
    reader = csv.DictReader(f)
    for row in reader:
        row["Income"] = float(row["Income"])
        row["Age"] = int(row["Age"])
        employee_data.append(row)

cleaned_employee_data = []
for row in employee_data:
    if (
        row["Region"] in ["NL", "BE"] and
        row["Income"] >= 30000 and
        row["Employment_status"] == "employee" and
        row["Age"] < 30
    ):
        cleaned_employee_data.append(row)


# NOT PART OF THE DSL OUTPUT------------
print("Original data:")
for row in employee_data:
    print(row)

print("Filtered results:")
for row in cleaned_employee_data:
    print(row)