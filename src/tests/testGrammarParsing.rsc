module tests::testGrammarParsing

import frontend::Grammar;
import ParseTree;

test bool testEmptyProgram() {
    parse(#start[DELTA], "");
    return true;
}

// IO
test bool testLoadStatement() {
    parse(#Element, "Load \"data.csv\" as my_data");
    return true;
}

test bool testSaveStatement() {
    parse(#Element, "Save my_data as \"out.csv\"");
    return true;
}

test bool testInvalidLoadMissingAs() {
    try {
        parse(#Element, "Load \"data.csv\" my_data");
        return false;
    } catch: return true;
}

// Filtering
test bool testFilterEmpty() {
    parse(#Element, "Filter my_data { }");
    return true;
}

test bool testFilterEqualityInt() {
    parse(#FilterCondition, "\"Age\" (int) \>= 18");
    return true;
}

test bool testFilterEqualityString() {
    parse(#FilterCondition, "\"Name\" (string) == \"Alice\"");
    return true;
}

test bool testFilterEqualityBool() {
    parse(#FilterCondition, "\"Active\" (bool) != false");
    return true;
}

test bool testFilterInList() {
    parse(#FilterCondition, "\"Region\" (string) in [\"NL\", \"BE\"]");
    return true;
}

test bool testFilterInListNumbers() {
    parse(#FilterCondition, "\"Score\" (int) in [1, 2, 3]");
    return true;
}

test bool testAllEqualityOps() {
    parse(#FilterCondition, "\"Age\" (int) \>= 10");
    parse(#FilterCondition, "\"Age\" (int) \> 10");
    parse(#FilterCondition, "\"Age\" (int) \<= 10");
    parse(#FilterCondition, "\"Age\" (int) \< 10");
    parse(#FilterCondition, "\"Age\" (int) == 10");
    parse(#FilterCondition, "\"Age\" (int) != 10");
    return true;
}

test bool testInvalidFilterCondition() {
    try {
        parse(#Element, "Score\" (int) inn [1, 2, 3]");
        return false;
    } catch: return true;
}


// Transformations
test bool testTransformKeep() {
    parse(#Transformation, "keep \"Age\"");
    return true;
}

test bool testTransformDropna() {
    parse(#Transformation, "dropna \"Income\"");
    return true;
}

test bool testTransformRename() {
    parse(#Transformation, "rename \"Pets\" to \"Animals\"");
    return true;
}

test bool testTransformSortAscending() {
    parse(#Transformation, "sort \"Age\" (int) ascending");
    return true;
}

test bool testTransformSortDescending() {
    parse(#Transformation, "sort \"Score\" (float) descending");
    return true;
}

test bool testInvalidSortTransformation() {
    try {
        parse(#Element, "sort \"Score\" (float) asc");
        return false;
    } catch: return true;
}


// Visualise
test bool testVisualise() {
    parse(#Element, "Visualise my_data");
    return true;
}

test bool testVisualiseUsingTable() {
    parse(#Element, "Visualise my_data using table");
    return true;
}

test bool testVisualiseUsingTableImage() {
    parse(#Element, "Visualise my_data using table_image");
    return true;
}

test bool testVisualiseUsingPieChart() {
    parse(#Element, "Visualise my_data using pie_chart");
    return true;
}

test bool testVisualiseUsingBarChart() {
    parse(#Element, "Visualise my_data using bar_chart");
    return true;
}

test bool testInvalidVisualise() {
    try {
        parse(#Element, "Visualise my_data using random");
        return false;
    } catch: return true;
}

// Values
test bool testNumberPositive() {
    parse(#Number, "42");
    return true;
}

test bool testNumberNegative() {
    parse(#Number, "-42");
    return true;
}

test bool testNumberFloat() {
    parse(#Number, "3.14");
    return true;
}

test bool testInvalidNumberFloat() {
    try {
        parse(#Number, "3,14");
        return false;
    } catch: return true;
}

test bool testBooleanTrue() {
    parse(#Boolean, "true");
    return true;
}

test bool testBooleanFalse() {
    parse(#Boolean, "false");
    return true;
}

test bool testNestedArray() {
    parse(#Value, "[1, 2, 3]");
    return true;
}

// Grouping
test bool testGroupByCount() {
    parse(#Element, "GroupBy my_data by \"Region\" count");
    return true;
}

test bool testGroupByAggSum() {
    parse(#Element, "GroupBy my_data by \"Region\" sum \"Income\" (float)");
    return true;
}

test bool testGroupByAggAvg() {
    parse(#Element, "GroupBy my_data by \"Region\" avg \"Score\" (int)");
    return true;
}

// Other
test bool testInvalidIdentifierStartsWithNumber() {
    try {
        parse(#Identifier, "1invalid");
        return false;
    } catch: return true;
}

test bool testInlineComment() {
    parse(#start[DELTA], "Load \"data.csv\" as my_data // this is a comment");
    return true;
}

test bool testBlockComment() {
    parse(#start[DELTA], "/* block comment */\nLoad \"data.csv\" as my_data");
    return true;
}

test bool testInvalidComment() {
    try {
        parse(#start[DELTA], "Load \"data.csv\" as my_data % this is a comment");
        return false;
    } catch: return true;
}
