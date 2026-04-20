module backend::codegen::GroupBy

import frontend::Grammar;
import backend::codegen::Extra;

str generate((Element)`GroupBy <Identifier id> by <String col> count`) =
    genGroupByAggGeneralised("<id>", "<col>", "\'count\'",
        "_groups[_key] = _groups.get(_key, 0) + 1");

str generate((Element)`GroupBy <Identifier id> by <String col> <AggType agg> <String valCol> (<CastType t>)`) =
    genGroupByAgg("<id>", "<col>", agg, "<valCol>", t);

str genGroupByAgg(str source, str groupCol, (AggType)`sum`, str valueCol, CastType cast) =
    genGroupByAggGeneralised(source, groupCol, valueCol,
        "_groups[_key] = _groups.get(_key, 0) + _val",
        valStep = genCast(valueCol, cast));

str genGroupByAgg(str source, str groupCol, (AggType)`avg`, str valueCol, CastType cast) =
    genGroupByAggGeneralised(source, groupCol, valueCol,
        "_groups[_key] = _groups.get(_key, 0) + _val\n    _counts[_key] = _counts.get(_key, 0) + 1",
        valStep = genCast(valueCol, cast), extraInit = "_counts = {}", resultExpr = "_groups[_key] / _counts[_key]");

str genGroupByAgg(str source, str groupCol, (AggType)`min`, str valueCol, CastType cast) =
    genGroupByAggGeneralised(source, groupCol, valueCol,
        "if _key not in _groups or _val \< _groups[_key]:\n        _groups[_key] = _val",
        valStep = genCast(valueCol, cast));

str genGroupByAgg(str source, str groupCol, (AggType)`max`, str valueCol, CastType cast) =
    genGroupByAggGeneralised(source, groupCol, valueCol,
        "if _key not in _groups or _val \> _groups[_key]:\n        _groups[_key] = _val",
        valStep = genCast(valueCol, cast));


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