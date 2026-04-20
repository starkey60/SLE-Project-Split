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
            return code += intercalate("\n", [generate(el) | Element el <- elements]);
        default: return code;
    }
}