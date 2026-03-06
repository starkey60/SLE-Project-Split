module DSL_CodeGen

import DSL_AST;
import DSL_Transformation;
import String;
import List;

str generate(ASTProgram program) {
    str code = "import csv\n\n";
    for (cmd <- program.commands) {
        code += genCommand(cmd);
    }

    return code;
}

str genCommand(ASTCommand command) {
    switch (command) {
        case load(path, name): {
            return genLoad(path, name);
        }
        case constrain(source, target, conditions): {
            return genConstrain(source, target, conditions);
        }
        case visualise(name): {
            return genVisualise(name, "default");
        }
        case visualiseUsing(name, vizType): {
            return genVisualise(name, vizType);            
        }
        default: throw "Unknown command when generating code";
    }
}

str genLoad(str path, str name) {
    return "
<name> = []
with open(\"<path>\", newline=\"\") as f:
    reader = csv.DictReader(f)
    for row in reader:
        <name>.append(row)
";
}

str genConstrain(str source, str target, list[ASTCondition] conditions) {
    str rows = genRowsConstrain(conditions);
    str conds = intercalate(
        " and\n",
        ["      " + genCondition(c) | c <- conditions]
    );

    return "
<target>_filters = <rows>
<target> = []
for row in <source>:
    if (
<conds>
    ):
        filtered_row = {col:row[col] for col in <target>_filters}
        <target>.append(filtered_row)
";
}

// placeholder "default" for when user does not specify type. Feel free to change
str genVisualise(str name, str vizType) {
    return "# VISUALISE IS NOT YET IMPLEMENTED (vizType = <vizType>, name = <name>)\n";
}

str genCondition(ASTCondition c) {
    switch(c) {
        case inList(col, t, values):
            return "<genTypedAccess(col, t)> in <genList(values)>";
        case greaterEq(col, t, v):
            return "<genTypedAccess(col, t)> \>= <genValue(v)>";
        case greater(col, t, v):
            return "<genTypedAccess(col, t)> \> <genValue(v)>";
        case lessEq(col, t, v):
            return "<genTypedAccess(col, t)> \<= <genValue(v)>";
        case less(col, t, v):
            return "<genTypedAccess(col, t)> \< <genValue(v)>";
        case equals(col, t, v):
            return "<genTypedAccess(col, t)> == <genValue(v)>";
        default: throw "Unknown Condition";
    }
}

str genValue(ASTValue v) {
    switch(v) {
        case intVal(i): return "<i>";
        case floatVal(f): return "<f>";
        case stringVal(s): return "\"<s>\"";
        case boolVal(b): return b ? "True" : "False";
        case arrayVal(arr): return genList(arr);
        default: throw "Unknown type";
    }
}

str genList(list[ASTValue] values) {
    return "[" + intercalate(", ", [ genValue(v) | v <- values]) + "]";
}

str genTypedAccess(str col, ASTType t) {
    switch(t) {
        case intType():
            return "int(row[\"<col>\"])";
        case floatType():
            return "float(row[\"<col>\"])";
        case stringType():
            return "row[\"<col>\"]";
        case boolType():
            return "row[\"<col>\"] == \"true\"";
        default: throw "Unknown Typed Access";
    }
}

str getColumn(ASTCondition cond) {
    switch (cond) {
        case inList(col, _, _): return col;
        case greaterEq(col, _, _): return col;
        case greater(col, _, _): return col;
        case lessEq(col, _, _): return col;
        case less(col, _, _): return col;
        case equals(col, _, _): return col;
        default: throw "Unknown condition";
    }
}

str genRowsConstrain(list[ASTCondition] conditions) {
    list[str] values = [getColumn(c) | c <- conditions];
    return "[" + intercalate(", ", ["\"<c>\"" | c <- values]) + "]";
}