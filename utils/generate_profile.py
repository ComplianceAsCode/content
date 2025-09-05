#!/usr/bin/env python3

# Get input file
# Determine format (CSV or something else like OSCAL)
# Parse input into a data structure (dictionary)

import abc
import argparse
import os
import re

import json
import yaml
from pycompliance import pycompliance

import pandas

DESCRIPTION = '''
A tool for converting benchmarks to profiles.
'''


class LiteralUnicode(str):
    pass


def literal_unicode_representer(dumper, data):
    # NOTE(rhmdnd): pyyaml will not format a string using the style we define for the scalar below
    # if any strings in the data end with a space (e.g., 'some text ' instead of 'some text'). This
    # has been reported upstream in https://github.com/yaml/pyyaml/issues/121. This particular code
    # goes through every line of data and strips any whitespace characters from the end of the
    # string, and reconstructs the string with newlines so that it will format properly.
    text = [line.rstrip() for line in data.splitlines()]
    sanitized = '\n'.join(text)
    return dumper.represent_scalar(u'tag:yaml.org,2002:str', sanitized, style='|')


yaml.add_representer(LiteralUnicode, literal_unicode_representer)


def setup_argument_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
        description=DESCRIPTION)
    parser.add_argument('-i', '--input-file', required=True)

    subparsers = parser.add_subparsers()
    list_parser = subparsers.add_parser('list', help='List controls within a benchmark')
    list_parser.set_defaults(func=list_controls)
    generate_parser = subparsers.add_parser('generate', help='Generate a control from benchmark')
    generate_parser.add_argument('-p', '--product-type', required=True,
                                 help='Product name to generate in output')
    generate_parser.add_argument('-c', '--control', help='Control ID to generate')
    generate_parser.add_argument('-s', '--section',
                                 help='Section ID to generate, including containing controls')
    generate_parser.set_defaults(func=generate_control)

    return parser


class Parser(abc.ABC):

    @abc.abstractmethod
    def __init__(self) -> None:
        raise NotImplementedError

    @abc.abstractmethod
    def get_name(self):
        raise NotImplementedError

    @abc.abstractmethod
    def get_version(self):
        raise NotImplementedError

    @abc.abstractmethod
    def parse(self):
        raise NotImplementedError


class XLSXParser(Parser):
    def __init__(self, input_file: str):
        self.input_file = input_file
        self.file_format = ".xlsx"

    def parse(self) -> pycompliance.Benchmark:
        cols = [
            'section #',
            'recommendation #',
            'profile',
            'title',
            'assessment status',
            'description',
            'remediation procedure',
            'rationale statement',
            'audit procedure']

        benchmark_name = self.get_name()
        benchmark_version = self.get_version()
        b = pycompliance.Benchmark(benchmark_name)
        b.version = benchmark_version
        df = pandas.read_excel(
            self.input_file, sheet_name='Combined Profiles', usecols=cols)
        result = df.to_json(orient='split')
        d = json.loads(result)

        for i in d['data']:
            section = str(i[0])
            if section.endswith('.0'):
                section = section.rstrip('.0')
            control = i[1]
            level = i[2]
            title = i[3]
            assessment = i[4]
            description = i[5]
            rationale = i[6]
            remediation = i[7]
            audit = i[8]
            if section and not control:
                s = pycompliance.Section(section)
                s.title = title
                s.description = description
                b.add_section(s)
            elif section and control:
                c = pycompliance.Control(control)
                c.title = title
                c.level = level
                c.description = description
                c.remediation = remediation
                c.rationale = rationale
                c.audit = audit
                c.assessment = assessment
                b.add_control(c)
        return b

    def get_name(self) -> str:
        name = os.path.splitext(self.input_file)[0]
        original = os.path.basename(name).replace("_", " ")
        parts = original.split()
        n = ''
        for p in parts:
            if p.startswith(self.get_version()):
                break
            n = n + p + ' '
        return n.strip()

    def get_version(self) -> str:
        name = os.path.splitext(self.input_file)[0]
        m = re.search(r"v\d.+", name)
        if m:
            return m.group()
        else:
            raise Exception("Unable to determine version from file name")


