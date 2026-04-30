module tests::testStaticAnalysis

import frontend::StaticAnalysis;
import frontend::Grammar;
import ParseTree;
import Message;
import IO;
import util::Maybe;

loc dummySrc  = |test:///dummy|(0, 1, <1,0>, <1,1>);
loc datasetA  = |test:///datasetA|(0, 1, <1,0>, <1,1>);

map[str, loc] emptyDatasets = ();
map[str, loc] withFoo = ("foo": datasetA);

Array parseArr(str s) = parse(#Array, s);
CastType parseCast(str s) = parse(#CastType, s);
FilterCondition parseCond(str s) = parse(#FilterCondition, s);
Transformation parseTrans(str s) = parse(#Transformation, s);

CastType intCast = parse(#CastType, "int");
CastType floatCast = parse(#CastType, "float");
CastType stringCast = parse(#CastType, "string");
CastType boolCast = parse(#CastType, "bool");

Value aNumber = parse(#Value, "42");
Value aString = parse(#Value, "\"hello\"");
Value aBool = parse(#Value, "true");
Value anArray = parse(#Value, "[1, 2, 3]");

// checkRef
test bool testCheckRefDatasetKnown() = checkRef("foo", dummySrc, withFoo) == {};

test bool testCheckRefMultipleDatasets() {
    map[str, loc] multi = ("foo": datasetA, "baz": datasetA);
    result = checkRef("bar", dummySrc, multi);
    return any(<dummySrc, error(/E01/, dummySrc)> <- result);
}

test bool testCheckRefDatasetNotKnown() {
    result = checkRef("bar", dummySrc, withFoo);
    return any(<dummySrc, error(/E01/, dummySrc)> <- result);
}
test bool testCheckRefErrorLocCorrect() {
    loc otherSrc = |test:///other|(5, 3, <2,0>, <2,3>);
    result = checkRef("missing", otherSrc, emptyDatasets);
    return any(<otherSrc, error(/E01/, otherSrc)> <- result);
}

// checkDefine
test bool testCheckDefineDatasetAlreadyDefined() {
    result = checkDefine("foo", dummySrc, withFoo);
    return any(<dummySrc, warning(/W01/, dummySrc)> <- result);
}

test bool testCheckDefineDatasetNotDefined() = 
    checkDefine("bar", dummySrc, emptyDatasets) == {};

// checkPath
test bool testCheckPathCorrect() {
    String path = parse(#String, "\"data.csv\"");
    return checkPath(path) == {};
}

test bool testCheckPathWrong() {
    String path = parse(#String, "\"data.txt\"");
    result = checkPath(path);
    return any(<_, warning(/W02/, _)> <- result);
}

// isNumericCast
test bool testIsNumericCastCorrect() {
    CastType cast = parse(#CastType, "int");
    return isNumericCast(cast);
}

test bool testIsNumericCastWrong() {
    CastType cast = parse(#CastType, "bool");
    return !isNumericCast(cast);
}

// isCompatibleValue
test bool testIsCompatibleValueIntCastNumberValue() = isCompatibleValue(intCast, aNumber);
test bool testIsCompatibleValueIntCastStringValue() = !isCompatibleValue(intCast, aString);
test bool testIsCompatibleValueIntCastBoolValue() = !isCompatibleValue(intCast, aBool);
test bool testIsCompatibleValueIntCastArrayValue() = !isCompatibleValue(intCast, anArray);

test bool testIsCompatibleValueFloatCastNumberValue() = isCompatibleValue(floatCast, aNumber);
test bool testIsCompatibleValueFloatCastStringValue() = !isCompatibleValue(floatCast, aString);

test bool testIsCompatibleValueStringCastStringValue() = isCompatibleValue(stringCast, aString);
test bool testIsCompatibleValueStringCastNumberValue() = !isCompatibleValue(stringCast, aNumber);

test bool testIsCompatibleValueBoolCastBoolValue() = isCompatibleValue(boolCast, aBool);
test bool testIsCompatibleValueBoolCastNumberValue() = !isCompatibleValue(boolCast, aNumber);

// getArrayValueType
test bool testGetArrayValueTypeEmptyArray() = getArrayValueType(parseArr("[]"), intCast) == just(intCast);
test bool testGetArrayValueTypeSingleInt() = just((CastType)`float`) := getArrayValueType(parseArr("[3]"), intCast);
test bool testGetArrayValueTypeSingleString() = just((CastType)`string`) := getArrayValueType(parseArr("[\"foo\"]"), intCast);

test bool testGetArrayValueTypeMultipleNumbers() =
    just((CastType)`float`) := getArrayValueType(parseArr("[1, 2.3, 4]"), intCast);
test bool testGetArrayValueTypeMultipleBools() =
    just((CastType)`bool`) := getArrayValueType(parseArr("[true, true, false]"), intCast);
    
test bool testGetArrayValuetypeDifferentNumbers() = 
    just((CastType)`float`) := getArrayValueType(parseArr("[1, 2.3, 4]"), intCast);

test bool testGetArrayValueTypeMixed() =
    nothing() := getArrayValueType(parseArr("[1, \"hello\", true]"), intCast);

// checkFilterCondition
test bool testCheckFilterConditionWithStringError() {
    result = checkFilterCondition(parseCond("\"col\" (string) \< \"foo\""));
    return any(<_, error(/E02/, _)> <- result);
}

test bool testCheckFilterConditionStringCorrect() =
    checkFilterCondition(parseCond("\"col\" (string) == \"hello\"")) == {};

test bool testCheckFilterConditionNumeric() =
    checkFilterCondition(parseCond("\"col\" (int) == 42")) == {};

test bool testCheckFilterConditionIncompatableValue() {
    result = checkFilterCondition(parseCond("\"col\" (int) == \"oops\""));
    return any(<_, error(/E03/, _)> <- result);
} 

test bool testCheckFilterConditionMixedArrayE04() {
    result = checkFilterCondition(parseCond("\"col\" (int) in [1, \"foo\"]"));
    return any(<_, error(/E04/, _)> <- result);
}

test bool testCheckFilterConditionTypeMismatch() {
    result = checkFilterCondition(parseCond("\"col\" (int) in [\"a\", \"b\"]"));
    return any(<_, error(/E05/, _)> <- result);
}

test bool testCheckFilterConditionArrayCorrect() =
    checkFilterCondition(parseCond("\"col\" (float) in [1, 2, 3]")) == {};

// checkTransformation
test bool testCheckTransformationRenameToSameName() {
    result = checkTransformation(parseTrans("rename \"col\" to \"col\""));
    return any(<_, warning(/W03/, _)> <- result);
}

test bool testCheckTransformationRenameCorrect() =
    checkTransformation(parseTrans("rename \"col\" to \"newcol\"")) == {};

test bool testCheckTransformationSortNonNumericCast() {
    result = checkTransformation(parseTrans("sort \"col\" (string) ascending"));
    return any(<_, error(/E07/, _)> <- result);
}

test bool testCheckTransformationSortCorrect() =
    checkTransformation(parseTrans("sort \"col\" (int) descending")) == {};

// getTransformationColumn
test bool testGetTransformationColumnKeep() = getTransformationColumn(parseTrans("keep \"age\"")) == "\"age\"";
test bool testGetTransformationColumnDropna() = getTransformationColumn(parseTrans("dropna \"age\"")) == "\"age\"";
test bool testGetTransformationColumnRename() = getTransformationColumn(parseTrans("rename \"a\" to \"b\"")) == "\"a\"";
test bool testGetTransformationColumnSort() = getTransformationColumn(parseTrans("sort \"x\" (int) ascending")) == "\"x\"";

// checkTransformationOrdering
test bool testCheckTransformationOrderingNoWarning() =
    checkTransformationOrdering([
        parseTrans("keep \"a\""),
        parseTrans("dropna \"a\""),
        parseTrans("keep \"b\"")
    ]) == {};

test bool testCheckTransformationOrderingWarning() {
    result = checkTransformationOrdering([
        parseTrans("keep \"a\""),
        parseTrans("keep \"b\""),
        parseTrans("dropna \"a\"")
    ]);
    return any(<_, warning(/W04/, _)> <- result);
}

// checkDuplicateKeeps
test bool testCheckDuplicateKeepsWarning() {
    result = checkDuplicateKeeps([
        parseTrans("keep \"col\""),
        parseTrans("keep \"col\"")
    ]);
    return any(<_, warning(/W05/, _)> <- result);
}

test bool checkDuplicateKeepsRedundantKeeps() {
    result = checkDuplicateKeeps([
        parseTrans("dropna \"col\""),
        parseTrans("keep \"col\"")
    ]);
    return any(<_, warning(/W05/, _)> <- result);
}

test bool checkDuplicateKeepsNoWarning() =
    checkDuplicateKeeps([
        parseTrans("keep \"a\""),
        parseTrans("keep \"b\"")
    ]) == {};