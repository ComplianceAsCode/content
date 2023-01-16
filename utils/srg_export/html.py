#!/usr/bin/env python3

import pathlib
import pandas as pd
import create_srg_export

import utils.srg_export.data

HTML_OUTPUT_TEMPLATE = '''
<html>
<head>
<title>{title}</title>
<style type="text/css">
table
{{
    border-collapse:collapse;
}}
table, th, td
{{
    border: 2px solid #dcdcdc;
    border-left: none;
    border-right: none;
    vertical-align: top;
    padding: 2px;
    font-family: verdana,arial,sans-serif;
    font-size:11px;
}}
pre {{
    white-space: pre-wrap;
    white-space: -moz-pre-wrap !important;
    word-wrap:break-word;
}}
table tr:nth-child(2n+2) {{ background-color: #f4f4f4; }}
thead
{{
    display: table-header-group;
    font-weight: bold;
    background-color: #dedede;
}}
</style>
</head>
<body>
    {table}
</body>
</html>
'''


def handle_dict(data: list, output_path: str, title: str) -> None:
    """
    Given a dict with the fields for the srg export, create an HTML file
    """
    pd.set_option('colheader_justify', 'center')
    df = pd.DataFrame(data, index=None)
    df.fillna("", inplace=True)
    df = df.reindex(utils.srg_export.data.HEADERS, axis=1)
    with open(pathlib.Path(output_path), 'w+') as f:
        html_table = df.to_html().replace("\\n", "<br>")
        html_page = HTML_OUTPUT_TEMPLATE.format(title=title, table=html_table)
        f.write(html_page)
