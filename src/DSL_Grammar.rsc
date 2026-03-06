module DSL_Grammar

start syntax DSL
  = element: Element*;

syntax Element
  = load: "Load" String "as" Identifier
  | constrain: "Constrain" Identifier "as" Identifier "{" Condition* "}"
  | visualise: "Visualise" Identifier
  | visualiseUsing: "Visualise" Identifier "using" Identifier
  ;

lexical Identifier
  = [a-zA-Z_][a-zA-Z0-9_]*;

syntax Condition
  = inList: Identifier "(" RowType ")" "in" Array
  | greaterEq: Identifier "(" RowType ")"  "\>=" Number
  | greater: Identifier "(" RowType ")"  "\>" Number
  | lessEq: Identifier "(" RowType ")"  "\<=" Number
  | less: Identifier "(" RowType ")"  "\<" Number
  | equals: Identifier "(" RowType ")"  "==" Value
  | keep: Identifier "(" RowType ")" "keep" //NEEDS FEEDBACK: does such grammar make sense for when we want to keep a col without any constrains
  ;
  
syntax Value
  = array: Array
  | string: String
  | number: Number
  | boolean: Boolean
  ;

syntax RowType
  = intType: "int"
  | floatType: "float"
  | stringType: "string"
  | boolType: "bool"
  ;

syntax Array
  = "[" {Value ","}* "]";

lexical String
  = [\"] ![\"]* [\"];

lexical Boolean
  = "true"
  | "false"
  ; 

lexical Number
  = "-"? [0-9]+ ("." [0-9]+)?
  ;

layout Layout = WhitespaceAndComment* !>> [\ \t\n\r%];

lexical WhitespaceAndComment
  = [\ \t\n\r]
  | @category="Comment" block: "/*" ![]+ "*/"
  | @category="Comment" line: "//" ![\n]* $
  ;