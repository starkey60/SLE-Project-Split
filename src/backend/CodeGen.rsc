module backend::CodeGen

import frontend::Grammar;
import String;
import List;

str generate(start[DELTA] dlt) {
    str code = "import csv\n\n";
    code += "from tabulate import tabulate\n";
    code += "import matplotlib\n";
    code += "matplotlib.use(\'Agg\')\n";
    code += "import matplotlib.pyplot as plt\n\n";
    
    switch (dlt) {
        case (start[DELTA])`<Element* elements>`:
            return code += intercalate("\n", [genElement(el) | Element el <- elements]);
        default: return code;
    }
}

str genElement(Element el) {
    switch (el) {
        case (Element)`Load <String path> as <Identifier id>`:
            return genLoad("<path>", "<id>");
        case (Element)`Save <Identifier id> as <String path>`:
            return genSave("<path>", "<id>");
        case (Element)`Filter <Identifier id> { <FilterCondition* conds> }`:
            return genFilter("<id>", [genFilterCondition(f) | f <- conds]);
        case (Element)`Transform <Identifier id> { <Transformation* transformations> }`:
            return genTransform("<id>", [t | t <- transformations]);
        case (Element)`Visualise <Identifier target>`:
            return genVisualiseTable("<target>");
        case (Element)`Visualise <Identifier target> using <VisType template>`:
            return genVisualise("<target>", template);
        case (Element)`GroupBy <Identifier src> by <String col> count`:
            return genGroupByAggGeneralised("<src>", "<col>", "\'count\'",
                "_groups[_key] = _groups.get(_key, 0) + 1");
        case (Element)`GroupBy <Identifier src> by <String col> <AggType agg> <String valCol> (<CastType t>)`:
            return genGroupByAgg("<src>", "<col>", agg, "<valCol>", t);
        default: throw "Unknown command when generating code";
    }
}

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

str genCast(str col, CastType cast) {
    switch (cast) {
        case (CastType) `int`: return "int(row[<col>])";
        case (CastType) `float`:  return "float(row[<col>])";
        case (CastType) `string`: return "str(row[<col>])";
        case (CastType) `bool`:  return "(row[<col>].strip().lower() == \"true\")";
        default: throw "unknown cast type <cast>";
    }
}

str genEqualityOperator(EqualityOp eq) = "<eq>";

