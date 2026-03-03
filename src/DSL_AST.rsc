module DSL_AST

data ASTProgram
  = program(list[ASTCommand] commands);

data ASTCommand
  = load(str path, str name)
  | constrain(str source, str target, list[ASTCondition] conditions)
  | visualise(str name, str vizType) // will have to have a default vizType if user does not provide, since optional str is not a thing
  ;

data ASTCondition
  = inList(str column, ASTType t, list[ASTValue] values)
  | greaterEq(str column, ASTType t, ASTValue v)
  | greater(str column, ASTType t, ASTValue v)
  | lessEq(str column, ASTType t, ASTValue v)
  | less(str column, ASTType t, ASTValue v)
  | equals(str column, ASTType t, ASTValue v)
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