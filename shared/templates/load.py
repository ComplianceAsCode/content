#!/usr/bin/python
import re
import sys
import os

print(os.path.realpath(__file__))

class ParsingException(Exception):
    pass


class DuplicateException(Exception):
    pass


class Template(object):
    oval_version = []
    platforms = []
    content = ""

    def __init__(self, oval_version, platforms, content):
        self.oval_version = oval_version
        self.platforms = platforms
        self.content = content


class TemplateLoader(object):

    def __init__(self, path_prefix,platform, oval_version):
        self._templates_cache = {}
        self._platform = platform
        self._oval_version = oval_version
        self._path_prefix = path_prefix

    def get_template(self, filename):
        """
        Get best matching template from filename
        Provide caching of results
        :param filename: filename of source templates
        :return: template content from file
        """
        try:
            return self._templates_cache[filename]
        except KeyError:
            templates = self._load_templates_from_file(os.path.join(self._path_prefix,filename))
            template_content = self._choose_appropriate_template(templates).content
            self._templates_cache[filename] = template_content
            return template_content

    def _is_template_supported(self, template):
        return True

    def _choose_appropriate_template(self, templates):
        selected = None
        for template in templates:
            if (self._is_template_supported(template)):
                if (template.oval_version>=self._oval_version):
                    if selected is None:
                        # every supported template is better than none
                        selected = template
                    elif selected.oval_version <= template.oval_version:
                        # later declared template should override template loaded before
                        selected = template
        return selected

    def _load_templates_from_file(self, filename):
        """
        Load library of templates for several platforms
        """
        with open(filename, "r") as template:
            f = template.read()
        self._validate_separators(f)

        blocks = self._parse_into_blocks(f)
        try:
            self._find_duplicates_in_blocks(blocks)
        except DuplicateException as e:
            sys.stderr.write("Already defined template found:\n" + str(e))
        # sys.exit(1) # should be enabled in future
        return blocks

    def _validate_separators(self, file_content):

        matches = re.findall(r"^(#{3,})(.*)$", file_content, re.MULTILINE)

        for match in matches:
            if len(match[0]) != 80:
                raise ParsingException("Separators ###... have to be of length 80\n")

            if len(match[1]) != 0:
                raise ParsingException("Unexpected text after separator '{0}'\n".format(match[1]))

    def _parse_into_blocks(self, text):

        parts = re.split("#{80}", text)

        if len(parts[0]) != 0:
            raise ParsingException("Section before first part should be empty")

        blocks = []
        for part in parts[1:]:
            oval_version = self._parse_oval_version(part)
            platforms = self._parse_platform_list(part)
            content = self._parse_content(part)
            blocks.append(Template(platforms, oval_version, content))
        return blocks

    def _parse_oval_version(self, part):
        oval_version_match = re.match(r"^\s*#\s*oval-version:\s*oval_([\d.]+)", part)
        if oval_version_match is None:
            raise ParsingException("Cannot find oval-version in block: " + part[0:400])

        return float(oval_version_match.group(1))

    def _parse_platform_list(self, cnt):
        """
        This function parse plarforms from OVAL <platform>
        and from remediations # platform
        """
        xml_platforms = re.findall(r"<platform>\s*([^<]*?)\s*</platform>", cnt)

        fix_platform_match = re.search(r"\s*platform\s*=\s*(.*)", cnt)
        if fix_platform_match is None:
            remediation_platforms = []
        else:
            splited = fix_platform_match.group(1).split(",");

            remediation_platforms = map(str.strip, splited)

        parsed_platforms = remediation_platforms + xml_platforms
        if len(parsed_platforms) == 0:
            raise ParsingException("No supported platforms found: " + cnt[0:400])

        return parsed_platforms

    def _parse_content(self, cnt):
        # skip first line (oval version) and remove empty space
        lines = cnt.split("\n")
        return "\n".join(lines[1:]).strip()

    def _find_duplicates_in_blocks(self, blocks):
        s = set()
        for block in blocks:
            prepared = self._prepare_for_comparing(block.content)
            if prepared in s:
                raise DuplicateException(block.content)
            s.add(prepared)

    def _prepare_for_comparing(self, text):
        """
        This will remove comments and all whitespaces.
        result is not valid content, but is easier comparable
        to find duplicates. Removing of comments is not perfect.
        """

        # remove xml comments
        text = re.sub("<!--.*?-->", "", text)
        # remove xml platforms
        text = re.sub("<platform>([^<]+?)</platform>", "", text)

        # remove remediations comments
        text = re.sub("#.*", "", text)

        # all whitespaces
        text = re.sub(r"\s+", "", text)
        return text


loader = TemplateLoader("rhel7",5.11)
template = loader.get_template("./package_installed/bash")
print(template)