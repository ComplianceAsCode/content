import os
import ssg.rule_yaml

data_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "data"))


def test_read_file_list():
    path = os.path.join(data_dir, 'ssg_rule_yaml.txt')
    contents = ssg.rule_yaml.read_file_list(path)

    assert isinstance(contents, list)
    assert len(contents) == 1
    assert contents[0] == 'testing'
