module backend::codegen::IO

import frontend::Grammar;

str generate((Element)`Load <String path> as <Identifier id>`) {
    return "
<id> = []
with open(<path>, newline=\"\") as f:
    reader = csv.DictReader(f)
    for row in reader:
        <id>.append(row)
";
}

str generate((Element)`Save <Identifier id> as <String path>`) {
    return "
with open(<path>, \"w\", newline=\"\") as f:
    if <id>:
        fields = <id>[0].keys()
        writer = csv.DictWriter(f, fieldnames=fields)
        writer.writeheader()
        writer.writerows(<id>)
";
}