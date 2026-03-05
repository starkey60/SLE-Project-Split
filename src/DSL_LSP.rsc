module DSL_LSP

import util::LanguageServer;
import util::IDEServices;
import ParseTree;
import util::Reflective;
import IO;

import DSL_Grammar;
import DSL_Parsing;

set[LanguageService] dslServices() = {
    parsing(parser(#start[DSL]))
};

Language DSL = language(
    pathConfig(srcs=[|project://SLE-Project/src|]),
    "DSL",
    {"dsl"},
    "DSL_LSP",
    "dslServices"
);

void register() {
    registerLanguage(DSL);
    println("registered");
}

void deregister() {
    unregisterLanguage(DSL);
    println("deregistered");
}