module DSL_Transformation

import DSL_Grammar;
import DSL_AST;
import String;
import ParseTree;
import IO;

// top level progam
ASTProgram toAST(start[DELTA] dsl) {
    switch (dsl) {
        case (start[DELTA])`<Element* elements>`:
            return program([ toAST(el) | el <- elements ]);
            
        default: throw "Top level error";
    }
}

// Main commands (Load, Constrain, Visualise (using?))
ASTCommand toAST(Element el) {
    switch (el) {
        case (Element)`Load <String s> as <Identifier id>`:
            return io("<stripQuotes(s)>", "<id>", load());
        case (Element)`Save <Identifier id> as <String s>`:
            return io("<stripQuotes(s)>", "<id>", save());
        case (Element)`Filter <Identifier from_id> { <FilterCondition* conds> }`:
            return filterDataset("<from_id>", [toAST(c) | c <- conds]);
        case (Element)`Transform <Identifier from_id> { <Transformation* transformations> }`:
            return transformDataset("<from_id>", [toAST(t) | t <- transformations]);
        case (Element)`Visualise <Identifier target>`:
            return visualise("<target>", defaultVis());
        case (Element)`Visualise <Identifier target> using <VisType template>`:
            return visualise("<target>", toAST(template));
        case (Element)`GroupBy <Identifier src> by <String col> count`:
            return groupByCount("<src>", "<stripQuotes(col)>");
        case (Element)`GroupBy <Identifier src> by <String col> <AggType agg> <String valCol> (<CastType t>)`:
            return groupByAgg("<src>", "<stripQuotes(col)>", toAST(agg), "<stripQuotes(valCol)>", toAST(t));
        default: throw "Unknown Command Type <el>";
    }
}

// filter conditions
ASTFilter toAST(FilterCondition cond) {
    switch (cond) {
        case (FilterCondition)`<String col> (<CastType t>) in [<{Value ","}* vals>]`: {
            list[ASTValue] values = [toAST(v) | Value v <- vals];
            return inList("<stripQuotes(col)>", values, toAST(t));
        }
        case (FilterCondition)`<String col> (<CastType t>) <EqualityOp operator> <Value val>`:
            return equality("<stripQuotes(col)>", toAST(val), toAST(operator), toAST(t));
        default: throw "unknown filter condition <cond>";
    }
}

//equality operations
ASTEquality toAST(EqualityOp op) {
    switch (op) {
        case (EqualityOp) `\>=`: return greaterEq();
        case (EqualityOp) `\>`:  return greater();
        case (EqualityOp) `\<=`: return lessEq();
        case (EqualityOp) `\<`:  return less();
        case (EqualityOp) `==`: return equals();
        case (EqualityOp) `!=`: return notEquals();
        default: throw "unknown equality operator <op>";
    }
}

// transformation
ASTTransformation toAST(Transformation t) {
    switch (t) {
        case (Transformation)`keep <String col>`:
            return keep("<stripQuotes(col)>");
        case (Transformation)`dropna <String col>`:
            return dropna("<stripQuotes(col)>");
        case (Transformation)`sort <String col> (<CastType cast>) <SortOrder order>`:
            return sort("<stripQuotes(col)>", toAST(order), toAST(cast));
        case (Transformation)`rename <String col> to <String s>`:
            return rename("<stripQuotes(col)>", "<stripQuotes(s)>");
        default: throw "unknown transformation <t>";
    }
}

// sorting orders
ASTSort toAST(SortOrder order) {
    switch (order) {
        case (SortOrder) `ascending`: return ascending();
        case (SortOrder) `descending`: return descending();
        default: throw "Unknonw sort order <order>";
    }
}

// casts
ASTCast toAST(CastType cast) {
    switch (cast) {
        case (CastType) `int`: return intCast();
        case (CastType) `float`:  return floatCast();
        case (CastType) `string`: return stringCast();
        case (CastType) `bool`:  return boolCast();
        default: throw "unknown cast type <cast>";
    }
}

ASTAggType toAST((AggType)`sum`) = DSL_AST::aggSum();
ASTAggType toAST((AggType)`avg`) = DSL_AST::aggAvg();
ASTAggType toAST((AggType)`min`) = DSL_AST::aggMin();
ASTAggType toAST((AggType)`max`) = DSL_AST::aggMax();

// visualisations
ASTVis toAST(VisType t) {
    switch (t) {
        case (VisType) `table`: return table();
        case (VisType) `table_image`: return tableImage();
        case (VisType) `pie_chart`: return pieChart();
        case (VisType) `bar_chart`: return barChart();
        default: throw "unknown visualisation type <t>";
    }
}

ASTValue toAST(Value val) {
    switch (val) {
        case (Value)`<String s>`:
            return stringVal(stripQuotes(s));
        case (Value)`<Boolean b>`:
            return boolVal("<b>" == "true");
        case (Value)`<Number n>`: 
            return toAST(n);
        default: throw "Could not transform value <val>";
    }
}

ASTValue toAST(Number n) {
    str raw = "<n>";
    return contains(raw, ".")
        ? floatVal(toReal(raw))
        : intVal(toInt(raw));
}

str stripQuotes(String s) {
    str raw = "<s>";
    return substring(raw, 1, size(raw) - 1);
}