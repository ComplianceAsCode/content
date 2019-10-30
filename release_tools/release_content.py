import argparse


def create_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument("--owner", default="ComplianceAsCode")
    parser.add_argument("--repo", default="content")

    return parser.parse_args()


if __name__ == "__main__":
    parser = create_parser()
