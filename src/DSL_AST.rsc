module DSL_AST

data Program
  = program(list[Command] commands);

data Command
  = load(str path, str name)
  | constrain(str source, str target, list[Condition] conditions)
  | visualise(str name, str vizType) // will have to have a default vizType if user does not provide, since optional str is not a thing
  ;

data Condition
  = inList(str column, Type t, list[ASTValue] values)
  | greaterEq(str column, Type t, ASTValue v)
  | greater(str column, Type t, ASTValue v)
  | lessEq(str column, Type t, ASTValue v)
  | less(str column, Type t, ASTValue v)
  | equals(str column, Type t, ASTValue v)
  ;

data Type
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