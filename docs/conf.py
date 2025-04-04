# Configuration file for the Sphinx documentation builder.
#
# This file only contains a selection of the most common options. For a full
# list see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Path setup --------------------------------------------------------------

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.
#
import os
import sys
sys.path.insert(0, os.path.abspath('..'))
sys.path.insert(0, os.path.abspath('../tests'))

# since these files live outside of root doc directory, we need to create a symlink to a dir under where conf.py lives
# so myst-parser can properly render them
filepaths = ["tests/README.md"]
for filepath in filepaths:
    try:
        path, _ = filepath.split("/")
        os.mkdir(os.path.join(path))
        os.symlink(os.path.join(os.path.abspath('..'), filepath), os.path.join(filepath))
    except FileExistsError as e:
        # ignore if file exists
        print("Warning: {}".format(e))

# -- Project information -----------------------------------------------------

project = 'ComplianceAsCode/content'
copyright = 'ComplianceAsCode'
author = 'ComplianceAsCode'


# -- General configuration ---------------------------------------------------

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
extensions = ['myst_parser',
    'sphinxcontrib.apidoc',
    'sphinx_rtd_theme',
    'sphinx.ext.autodoc',
    'sphinx.ext.autosummary',
    'sphinx.ext.doctest',
    'sphinx.ext.todo',
    'sphinx.ext.coverage',
    'sphinx.ext.viewcode',
    'sphinx.ext.napoleon',
    'sphinxcontrib.jinjadomain',
    'sphinxcontrib.autojinja.jinja',
]

apidoc_module_dir = '../ssg'
apidoc_output_dir = 'api'
apidoc_excluded_paths = ['tests', 'build-scripts']
apidoc_separate_modules = True

# Add any paths that contain templates here, relative to this directory.
# templates_path = ['_templates']

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This pattern also affects html_static_path and html_extra_path.
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']


# -- Options for HTML output -------------------------------------------------

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
#
html_theme = 'sphinx_rtd_theme'

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
# html_static_path = ['_static']

# Required for autojinja to work
jinja_template_path = os.path.abspath('..')

source_suffix = ['.rst', '.md']

# Allow linking to (most) headers
myst_heading_anchors = 3
