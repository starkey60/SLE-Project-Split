module backend::codegen::Transformation

import frontend::Grammar;
import backend::codegen::Extra;
import List;
import String;

str generate((Element)`Transform <Identifier id> { <Transformation* transformations> }`) {
    // separate different transformations
    list[Transformation] ts = [t | t <- transformations];

    list[Transformation] renames = [t | t <- ts, t is rename];
    str renamesTransformations = isEmpty(renames) ? "" : genRenameTransformations("<id>", renames);

    list[Transformation] sorts = [t | t <- ts, t is sortBy];
    str sortsTransformations = isEmpty(sorts) ? "" : genSortTransformations("<id>", sorts);

    list[Transformation] dropnas = [t | t <- ts, t is dropna];
    str dropnasTransformations = isEmpty(dropnas) ? "" : genDropnaTransformations("<id>", dropnas);

    str keeps = genKeepTransformation("<id>", ts);

    return "<dropnasTransformations> <renamesTransformations> <sortsTransformations> <keeps>";
}

str genDropnaTransformations(str source, list[Transformation] dropnas) {
    list[str] checks = [];
    for (dropna(col) <- dropnas) {
        checks += "str(row[<col>]).strip() != \'\'";
    }
    str conds = intercalate(" and\n      ", checks);
    return "
<source>_clean = []
for row in <source>:
    if (
      <conds>
    ):
        <source>_clean.append(row)
<source> = <source>_clean
";
}

str genRenameTransformations(str source, list[Transformation] renames) {
    str code = "";
    for (rename(old, new) <- renames) {
        code +="
for _row in <source>:
    _row[<new>] = _row.pop(<old>)
";
    }
    return code;
}

str genSortTransformations(str source, list[Transformation] sorts) {
    str code = "";
    for (sortBy(col, cast, order) <- sorts) {
        str access = genCast("<col>", cast);
        str rev = (order is descending) ? "True" : "False";
        code += "
<source>.sort(key=lambda row: <access>, reverse=<rev>)
";
    }
    return code;
}

str genKeepTransformation(str source, list[Transformation] transformations) {
    // extract columns that the transformed dataset will contain 
    list[str] values = genColOrder(transformations);
    str colsToKeep =  "[" + intercalate(", ", ["\"<c>\"" | c <- values]) + "]";

    return "
filters = <colsToKeep>    
filtered_<source> = []
for row in <source>:
    filtered_row = {k: row[k] for k in filters if k in row}
    filtered_<source>.append(filtered_row)
<source> = filtered_<source>
";
}

list[str] genColOrder(list[Transformation] ts) {
    list[str] cols = [];
    set[str] renamed = {};
    for (t <- ts) {
        switch (t) {
            case (Transformation)`keep <String c>`: 
                if ("<c>" notin renamed) cols += ["<c>"];
            case (Transformation)`rename <String old> to <String new>`: {
                renamed += {"<old>"};
                if ("<old>" in cols) {
                    int idx = indexOf(cols, "<old>");
                    cols = [c | c <- cols, c != "<old>"];
                    cols = cols[0..idx] + ["<new>"] + cols[idx..];
                } else cols += ["<new>"];
            }
            case (Transformation)`sort <String c> (<CastType _>) <SortOrder _>`: 
                if ("<c>" notin renamed) cols += ["<c>"];
            case (Transformation)`dropna <String c>`: 
                if ("<c>" notin renamed) cols += ["<c>"];
            default:;
        }
    }
    
    //strip quotes from string
    cols = [c[1..size(c)-1] | c <- cols];
    return dup(cols);
}