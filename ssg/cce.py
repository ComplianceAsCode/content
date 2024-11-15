"""
Common functions for processing CCE (Common Configuration Enumeration) in SSG
"""

import re
import random
import os


CCE_POOLS = dict()


class CCEFile:
    """
    A class to represent a CCE (Common Configuration Enumeration) file.

    Attributes:
        project_root (str): The root directory of the project.
    """
    def __init__(self, project_root=None):
        if not project_root:
            project_root = os.path.join(
                os.path.dirname(os.path.abspath(__file__)), "..")
        self.project_root = project_root

    @property
    def absolute_path(self):
        raise NotImplementedError()

    def line_to_cce(self, line):
        return line

    def line_isnt_cce(self, cce, line):
        return line != cce

    def read_cces(self):
        """
        Reads the CCEs (Common Configuration Enumeration) from a file and validates them.

        This method opens the file specified by `self.absolute_path`, reads its contents
        line by line, and checks each line to ensure it is a valid CCE value. If an invalid CCE
        is detected, a RuntimeError is raised with an appropriate error message.

        Returns:
            list: A list of valid CCE values read from the file.

        Raises:
            RuntimeError: If an invalid CCE value is detected in the file.
        """
        with open(self.absolute_path, "r") as f:
            cces = f.read().splitlines()
        for cce in cces:
            if not is_cce_value_valid(cce):
                msg = (
                    "Invalid CCE detected in {cce_path}: {cce}"
                    .format(cce=cce, cce_path=self.absolute_path))
                raise RuntimeError(msg)
        return cces

    def remove_cce_from_file(self, cce):
        """
        Removes lines containing the specified CCE (Common Configuration Enumeration) from a file.

        Args:
            cce (str): The CCE identifier to be removed from the file.

        The method reads the file, filters out lines containing the specified CCE,
        and writes the remaining lines back to the file.
        """
        file_lines = self.read_cces()
        lines_except_cce = [
            line for line in file_lines
            if self.line_isnt_cce(cce, line)
        ]
        with open(self.absolute_path, "w") as f:
            f.write("\n".join(lines_except_cce) + "\n")

    def random_cce(self):
        """
        Selects a random CCE (Common Configuration Enumeration) from the list of CCEs.

        Reads the list of CCEs, shuffles them randomly, and returns the first CCE
        from the shuffled list after stripping any leading or trailing whitespace.

        Returns:
            str: A randomly selected and stripped CCE.
        """
        cces = self.read_cces()
        random.shuffle(cces)
        return cces[0].strip()


class RedhatCCEFile(CCEFile):
    """
    RedhatCCEFile is a subclass of CCEFile that represents a file containing
    Red Hat Common Configuration Enumeration (CCE) data.

    Properties:
        absolute_path (str): The absolute path to the Red Hat CCE file, which is located in the
                             "shared/references" directory within the project root and named "cce-redhat-avail.txt".
    """
    @property
    def absolute_path(self):
        return os.path.join(self.project_root, "shared", "references", "cce-redhat-avail.txt")


class SLE12CCEFile(CCEFile):
    """
    SLE12CCEFile is a subclass of CCEFile that represents a file containing
    SLE12 Common Configuration Enumeration (CCE) data.

    This class provides a property to get the absolute path of the SLE12 CCE file.

    Properties:
        absolute_path (str): The absolute path to the SLE12 CCE file, which is located in the
                             "shared/references" directory.
    """
    @property
    def absolute_path(self):
        return os.path.join(self.project_root, "shared", "references", "cce-sle12-avail.txt")


class SLE15CCEFile(CCEFile):
    """
    SLE15CCEFile is a subclass of CCEFile that represents a file containing
    SLE15 Common Configuration Enumeration (CCE) data.

    This class provides a property to get the absolute path of the SLE12 CCE file.

    Properties:
        absolute_path (str): The absolute path to the SLE15 CCE file, which is located in the
                             "shared/references" directory.
    """
    @property
    def absolute_path(self):
        return os.path.join(self.project_root, "shared", "references", "cce-sle15-avail.txt")


CCE_POOLS["redhat"] = RedhatCCEFile
CCE_POOLS["sle12"] = SLE12CCEFile
CCE_POOLS["sle15"] = SLE15CCEFile


def is_cce_format_valid(cceid):
    """
    Check if the given CCE ID is in a valid format.

    A valid CCE ID must be in one of the following formats:
    - 'CCE-XXXX-X'
    - 'CCE-XXXXX-X'

    where each 'X' is a digit, and the final 'X' is a check-digit.

    Args:
        cceid (str): The CCE ID to validate.

    Returns:
        bool: True if the CCE ID is in a valid format, False otherwise.
    """
    match = re.match(r'^CCE-\d{4,5}-\d$', cceid)
    return match is not None


def is_cce_value_valid(cceid):
    """
    Validates a CCE (Common Configuration Enumeration) identifier using Luhn's algorithm.

    This function removes non-digit characters from the CCE identifier and then applies
    Luhn's algorithm to determine if the identifier is valid.

    Args:
        cceid (str): The CCE identifier to validate.

    Returns:
        bool: True if the CCE identifier is valid, False otherwise.

    References:
        For context, see:
        https://github.com/ComplianceAsCode/content/issues/3044#issuecomment-420844095
    """
    # concat(substr ... , substr ...) -- just remove non-digit characters.
    # Since we've already validated format, this hack suffices:
    cce = re.sub(r'(CCE|-)', '', cceid)

    # The below is an implementation of Luhn's algorithm as this is what the
    # XPath code does.

    # First, map string numbers to integers. List cast is necessary to be able
    # to index it.
    digits = list(map(int, cce))

    # Even indices are doubled. Coerce to list for list addition. However,
    # XPath uses 1-indexing so "evens" and "odds" are swapped from Python.
    # We handle both the idiv and the mod here as well; note that we only
    # hvae to do this for evens: no single digit is above 10, so the idiv
    # always returns 0 and the mod always returns the original number.
    evens = list(map(lambda i: (i*2)//10 + (i*2) % 10, digits[-2::-2]))
    odds = digits[-1::-2]

    # The checksum value is now the sum of the evens and the odds.
    value = sum(evens + odds) % 10

    # Valid CCE <=> value == 0
    return value == 0
