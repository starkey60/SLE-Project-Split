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
        case visualise(name, vizType): {
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
    str conds = intercalate(
        " and\n",
        ["      " + genCondition(c) | c <- conditions]
    );

    return "
<target> = []
for row in <source>:
    if (
<conds>
    ):
        <target>.append(row)
";
}

str genVisualise(str name, str vizType) {
    name = vizType; // TEMP just to avoid unused warning;
    return "VISUALISE IS NOT YET IMPLEMENTED\n";
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
    return "[" + intercalate(" ,", [ genValue(v) | v <- values]) + "]";
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