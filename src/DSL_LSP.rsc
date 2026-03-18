module DSL_LSP

import util::LanguageServer;
import util::IDEServices;
import util::Reflective;
import String;
import ParseTree;
import util::Maybe;

import DSL_Grammar;

set[LanguageService] dslServices() = {
    parsing(parser(#start[DSL])),
    analysis(dslSummarizer,
        providesDocumentation = false,
        providesDefinitions = false,
        providesReferences = false,
        providesImplementations = false)
};

Language DSL = language(
    pathConfig(srcs=[|project://SLE-Project-Split/src|]),
    "DSL",
    {"dsl"},
    "DSL_LSP",
    "dslServices"
);

rel[loc, Message] checkRef(str name, loc src, map[str, loc] datasets) =
    name notin datasets ? {<src, error("Undefined dataset \'<name>\'", src)>} : {};

rel[loc, Message] checkDefine(str name, loc src, map[str, loc] datasets) =
    name in datasets ? {<src, warning("Dataset \'<name>\' is already defined", src)>} : {};

rel[loc, Message] checkPath(String path) {
    if (!endsWith("<path>", ".csv\""))
        return {<path.src, warning("Path <path> doesn\'t end with .csv, is it a proper dataset?", path.src)>};
    else return {};
}

bool isNumericCast(CastType cast) =
    (CastType)`int` := cast || (CastType)`float` := cast;

bool isCompatibleValue(CastType cast, Value val) {
    if (cast is intCast || cast is floatCast) return (Value)`<Number _>` := val;
    if (cast is boolCast) return (Value)`<Boolean _>` := val;
    if (cast is stringCast) return (Value)`<String _>` := val;
    return false;
}

Maybe[CastType] getArrayValueType(Array arr, CastType cast) {
    if ((Array)`[ <{Value ","}* vals> ]` := arr) {
        list[Value] values = [v | v <- vals];
        if (values == []) return just(cast); //for empty sets

        CastType getType(Value v) {
            switch (v) {
                case (Value)`<Number _>`: return (CastType)`float`;
                case (Value)`<Boolean _>`: return (CastType)`bool`;
                case (Value)`<String _>`: return (CastType)`string`;
            }
            throw "Unknown Value";
        }

        CastType found = getType(values[0]);
        for (v <- values[1..])
            if (getType(v) != found) return nothing();
        return just(found);
    }
    return nothing(); 
}

rel[loc, Message] checkFilterCondition(FilterCondition cond) {
    switch (cond) {
        case (FilterCondition)`<String col> (<CastType cast>) <EqualityOp op> <Value val>`: {
            if (!isNumericCast(cast) && !(op is eq) && !(op is ne))
                return {<op.src, error("Cast \'<cast>\' on \'<col>\' can only use == or !=", op.src)>};
            if (!isCompatibleValue(cast, val))
                return {<val.src, error("Value \'<val>\' is incompatible with cast \'<cast>\' on \'<col>\'", val.src)>};
        }
        case (FilterCondition)`<String _> (<CastType cast>) in <Array arr>`: {
            switch (getArrayValueType(arr, cast)) {
                case nothing():
                    return {<arr.src, error("Array contains items of different types", arr.src)>};
                case just(CastType t):
                    if (t != cast) return {<cast.src, error("Cast \'<cast>\' used on array of type \'<t>\'", cast.src)>};
            }
        }
        default: return {};
    }
    return {};
}

// CST matching, to keep loc (otherwise would have to add it to AST)
Summary dslSummarizer(loc l, start[DSL] input) {
    rel[loc, Message] msgs = {};
    map[str, loc] datasets = ();

    try{
        if ((DSL)`<Element* elems>` := input.top) {
            for (Element e <- elems) {
                switch (e) {
                    case (Element)`Load <String path> as <Identifier name>`: {
                        str n = "<name>";
                        msgs += checkDefine(n, name.src, datasets);
                        datasets[n] = name.src;

                        msgs += checkPath(path);
                    }
                    case (Element)`Save <Identifier name> as <String path>`: {
                        msgs += checkRef("<name>", name.src, datasets);
                        msgs += checkPath(path);
                    }
                    case (Element)`Filter <Identifier src> { <FilterCondition* conds> }`: {
                        msgs += checkRef("<src>", src.src, datasets);
                        for (c <- conds) msgs += checkFilterCondition(c);
                    }
                    default: msgs += {};
                }
            }
        }
    } catch e: {
        return summary(l, messages = {<l, error("Summarizer crashed: <e>", l)>});
    }

    return summary(l, messages = msgs);
}

void register() {
    registerLanguage(DSL);
}

void deregister() {
    unregisterLanguage(DSL);
}