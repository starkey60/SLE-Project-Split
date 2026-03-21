module DSL_Analysis

import util::LanguageServer;
import util::IDEServices;
import util::Maybe;
import ParseTree;
import String;
import IO;

import DSL_Grammar;

rel[loc, Message] checkRef(str name, loc src, map[str, loc] datasets) =
    name notin datasets ? {<src, error("E01: Undefined dataset \'<name>\'", src)>} : {};

rel[loc, Message] checkDefine(str name, loc src, map[str, loc] datasets) =
    name in datasets ? {<src, warning("W01: Dataset \'<name>\' is already defined", src)>} : {};

rel[loc, Message] checkPath(String path) {
    if (!endsWith("<path>", ".csv\""))
        return {<path.src, warning("W02: Path <path> doesn\'t end with .csv", path.src)>};
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
                return {<op.src, error("E02: Cast <cast> on <col> can only use == or != equality", op.src)>};
            if (!isCompatibleValue(cast, val))
                return {<val.src, error("E03: Value \'<val>\' is incompatible with cast \'<cast>\' on <col>", val.src)>};
        }
        case (FilterCondition)`<String _> (<CastType cast>) in <Array arr>`: {
            switch (getArrayValueType(arr, cast)) {
                case nothing():
                    return {<arr.src, error("E04: Array contains items of different types", arr.src)>};
                case just(CastType t): //interpolate as string, since comparing nodes results in non equality
                    if ("<t>" != "<cast>") return {<cast.src, error("E05: Cast \'<cast>\' used on array of type \'<t>\'", cast.src)>};
            }
        }
    }
    return {};
}

rel[loc, Message] checkTransformation(Transformation t) {
    switch (t) {
        case (Transformation)`rename <String origName> to <String newName>`:
            if("<origName>" == "<newName>")
                return {<newName.src, warning("W03: Renaming to the same name as original", newName.src)>};
        case (Transformation)`sort <String col> (<CastType cast>) <SortOrder _>`:
            if(!isNumericCast(cast))
                return {<cast.src, error("E07: Sort requires numeric cast (int or float), got \'<cast>\' on <col>", cast.src)>};    
    }
    return{};
}

str getTransformationColumn(Transformation t) {
    switch (t) {
        case (Transformation)`keep <String c>`: return "<c>";
        case (Transformation)`dropna <String c>`: return "<c>";
        case (Transformation)`rename <String c> to <String _>`: return "<c>";
        case (Transformation)`sort <String c> (<CastType _>) <SortOrder _>`: return "<c>";
        default: return "";
    }
}

rel[loc, Message] checkTransformationOrdering(list[Transformation] ts) {
    set[str] closed = {};
    str current = "";
    for (t <- ts) {
        str col = getTransformationColumn(t);
        if(col != current) {
            if (col in closed) return {<t.src, warning("W04: It is advised to group transformations on same columns together", t.src)>};
            closed += {current};
            current = col;
        }
    }
    return {};
}

rel[loc, Message] checkDuplicateKeeps(list[Transformation] ts) {
    rel[loc, Message] msgs = {};
    set[str] seen = {};
    for (t <- ts) {
        if ((Transformation)`keep <String col>` := t) {
            if ("<col>" in seen) {
                msgs += {<col.src, warning("W05: Duplicate keep for column <col>", col.src)>};
            }
            seen += {"<col>"};
        }
    }
    return msgs;
}

// CST matching, to keep loc (otherwise would have to add it to AST)
Summary dslSummarizer(loc l, start[DSL] input) {
    rel[loc, Message] msgs = {};
    map[str, loc] datasets = ();
    rel[loc, loc] refs = {};

    if ((DSL)`<Element* elems>` := input.top) {
        for (Element e <- elems) {
            switch (e) {
                case (Element)`Load <String path> as <Identifier name>`: {
                    str n = "<name>";
                    msgs += checkDefine(n, name.src, datasets);
                    if (n notin datasets) datasets[n] = name.src;
                    msgs += checkPath(path);
                }
                case (Element)`Save <Identifier name> as <String path>`: {
                    msgs += checkRef("<name>", name.src, datasets);
                    msgs += checkPath(path);
                    if ("<name>" in datasets) refs += <datasets["<name>"], name.src>;
                }
                case (Element)`Filter <Identifier name> { <FilterCondition* conds> }`: {
                    msgs += checkRef("<name>", name.src, datasets);
                    if ("<name>" in datasets) refs += <datasets["<name>"], name.src>;
                    for (c <- conds) msgs += checkFilterCondition(c);
                }
                case (Element)`Transform <Identifier name> { <Transformation* transformations> }`: {
                    msgs += checkRef("<name>", name.src, datasets);
                    if ("<name>" in datasets) refs += <datasets["<name>"], name.src>;
                    for (t <- transformations) msgs += checkTransformation(t);
                    msgs += checkTransformationOrdering([t | t <- transformations]);
                    msgs += checkDuplicateKeeps([t | t <- transformations]);
                }
                case (Element)`Visualise <Identifier name>`: {
                    msgs += checkRef("<name>", name.src, datasets);
                    if ("<name>" in datasets) refs += <datasets["<name>"], name.src>;
                }
                case (Element)`Visualise <Identifier name> using <VisType _>`: {
                    msgs += checkRef("<name>", name.src, datasets);
                    if ("<name>" in datasets) refs += <datasets["<name>"], name.src>;
                }
                case (Element)`GroupBy <Identifier name> by <String _> count`: {
                    msgs += checkRef("<name>", name.src, datasets);
                    if ("<name>" in datasets) refs += <datasets["<name>"], name.src>;
                }
                case (Element)`GroupBy <Identifier name> by <String _> <AggType _> <String _> (<CastType cast>)`: {
                    msgs += checkRef("<name>", name.src, datasets);
                    if ("<name>" in datasets) refs += <datasets["<name>"], name.src>;
                    if (!isNumericCast(cast)) msgs += {<cast.src, error("E06: Agg groupings can only use numeric casts", cast.src)>};
                }
                default: msgs += {};
            }
        }
    }

    return summary(l, messages = msgs, references = refs);
}