#!/usr/bin/python3

import os
import ssg.jinja
from utils.template_renderer import FlexibleLoader


def create_table(data, template_name, output_filename):
    html_jinja_template = os.path.join(
        os.path.dirname(__file__), "tables", template_name)
    env = ssg.jinja._get_jinja_environment(dict())
    env.loader = FlexibleLoader(os.path.dirname(html_jinja_template))
    result = ssg.jinja.process_file(html_jinja_template, data)
    with open(output_filename, "wb") as f:
        f.write(result.encode('utf8', 'replace'))
