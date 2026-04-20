module backend::codegen::GroupBy

import frontend::Grammar;
import backend::codegen::Extra;

str genGroupByAgg(str source, str groupCol, AggType agg, str valueCol, CastType cast) {
    switch (agg) {
        case aggSum(): return genGroupByAggGeneralised(source, groupCol, valueCol,
            "_groups[_key] = _groups.get(_key, 0) + _val",
            valStep = genCast(valueCol, cast));
        case aggAvg(): return genGroupByAggGeneralised(source, groupCol, valueCol,
            "_groups[_key] = _groups.get(_key, 0) + _val\n    _counts[_key] = _counts.get(_key, 0) + 1",
            valStep = genCast(valueCol, cast), extraInit = "_counts = {}", resultExpr = "_groups[_key] / _counts[_key]");
        case aggMin(): return genGroupByAggGeneralised(source, groupCol, valueCol,
            "if _key not in _groups or _val \< _groups[_key]:\n        _groups[_key] = _val",
            valStep = genCast(valueCol, cast));
        case aggMax(): return genGroupByAggGeneralised(source, groupCol, valueCol,
            "if _key not in _groups or _val \> _groups[_key]:\n        _groups[_key] = _val",
            valStep = genCast(valueCol, cast));
        default: throw "unknown agg <agg>";
    }
}

str genGroupByAggGeneralised(str source, str groupCol, str valueCol, str aggStep,
                              str valStep = "", str extraInit = "", str resultExpr = "_groups[_key]") {
    return "
_groups = {}
<extraInit>
for _row in <source>:
    _key = _row[<groupCol>]
    <if (valStep != "") {>_val = <valStep>
    <}><aggStep>
<source> = [{<groupCol>: _key, <valueCol>: <resultExpr>} for _key in sorted(_groups.keys())]
print(\"GroupBy <groupCol[1..-1]> ( <valueCol>):\")
for _key in sorted(_groups.keys()):
    print(f\'  {_key}: {<resultExpr>}\')
";
}