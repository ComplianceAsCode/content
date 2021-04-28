from __future__ import absolute_import
from __future__ import print_function


from .products import load_product_yaml
from .yaml import open_raw


def open_environment(build_config_yaml_path, product_yaml_path):
    contents = open_raw(build_config_yaml_path)
    contents.update(load_product_yaml(product_yaml_path))
    return contents
