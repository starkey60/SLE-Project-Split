module DSL_CodeGen

import DSL_AST;
import DSL_Transformation;
import String;
import List;

str generate(ASTProgram program) {
    str code = "import csv\n\n";
    bool needsTabulate = false;
    bool needsMatplotlib = false;

    for (cmd <- program.commands) {
        if (cmd is visualise) {
            needsTabulate = true;
        }
        if (cmd is visualise) {
            if (cmd.vis == table()) needsTabulate = true;
            if (cmd.vis == tableImage()) needsMatplotlib = true;
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
        case io(path, name, io): {
            return genIO(path, name, io);
        }
        case filterDataset(source, filters): {
            return genFilterDataset(source, filters);
        }
        case transformDataset(source, transformations): {
            return genTransformDataset(source, transformations);
        }
        case visualise(name, vis): {
            return genVisualise(name, vis);
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

str genIO(str path, str name, ASTIO io) {
    switch (io) {
        case load(): return genLoad(path, name);
        case save(): return genSave(path, name);
        default: throw "Unknown io while running codegen <io>";
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

str genSave(str path, str name) {
    return "
with open(\"<path>\", \"w\", newline=\"\") as f:
    fields = <name>[0].keys()

    writer = csv.DictWriter(f, fieldnames=fields)
    writer.writeheader()
    writer.writerows(<name>)
";
}

//transform the genFilterDataset
str genTransformDataset(str source, list[ASTTransformation] transformations) {
    // separate different transformations
    list[ASTTransformation] renames = [t | t: rename(_, _) <- transformations];
    str renamesTransformation = isEmpty(renames) ? "" : genRenameTransformation(source, renames);

    list[ASTTransformation] sorts = [t | t: sort(_, _, _) <- transformations];
    str sortsTransformation = isEmpty(sorts) ? "" : genSortTransformation(source, sorts);

    list[ASTTransformation] dropnas = [t | t: dropna(_) <- transformations];
    str dropnasTransformation = isEmpty(dropnas) ? "" : genDropnaTransformation(source, dropnas);

    str keeps = genKeepTransformation(source, transformations);

    return "<keeps> <renamesTransformation> <sortsTransformation> <dropnasTransformation>";
}

str genRenameTransformation(str source, list[ASTTransformation] renames) {
    return "\nTODO rename\n";
}

str genSortTransformation(str source, list[ASTTransformation] sorts) {
    return "\nTODO sort\n";
}

str genDropnaTransformation(str source, list[ASTTransformation] dropna) {
    return "\nTODO dropna\n";
}

str genKeepTransformation(str source, list[ASTTransformation] transformations) {
    // extract columns that the transformed dataset will contain 
    str colsToKeep = genRowsConstrain(transformations);

    return "
filters = <colsToKeep>    
filtered_<source> = []
for row in <source>:
    filtered_row = {k: row[k] for k in filters if k in row}
    filtered_<source>.append(filtered_row)
<source> = filtered_<source>
";
}

str genRowsConstrain(list[ASTTransformation] transformations) {
    set[str] values =
        {c | rename(c, _) <- transformations}
        + {c | sort(c, _, _) <- transformations}
        + {c | dropna(c) <- transformations}
        + {c | keep(c) <- transformations};
    return "[" + intercalate(", ", ["\"<c>\"" | c <- values]) + "]";
}

// just filters loaded columns, no ordering or keeping constrains
str genFilterDataset(str source, list[ASTFilter] filters) {
    list[str] filtList = [genFilter(f) | f <- filters];
    str conds = intercalate( " and\n", ["      " + f | f <- filtList] );

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

str genFilter(ASTFilter f) {
    switch(f) {
        case inList(col, valList, cast):
            return "<genCast(col, cast)> in <genList(valList)>";
        case equality(col, val, eq, cast):
            return "<genCast(col, cast)> <genEqualityOperator(eq)> <genValue(val)>";
        default: throw "Unknown Condition";
    }
}

str genVisualise(str dataName, ASTVis vis) {
    switch (vis) {
        case defaultVis(): return "\nTODO defaultVis with <dataName>";
        case table(): return "\nTODO table with <dataName>";
        case tableImage(): return "\nTODO tableImage with <dataName>";
        default: throw "Unknown vis type during codegen <vis>";
    }
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

str genCast(str col, ASTCast cast) {
    switch(cast) {
        case intCast():
            return "int(row[\"<col>\"])";
        case floatCast():
            return "float(row[\"<col>\"])";
        case stringCast():
            return "str(row[\"<col>\"])";
        case boolCast():
            return "bool(row[\"<col>\"])";
        default: throw "Unknown Typed Access";
    }
}

str genEqualityOperator(ASTEquality eq) {
    switch (eq) {
        case greaterEq(): return "\>=";
        case greater(): return "\>";
        case lessEq(): return "\<=";
        case less(): return "\<";
        case equals(): return "==";
        case notEquals(): return "!=";
        default: throw "Unknown equality operator";
    }
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
str genSort(str source, str col, ASTCast cast, ASTSort sort) {
    return "\nTODO genSort(<source>, <col>, <cast>, <sort>)\n";
//     str access = genTypedAccess(col, t);
//     str rev = descending ? "True" : "False";
//     return
// "
// <source>.sort(key=lambda row: <access>, reverse=<rev>)
// ";
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
str genGroupByAgg(str source, str groupCol, ASTAggType aggType, str valueCol, ASTCast cast) {
    return "\nTODO genGroupByAgg(<source>, <groupCol>, <aggType>, <valueCol>, <cast>)\n";
    // str typeFunc = genTypeFunc(valType);
    // str aggName = getAggName(aggType);

    // if (aggType == aggAvg()) {
    //     return genGroupByAvg(source, groupCol, valueCol, typeFunc);
    // }
    // if (aggType == aggMin()) {
    //     return genGroupByMinMax(source, groupCol, valueCol, typeFunc, "min", "\<");
    // }
    // if (aggType == aggMax()) {
    //     return genGroupByMinMax(source, groupCol, valueCol, typeFunc, "max", "\>");
    // }
    // // default: sum
    // return genGroupBySum(source, groupCol, valueCol, typeFunc);
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

// // helper: get just the Python type function name
// str genTypeFunc(ASTType t) {
//     switch(t) {
//         case intType(): return "int";
//         case floatType(): return "float";
//         case stringType(): return "str";
//         case boolType(): return "bool";
//         default: throw "Unknown type for aggregation";
//     }
// }

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

