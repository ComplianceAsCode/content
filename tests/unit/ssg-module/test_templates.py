import os

import ssg.utils
import ssg.products
import ssg.build_yaml
import ssg.build_cpe
import ssg.templates as tpl

from ssg.environment import open_environment
from ssg.yaml import ordered_load


ssg_root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(__file__))))
DATADIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "data"))
templates_dir = os.path.join(DATADIR, "templates")
platforms_dir = os.path.join(DATADIR, ".")
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

        oval_content = builder.get_lang_contents_for_templatable(
            rule, ssg.templates.LANGUAGES["oval"])

        assert 'id="package_%s_installed"' % (rule.template['vars']['pkgname']) \
               in oval_content

        assert "<title>%s</title>" % (oval_def_id,) \
               in oval_content


def test_platform_templates():
    builder = ssg.templates.Builder(
        env_yaml, '', templates_dir,
        '', '', platforms_dir, cpe_items_dir)

    platform_path = os.path.join(builder.platforms_dir, "package_ntp.yml")
    platform = ssg.build_yaml.Platform.from_yaml(platform_path, builder.env_yaml,
                                                 builder.product_cpes)
    for fact_ref in platform.test.get_symbols():
        cpe = builder.product_cpes.get_cpe_for_fact_ref(fact_ref)
        oval_content = builder.get_lang_contents_for_templatable(
            cpe, ssg.templates.LANGUAGES["oval"])

        assert 'id="package_%s"' % (cpe.template['vars']['pkgname']) \
               in oval_content

        assert "<title>Package %s is installed</title>" % (cpe.template['vars']['pkgname'],) \
               in oval_content
