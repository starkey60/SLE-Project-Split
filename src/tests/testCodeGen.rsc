module tests::testCodeGen

import DSL_CodeGen;
import DSL_AST;
import String;
import IO;

// genValue
test bool testIntVal() = genValue(intVal(-42)) == "-42";
test bool testFloatVal() = genValue(floatVal(3.14)) == "3.14";
test bool testStringVal() = genValue(stringVal("hello")) == "\"hello\"";
test bool testBoolValTrue() = genValue(boolVal(true)) == "True";
test bool testBoolValFalse() = genValue(boolVal(false)) == "False";

// genList
test bool testGenListEmpty() = genList([]) == "[]";
test bool testGenListSingle() = genList([intVal(1)]) == "[1]";
test bool testGenListMultiple() = genList([intVal(4), intVal(0), intVal(4)]) == "[4, 0, 4]";

// genCast
test bool testIntCast() = genCast("age age", intCast()) == "int(row[\"age age\"])";
test bool testFloatCast() = genCast("price", floatCast()) == "float(row[\"price\"])";
test bool testStringCast() = genCast("name", stringCast()) == "str(row[\"name\"])";
test bool testBoolCast() = genCast("active", boolCast()) == "(row[\"active\"].strip().lower() == \"true\")";

// genCastFunc
test bool testCastFuncInt() = genCastFunc(intCast()) == "int";
test bool testCastFuncFloat() = genCastFunc(floatCast()) == "float";
test bool testCastFuncString() = genCastFunc(stringCast()) == "str";
test bool testCastFuncBool() = genCastFunc(boolCast()) == "bool";

// genEqualityOperator
test bool testEqGreaterEq() = genEqualityOperator(greaterEq()) == "\>=";
test bool testEqGreater() = genEqualityOperator(greater()) == "\>";
test bool testEqLessEq() = genEqualityOperator(lessEq()) == "\<=";
test bool testEqLess() = genEqualityOperator(less()) == "\<";
test bool testEqEquals() = genEqualityOperator(equals()) == "==";
test bool testEqNotEquals() = genEqualityOperator(notEquals()) == "!=";

// genFilter
test bool testFilterEquality() {
    str result = genFilter(equality("age", intVal(30), greaterEq(), intCast()));
    return result == "int(row[\"age\"]) \>= 30";
}

test bool testFilterInList() {
    str result = genFilter(inList("country", [stringVal("NL"), stringVal("DE")], stringCast()));
    return result == "str(row[\"country\"]) in [\"NL\", \"DE\"]";
}

// genRename
test bool testGenRename() {
    str result = genRename("data", "old_col", "new_col");
    return contains(result, "_row[\'new_col\'] = _row.pop(\'old_col\')");
}

// genSort
test bool testGenSortAscending() {
    str result = genSort("data", "age", intCast(), ascending());
    return contains(result, "reverse=False") && contains(result, "int(row[\"age\"])");
}

test bool testGenSortDescending() {
    str result = genSort("data", "price", floatCast(), descending());
    return contains(result, "reverse=True") && contains(result, "float(row[\"price\"])");
}

// genLoad
test bool testGenLoad() {
    str result = genLoad("data/file.csv", "myData");
    return contains(result, "open(\"data/file.csv\"")
        && contains(result, "myData = []")
        && contains(result, "myData.append(row)");
}

// genSave
test bool testGenSave() {
    str result = genSave("out/file.csv", "myData");
    return contains(result, "open(\"out/file.csv\", \"w\"")
        && contains(result, "writer.writerows(myData)");
}

// genColOrder
test bool testColOrderKeep() =
    genColOrder([dropna("c"), keep("a"), keep("b"), keep("c")]) == ["c", "a", "b"];

test bool testColOrderRename() =
    genColOrder([keep("p"), keep("r"), keep("i"), dropna("p"), dropna("i"), dropna("r"), rename("p", "a")]) == ["a", "r", "i"];
    
test bool testColOrderRenameComplex() =
    genColOrder([keep("a"), rename("a", "x"), keep("a"), keep("c")]) == ["x", "c"];

test bool testColOrderNoDuplicates() =
    genColOrder([keep("a"), sort("a", ascending(), intCast())]) == ["a"];

// genGroupByCount
test bool testGroupByCount() {
    str result = genGroupByCount("sales", "region");
    return contains(result, "_key = _row[\'region\']")
        && contains(result, "GroupBy region (count)");
}

// genGroupByAgg
test bool testGroupBySum() {
    str result = genGroupByAgg("sales", "region", aggSum(), "amount", floatCast());
    return contains(result, "GroupBy region (sum amount)")
        && contains(result, "float(_row[\'amount\'])");
}

