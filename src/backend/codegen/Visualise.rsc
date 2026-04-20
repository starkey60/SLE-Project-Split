module backend::codegen::Visualise

import frontend::Grammar;

// TODO: cleaner default handling
str generate((Element)`Visualise <Identifier id>`) {
    return "
if <id>:
    _headers = list(<id>[0].keys())
    _rows = [list(row.values()) for row in <id>]
    print(tabulate(_rows, headers=_headers, tablefmt=\'grid\'))
";
}

str generate((Element)`Visualise <Identifier id> using table_image`) {
    return "
if <id>:
    _headers = list(<id>[0].keys())
    _rows = [list(row.values()) for row in <id>]
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
    plt.title(\'<id>\', fontsize=14, fontweight=\'bold\', pad=20)
    plt.tight_layout()
    plt.savefig(\'<id>_table.png\', dpi=150, bbox_inches=\'tight\')
    plt.close()
";
}

str generate((Element)`Visualise <Identifier id> using table`) {
    return "
if <id>:
    _headers = list(<id>[0].keys())
    _rows = [list(row.values()) for row in <id>]
    print(tabulate(_rows, headers=_headers, tablefmt=\'grid\'))
";
}

str generate((Element)`Visualise <Identifier id> using pie_chart`) {
    return "
if <id>:
    _keys = list(<id>[0].keys())
    _labelCol = _keys[0]
    _valueCol = _keys[1]
    _labels = [row[_labelCol] for row in <id>]
    _values = [float(row[_valueCol]) for row in <id>]
    _fig, _ax = plt.subplots()
    _ax.pie(
        _values,
        labels=_labels,
        autopct=\'%1.1f%%\',
        startangle=140
    )
    _ax.axis(\'equal\')
    plt.title(\'<id>\', fontsize=14, fontweight=\'bold\')
    plt.tight_layout()
    plt.savefig(\'<id>_pie.png\', dpi=150, bbox_inches=\'tight\')
    plt.close()
";
}

str generate((Element)`Visualise <Identifier id> using bar_chart`) {
    return "
if <id>:
    _keys = list(<id>[0].keys())
    _labelCol = _keys[0]
    _valueCol = _keys[1]
    _labels = [row[_labelCol] for row in <id>]
    _values = [float(row[_valueCol]) for row in <id>]
    _fig, _ax = plt.subplots(figsize=(max(8, len(_labels) * 1.5), 6))
    _bars = _ax.bar(_labels, _values, color=\'#4472C4\', edgecolor=\'#2F5597\')
    for _bar, _val in zip(_bars, _values):
        _ax.text(_bar.get_x() + _bar.get_width() / 2, _bar.get_height() + 0.3,
                 str(_val), ha=\'center\', va=\'bottom\', fontweight=\'bold\')
    _ax.set_xlabel(_labelCol, fontsize=12)
    _ax.set_ylabel(_valueCol, fontsize=12)
    _ax.set_title(\'<id>\', fontsize=14, fontweight=\'bold\')
    _ax.spines[\'top\'].set_visible(False)
    _ax.spines[\'right\'].set_visible(False)
    plt.tight_layout()
    plt.savefig(\'<id>_bar.png\', dpi=150, bbox_inches=\'tight\')
    plt.close()
";
}