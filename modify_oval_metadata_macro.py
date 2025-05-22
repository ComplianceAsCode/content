#!/usr/bin/env/python3

import os
import re
import sys

def is_ignore_dir(dirpath): 
    """
    Check if the directory should be ignored.
    """
    ignore_dirs = ["build/", "dist/", ".git/", "__pycache__/"]
    return any(ignore_dir in dirpath for ignore_dir in ignore_dirs)

def change_oval_metadata(original_content):
    oval_metadata_pattern = re.compile(r"({{{-?\s*\boval_metadata\b\()(.*?)(\)\s*}}})", re.DOTALL)
    for match in oval_metadata_pattern.finditer(original_content):
        if match is None:
            return original_content
        opening = match.group(1)
        arguments = match.group(2)
        closing = match.group(3)
        affected_platforms_pattern = re.compile(r",\s*affected_platforms\s*=\s*(None|\[[^]]*\])")
        arguments = affected_platforms_pattern.sub("", arguments)
        if "title=" not in arguments:
            arguments += ", title=rule_title"
        final = opening + arguments + closing
        original_content = original_content.replace(match.group(0), final)
    return original_content


def process_file(filepath):
    try:
        with open(filepath, "r") as file:
            original_content = file.read()
    except Exception as e:
        return
    modified_content = change_oval_metadata(original_content)
    if original_content != modified_content:
        with open(filepath, "w") as file:
            file.write(modified_content)
        print(f"Modified: {filepath}")

def main():
    for dirpath, dirnames, filenames in os.walk("."):
        if is_ignore_dir(dirpath):
            continue
        for filename in filenames:
            filepath = os.path.join(dirpath, filename)
            process_file(filepath)


if __name__ == "__main__":
    main()