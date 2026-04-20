module backend::codegen::Extra

import frontend::Grammar;
import List;
import String;

str genCast(str col, (CastType)`int`) = "int(row[<col>])";
str genCast(str col, (CastType)`float`) = "float(row[<col>])";
str genCast(str col, (CastType)`string`) = "str(row[<col>])";
str genCast(str col, (CastType)`bool`) = "(row[<col>].strip().lower() == \"true\")";

str generate((Value)`[<{Value ","}* values>]`) =
    "[" + intercalate(", ", [ generate(v) | v <- values]) + "]";

str generate((Value)`<String s>`) = "<s>";

str generate((Value)`<Boolean b>`) =
    ("<b>" == "true") ? "True" : "False";

str generate((Value)`<Number n>`) {
    str raw = "<n>";
    return contains(raw, ".")
        ? "<toReal(raw)>"
        : "<toInt(raw)>";
}

str genEqualityOperator(EqualityOp eq) = "<eq>";