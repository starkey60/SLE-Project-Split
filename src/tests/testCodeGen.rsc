module tests::testCodeGen

import DSL_CodeGen;
import DSL_Grammar;
import String;
import IO;

// genValue
test bool testIntVal() = genValue((Value)`-42`) == "-42";
test bool testFloatVal() = genValue((Value)`3.14`) == "3.14";
test bool testStringVal() = genValue((Value)`"hello"`) == "\"hello\"";
test bool testBoolValTrue() = genValue((Value)`true`) == "True";
test bool testBoolValFalse() = genValue((Value)`false`) == "False";

// genList
test bool testGenListEmpty() = genList([]) == "[]";
test bool testGenListSingle() = genList([(Value)`1`]) == "[1]";
test bool testGenListMultiple() = genList([(Value)`4`, (Value)`0`, (Value)`4`]) == "[4, 0, 4]";

// genCast
test bool testIntCast() = genCast("\"age age\"", (CastType)`int`) == "int(row[\"age age\"])";
test bool testFloatCast() = genCast("\"price\"", (CastType)`float`) == "float(row[\"price\"])";
test bool testStringCast() = genCast("\"name\"", (CastType)`string`) == "str(row[\"name\"])";
test bool testBoolCast() = genCast("\"active\"", (CastType)`bool`) == "(row[\"active\"].strip().lower() == \"true\")";

// genEqualityOperator
test bool testEqGreaterEq() = genEqualityOperator((EqualityOp)`\>=`) == "\>=";
test bool testEqGreater() = genEqualityOperator((EqualityOp)`\>`) == "\>";
test bool testEqLessEq() = genEqualityOperator((EqualityOp)`\<=`) == "\<=";
test bool testEqLess() = genEqualityOperator((EqualityOp)`\<`) == "\<";
test bool testEqEquals() = genEqualityOperator((EqualityOp)`==`) == "==";
test bool testEqNotEquals() = genEqualityOperator((EqualityOp)`!=`) == "!=";

// genFilterCondition
test bool testFilterConditionEquality() {
    str result = genFilterCondition((FilterCondition)`"age" (int) \>= 30`);
    return result == "int(row[\"age\"]) \>= 30";
}

test bool testFilterConditionInList() {
    str result = genFilterCondition((FilterCondition)`"country" (string) in ["NL", "DE"]`);
    return result == "str(row[\"country\"]) in [\"NL\", \"DE\"]";
}

// genRenameTransformations
test bool testGenRename() {
    str result = genRenameTransformations("data", [(Transformation)`rename "old_col" to "new_col"`]);
    return contains(result, "_row[\"new_col\"] = _row.pop(\"old_col\")");
}

// genSortTransformations
test bool testgenSortTransformationsAscending() {
    str result = genSortTransformations("data", [(Transformation)`sort "age" (int) ascending`]);
    return contains(result, "reverse=False") && contains(result, "int(row[\"age\"])");
}

test bool testgenSortTransformationsDescending() {
    str result = genSortTransformations("data", [(Transformation)`sort "price" (float) descending`]);
    return contains(result, "reverse=True") && contains(result, "float(row[\"price\"])");
}

// genLoad
test bool testGenLoad() {
    str result = genLoad("\"data/file.csv\"", "myData");
    return contains(result, "open(\"data/file.csv\"")
        && contains(result, "myData = []")
        && contains(result, "myData.append(row)");
}

// genSave
test bool testGenSave() {
    str result = genSave("\"out/file.csv\"", "myData");
    return contains(result, "open(\"out/file.csv\", \"w\"")
        && contains(result, "writer.writerows(myData)");
}

// // genColOrder
test bool testColOrderKeep() =
    genColOrder([(Transformation)`dropna "c"`, (Transformation)`keep "a"`, (Transformation)`keep "b"`, (Transformation)`keep "c"`]) == ["c", "a", "b"];

test bool testColOrderRename() =
    genColOrder([(Transformation)`keep "p"`, (Transformation)`keep "r"`, (Transformation)`keep "i"`, (Transformation)`dropna "p"`, (Transformation)`dropna "i"`, (Transformation)`dropna "r"`, (Transformation)`rename "p" to "a"`]) == ["a", "r", "i"];

test bool testColOrderRenameComplex() =
    genColOrder([(Transformation)`keep "a"`, (Transformation)`rename "a" to "x"`, (Transformation)`keep "a"`, (Transformation)`keep "c"`]) == ["x", "c"];

test bool testColOrderNoDuplicates() =
    genColOrder([(Transformation)`keep "a"`, (Transformation)`sort "a" (int) ascending`]) == ["a"];


// // genGroupByCount
test bool testGroupByCount() {
    str result = genGroupByAggGeneralised("sales", "\"region\"", "\'count\'",
        "_groups[_key] = _groups.get(_key, 0) + 1");
    return contains(result, "_key = _row[\"region\"]")
        && contains(result, "GroupBy region");
}

