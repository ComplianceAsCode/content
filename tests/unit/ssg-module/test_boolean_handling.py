import pytest

import ssg.boolean_handling as tested_module


class Entity(tested_module.GraphCompatible):
    """
    A minimal class for testing - just contains a name
    """
    def __init__(self, name):
        self.name = name

    def get_id(self):
        return self.name


@pytest.fixture
def entity_one():
    return Entity("1")


@pytest.fixture
def entity_two():
    return Entity("2")


@pytest.fixture
def entity_three():
    return Entity("3")


@pytest.fixture
def one_and_two(entity_one, entity_two):
    return tested_module.operation_and(entity_one, entity_two)


@pytest.fixture
def one_or_two(entity_one, entity_two):
    return tested_module.operation_or(entity_one, entity_two)


def test_trivial(entity_one, entity_two, one_and_two, one_or_two):
    negated_one = tested_module.operation_not(entity_one)
    assert "NOT-1" in str(negated_one)

    assert "1-AND-2" in str(one_and_two)
    assert "1-OR-2" in str(one_or_two)

    assert "2-AND-NOT-1" in str(tested_module.operation_and(negated_one, entity_two))


def test_ordering(entity_one, entity_two):
    one_order = tested_module.operation_and(entity_one, entity_two)
    other_order = tested_module.operation_and(entity_two, entity_one)
    assert str(one_order) == str(other_order)


def test_immutability(entity_one, entity_two, one_and_two, entity_three):
    tested_module.operation_and(one_and_two, entity_three)

    str_maybe_tainted_and = str(one_and_two)
    str_pure_and = str(tested_module.operation_and(entity_one, entity_two))

    assert str_maybe_tainted_and == str_pure_and


def test_merge_of_and(one_and_two):
    convoluted = tested_module.AndNode()
    convoluted.nodes.append(one_and_two)
    convoluted.nodes.append(one_and_two)
    convoluted.merge()

    assert str(convoluted) == str(one_and_two)


def test_complex_ordering(one_or_two, one_and_two, entity_three):
    one_order = tested_module.operation_and(
        tested_module.operation_or(
            entity_three,
            one_or_two,
        ),
        one_and_two,
    )

    other_order = tested_module.operation_and(
        one_and_two,
        tested_module.operation_or(
            one_or_two,
            entity_three,
        ),
    )

    assert str(one_order) == str(other_order)


def test_type_mix(entity_one, entity_two, entity_three, one_and_two):
    left_leaf_and = tested_module.operation_and(entity_one.to_node(), entity_two)
    assert str(left_leaf_and) == str(one_and_two)

    right_leaf_and = tested_module.operation_and(entity_one, entity_two.to_node())
    assert str(right_leaf_and) == str(one_and_two)

    plain_and_str = str(tested_module.operation_and(
        tested_module.operation_and(
            entity_one, entity_two
        ),
        entity_three))
    assert plain_and_str == str(tested_module.operation_and(
        left_leaf_and,
        entity_three))
    assert plain_and_str == str(tested_module.operation_and(
        entity_one,
        tested_module.operation_and(
            entity_two,
            entity_three)))
