from __future__ import absolute_import
from __future__ import print_function

import os.path
import jinja2

from .utils import required_key


class AbsolutePathFileSystemLoader(jinja2.BaseLoader):
    """Loads templates from the file system. This loader insists on absolute
    paths and fails if a relative path is provided.

    >>> loader = AbsolutePathFileSystemLoader()

    Per default the template encoding is ``'utf-8'`` which can be changed
    by setting the `encoding` parameter to something else.
    """

    def __init__(self, encoding='utf-8'):
        self.encoding = encoding

    def get_source(self, environment, template):
        if not os.path.isabs(template):
            raise jinja2.TemplateNotFound(template)

        template_file = jinja2.utils.open_if_exists(template)
        if template_file is None:
            raise jinja2.TemplateNotFound(template)
        try:
            contents = template_file.read().decode(self.encoding)
        finally:
            template_file.close()

        mtime = os.path.getmtime(template)

        def uptodate():
            try:
                return os.path.getmtime(template) == mtime
            except OSError:
                return False
        return contents, template, uptodate


def _get_jinja_environment(substitutions_dict):
    if _get_jinja_environment.env is None:
        bytecode_cache = None
        if substitutions_dict.get("jinja2_cache_enabled") == "true":
            bytecode_cache = jinja2.FileSystemBytecodeCache(
                required_key(substitutions_dict, "jinja2_cache_dir")
            )

        # TODO: Choose better syntax?
        _get_jinja_environment.env = jinja2.Environment(
            block_start_string="{{%",
            block_end_string="%}}",
            variable_start_string="{{{",
            variable_end_string="}}}",
            comment_start_string="{{#",
            comment_end_string="#}}",
            loader=AbsolutePathFileSystemLoader(),
            bytecode_cache=bytecode_cache
        )

    return _get_jinja_environment.env


_get_jinja_environment.env = None


def extract_substitutions_dict_from_template(filename, substitutions_dict):
    """
    Treat the given filename as a jinja2 file containing macro definitions,
    and export definitions that don't start with _ as a name->macro dictionary.
    During macro compilation, symbols from substitutions_dict may be used in those definitions.
    """
    template = _get_jinja_environment(substitutions_dict).get_template(filename)
    all_symbols = template.make_module(substitutions_dict).__dict__
    symbols_to_export = dict()
    for name, symbol in all_symbols.items():
        if name.startswith("_"):
            continue
        symbols_to_export[name] = symbol
    return symbols_to_export


def process_file(filepath, substitutions_dict):
    filepath = os.path.abspath(filepath)
    template = _get_jinja_environment(substitutions_dict).get_template(filepath)
    return template.render(substitutions_dict)
