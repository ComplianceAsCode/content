import os

import ssg.templates as tpl
from ssg.environment import open_environment
import ssg.utils
import ssg.products
from ssg.yaml import ordered_load
import ssg.build_yaml
import ssg.build_cpe


ssg_root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(__file__))))
DATADIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "data"))
templates_dir = os.path.join(DATADIR, "templates")
cpe_items_dir = os.path.join(DATADIR, "applicability")

build_config_yaml = os.path.join(ssg_root, "build", "build_config.yml")
product_yaml = os.path.join(ssg_root, "products", "rhel8", "product.yml")
env_yaml = open_environment(build_config_yaml, product_yaml)


def test_render_extra_ovals():
    builder = ssg.templates.Builder(
        env_yaml, '', templates_dir,
        '', '', '', cpe_items_dir)

    declaration_path = os.path.join(builder.templates_dir, "extra_ovals.yml")
    declaration = ssg.yaml.open_raw(declaration_path)
    for oval_def_id, template in declaration.items():
        rule = ssg.build_yaml.Rule.get_instance_from_full_dict({
            "id_": oval_def_id,
            "title": oval_def_id,
            "template": template,
        })
        oval_content = builder.get_lang_contents_for_templatable(rule,
                                                                 ssg.templates.LANGUAGES["oval"])
        assert "<title>%s</title>" % (oval_def_id,) in oval_content
