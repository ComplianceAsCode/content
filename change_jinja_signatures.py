import os
import re
from jinja2 import Environment, FileSystemLoader
from jinja2.nodes import Name, Getattr, Macro

# --- Configuration ---
JINJA_FILES_DIRECTORY = 'shared/macros'
OFFENDING_GLOBALS = {
    "rule_id", "rule_title", "cce_identifiers"
}


def get_defined_names_in_node(node):
    """
    Recursively finds names that are defined (e.g., loop variables, macro args).
    This is a simplified version and might need enhancement for complex cases.
    """
    defined = set()
    if hasattr(node, 'name') and isinstance(node, Name) and node.ctx == 'store':
        defined.add(node.name)
    if hasattr(node, 'target') and isinstance(node.target, Name): # For 'set' tags
        defined.add(node.target.name)
    if hasattr(node, 'targets'): # For 'for' loops
        for target in node.targets:
            if isinstance(target, Name):
                defined.add(target.name)
            elif isinstance(target, tuple): # e.g., for k, v in my_dict.items()
                for sub_target in target:
                    if isinstance(sub_target, Name):
                        defined.add(sub_target.name)

    for child_node in node.iter_child_nodes():
        defined.update(get_defined_names_in_node(child_node))
    return defined


def get_accessed_names_in_node(node):
    """
    Recursively finds names that are accessed (e.g., variables being read).
    """
    accessed = set()
    if isinstance(node, Name) and node.ctx == 'load':
        accessed.add(node.name)
    elif isinstance(node, Getattr): # e.g., my_obj.attribute
        # We are interested in the base object being accessed
        current = node
        while isinstance(current.node, Getattr):
            current = current.node
        if isinstance(current.node, Name):
            accessed.add(current.node.name)
    # Note: This doesn't deeply analyze calls, filters, etc., for simplicity.
    # It primarily focuses on direct variable name access.

    for child_node in node.iter_child_nodes():
        accessed.update(get_accessed_names_in_node(child_node))
    return accessed


def analyze_macro_node(macro_node):
    """
    Analyzes a macro's AST node to find potential global variables.
    """
    local_defs = set()

    # Find local assignments (e.g., {% set x = ... %}) and loop variables
    for node in macro_node.body:
        local_defs.update(get_defined_names_in_node(node))

    all_accessed_names = set()
    for node in macro_node.body:
        all_accessed_names.update(get_accessed_names_in_node(node))

    # Potential globals are accessed names that are not:
    # - macro arguments
    # - locally defined variables (set, for loop vars)
    # - known Jinja built-ins or common globals
    #potential_globals = all_accessed_names - macro_args - local_defs - known_globals_filters_tests
    potential_globals = all_accessed_names.intersection(OFFENDING_GLOBALS)
    return sorted(list(potential_globals))


def refactor_macro_content(macro_name, original_content, potential_globals):
    """
    Rewrites the macro definition line to include new keyword arguments.
    This is a regex-based approach and might need refinement for complex signatures.
    """
    if not potential_globals:
        return original_content

    # Regex to find the macro definition: {% macro name(arg1, arg2=default, ...) %}
    # This regex is a bit simplified and might need adjustment for very complex arg lists
    macro_def_pattern = re.compile(
        r"({{%-?\s*macro\s+" + re.escape(macro_name) + r"\s*)\(([^)]*)\)(\s*-?%}})"
    )

    match = macro_def_pattern.search(original_content)
    if not match:
        print(f"  [!] Could not find definition for macro '{macro_name}' to rewrite. Skipping line change.")
        return original_content # Should not happen if we parsed it

    original_args_str = match.group(2).strip()
    new_kwargs_str = ", ".join([f"{x}=None" for x in potential_globals if x not in original_args_str]) # Default to None

    if original_args_str and new_kwargs_str:
        updated_args_str = f"{original_args_str}, {new_kwargs_str}"
    elif new_kwargs_str:
        updated_args_str = new_kwargs_str
    else:
        updated_args_str = original_args_str # No changes needed if no new globals

    updated_macro_def = f"{match.group(1)}({updated_args_str}){match.group(3)}"
    return original_content.replace(match.group(0), updated_macro_def)


