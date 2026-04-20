module backend::codegen::Filter

import frontend::Grammar;
import backend::codegen::Extra;
import List;

str generate((Element)`Filter <Identifier id> { <FilterCondition* conditions> }`) {
    list[str] filters = [generate(f) | f <- conditions];
    if (isEmpty(filters)) return "";
    str conds = intercalate( " and\n", ["      " + f | f <- filters] );

    return "
<id>_filtered = []
for row in <id>:
    if (
<conds>
    ):
        <id>_filtered.append(row)
<id> = <id>_filtered
";
}

str generate((FilterCondition)`<String col> (<CastType t>) in [<{Value ","}* vals>]`) =
    "<genCast("<col>", t)> in [<intercalate(", ", [generate(v) | v <- vals])>]";

str generate((FilterCondition)`<String col> (<CastType t>) <EqualityOp op> <Value v>`) =
    "<genCast("<col>", t)> <genEqualityOperator(op)> <generate(v)>";