module DSL_LSP

import util::LanguageServer;
import util::IDEServices;
import util::Reflective;
import String;
import ParseTree;

import DSL_Grammar;
import DSL_Analysis;

set[LanguageService] dslServices() = {
    parsing(parser(#start[DSL])),
    analysis(dslSummarizer,
        providesDocumentation = false,
        providesDefinitions = false,
        providesImplementations = false)
};

Language DSL = language(
    pathConfig(srcs=[|project://SLE-Project-Split/src|]),
    "DSL",
    {"dsl"},
    "DSL_LSP",
    "dslServices"
);

void register() {
    registerLanguage(DSL);
}

void deregister() {
    unregisterLanguage(DSL);
}