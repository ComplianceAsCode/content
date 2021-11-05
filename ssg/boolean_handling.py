import ast
import copy


class GraphNode:
    """
    Base for both AND/OR or leaf nodes
    """
    def __init__(self, * args, ** kwargs):
        super().__init__(* args, ** kwargs)

        self.negated = False

    def to_node(self):
        return self

    def merge(self):
        pass

    def order_operands(self):
        pass


class ContainerNode(GraphNode):
    """
    Container node contains leaf nodes or other container nodes

    Container nodes support minimal normalization
    and generating IDs based on IDs of contained nodes
    """
    CONNECTION = ""

    def __init__(self, * args, ** kwargs):
        super().__init__(* args, ** kwargs)

        self.nodes = []

    def normalize(self):
        self.merge()
        self.order_operands()

    def merge(self):
        for n in self.nodes:
            n.merge()

        nodes_to_remove = set()
        for n in self.nodes:
            if isinstance(n, ContainerNode) and n.CONNECTION == self.CONNECTION:
                self.nodes.extend(n.nodes)
                nodes_to_remove.add(n)

        self.nodes = list({n for n in self.nodes if n not in nodes_to_remove})

    def generate_id(self):
        self.normalize()
        elements = f"-{self.CONNECTION}-".join((x.generate_id() for x in self.nodes))
        return "(" + elements + ")"

    def print_contents(self, indent=0):
        indentation = " " * indent
        list_indentation = indentation + "- "
        print(indentation + self.CONNECTION)
        for n in self.nodes:
            n.print_contents(indent + 2)

    def __str__(self):
        return self.generate_id()

    def order_operands(self):
        for n in self.nodes:
            n.order_operands()
        self.nodes.sort(key=lambda x: x.generate_id())


class AndNode(ContainerNode):
    CONNECTION = "AND"

    def __or2__(self, rhs):
        top = OrNode()
        top.nodes.append(self)
        top.nodes.append(rhs.to_node())
        return top

    def __and2__(self, rhs):
        ret = copy.deepcopy(self)
        ret.nodes.append(rhs.to_node())
        return ret


class OrNode(ContainerNode):
    CONNECTION = "OR"

    def __or2__(self, rhs):
        ret = copy.deepcopy(self)
        ret.nodes.append(rhs.to_node())
        return ret

    def __and2__(self, rhs):
        top = AndNode()
        top.nodes.append(self)
        top.nodes.append(rhs.to_node())
        return top


class LeafNode(GraphNode):
    def __init__(self, * args, ** kwargs):
        self.leaf = kwargs.pop("leaf")
        super().__init__(* args, ** kwargs)

    def generate_id(self):
        stem = self.leaf.get_id()
        if self.negated:
            return f"NOT-{stem}"
        else:
            return stem

    def __and2__(self, rhs):
        if isinstance(rhs, ContainerNode):
            return rhs.__and2__(self)
        else:
            ret = AndNode()
            ret.nodes.append(self)
            ret.nodes.append(rhs)
            return ret

    def __or2__(self, rhs):
        if isinstance(rhs, ContainerNode):
            return rhs.__or2__(self)
        else:
            ret = OrNode()
            ret.nodes.append(self)
            ret.nodes.append(rhs)
            return ret

    def __not2__(self):
        ret = copy.copy(self)
        ret.negated = not self.negated
        return ret

    def __str__(self):
        return self.generate_id()

    def print_contents(self, indent=0):
        indentation = " " * indent
        print(indentation + self.leaf.name)


class GraphCompatible:
    """
    Class to inherit from if one would like to be used in eval expressions
    """
    def get_id(self):
        raise NotImplementedError

    def to_node(self):
        return LeafNode(leaf=self)


# Operations for simpleeval
def operation_and(lhs, rhs):
    return lhs.to_node().__and2__(rhs.to_node())


def operation_or(lhs, rhs):
    return lhs.to_node().__or2__(rhs.to_node())


def operation_not(rhs):
    return rhs.to_node().__not2__()