str genTransform(str source, list[Transformation] transformations) {
    // separate different transformations
    list[Transformation] renames = [t | t <- transformations, t is rename];
    str renamesTransformations = isEmpty(renames) ? "" : genRenameTransformations(source, renames);

    list[Transformation] sorts = [t | t <- transformations, t is sortBy];
    str sortsTransformations = isEmpty(sorts) ? "" : genSortTransformations(source, sorts);

    list[Transformation] dropnas = [t | t <- transformations, t is dropna];
    str dropnasTransformations = isEmpty(dropnas) ? "" : genDropnaTransformations(source, dropnas);

    str keeps = genKeepTransformation(source, transformations);

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

str genVisualise(str target, VisType vis) {
    switch (vis) {
        case visTable(): return genVisualiseTable(target);
        case visTableImage(): return genVisualiseTableImage(target);
        case pieChart(): return genVisualisePieChart(target);
        case barChart(): return genVisualiseBarChart(target);
        default: throw "Unknown vis type during codegen <vis>";
    }
}

str genVisualiseTableImage(str target) {
    return "
if <target>:
    _headers = list(<target>[0].keys())
    _rows = [list(row.values()) for row in <target>]
    _num_cols = len(_headers)
    _num_rows = len(_rows)
    _fig_width = max(8, _num_cols * 2.0)
    _fig_height = max(2, (_num_rows + 1) * 0.5)
    _fig, _ax = plt.subplots(figsize=(_fig_width, _fig_height))
    _ax.axis(\'off\')
    _ax.axis(\'tight\')
    _tbl = _ax.table(
        cellText=_rows,
        colLabels=_headers,
        cellLoc=\'center\',
        loc=\'center\'
    )
    _tbl.auto_set_font_size(False)
    _tbl.set_fontsize(10)
    _tbl.auto_set_column_width(col=list(range(_num_cols)))
    for (row_idx, col_idx), cell in _tbl.get_celld().items():
        if row_idx == 0:
            cell.set_facecolor(\'#4472C4\')
            cell.set_text_props(color=\'white\', fontweight=\'bold\')
        elif row_idx % 2 == 0:
            cell.set_facecolor(\'#D9E2F3\')
        else:
            cell.set_facecolor(\'#FFFFFF\')
        cell.set_edgecolor(\'#BFBFBF\')
    plt.title(\'<target>\', fontsize=14, fontweight=\'bold\', pad=20)
    plt.tight_layout()
    plt.savefig(\'<target>_table.png\', dpi=150, bbox_inches=\'tight\')
    plt.close()
";
}

str genVisualiseTable(str target) {
    return "
if <target>:
    _headers = list(<target>[0].keys())
    _rows = [list(row.values()) for row in <target>]
    print(tabulate(_rows, headers=_headers, tablefmt=\'grid\'))
";
}

str genVisualisePieChart(str target) {
    return "
if <target>:
    _keys = list(<target>[0].keys())
    _labelCol = _keys[0]
    _valueCol = _keys[1]
    _labels = [row[_labelCol] for row in <target>]
    _values = [float(row[_valueCol]) for row in <target>]
    _fig, _ax = plt.subplots()
    _ax.pie(
        _values,
        labels=_labels,
        autopct=\'%1.1f%%\',
        startangle=140
    )
    _ax.axis(\'equal\')
    plt.title(\'<target>\', fontsize=14, fontweight=\'bold\')
    plt.tight_layout()
    plt.savefig(\'<target>_pie.png\', dpi=150, bbox_inches=\'tight\')
    plt.close()
";
}

str genVisualiseBarChart(str target) {
    return "
if <target>:
    _keys = list(<target>[0].keys())
    _labelCol = _keys[0]
    _valueCol = _keys[1]
    _labels = [row[_labelCol] for row in <target>]
    _values = [float(row[_valueCol]) for row in <target>]
    _fig, _ax = plt.subplots(figsize=(max(8, len(_labels) * 1.5), 6))
    _bars = _ax.bar(_labels, _values, color=\'#4472C4\', edgecolor=\'#2F5597\')
    for _bar, _val in zip(_bars, _values):
        _ax.text(_bar.get_x() + _bar.get_width() / 2, _bar.get_height() + 0.3,
                 str(_val), ha=\'center\', va=\'bottom\', fontweight=\'bold\')
    _ax.set_xlabel(_labelCol, fontsize=12)
    _ax.set_ylabel(_valueCol, fontsize=12)
    _ax.set_title(\'<target>\', fontsize=14, fontweight=\'bold\')
    _ax.spines[\'top\'].set_visible(False)
    _ax.spines[\'right\'].set_visible(False)
    plt.tight_layout()
    plt.savefig(\'<target>_bar.png\', dpi=150, bbox_inches=\'tight\')
    plt.close()
";
}

str genGroupByAgg(str source, str groupCol, AggType agg, str valueCol, CastType cast) {
    switch (agg) {
        case aggSum(): return genGroupByAggGeneralised(source, groupCol, valueCol,
            "_groups[_key] = _groups.get(_key, 0) + _val",
            valStep = genCast(valueCol, cast));
        case aggAvg(): return genGroupByAggGeneralised(source, groupCol, valueCol,
            "_groups[_key] = _groups.get(_key, 0) + _val\n    _counts[_key] = _counts.get(_key, 0) + 1",
            valStep = genCast(valueCol, cast), extraInit = "_counts = {}", resultExpr = "_groups[_key] / _counts[_key]");
        case aggMin(): return genGroupByAggGeneralised(source, groupCol, valueCol,
            "if _key not in _groups or _val \< _groups[_key]:\n        _groups[_key] = _val",
            valStep = genCast(valueCol, cast));
        case aggMax(): return genGroupByAggGeneralised(source, groupCol, valueCol,
            "if _key not in _groups or _val \> _groups[_key]:\n        _groups[_key] = _val",
            valStep = genCast(valueCol, cast));
        default: throw "unknown agg <agg>";
    }
}

str genGroupByAggGeneralised(str source, str groupCol, str valueCol, str aggStep,
                              str valStep = "", str extraInit = "", str resultExpr = "_groups[_key]") {
    return "
_groups = {}
<extraInit>
for _row in <source>:
    _key = _row[<groupCol>]
    <if (valStep != "") {>_val = <valStep>
    <}><aggStep>
<source> = [{<groupCol>: _key, <valueCol>: <resultExpr>} for _key in sorted(_groups.keys())]
print(\"GroupBy <groupCol[1..-1]> ( <valueCol>):\")
for _key in sorted(_groups.keys()):
    print(f\'  {_key}: {<resultExpr>}\')
";
}