def update_macros_in_file(filepath, env):
    changes_summary = {}
    """
    Processes a single Jinja file to refactor macros.
    """
    print(f"\nProcessing file: {filepath}")
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            original_content = f.read()
    except Exception as e:
        print(f"  [!] Error reading file {filepath}: {e}")
        return

    modified_content = original_content
    try:
        # Parse the template to get the AST
        source, filename, _ = env.loader.get_source(env, os.path.basename(filepath))
        parsed_template = env.parse(source)
    except Exception as e:
        print(f"  [!] Error parsing Jinja template {filepath}: {e}")
        return

    macros_found = parsed_template.find_all(Macro)

    if not macros_found:
        print("  No macros found in this file.")
        return

    changed_macros = 0
    for macro_node in parsed_template.find_all(Macro):
        macro_name = macro_node.name
        print(f"  Analyzing macro: {macro_name}(args: {[arg.name for arg in macro_node.args]})")

        potential_globals = analyze_macro_node(macro_node)
        if potential_globals:
            print(f"    Potential global variables found: {potential_globals}")
            # Get the raw text of the macro definition for rewriting
            # This is a bit tricky as the AST doesn't directly give us raw text of just the macro
            # We will operate on the full file content for replacement.
            modified_content = refactor_macro_content(macro_name, modified_content, potential_globals)
            if modified_content != original_content : # check if refactor_macro_content actually changed something.
                print(f"    Refactored macro signature for: {macro_name}")
                changed_macros +=1
                changes_summary[macro_name] = potential_globals
        else:
            print(f"    No new global variables to parameterize for macro: {macro_name}")

    if changed_macros > 0:
        try:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(modified_content)
            print(f"  Successfully updated {changed_macros} macro(s) in {filepath}")
        except Exception as e:
            print(f"  [!] Error writing updated file {filepath}: {e}")
    else:
        print(f"  No changes made to {filepath}")
    print(f"  Summary of changes: {changes_summary}")
    return changes_summary


def update_macro_invocations_in_string(string, macro_updates):
    for macro_name, new_args in macro_updates.items():
        if not new_args:
            continue
        # Pattern for {{ macro_name(...) }}
        pattern_regular = re.compile(
            r"({{{-?\s*)"  # 1: Opening {{
            r"(\s*)"  # 2: Whitespace before macro name
            rf"({re.escape(macro_name)})"  # 3: Macro name
            r"(\s*\()"  # 4: Whitespace and opening parenthesis
            r"(.*?)"  # 5: Existing arguments (non-greedy)
            r"((?:\)\s*|\) \|\s*indent\s*\(\d+\)\s*)-?}}})"  # 6: Closing parenthesis and }}
            , re.DOTALL
        )
        def replace_invocation(match):
            open_tag, pre_space, name, open_paren_ws, current_args_str, close_tag = match.groups()
            new_args_str_list = [f"{arg_name}={arg_name}" for arg_name in new_args if f"{arg_name}={arg_name}" not in current_args_str]
            if not new_args_str_list:
                return match.group(0)
            new_args_to_add_str = ", ".join(new_args_str_list)

            if current_args_str.strip(): # If there are existing arguments
                if "**" in current_args_str:
                    double_star = current_args_str.find('**')
                    updated_args_str = f"{current_args_str[:double_star]}{new_args_to_add_str}, {current_args_str[double_star:]}"
                # Add a comma if not ending with one, and then the new args
                elif current_args_str.strip().endswith(','):
                    updated_args_str = f"{current_args_str.rstrip()}{' ' if current_args_str.rstrip() and not current_args_str.endswith(' ') else ''}{new_args_to_add_str}"
                else:
                    updated_args_str = f"{current_args_str.rstrip()}, {new_args_to_add_str}"
            else: # No existing arguments
                updated_args_str = new_args_to_add_str

            # Reconstruct the macro call
            # Ensure correct spacing around parentheses if no arguments were present before
            if not current_args_str.strip() and not open_paren_ws.endswith('('):
                # This case means the regex captured {{ macro_name ( ... ) }}
                # but the original was likely {{ macro_name() }}
                # We reconstruct carefully.
                if open_paren_ws.strip() == '(': # only parenthesis
                    return f"{open_tag}{pre_space}{name}({updated_args_str}){close_tag.lstrip()}"
                else: # whitespace then parenthesis
                    return f"{open_tag}{pre_space}{name}{open_paren_ws.rstrip()}({updated_args_str}){close_tag.lstrip()}"
            return f"{open_tag}{pre_space}{name}{open_paren_ws}{updated_args_str}{close_tag}"
        string = pattern_regular.sub(replace_invocation, string)
    return string


