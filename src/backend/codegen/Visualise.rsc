module backend::codegen::Visualise

import frontend::Grammar;

str genVisualise(str target, VisType vis) {
    switch (vis) {
        case visTable(): return genVisualiseTable(target);
        case visTableImage(): return genVisualiseTableImage(target);
        case pieChart(): return genVisualisePieChart(target);
        case barChart(): return genVisualiseBarChart(target);
        default: throw "Unknown vis type during codegen <vis>";
    }
}

str genVisualiseTableImage(str target) {
    return "
if <target>:
    _headers = list(<target>[0].keys())
    _rows = [list(row.values()) for row in <target>]
    _num_cols = len(_headers)
    _num_rows = len(_rows)
    _fig_width = max(8, _num_cols * 2.0)
    _fig_height = max(2, (_num_rows + 1) * 0.5)
    _fig, _ax = plt.subplots(figsize=(_fig_width, _fig_height))
    _ax.axis(\'off\')
    _ax.axis(\'tight\')
    _tbl = _ax.table(
        cellText=_rows,
        colLabels=_headers,
        cellLoc=\'center\',
        loc=\'center\'
    )
    _tbl.auto_set_font_size(False)
    _tbl.set_fontsize(10)
    _tbl.auto_set_column_width(col=list(range(_num_cols)))
    for (row_idx, col_idx), cell in _tbl.get_celld().items():
        if row_idx == 0:
            cell.set_facecolor(\'#4472C4\')
            cell.set_text_props(color=\'white\', fontweight=\'bold\')
        elif row_idx % 2 == 0:
            cell.set_facecolor(\'#D9E2F3\')
        else:
            cell.set_facecolor(\'#FFFFFF\')
        cell.set_edgecolor(\'#BFBFBF\')
    plt.title(\'<target>\', fontsize=14, fontweight=\'bold\', pad=20)
    plt.tight_layout()
    plt.savefig(\'<target>_table.png\', dpi=150, bbox_inches=\'tight\')
    plt.close()
";
}

str genVisualiseTable(str target) {
    return "
if <target>:
    _headers = list(<target>[0].keys())
    _rows = [list(row.values()) for row in <target>]
    print(tabulate(_rows, headers=_headers, tablefmt=\'grid\'))
";
}

str genVisualisePieChart(str target) {
    return "
if <target>:
    _keys = list(<target>[0].keys())
    _labelCol = _keys[0]
    _valueCol = _keys[1]
    _labels = [row[_labelCol] for row in <target>]
    _values = [float(row[_valueCol]) for row in <target>]
    _fig, _ax = plt.subplots()
    _ax.pie(
        _values,
        labels=_labels,
        autopct=\'%1.1f%%\',
        startangle=140
    )
    _ax.axis(\'equal\')
    plt.title(\'<target>\', fontsize=14, fontweight=\'bold\')
    plt.tight_layout()
    plt.savefig(\'<target>_pie.png\', dpi=150, bbox_inches=\'tight\')
    plt.close()
";
}

str genVisualiseBarChart(str target) {
    return "
if <target>:
    _keys = list(<target>[0].keys())
    _labelCol = _keys[0]
    _valueCol = _keys[1]
    _labels = [row[_labelCol] for row in <target>]
    _values = [float(row[_valueCol]) for row in <target>]
    _fig, _ax = plt.subplots(figsize=(max(8, len(_labels) * 1.5), 6))
    _bars = _ax.bar(_labels, _values, color=\'#4472C4\', edgecolor=\'#2F5597\')
    for _bar, _val in zip(_bars, _values):
        _ax.text(_bar.get_x() + _bar.get_width() / 2, _bar.get_height() + 0.3,
                 str(_val), ha=\'center\', va=\'bottom\', fontweight=\'bold\')
    _ax.set_xlabel(_labelCol, fontsize=12)
    _ax.set_ylabel(_valueCol, fontsize=12)
    _ax.set_title(\'<target>\', fontsize=14, fontweight=\'bold\')
    _ax.spines[\'top\'].set_visible(False)
    _ax.spines[\'right\'].set_visible(False)
    plt.tight_layout()
    plt.savefig(\'<target>_bar.png\', dpi=150, bbox_inches=\'tight\')
    plt.close()
";
}