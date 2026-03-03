module Transformation

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

// Main commands (Load, Constrain, Visualise)
ASTCommand toAST(Element el) {
    switch (el) {
        case (Element)`Load <String s> as <Identifier id>`:
            return load("<stripQuotes(s)>", "<id>");
        case (Element)`Constrain <Identifier from_id> as <Identifier to_id> { <Condition* conds> }`:
            return constrain("<from_id>", "<to_id>", [toAST(c) | c <- conds]);
        case (Element)`Visualise <Identifier target>`:
            return visualise("<target>", "default");
        case (Element)`Visualise <Identifier target> using <Identifier template>`:
            return visualise("<target>", "<template>");
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

ASTType toAST((RowType)`int`) = DSL_AST::intType();
ASTType toAST((RowType)`float`) = DSL_AST::floatType();
ASTType toAST((RowType)`string`) = DSL_AST::stringType();
ASTType toAST((RowType)`bool`) = DSL_AST::boolType();

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