module Transformation

import DSL_Grammar;
import DSL_AST;
import String;
import ParseTree;

// top level progam
Program toAST(start[DSL] dsl) {
  switch (dsl) {
    case (start[DSL])`<Element* elements>`:
      return program([ toAST(el) | el <- elements ]);
    default: throw "Top level error";
  }
}

Command toAST(Element el) {
    switch (el) {
        case (Element)`Load <String s> as <Identifier id>`:
            return load("<stripQuotes(s)>", "<id>");
        case (Element)`Constrain <Identifier from_id> as <Identifier to_id> { <Condition* conds> }`:
            return constrain("<from_id>", "<to_id>", [toAST(cond) | cond <- conds]);
        case (Element)`Visualise <Identifier target>`:
            return visualise("<target>", "default");
        case (Element)`Visualise <Identifier target> using <Identifier template>`:
            return visualise("<target>", "<template>");
        default: throw "Unknown Command Type";
    }
}


// Constrain
// Command toAST((Element)`Constrain <Identifier src> as <Identifier trgt> { <Condition* conds> }`) {
//     return constrain("<src>", "<trgt>", [toAST(c) | c <- conds]);
// }

Condition toAST(Condition cond) {
    switch (cond) {
        // case (Condition)`<Identifier col> (<RowType t>) in <Array  arr>`:
        //     return inList("<col>", toAST(t), toArray(arr));
        // case (Condition)`<Identifier col> (<RowType t>) \>= <Number n>`:
        //     return greaterEq("<col>", intType(), intVal(5));
        case (Condition)`<Identifier col> (<RowType t>) \>= <Number n>`:
            return greaterEq("<col>", intType(), intVal(5));
        default: throw "Unknown Condition";
    }
}

// // inList condition
// Condition toAST((Condition)`<Identifier col> (<RowType t>) in <Array arr>`) {
//   return inList("<col>", toAST(t), toArray(arr));
// }
 
// // greaterEq condition
// Condition toAST((Condition)`<Identifier col> (<RowType t>) \>= <Number n>`){
//     return greaterEq("<col>", toAST(t), numberToValue(n));
// }

// // greater condition
// Condition toAST((Condition)`<Identifier col> (<RowType t>) \> <Number n>`){
//     return greater("<col>", toAST(t), numberToValue(n));
// }

// // lessEq condition
// Condition toAST((Condition)`<Identifier col> (<RowType t>) \<= <Number n>`){
//     return lessEq("<col>", toAST(t), numberToValue(n));
// }

// // less condition
// Condition toAST((Condition)`<Identifier col> (<RowType t>) \< <Number n>`){
//     return less("<col>", toAST(t), numberToValue(n));
// }

// // equals condition
// Condition toAST((Condition)`<Identifier col> (<RowType t>) == <Value v>`) {
//     return equals("<col>", toAST(t), toAST(v));
// }

Type toAST((RowType)`int`) = DSL_AST::intType();
Type toAST((RowType)`float`) = DSL_AST::floatType();
Type toAST((RowType)`string`) = DSL_AST::stringType();
Type toAST((RowType)`bool`) = DSL_AST::boolType();

// ASTValue toAST((Value)`<Number n>`) {
//   str raw = n;
//   if (contains(raw, ".")) {
//     return floatVal(toReal(raw));
//   }
//   return intVal(toInt(raw));
// }

// ASTValue toAST((Value)`<String s>`) {
//   return stringVal(stripQuotes(s));
// }

// ASTValue toAST((Value)`<Boolean b>`) {
//   return boolVal(b == "true");
// }

// ASTValue toAST((Value)`<Array arr>`) {
//   return arrayVal(toArray(arr));
// }

// Value toAST((Value)`<Number n>`) {
//   str raw = "<n>";
//   if (contains(raw,".")) return floatVal(toReal(raw));
//   return intVal(toInt(raw));
// }

// Value toAST((Value)`<String s>`) {
//   return stringVal(stripQuotes(s));
// }

// Value toAST((Value)`<Boolean b>`) {
//   return boolVal("<b>" == "true");
// }

// Value toAST((Array)`[<Value* vals>]`) {
//   return arrayVal([toAST(v) | v <- vals]);
// }

ASTValue numberToValue(Number n) {
  str raw = "<n>";
  return contains(raw, ".")
    ? floatVal(toReal(raw))
    : intVal(toInt(raw));
}

str stripQuotes(String s) {
  str raw = "<s>";
  return substring(raw, 1, size(raw) - 1);
}

// list[ASTValue] toArray((Array)`[<Value* vals>]`) {
//     return [toAST(v) | v <- vals];
// }