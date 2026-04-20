module backend::CodeGen

import frontend::Grammar;
import String;
import List;

extend backend::codegen::Extra;
extend backend::codegen::GroupBy;
extend backend::codegen::Transformation;
extend backend::codegen::Visualise;
extend backend::codegen::IO;
extend backend::codegen::Filter;

str generate(start[DELTA] dlt) {
    str code = "import csv\n\n";
    code += "from tabulate import tabulate\n";
    code += "import matplotlib\n";
    code += "matplotlib.use(\'Agg\')\n";
    code += "import matplotlib.pyplot as plt\n\n";
    
    switch (dlt) {
        case (start[DELTA])`<Element* elements>`:
            return code += intercalate("\n", [genElement(el) | Element el <- elements]);
        default: return code;
    }
}

str genElement(Element el) {
    switch (el) {
        case (Element)`Load <String path> as <Identifier id>`:
            return genLoad("<path>", "<id>");
        case (Element)`Save <Identifier id> as <String path>`:
            return genSave("<path>", "<id>");
        case (Element)`Filter <Identifier id> { <FilterCondition* conds> }`:
            return genFilter("<id>", [genFilterCondition(f) | f <- conds]);
        case (Element)`Transform <Identifier id> { <Transformation* transformations> }`:
            return genTransform("<id>", [t | t <- transformations]);
        case (Element)`Visualise <Identifier target>`:
            return genVisualiseTable("<target>");
        case (Element)`Visualise <Identifier target> using <VisType template>`:
            return genVisualise("<target>", template);
        case (Element)`GroupBy <Identifier src> by <String col> count`:
            return genGroupByAggGeneralised("<src>", "<col>", "\'count\'",
                "_groups[_key] = _groups.get(_key, 0) + 1");
        case (Element)`GroupBy <Identifier src> by <String col> <AggType agg> <String valCol> (<CastType t>)`:
            return genGroupByAgg("<src>", "<col>", agg, "<valCol>", t);
        default: throw "Unknown command when generating code";
    }
}