class Generator:

    def __init__(self, benchmark: pycompliance.Benchmark) -> None:
        self.benchmark = benchmark

    def placeholder(self, key=None):
        if key is None:
            key = 'PLACEHOLDER'
        return key

    def _get_controls(self, section=None) -> list[dict]:
        controls = []
        if section:
            c = self._generate(section)
            controls.append(c)
            return controls
        for i in self.benchmark.children:
            c = self._generate(i)
            controls.append(c)
        return controls

    def _get_levels(self) -> list[dict]:
        levels = []
        for n in self.benchmark.traverse(self.benchmark):
            if hasattr(n, 'level'):
                level = n.level.replace(' ', '_').lower()
                if level not in levels:
                    levels.append(level)
        res = []
        for level in levels:
            res.append({'id': level, 'inherits_from': self.placeholder()})
        return res

    def _generate(self, node: pycompliance.Node) -> dict:
        d = {
            'id': node.id,
            'title': node.title,
            'status': self.placeholder(key='pending'),
            'rules': []
        }
        if hasattr(node, 'level'):
            d['levels'] = node.level.replace(' ', '_').lower()
        if node.children:
            d['controls'] = []
        for node in node.children:
            d['controls'].append(self._generate(node))
        return d


class RuleGenerator(Generator):

    def __init__(self, benchmark: pycompliance.Benchmark, product_type: str):
        super().__init__(benchmark)
        self.product_type = product_type

    def generate(self, control: pycompliance.Control):
        if not isinstance(control, pycompliance.Control):
            return
        description = (
                LiteralUnicode(control.description) + '\n' +
                LiteralUnicode(control.remediation)
        )
        output = {
            'documentation_complete': False,
            'prodtype': self.product_type,
            'title': LiteralUnicode(control.title),
            'description': description,
            'rationale': LiteralUnicode(control.rationale),
            'severity': self.placeholder(),
            'references': self.placeholder(),
            'ocil': LiteralUnicode(control.audit),
            'ocil_clause': self.placeholder(),
            'warnings': self.placeholder(),
            'template': self.placeholder(),
        }
        print(yaml.dump(output, sort_keys=False, width=float("inf")))


class SectionGenerator(Generator):

    def generate(self, section=None):
        output = {
            'controls': self._get_controls(section=section)
        }
        print(yaml.dump(output, sort_keys=False, width=float("inf")))


class ProfileGenerator(Generator):

    def generate(self, section=None):
        output = {
            'policy': self.benchmark.name,
            'title': self.benchmark.name,
            'id': self.placeholder(),
            'version': self.benchmark.version.lstrip('v'),
            'source': self.placeholder(key="https://example.com/benchmark"),
            'levels': self._get_levels(),
            'controls': self._get_controls(section=section)
        }
        print(yaml.dump(output, sort_keys=False))


def get_parser(input_file) -> Parser:
    if input_file.endswith('xlsx'):
        return XLSXParser(input_file)
    raise Exception("Unable to parse format")


def list_controls(args):
    p = get_parser(args.input_file)
    b = p.parse()
    for n in b.traverse(b):
        if isinstance(n, pycompliance.Control):
            print(n.id)


def generate_control(args):
    p = get_parser(args.input_file)
    b = p.parse()

    control = b.find(args.control)
    section = b.find(args.section)
    if control:
        r = RuleGenerator(b, args.product_type)
        r.generate(control)
    elif section:
        r = SectionGenerator(b)
        r.generate(section)
    else:
        p = ProfileGenerator(b)
        p.generate()


def main():
    arg_parser = setup_argument_parser()
    args = arg_parser.parse_args()
    args.func(args)


main()
