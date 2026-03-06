module DSL_CodeGen

import DSL_AST;
import DSL_Transformation;
import String;
import List;
import util::Maybe;

str generate(ASTProgram program) {
    str code = "import csv\n\n";
    bool needsTabulate = false;
    bool needsMatplotlib = false;

    for (cmd <- program.commands) {
        if (cmd is visualise) {
            needsTabulate = true;
        }
        if (cmd is visualiseUsing) {
            str vt = cmd.vizType;
            if (vt == "table") needsTabulate = true;
            if (vt == "table_image") needsMatplotlib = true;
        }
    }

    if (needsTabulate) code += "from tabulate import tabulate\n";
    if (needsMatplotlib) {
        code += "import matplotlib\n";
        code += "matplotlib.use(\'Agg\')\n";
        code += "import matplotlib.pyplot as plt\n";
    }

    code += "\n";

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
        case rename(source, oldCol, newCol): {
            return genRename(source, oldCol, newCol);
        }
        case sortAsc(source, col, t): {
            return genSort(source, col, t, false);
        }
        case sortDesc(source, col, t): {
            return genSort(source, col, t, true);
        }
        case groupByCount(source, groupCol): {
            return genGroupByCount(source, groupCol);
        }
        case groupByAgg(source, groupCol, aggType, valueCol, valType): {
            return genGroupByAgg(source, groupCol, aggType, valueCol, valType);
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
    list[str] condList = [s | just(s) <- [genCondition(c) | c <- conditions]];
    str conds = intercalate(
        " and\n",
        ["      " + cond | cond <- condList]
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
str genVisualise(str dataName, str vizType) {
    if (vizType == "table_image") return genVisualiseTableImage(dataName);
    return genVisualiseTable(dataName);
}

str genVisualiseTable(str dataName) {
    return
    
"
# visualise <dataName> as table
if <dataName>:
    _headers = list(<dataName>[0].keys())
    _rows = [list(row.values()) for row in <dataName>]
    print(tabulate(_rows, headers=_headers, tablefmt=\'grid\'))
else:
    print(\'No data to display for <dataName>.\')
";
}

str genVisualiseTableImage(str dataName) {
    return

"
# visualise <dataName> as table image
if <dataName>:
    _headers = list(<dataName>[0].keys())
    _rows = [list(row.values()) for row in <dataName>]
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
    plt.title(\'<dataName>\', fontsize=14, fontweight=\'bold\', pad=20)
    plt.tight_layout()
    plt.savefig(\'<dataName>_table.png\', dpi=150, bbox_inches=\'tight\')
    plt.close()
    print(\'Table image saved to <dataName>_table.png\')
else:
    print(\'No data to display for <dataName>.\')
";
}

Maybe[str] genCondition(ASTCondition c) {
    switch(c) {
        case inList(col, t, values):
            return just("<genTypedAccess(col, t)> in <genList(values)>");
        case greaterEq(col, t, v):
            return just("<genTypedAccess(col, t)> \>= <genValue(v)>");
        case greater(col, t, v):
            return just("<genTypedAccess(col, t)> \> <genValue(v)>");
        case lessEq(col, t, v):
            return just("<genTypedAccess(col, t)> \<= <genValue(v)>");
        case less(col, t, v):
            return just("<genTypedAccess(col, t)> \< <genValue(v)>");
        case equals(col, t, v):
            return just("<genTypedAccess(col, t)> == <genValue(v)>");
        case dropna(col, t):
            return just("str(row[\"<col>\"]).strip() != \'\'");
        case keep(_, _):
            return nothing(); 
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
        case keep(col, _): return col;
        case dropna(col, _): return col;
        default: throw "Unknown condition";
    }
}

str genRowsConstrain(list[ASTCondition] conditions) {
    list[str] values = [getColumn(c) | c <- conditions];
    return "[" + intercalate(", ", ["\"<c>\"" | c <- values]) + "]";
}

// rename oldCol to newCol in source
str genRename(str source, str oldCol, str newCol) {
    return
"
for _row in <source>:
    _row[\'<newCol>\'] = _row.pop(\'<oldCol>\')
";
}

// sort source by col of type t, descending if specified
str genSort(str source, str col, ASTType t, bool descending) {
    str access = genTypedAccess(col, t);
    str rev = descending ? "True" : "False";
    return
"
<source>.sort(key=lambda row: <access>, reverse=<rev>)
";
}

// group cource by col, count occurences
str genGroupByCount(str source, str groupCol) {
    return
"
_groups = {}
for _row in <source>:
    _key = _row[\'<groupCol>\']
    _groups[_key] = _groups.get(_key, 0) + 1
print(\'GroupBy <groupCol> (count):\')
for _key in sorted(_groups.keys()):
    print(f\'  {_key}: {_groups[_key]}\')
";
}

// group source by aggregation (sum, avg, min, max)
str genGroupByAgg(str source, str groupCol, ASTAggType aggType, str valueCol, ASTType valType) {
    str typeFunc = genTypeFunc(valType);
    str aggName = getAggName(aggType);

    if (aggType == aggAvg()) {
        return genGroupByAvg(source, groupCol, valueCol, typeFunc);
    }
    if (aggType == aggMin()) {
        return genGroupByMinMax(source, groupCol, valueCol, typeFunc, "min", "\<");
    }
    if (aggType == aggMax()) {
        return genGroupByMinMax(source, groupCol, valueCol, typeFunc, "max", "\>");
    }
    // default: sum
    return genGroupBySum(source, groupCol, valueCol, typeFunc);
}

// GroupBy: <source> by <groupCol> (sum <valueCol>)
str genGroupBySum(str source, str groupCol, str valueCol, str typeFunc) {
    return
"
_groups = {}
for _row in <source>:
    _key = _row[\'<groupCol>\']
    _val = <typeFunc>(_row[\'<valueCol>\'])
    _groups[_key] = _groups.get(_key, 0) + _val
print(\'GroupBy <groupCol> (sum <valueCol>):\')
for _key in sorted(_groups.keys()):
    print(f\'  {_key}: {_groups[_key]}\')
";
}

// GroupBy: <source> by <groupCol> (avg <valueCol>)
str genGroupByAvg(str source, str groupCol, str valueCol, str typeFunc) {
    return
"
_groups = {}
_counts = {}
for _row in <source>:
    _key = _row[\'<groupCol>\']
    _val = <typeFunc>(_row[\'<valueCol>\'])
    _groups[_key] = _groups.get(_key, 0) + _val
    _counts[_key] = _counts.get(_key, 0) + 1
print(\'GroupBy <groupCol> (avg <valueCol>):\')
for _key in sorted(_groups.keys()):
    print(f\'  {_key}: {_groups[_key] / _counts[_key]}\')
";
}

// GroupBy: <source> by <groupCol> (<aggName> <valueCol>)
str genGroupByMinMax(str source, str groupCol, str valueCol, str typeFunc, str aggName, str op) {
    return
"
_groups = {}
for _row in <source>:
    _key = _row[\'<groupCol>\']
    _val = <typeFunc>(_row[\'<valueCol>\'])
    if _key not in _groups or _val <op> _groups[_key]:
        _groups[_key] = _val
print(\'GroupBy <groupCol> (<aggName> <valueCol>):\')
for _key in sorted(_groups.keys()):
    print(f\'  {_key}: {_groups[_key]}\')
";
}

// helper: get just the Python type function name
str genTypeFunc(ASTType t) {
    switch(t) {
        case intType(): return "int";
        case floatType(): return "float";
        case stringType(): return "str";
        case boolType(): return "bool";
        default: throw "Unknown type for aggregation";
    }
}

// helper: get aggregation name as string
str getAggName(ASTAggType aggType) {
    switch(aggType) {
        case aggSum(): return "sum";
        case aggAvg(): return "avg";
        case aggMin(): return "min";
        case aggMax(): return "max";
        default: throw "Unknown aggregation type";
    }
}

