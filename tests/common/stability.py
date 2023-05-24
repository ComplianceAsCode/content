from __future__ import print_function

import sys


class Difference(object):
    def __init__(self):
        self.added = []
        self.removed = []
        self.modified = dict()

    def remove_item_from_comparison(self, item):
        if item in self.added:
            self.added.remove(item)
        if item in self.removed:
            self.removed.remove(item)
        if item in self.modified:
            self.modified.pop(item)

    @property
    def empty(self):
        return not (self.added or self.removed or self.modified)


def describe_changeset(intro, changeset):
    if not changeset:
        return ""

    msg = intro
    for item in changeset:
        msg += " - {item}\n".format(item=item)
    return msg


def report_comparison(name, result, message_generator):
    if not result.empty:
        msg = message_generator(result, name)
        print(msg, file=sys.stderr)


