from __future__ import absolute_import

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

        f = jinja2.utils.open_if_exists(template)
        if f is None:
            raise jinja2.TemplateNotFound(template)
        try:
            contents = f.read().decode(self.encoding)
        finally:
            f.close()

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
        if required_key(substitutions_dict, "jinja2_cache_enabled") == "true":
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


def _extract_substitutions_dict_from_template(filename, substitutions_dict):
    template = _get_jinja_environment(substitutions_dict).get_template(filename)
    all_symbols = template.make_module().__dict__
    symbols_to_export = dict()
    for name, symbol in all_symbols.items():
        if name.startswith("_"):
            continue
        symbols_to_export[name] = symbol
    return symbols_to_export


def _rename_items(original_dict, renames):
    renamed_macros = dict()
    for rename_from, rename_to in renames.items():
        if rename_from in original_dict:
            renamed_macros[rename_to] = original_dict[rename_from]
    return renamed_macros


def process_file(filepath, substitutions_dict):
    template = _get_jinja_environment(substitutions_dict).get_template(filepath)
    return template.render(substitutions_dict)
