module backend::codegen::IO

str genLoad(str path, str name) {
    return "
<name> = []
with open(<path>, newline=\"\") as f:
    reader = csv.DictReader(f)
    for row in reader:
        <name>.append(row)
";
}

str genSave(str path, str name) {
    return "
with open(<path>, \"w\", newline=\"\") as f:
    if <name>:
        fields = <name>[0].keys()
        writer = csv.DictWriter(f, fieldnames=fields)
        writer.writeheader()
        writer.writerows(<name>)
";
}