def is_ignored_dir(path):   
    # Ignore directories that are not relevant for macro updates
    ignored_dirs = ['.git', '__pycache__', 'venv', 'node_modules/', "build/"]
    return any(ignored in path for ignored in ignored_dirs)


def update_macro_invocations_in_file(filepath, macro_updates):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        print(f"Error reading file {filepath}: {e}")
        return
    original_content = content
    content = update_macro_invocations_in_string(content, macro_updates)
    if content != original_content:
        try:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Updated macros in: {filepath}")
        except Exception as e:
            print(f"Error writing file {filepath}: {e}")


def update_macro_invocations(macro_updates):
    """
    Updates Jinja2 macro invocations in the whole project.

    Args:
        macro_updates (dict): A dictionary where keys are macro names (str)
                              and values are lists of new argument names (str)
                              to be added.
    """
    for root, _, files in os.walk("."):
        if is_ignored_dir(root):
            continue
        for filename in files:
            filepath = os.path.join(root, filename)
            update_macro_invocations_in_file(filepath, macro_updates)
    print("Macro update process finished.")


def main():
    if not os.path.isdir(JINJA_FILES_DIRECTORY):
        print(f"Error: Directory not found: {JINJA_FILES_DIRECTORY}")
        print("Please change the 'JINJA_FILES_DIRECTORY' variable in the script.")
        return

    # Set up a Jinja2 environment purely for parsing
    # We use FileSystemLoader to allow Jinja to find files if they include/import others,
    # which helps with more accurate parsing context, though for this script
    # we are processing files one by one for macro definitions.
    env = Environment(
        loader=FileSystemLoader(JINJA_FILES_DIRECTORY),
        block_start_string="{{%",
        block_end_string="%}}",
        variable_start_string="{{{",
        variable_end_string="}}}",
        comment_start_string="{{#",
        comment_end_string="#}}")

    round = 1
    while True:
        summary = {}
        for filename in os.listdir(JINJA_FILES_DIRECTORY):
            filepath = os.path.join(JINJA_FILES_DIRECTORY, filename)
            file_changes_summary = update_macros_in_file(filepath, env)
            summary.update(file_changes_summary)

        print(f"\nSummary of all changes in round {round}:")
        for k, v in summary.items():
            print(f"  {k}: {",".join(v)}")

        if len(summary) == 0:
            print(f"No changes made in round {round}. Exiting.")
            break
        update_macro_invocations(summary)
        round += 1

    print("\nScript finished. Please review and test the changes thoroughly!")


if __name__ == "__main__":
    main()


##############################################################################
# UNIT TESTS
##############################################################################

def test_update_macro_invocations_in_file_content_simple():
    """
    Test function for update_macro_invocations_in_file_content.
    This is a simple test to ensure the function works as expected.
    """
    content = """
    {{{ my_macro(arg1, arg2) }}}
    {{{ my_macro(arg1, arg2, arg3) }}}
    {{{ my_macro() }}}
    {{{ my_macro(arg1) }}}
    """
    macro_updates = {
        "my_macro": ["arg4", "arg5"]
    }
    
    updated_content = update_macro_invocations_in_string(content, macro_updates)
    
    expected_content = """
    {{{ my_macro(arg1, arg2, arg4=arg4, arg5=arg5) }}}
    {{{ my_macro(arg1, arg2, arg3, arg4=arg4, arg5=arg5) }}}
    {{{ my_macro(arg4=arg4, arg5=arg5) }}}
    {{{ my_macro(arg1, arg4=arg4, arg5=arg5) }}}
    """
    
    assert updated_content.strip() == expected_content.strip(), "Test failed!"


