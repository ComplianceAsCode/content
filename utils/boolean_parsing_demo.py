import ast

import ssg.boolean_handling
import third_party.simpleeval


class Entity(ssg.boolean_handling.GraphCompatible):
    """
    A demo class - just contains a name"
    """
    def __init__(self, name):
        self.name = name

    def get_id(self):
        return self.name


if __name__ == "__main__":
    s = third_party.simpleeval.SimpleEval()
    s.operators[ast.And] = ssg.boolean_handling.operation_and
    s.operators[ast.Or] = ssg.boolean_handling.operation_or
    s.operators[ast.Not] = ssg.boolean_handling.operation_not

    one = Entity("one")
    two = Entity("two")
    three = Entity("three")

    s.names = dict(one=one, two=two, three=three)

    res = s.eval("(one and not two) or three")
    res.print_contents()
