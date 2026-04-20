module backend::codegen::Extra

import frontend::Grammar;
import List;
import String;

str genCast(str col, CastType cast) {
    switch (cast) {
        case (CastType) `int`: return "int(row[<col>])";
        case (CastType) `float`:  return "float(row[<col>])";
        case (CastType) `string`: return "str(row[<col>])";
        case (CastType) `bool`:  return "(row[<col>].strip().lower() == \"true\")";
        default: throw "unknown cast type <cast>";
    }
}

str genValue(Value v) {
    switch (v) {
        case (Value)`<String s>`:
            return "<s>";
        case (Value)`<Boolean b>`:
            return ("<b>" == "true") ? "True" : "False";
        case (Value)`<Number n>`: {
            str raw = "<n>";
            return contains(raw, ".")
                ? "<toReal(raw)>"
                : "<toInt(raw)>";
        }
        case (Value)`[<{Value ","}* vals>]`:
            return genList([val | val <- vals]);
        default: throw "Could not transform value <v>";
    }
}

str genList(list[Value] values) {
    return "[" + intercalate(", ", [ genValue(v) | v <- values]) + "]";
}

str genEqualityOperator(EqualityOp eq) = "<eq>";