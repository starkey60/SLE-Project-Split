module DSL_AST

data ASTProgram
  = program(list[ASTCommand] commands);

data ASTCommand
  = io(str path, str name, ASTIO io)
  | filterDataset(str source, str target, list[ASTFilter] filters)
  | transformDataset(str source, list[ASTTransformation] transformations)
  | visualise(str name)
  | visualiseUsing(str name, ASTVis vis)
  | groupByCount(str source, str groupCol)
  | groupByAgg(str source, str groupCol, ASTAggType aggType, str valueCol, ASTCast cast)
  ;

data ASTFilter
  = inList(str column, list[ASTValue] values, ASTCast cast)
  | equality(str column, ASTValue val, ASTEquality eq, ASTCast cast)
  ;

data ASTTransformation
  = rename(str column, str newName)
  | sort(str source, str col, ASTSort sort, ASTCast cast)
  | dropna(str column)
  | keep(str column)
  ;

data ASTCast
  = boolCast()
  | stringCast()
  | intCast()
  | floatCast()
  ;

data ASTIO 
  = load()
  | save()
  ;

data ASTVis
  = defaultVis()
  | table()
  | tableImage()
  ;

data ASTSort
  = ascending()
  | descending()
  ;

data ASTEquality
  = greaterEq()
  | greater()
  | lessEq()
  | less()
  | equals()
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