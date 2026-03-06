module DSL_AST

data ASTProgram
  = program(list[ASTCommand] commands);

data ASTCommand
  = load(str path, str name)
  | constrain(str source, str target, list[ASTCondition] conditions)
  | visualise(str name)
  | visualiseUsing(str name, str vizType)
  | rename(str source, str oldCol, str newCol)
  | sortAsc(str source, str col, ASTType t)
  | sortDesc(str source, str col, ASTType t)
  | groupByCount(str source, str groupCol)
  | groupByAgg(str source, str groupCol, ASTAggType aggType, str valueCol, ASTType valType)
  ;

data ASTCondition
  = inList(str column, ASTType t, list[ASTValue] values)
  | greaterEq(str column, ASTType t, ASTValue v)
  | greater(str column, ASTType t, ASTValue v)
  | lessEq(str column, ASTType t, ASTValue v)
  | less(str column, ASTType t, ASTValue v)
  | equals(str column, ASTType t, ASTValue v)
  | keep(str column, ASTType t)
  | dropna(str column, ASTType t)
  ;

data ASTType
  = intType()
  | floatType()
  | stringType()
  | boolType()
  ;

data ASTValue
  = intVal(int i)
  | floatVal(real r)
  | stringVal(str s)
  | boolVal(bool b)
  | arrayVal(list[ASTValue] arr)
  ;

data ASTAggType
  = aggSum()
  | aggAvg()
  | aggMin()
  | aggMax()
  ;