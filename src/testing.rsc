module testing

import DSL_Grammar;
import Parsing;
import Transformation;
import DSL_AST;
import IO;
import ParseTree;


void testDSL() {
    loc myFile = |file:///home/starkey/SLE-Project/test.dsl|;

    start[DSL] dsl = parseFromFile(myFile);
    
    println("Concrete syntax tree:");
    println(dsl);

    Program cmd = toAST(dsl);
    println(cmd);

}