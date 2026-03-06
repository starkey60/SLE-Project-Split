module DSL_Transformation

import DSL_Grammar;
import DSL_AST;
import String;
import ParseTree;
import IO;

// top level progam
ASTProgram toAST(start[DSL] dsl) {
    switch (dsl) {
        case (start[DSL])`<Element* elements>`:
            return program([ toAST(el) | el <- elements ]);
            
        default: throw "Top level error";
    }
}

// Main commands (Load, Constrain, Visualise (using?))
ASTCommand toAST(Element el) {
    switch (el) {
        case (Element)`Load <String s> as <Identifier id>`:
            return load("<stripQuotes(s)>", "<id>");
        case (Element)`Constrain <Identifier from_id> as <Identifier to_id> { <Condition* conds> }`:
            return constrain("<from_id>", "<to_id>", [toAST(c) | c <- conds]);
        case (Element)`Visualise <Identifier target>`:
            return visualise("<target>");
        case (Element)`Visualise <Identifier target> using <Identifier template>`:
            return visualiseUsing("<target>", "<template>");
        case (Element)`Rename <Identifier src> column <String oldCol> to <String newCol>`:
            return rename("<src>", "<stripQuotes(oldCol)>", "<stripQuotes(newCol)>");
        case (Element)`Sort <Identifier src> by <Identifier col> (<RowType t>) ascending`:
            return sortAsc("<src>", "<col>", toAST(t));
        case (Element)`Sort <Identifier src> by <Identifier col> (<RowType t>) descending`:
            return sortDesc("<src>", "<col>", toAST(t));
        case (Element)`GroupBy <Identifier src> by <Identifier col> count`:
            return groupByCount("<src>", "<col>");
        case (Element)`GroupBy <Identifier src> by <Identifier col> <AggType agg> <Identifier valCol> (<RowType t>)`:
            return groupByAgg("<src>", "<col>", toAST(agg), "<valCol>", toAST(t));
        default: throw "Unknown Command Type";
    }
}


// inList condition
ASTCondition toAST((Condition)`<Identifier col> (<RowType t>) in [<{Value ","}* vals>]`) {
  list[ASTValue] values = [toAST(v) | Value v <- vals];
  return inList("<col>", toAST(t), values);
}
 
// greaterEq condition
ASTCondition toAST((Condition)`<Identifier col> (<RowType t>) \>= <Number n>`){
    return greaterEq("<col>", toAST(t), toAST(n));
}

// greater condition
ASTCondition toAST((Condition)`<Identifier col> (<RowType t>) \> <Number n>`){
    return greater("<col>", toAST(t), toAST(n));
}

// lessEq condition
ASTCondition toAST((Condition)`<Identifier col> (<RowType t>) \<= <Number n>`){
    return lessEq("<col>", toAST(t), toAST(n));
}

// less condition
ASTCondition toAST((Condition)`<Identifier col> (<RowType t>) \< <Number n>`){
    return less("<col>", toAST(t), toAST(n));
}

// equals condition
ASTCondition toAST((Condition)`<Identifier col> (<RowType t>) == <Value v>`) {
    return equals("<col>", toAST(t), toAST(v));
}

// keep condition
ASTCondition toAST((Condition)`<Identifier col> (<RowType t>) keep`) {
    return keep("<col>", toAST(t));
}

// dropna condition
ASTCondition toAST((Condition)`<Identifier col> (<RowType t>) dropna`) {
    return dropna("<col>", toAST(t));
}

ASTType toAST((RowType)`int`) = DSL_AST::intType();
ASTType toAST((RowType)`float`) = DSL_AST::floatType();
ASTType toAST((RowType)`string`) = DSL_AST::stringType();
ASTType toAST((RowType)`bool`) = DSL_AST::boolType();
ASTAggType toAST((AggType)`sum`) = DSL_AST::aggSum();
ASTAggType toAST((AggType)`avg`) = DSL_AST::aggAvg();
ASTAggType toAST((AggType)`min`) = DSL_AST::aggMin();
ASTAggType toAST((AggType)`max`) = DSL_AST::aggMax();

ASTValue toAST((Value)`<String s>`) {
    return stringVal(stripQuotes(s));
}

ASTValue toAST((Value)`<Boolean b>`) {
    return boolVal("<b>" == "true");
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