// genGroupByAgg
test bool testGroupBySum() {
    str result = genGroupByAgg("sales", "\"region\"", (AggType)`sum`, "\"amount\"", (CastType)`float`);
    return contains(result, "GroupBy region")
        && contains(result, "float(row[\"amount\"])");
}

test bool testGroupByAvg() {
    str result = genGroupByAgg("sales", "\"region\"", (AggType)`avg`, "\"amount\"", (CastType)`float`);
    return contains(result, "GroupBy region")
        && contains(result, "_counts");
}

test bool testGroupByMin() {
    str result = genGroupByAgg("sales", "\"cat\"", (AggType)`min`, "\"price\"", (CastType)`int`);
    return contains(result, "GroupBy cat")
        && contains(result, "\<");
}

test bool testGroupByMax() {
    str result = genGroupByAgg("sales", "\"cat\"", (AggType)`max`, "\"price\"", (CastType)`int`);
    return contains(result, "GroupBy cat")
        && contains(result, "\>");
}

// genFilterDataset
test bool testFilterDatasetSingleCondition() {
    str result = genFilter("data", [genFilterCondition((FilterCondition)`"age" (int) \>= 18`)]);
    return contains(result, "data_filtered = []")
        && contains(result, "for row in data")
        && contains(result, "int(row[\"age\"]) \>= 18")
        && contains(result, "data_filtered.append(row)")
        && contains(result, "data = data_filtered");
}

test bool testFilterDatasetMultipleConditions() {
    str result = genFilter("data", [
        genFilterCondition((FilterCondition)`"age" (int) \>= 18`),
        genFilterCondition((FilterCondition)`"country" (string) in ["NL", "DE"]`)
    ]);
    return contains(result, "int(row[\"age\"]) \>= 18")
        && contains(result, "str(row[\"country\"]) in [\"NL\", \"DE\"]");
}

test bool testFilterDatasetEmptyFilters() {
    str result = genFilter("data", []);
    return result == "";
}

// genTransform
test bool testTransformDatasetRenameOnly() {
    str result = genTransform("data", [(Transformation)`keep "a"`, (Transformation)`rename "a" to "b"`]);
    return contains(result, "_row[\"b\"] = _row.pop(\"a\")")
        && contains(result, "filters = [\"b\"]");
}

test bool testTransformDatasetSortOnly() {
    str result = genTransform("data", [(Transformation)`keep "age"`, (Transformation)`sort "age" (int) ascending`]);
    return contains(result, "data.sort(key=lambda row: int(row[\"age\"])")
        && contains(result, "reverse=False");
}

test bool testTransformDatasetDropnaOnly() {
    str result = genTransform("data", [(Transformation)`keep "name"`, (Transformation)`dropna "name"`]);
    return contains(result, "data_clean = []")
        && contains(result, "str(row[\"name\"]).strip() != \'\'")
        && contains(result, "data = data_clean");
}

test bool testTransformDatasetCombined() {
    str result = genTransform("data", [
        (Transformation)`keep "name"`,
        (Transformation)`keep "age"`,
        (Transformation)`dropna "name"`,
        (Transformation)`rename "age" to "years"`,
        (Transformation)`sort "years" (int) descending`
    ]);
    return contains(result, "data_clean = []")
        && contains(result, "_row[\"years\"] = _row.pop(\"age\")")
        && contains(result, "reverse=True")
        && contains(result, "filters = [\"name\", \"years\"]");
}

// genVisualiseTable
test bool testVisualiseTable() {
    str result = genVisualiseTable("myData");
    return contains(result, "if myData:")
        && contains(result, "_headers = list(myData[0].keys())")
        && contains(result, "_rows = [list(row.values()) for row in myData]")
        && contains(result, "print(tabulate(_rows, headers=_headers");
}

// genVisualiseTableImage
test bool testVisualiseTableImage() {
    str result = genVisualiseTableImage("myData");
    return contains(result, "if myData:")
        && contains(result, "_headers = list(myData[0].keys())")
        && contains(result, "plt.savefig(\'myData_table.png\'");
}

// genVisualisePieChart
test bool testVisualisePieChart() {
    str result = genVisualisePieChart("myData");
    return contains(result, "if myData:")
        && contains(result, "_labelCol = _keys[0]")
        && contains(result, "_valueCol = _keys[1]")
        && contains(result, "plt.savefig(\'myData_pie.png\'");
}

// genVisualiseBarChart
test bool testVisualiseBarChart() {
    str result = genVisualiseBarChart("myData");
    return contains(result, "if myData:")
        && contains(result, "_labelCol = _keys[0]")
        && contains(result, "_valueCol = _keys[1]")
        && contains(result, "_ax.bar(_labels, _values")
        && contains(result, "plt.savefig(\'myData_bar.png\'");
}
