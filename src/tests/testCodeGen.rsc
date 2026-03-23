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
test bool testBoolCast() = genCast("active", boolCast()) == "bool(row[\"active\"])";

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