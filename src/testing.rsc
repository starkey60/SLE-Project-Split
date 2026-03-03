module testing

import DSL_Grammar;
import Parsing;
import Transformation;
import DSL_AST;
import IO;
import ParseTree;


void testDSL(loc file) {
    start[DSL] dsl = parseFromFile(file);
    
    println("Concrete syntax tree:");
    println(dsl);

    ASTProgram cmd = toAST(dsl);
    println(cmd);

}