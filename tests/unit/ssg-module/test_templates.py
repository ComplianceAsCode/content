import os

import ssg
import ssg.templates

from ssg.environment import open_environment


ssg_root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(__file__))))
DATADIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "data"))
templates_dir = os.path.join(DATADIR, "templates")
platforms_dir = os.path.join(DATADIR, ".")
missing_dir = os.path.join(DATADIR, "missing")
cpe_items_dir = os.path.join(DATADIR, "applicability")

build_config_yaml = os.path.join(ssg_root, "build", "build_config.yml")
product_yaml = os.path.join(ssg_root, "products", "rhel8", "product.yml")
env_yaml = open_environment(build_config_yaml, product_yaml)


def test_render_extra_ovals():
    class MockExtraOValsBuilder(ssg.templates.Builder):
        # Ensure no modifications
        def _write_template(self, filled_template, output_filepath):
            self._called__write_template += 1

        def write_lang_contents_for_templatable(self, oval_content, lang, rule):
            self._rule_count += 1
            super(MockExtraOValsBuilder, self).write_lang_contents_for_templatable(
                oval_content, lang, rule
            )

            assert (
                'id="package_%s_installed"' % (rule.template["vars"]["pkgname"])
                in oval_content
            )

            assert "<title>%s</title>" % (rule.title,) in oval_content

    builder = MockExtraOValsBuilder(
        env_yaml, None, templates_dir, missing_dir, missing_dir, None, cpe_items_dir
    )
    builder._rule_count = 0
    builder._called__write_template = 0

    builder.build_extra_ovals()
    assert builder._called__write_template == builder._rule_count
    assert builder._called__write_template > 0

    assert not os.path.exists(missing_dir)


def test_platform_templates():
    builder = ssg.templates.Builder(
        env_yaml, None, templates_dir,
        missing_dir, missing_dir, platforms_dir, cpe_items_dir)

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

    assert not os.path.exists(missing_dir)