test bool testGroupByAvg() {
    str result = genGroupByAgg("sales", "region", aggAvg(), "amount", floatCast());
    return contains(result, "GroupBy region (avg amount)")
        && contains(result, "_counts");
}

test bool testGroupByMin() {
    str result = genGroupByAgg("sales", "cat", aggMin(), "price", intCast());
    return contains(result, "GroupBy cat (min price)")
        && contains(result, "\<");
}

test bool testGroupByMax() {
    str result = genGroupByAgg("sales", "cat", aggMax(), "price", intCast());
    return contains(result, "GroupBy cat (max price)")
        && contains(result, "\>");
}

// genFilterDataset
test bool testFilterDatasetSingleCondition() {
    str result = genFilterDataset("data", [equality("age", intVal(18), greaterEq(), intCast())]);
    return contains(result, "data_filtered = []")
        && contains(result, "for row in data")
        && contains(result, "int(row[\"age\"]) \>= 18")
        && contains(result, "data_filtered.append(row)")
        && contains(result, "data = data_filtered");
}

test bool testFilterDatasetMultipleConditions() {
    str result = genFilterDataset("data", [
        equality("age", intVal(18), greaterEq(), intCast()),
        inList("country", [stringVal("NL"), stringVal("DE")], stringCast())
    ]);
    return contains(result, "int(row[\"age\"]) \>= 18")
        && contains(result, "str(row[\"country\"]) in [\"NL\", \"DE\"]");
}

test bool testFilterDatasetEmptyFilters() {
    str result = genFilterDataset("data", []);
    return result == "";
}

// genTransformDataset
test bool testTransformDatasetRenameOnly() {
    str result = genTransformDataset("data", [keep("a"), rename("a", "b")]);
    return contains(result, "_row[\'b\'] = _row.pop(\'a\')")
        && contains(result, "filters = [\"b\"]");
}

test bool testTransformDatasetSortOnly() {
    str result = genTransformDataset("data", [keep("age"), sort("age", ascending(), intCast())]);
    return contains(result, "data.sort(key=lambda row: int(row[\"age\"])")
        && contains(result, "reverse=False");
}

test bool testTransformDatasetDropnaOnly() {
    str result = genTransformDataset("data", [keep("name"), dropna("name")]);
    return contains(result, "data_clean = []")
        && contains(result, "str(row[\'name\']).strip() != \'\'")
        && contains(result, "data = data_clean");
}

test bool testTransformDatasetCombined() {
    str result = genTransformDataset("data", [
        keep("name"),
        keep("age"),
        dropna("name"),
        rename("age", "years"),
        sort("years", descending(), intCast())
    ]);
    return contains(result, "data_clean = []")
        && contains(result, "_row[\'years\'] = _row.pop(\'age\')")
        && contains(result, "reverse=True")
        && contains(result, "filters = [\"name\", \"years\"]");
}

// genVisualiseTable
test bool testVisualiseTable() {
    str result = genVisualiseTable("myData");
    return contains(result, "if myData:")
        && contains(result, "_headers = list(myData[0].keys())")
        && contains(result, "_rows = [list(row.values()) for row in myData]")
        && contains(result, "print(tabulate(_rows, headers=_headers")
        && contains(result, "No data to display for myData.");
}

// genVisualiseTableImage
test bool testVisualiseTableImage() {
    str result = genVisualiseTableImage("myData");
    return contains(result, "if myData:")
        && contains(result, "_headers = list(myData[0].keys())")
        && contains(result, "plt.savefig(\'myData_table.png\'")
        && contains(result, "Table image saved to myData_table.png")
        && contains(result, "No data to display for myData.");
}

// genVisualisePieChart
test bool testVisualisePieChart() {
    str result = genVisualisePieChart("myData");
    return contains(result, "if myData:")
        && contains(result, "_labelCol = _keys[0]")
        && contains(result, "_valueCol = _keys[1]")
        && contains(result, "plt.savefig(\'myData_pie.png\'")
        && contains(result, "Pie chart saved to myData_pie.png");
}

// genVisualiseBarChart
test bool testVisualiseBarChart() {
    str result = genVisualiseBarChart("myData");
    return contains(result, "if myData:")
        && contains(result, "_labelCol = _keys[0]")
        && contains(result, "_valueCol = _keys[1]")
        && contains(result, "_ax.bar(_labels, _values")
        && contains(result, "plt.savefig(\'myData_bar.png\'")
        && contains(result, "Bar chart saved to myData_bar.png");
}