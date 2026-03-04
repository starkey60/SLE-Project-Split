module testing

import DSL_Grammar;
import DSL_Parsing;
import DSL_Transformation;
import DSL_AST;
import IO;
import ParseTree;

import DSL_CodeGen;


void testDSL(loc file, loc target) {
    start[DSL] dsl = parseFromFile(file);
    
    println("Concrete syntax tree:");
    println("____________________________________");
    println(dsl);
    println("____________________________________");

    ASTProgram cmd = toAST(dsl);
    println("Abstract syntax tree:");
    println("____________________________________");
    println(cmd);
    println("____________________________________");

    str pyCode = generate(cmd);
    println("Python code:");
    println("____________________________________");
    println(pyCode);
    println("____________________________________");

    writeFile(target, pyCode);
}