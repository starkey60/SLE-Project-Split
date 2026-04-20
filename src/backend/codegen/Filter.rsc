module backend::codegen::Filter

import frontend::Grammar;
import backend::codegen::Extra;
import List;

str genFilter(str source, list[str] filters) {
    if (isEmpty(filters)) return "";
    str conds = intercalate( " and\n", ["      " + f | f <- filters] );

    return "
<source>_filtered = []
for row in <source>:
    if (
<conds>
    ):
        <source>_filtered.append(row)
<source> = <source>_filtered
";
}

str genFilterCondition(FilterCondition f) {
    switch (f) {
        case (FilterCondition)`<String col> (<CastType t>) in [<{Value ","}* vals>]`: {
            return "<genCast("<col>", t)> in <genList([v | v <- vals])>";
        }
        case (FilterCondition)`<String col> (<CastType t>) <EqualityOp op> <Value v>`:
            return "<genCast("<col>", t)> <genEqualityOperator(op)> <genValue(v)>";
        default: throw "unknown filter condition <f>";
    }
}