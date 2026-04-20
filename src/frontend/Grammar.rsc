module frontend::Grammar

start syntax DELTA
  = element: Element*;

// top-level commands
syntax Element
  = load: "Load" String "as" Identifier
  | save: "Save" Identifier "as" String
  | filterDataset: "Filter" Identifier "{" FilterCondition* "}"
  | transformDataset: "Transform" Identifier "{" Transformation* "}"
  | visualise: "Visualise" Identifier
  | visualiseUsing: "Visualise" Identifier "using" VisType
  | groupByCount: "GroupBy" Identifier "by" String "count"
  | groupByAgg: "GroupBy" Identifier "by" String AggType String "(" CastType ")"
  ;

// filter conditions (inside Filter block)
syntax FilterCondition
  = inList: String "(" CastType ")" "in" Array
  | equality: String "(" CastType ")" EqualityOp Value
  ;

// transformations (inside Transform block)
syntax Transformation
  = rename: "rename" String "to" String
  | sortBy: "sort" String "(" CastType ")" SortOrder
  | dropna: "dropna" String
  | keep: "keep" String
  ;

// operator and type definition
syntax EqualityOp
  = geq: "\>="
  | gt: "\>"
  | leq:"\<="
  | lt: "\<"
  | eq: "=="
  | ne: "!="
  ;

syntax SortOrder
  = ascending: "ascending"
  | descending: "descending"
  ;

syntax VisType
  = visTable: "table"
  | visTableImage: "table_image"
  | pieChart: "pie_chart"
  | barChart: "bar_chart"
  ;

syntax CastType
  = intCast: "int"
  | floatCast: "float"
  | stringCast: "string"
  | boolCast: "bool"
  ;

syntax AggType
  = aggSum: "sum"
  | aggAvg: "avg"
  | aggMin: "min"
  | aggMax: "max"
  ;

// values
syntax Value
  = array: Array
  | string: String
  | number: Number
  | boolean: Boolean
  ;

syntax Array
  = "[" {Value ","}* "]";

// lexicals
lexical Identifier
  = [a-zA-Z_][a-zA-Z0-9_]*;

lexical String
  = [\"] ![\"]* [\"];

lexical Boolean
  = "true"
  | "false"
  ; 

lexical Number
  = "-"? [0-9]+ ("." [0-9]+)?
  ;

// layout rules (whitespace and comments)
layout Layout = WhitespaceAndComment* !>> [\ \t\n\r%];

lexical WhitespaceAndComment
  = [\ \t\n\r]
  | @category="Comment" block: "/*" ![]+ "*/"
  | @category="Comment" line: "//" ![\n]* $
  ;