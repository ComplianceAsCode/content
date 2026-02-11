import os
from argparse import Namespace
from utils.profile_tool import command_most_used_rules

DATA_DIR = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "..", "ssg-module", "data")
)
DATA_STREAM_PATH = os.path.join(DATA_DIR, "simple_data_stream.xml")


def get_fake_args():
    return Namespace(
        subcommand="most-used-rules", BENCHMARKS=[str(DATA_STREAM_PATH)], format="plain"
    )


def test_command(capsys):
    command_most_used_rules(get_fake_args())
    captured = capsys.readouterr()
    assert "xccdf_com.example.www_rule_test-pass: 1" in captured.out
