"""
Common methods for generating files from templates
"""

import csv
import sys
import os
import re

EXIT_NO_TEMPLATE    = 2
EXIT_UNKNOWN_TARGET = 3

class UnknownTargetError(ValueError):
    def __init__(self, msg):
        ValueError.__init__(self, "Unknown target: \"{0}\"".format(msg))


class TemplateDirMissingError(ValueError):
    def __init__(self):
        ValueError.__init__(self,
                            "TEMPLATE_DIR environment variable is missing.")


class BuildDirMissingError(ValueError):
    def __init__(self):
        ValueError.__init__(self, "BUILD_DIR environment variable is missing.")


class ParsingException(Exception):
    pass


class DuplicateException(Exception):
    pass


class Template(object):
    """
    Contains single snippet of whole file
    """
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

    def get_template_abs_path(self,filename):
        joined = os.path.join(self._path_prefix, filename)
        return os.path.abspath(joined)

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
            abs_path = self.get_template_abs_path(filename)
            templates = self._load_templates_from_file(abs_path)
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
            # todo don't ignore it!
            #raise ParsingException("No supported platforms found: " + cnt)
            sys.stderr.write("No platform found in: " + cnt)

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

class TargetType:
    INPUT = 1
    OUTPUT = 2
    BUILD = 3

class FilesGenerator(object):

    def __init__(self):
        self._target_type = None
        self._template_loader = None

    def run(self, prefix, argv):
        argv_len = len(argv)

        self._current_script = sys.argv[0]
        if argv_len < 4:
            self._help()
            sys.exit(1)

        language = sys.argv[1]
        csv_filename = sys.argv[2]
        target_type = sys.argv[3]
        product = sys.argv[4]
        oval_version = sys.argv[5]
        self._build_dir = sys.argv[6]
        types_dict = {
            "build": TargetType.BUILD,
            "list-inputs":TargetType.INPUT,
            "list-outputs":TargetType.OUTPUT,
        }

        self._target_type = types_dict[target_type]

        path_prefix = os.path.join(
            os.path.dirname(__file__),
            "..",
            "templates",
            prefix
        )
        self._result_list=[]
        oval_version = float(oval_version.split("_")[1])
        self._template_loader = TemplateLoader(path_prefix, product, oval_version)
        self.__generate_for_csv(csv_filename, language)

        if self._target_type!= TargetType.BUILD:
            for file in set(self._result_list):
                print(file)
        sys.exit(0)

    def register_file(self, file):
        self._result_list.append(file)

    def generate(self, target, data):
        raise NotImplementedError("This method has to be overridden to generate templates")

    def _help(self):
        targets = self.supported_targets()
        if len(targets) == 0:
            raise Exception("Script doesn't allow any targets")

        print("Usage:\n\t{0} <template language> <csv filename> <build/list-inputs/list-outputs> <product> <supported oval> <build dir>".format(self._current_script))

        formatted_targets = "\t- " + "\n\t- ".join(targets)
        print("Supported languages:\n{0}".format(formatted_targets))

        extra_help = self.extra_help()
        if extra_help is not None:
            print(extra_help)

    def supported_targets(self):
        return []

    def extra_help(self):
        None

    def __generate_for_csv(self, csv_filename, target):
        """
        Call specified function on every line of file
        CSV lines can look like:
            col1, col2 # comment
            col3, col4 # only-for: bash, oval

        todo: remove skip_comments parameter - should be always True
        """

        csv_filename = os.path.abspath(csv_filename)

        if self._target_type == TargetType.INPUT:
            self.register_file(csv_filename)

        with open(csv_filename, 'r') as csv_file:
            filtered_file = self.__filter_out_csv_lines(csv_file, target)

            try:
                for line in csv.reader(filtered_file):
                    self.generate(target,line)
            except UnknownTargetError as e:
                sys.stderr.write(str(e) + "\n")
                sys.exit(EXIT_UNKNOWN_TARGET)

    def __process_line(self, line, target):
        """
        Remove comments
        Remove line if target is unsupported
        """

        if target is not None:
            regex = re.compile(r"#\s*only-for:([\s\w,]*)")

            match = regex.search(line)

            if match:
                # if line contains restriction to target, check it
                supported_targets = [x.strip() for x in match.group(1).split(",")]
                if target not in supported_targets:
                    return None

        # get part before comment
        return (line.split("#")[0]).strip()

    def __filter_out_csv_lines(self, csv_file, target):
        """
        Filter out not applicable lines
        """

        for line in csv_file:
            processed_line = self.__process_line(line, target)

            if not processed_line:
                continue

            yield processed_line

    def load_modified(self, filename, constants_dict, regex_replace=[]):
        """
        Load file and replace constants accoridng to constants_dict and regex_dict

        constants_dict: dict of constants - replace ( key -> value)
        regex_dict: dict of regex substitutions - sub ( key -> value)
        """

        if self._target_type == TargetType.OUTPUT:
            return ""

        if self._target_type == TargetType.INPUT:
            template_filename = self._template_loader.get_template_abs_path(filename)
            self.register_file(template_filename)
            return ""

        filestring = self._template_loader.get_template(filename)

        for key, value in constants_dict.iteritems():
            filestring = filestring.replace(key, value)

        for pattern, replacement in regex_replace:
            filestring = re.sub(pattern, replacement, filestring)

        return filestring

    def save_modified(self, filename_format, filename_value, string):
        """
        Save string to file
        """
        filename = filename_format.format(filename_value)

        filename = os.path.join(self._build_dir, filename)

        if self._target_type == TargetType.INPUT:
            return

        if self._target_type == TargetType.OUTPUT:
            self.register_file(filename)
            return

        with open(filename, 'w+') as outputfile:
            outputfile.write(string)

    def file_from_template(self, template_filename, constants,
                           filename_format, filename_value, regex_replace=[]):
        """
        Load template, fill constant and create new file
        @param regex_replace: array of tuples (pattern, replacement)
        """

        filled_template = self.load_modified(template_filename, constants, regex_replace)

        self.save_modified(filename_format, filename_value, filled_template)




