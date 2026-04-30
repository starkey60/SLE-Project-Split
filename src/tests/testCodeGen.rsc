module tests::testCodeGen

import backend::CodeGen;
import frontend::Grammar;
import ParseTree;
import String;
import IO;

// Value
test bool testIntVal() = generate((Value)`-42`) == "-42";
test bool testFloatVal() = generate((Value)`3.14`) == "3.14";
test bool testStringVal() = generate((Value)`"hello"`) == "\"hello\"";
test bool testBoolValTrue() = generate((Value)`true`) == "True";
test bool testBoolValFalse() = generate((Value)`false`) == "False";

// List
test bool testGenListEmpty() = generate((Value)`[]`) == "[]";
test bool testGenListSingle() = generate((Value)`[1]`) == "[1]";
test bool testGenListMultiple() = generate((Value)`[4, 0, 4]`) == "[4, 0, 4]";

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

// FilterCondition
test bool testFilterConditionEquality() {
    str result = generate((FilterCondition)`"age" (int) \>= 30`);
    return result == "int(row[\"age\"]) \>= 30";
}

test bool testFilterConditionInList() {
    str result = generate((FilterCondition)`"country" (string) in ["NL", "DE"]`);
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

// Load
test bool testGenSave() {
    Element el = parse(#Element, "Load \"data/file.csv\" as myData");
    str result = generate(el);
    return contains(result, "open(\"data/file.csv\"")
        && contains(result, "myData = []")
        && contains(result, "myData.append(row)");
}

// Save
test bool testGenSave() {
    Element el = parse(#Element, "Save myData as \"out/file.csv\"");
    str result = generate(el);
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

// Filter
test bool testFilterDatasetSingleCondition() {
    str result = generate((Element)`Filter data { "age" (int) \>= 18 }`);
    return contains(result, "data_filtered = []")
        && contains(result, "for row in data")
        && contains(result, "int(row[\"age\"]) \>= 18")
        && contains(result, "data_filtered.append(row)")
        && contains(result, "data = data_filtered");
}

test bool testFilterDatasetMultipleConditions() {
    Element el = parse(#Element, "Filter data { \"age\" (int) \>= 18\n\"country\" (string) in [\"NL\", \"DE\"] }");
    str result = generate(el);
    return contains(result, "int(row[\"age\"]) \>= 18")
        && contains(result, "str(row[\"country\"]) in [\"NL\", \"DE\"]");
}

test bool testFilterDatasetEmptyFilters() {
    str result = generate((Element)`Filter data {  }`);
    return result == "";
}

// genTransform
test bool testTransformDatasetRenameOnly() {
    Element el = parse(#Element, "Transform data { keep \"a\" rename \"a\" to \"b\" }");
    str result = generate(el);
    return contains(result, "_row[\"b\"] = _row.pop(\"a\")")
        && contains(result, "filters = [\"b\"]");
}

test bool testTransformDatasetSortOnly() {
    Element el = parse(#Element, "Transform data { keep \"age\" sort \"age\" (int) ascending }");
    str result = generate(el);
    return contains(result, "data.sort(key=lambda row: int(row[\"age\"])")
        && contains(result, "reverse=False");
}

test bool testTransformDatasetDropnaOnly() {
    Element el = parse(#Element, "Transform data { keep \"name\" dropna \"name\" }");
    str result = generate(el);
    return contains(result, "data_clean = []")
        && contains(result, "str(row[\"name\"]).strip() != \'\'")
        && contains(result, "data = data_clean");
}

test bool testTransformDatasetCombined() {
    Element el = parse(#Element, "Transform data { keep \"name\" keep \"age\" dropna \"name\" rename \"age\" to \"years\" sort \"years\" (int) descending }");
    str result = generate(el);
    return contains(result, "data_clean = []")
        && contains(result, "_row[\"years\"] = _row.pop(\"age\")")
        && contains(result, "reverse=True")
        && contains(result, "filters = [\"name\", \"years\"]");
}

// Visualise
test bool testVisualiseTable() {
    str result = generate((Element)`Visualise myData`);
    return contains(result, "if myData:")
        && contains(result, "_headers = list(myData[0].keys())")
        && contains(result, "_rows = [list(row.values()) for row in myData]")
        && contains(result, "print(tabulate(_rows, headers=_headers");
}

test bool testVisualiseTableImage() {
    str result = generate((Element)`Visualise myData using table_image`);
    return contains(result, "if myData:")
        && contains(result, "_headers = list(myData[0].keys())")
        && contains(result, "plt.savefig(\'myData_table.png\'");
}

test bool testVisualisePieChart() {
    str result = generate((Element)`Visualise myData using pie_chart`);
    return contains(result, "if myData:")
        && contains(result, "_labelCol = _keys[0]")
        && contains(result, "_valueCol = _keys[1]")
        && contains(result, "plt.savefig(\'myData_pie.png\'");
}

test bool testVisualiseBarChart() {
    str result = generate((Element)`Visualise myData using bar_chart`);
    return contains(result, "if myData:")
        && contains(result, "_labelCol = _keys[0]")
        && contains(result, "_valueCol = _keys[1]")
        && contains(result, "_ax.bar(_labels, _values")
        && contains(result, "plt.savefig(\'myData_bar.png\'");
}