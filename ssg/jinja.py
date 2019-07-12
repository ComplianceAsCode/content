from __future__ import absolute_import
from __future__ import print_function

import os.path
import jinja2

from .constants import (JINJA_MACROS_BASE_DEFINITIONS,
                        JINJA_MACROS_HIGHLEVEL_DEFINITIONS,
                        JINJA_MACROS_ANSIBLE_DEFINITIONS,
                        JINJA_MACROS_OVAL_DEFINITIONS)
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


def update_substitutions_dict(filename, substitutions_dict):
    """
    Treat the given filename as a jinja2 file containing macro definitions,
    and export definitions that don't start with _ into the substitutions_dict,
    a name->macro dictionary. During macro compilation, symbols already
    existing in substitutions_dict may be used by those definitions.
    """
    template = _get_jinja_environment(substitutions_dict).get_template(filename)
    all_symbols = template.make_module(substitutions_dict).__dict__
    for name, symbol in all_symbols.items():
        if name.startswith("_"):
            continue
        substitutions_dict[name] = symbol


def process_file(filepath, substitutions_dict):
    """
    Process the jinja file at the given path with the specified
    substitutions. Return the result as a string. Note that this will not
    load the project macros; use process_file_with_macros(...) for that.
    """
    filepath = os.path.abspath(filepath)
    template = _get_jinja_environment(substitutions_dict).get_template(filepath)
    return template.render(substitutions_dict)


def load_macros(substitutions_dict):
    """
    Augment the substitutions_dict dict with project Jinja macros in /shared/.
    """
    if substitutions_dict is None:
        substitutions_dict = dict()

    try:
        update_substitutions_dict(JINJA_MACROS_BASE_DEFINITIONS, substitutions_dict)
        update_substitutions_dict(JINJA_MACROS_HIGHLEVEL_DEFINITIONS, substitutions_dict)
        update_substitutions_dict(JINJA_MACROS_ANSIBLE_DEFINITIONS, substitutions_dict)
        update_substitutions_dict(JINJA_MACROS_OVAL_DEFINITIONS, substitutions_dict)
    except Exception as exc:
        msg = ("Error extracting macro definitions: {0}"
               .format(str(exc)))
        raise RuntimeError(msg)

    return substitutions_dict


def process_file_with_macros(filepath, substitutions_dict):
    """
    Process the file with jinja macros at the given path with the specified
    substitutions. Return the result as a string.

    See also: process_file
    """
    substitutions_dict = load_macros(substitutions_dict)
    assert 'indent' not in substitutions_dict
    return process_file(filepath, substitutions_dict)
