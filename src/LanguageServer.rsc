module LanguageServer

import util::LanguageServer;
import util::IDEServices;
import util::Reflective;
import String;
import ParseTree;

import frontend::Grammar;
import frontend::StaticAnalysis;

set[LanguageService] dslServices() = {
    parsing(parser(#start[DELTA])),
    analysis(dslSummarizer, providesImplementations = false)
};

Language DELTA = language(
    pathConfig(srcs=[|project://SLE-Project-Split/src|]),
    "DELTA",
    {"delta"},
    "DSL_LSP",
    "dslServices"
);

void register() {
    registerLanguage(DELTA);
}

void deregister() {
    unregisterLanguage(DELTA);
}