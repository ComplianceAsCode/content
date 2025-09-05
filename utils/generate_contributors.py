#!/usr/bin/env python2

import os.path
import codecs
import ssg
import ssg.contributors


def main():
    contributors_md, contributors_xml = ssg.contributors.generate()

    root_dir = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))
    with codecs.open(os.path.join(root_dir, "Contributors.md"),
                     mode="w", encoding="utf-8") as f:
        f.write(contributors_md)

    with codecs.open(os.path.join(root_dir, "Contributors.xml"),
                     mode="w", encoding="utf-8") as f:
        f.write(contributors_xml)

    print("Don't forget to commit Contributors.md and Contributors.xml!")


if __name__ == "__main__":
    main()
