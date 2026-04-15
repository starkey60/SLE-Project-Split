module DSL_Main

import IO;
import List;
import ParseTree;
import util::LanguageServer;

import DSL_Grammar;
import DSL_Analysis;
import DSL_CodeGen;

void main(loc file) {
    println("Processing file: <file>");

    // Step 1: Parsing
    start[DELTA] tree = parse(#start[DELTA], file);

    // Step 2: Analysis
    Summary s = dslSummarizer(file, tree);
    list[Message] msgs = [m | <loc _, Message m> <- s.messages];
    int result = mainMessageHandler(msgs, projectRoot=file);
    if (result != 0) {
        println("Found errors, aborting...");
        return;
    }

    // Step 3: Code generation
    str output = generate(tree);
    str baseName = file.file[0..-6];
    loc outFile = file.parent + "<baseName>.py";
    writeFile(outFile, output);

    println("Output written to; <outFile>");
}