def test_update_macro_invocations_in_file_content_advanced():

    content = """
{{# The regular expression filters away accounts with no passwords and locked passwords (passwords are located in the 2nd field of /etc/shadow entries). #}}
{{{ test_etc_shadow_password_variable(
    regex="^(?:[^:]*:)(?:[^\!\*:]*:)(?:[^:]*:){4}(\d+):(?:[^:]*:)(?:[^:]*)$",
    external_variable_id="var_account_disable_post_pw_expiration",
    operation="less than or equal",
    description="Set existing passwords a period of inactivity before they been locked") }}}
    """
    macro_updates = {
        "test_etc_shadow_password_variable": ["arg4", "arg5"]
    }
    
    updated_content = update_macro_invocations_in_string(content, macro_updates)
    
    expected_content = """
{{# The regular expression filters away accounts with no passwords and locked passwords (passwords are located in the 2nd field of /etc/shadow entries). #}}
{{{ test_etc_shadow_password_variable(
    regex="^(?:[^:]*:)(?:[^\!\*:]*:)(?:[^:]*:){4}(\d+):(?:[^:]*:)(?:[^:]*)$",
    external_variable_id="var_account_disable_post_pw_expiration",
    operation="less than or equal",
    description="Set existing passwords a period of inactivity before they been locked", arg4=arg4, arg5=arg5) }}}
    """
    
    assert updated_content.strip() == expected_content.strip(), "Test failed!"


def test_update_macro_invocations_in_file_content_indent():

    content = """
    {{{ bash_shell_file_set("$tmp_file", "something", "value",) | indent(4) }}}
    {{{ bash_shell_file_set("$tmp_file", "something", "value", no_quotes=true) | indent (17) }}}
    """
    macro_updates = {
        "bash_shell_file_set": ["rule_title", "rule_id"]
    }
    
    updated_content = update_macro_invocations_in_string(content, macro_updates)

    expected_content = """
    {{{ bash_shell_file_set("$tmp_file", "something", "value", rule_title=rule_title, rule_id=rule_id) | indent(4) }}}
    {{{ bash_shell_file_set("$tmp_file", "something", "value", no_quotes=true, rule_title=rule_title, rule_id=rule_id) | indent (17) }}}
    """

    assert updated_content.strip() == expected_content.strip(), "Test failed!"


def test_update_macro_invocations_in_file_content_double_star():
    content = """
    {{{ oval_line_in_directory_object(sshd_config_dir, parameter=parameter, ** case_insensitivity_kwargs) | indent (2) }}}
    """
    macro_updates = {
        "oval_line_in_directory_object": ["rule_id"]
    }
    
    updated_content = update_macro_invocations_in_string(content, macro_updates)

    expected_content = """
    {{{ oval_line_in_directory_object(sshd_config_dir, parameter=parameter, rule_id=rule_id, ** case_insensitivity_kwargs) | indent (2) }}}
    """

    assert updated_content.strip() == expected_content.strip(), "Test failed!"


def test_update_macro_invocations_in_file_substring_in_substring():
    content = """
    {{{ oval_file_contents("/proc/sys/crypto/fips_enabled", rule_id + "_fips_enabled", "1") }}}
    """
    macro_updates = {
        "oval_file_contents": ["rule_id"]
    }
    
    updated_content = update_macro_invocations_in_string(content, macro_updates)

    expected_content = """
    {{{ oval_file_contents("/proc/sys/crypto/fips_enabled", rule_id + "_fips_enabled", "1", rule_id=rule_id) }}}
    """

    assert updated_content.strip() == expected_content.strip(), "Test failed!"
