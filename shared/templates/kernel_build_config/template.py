def preprocess(data, lang):
    if 'value' in data and 'variable' in data:
        raise RuntimeError(
                "ERROR: The template should not set both 'value' and 'variable'.\n"
                "arg_name: {0}\n"
                "arg_variable: {1}".format(data['value'], data['variable']))

    if data.get('value', False) == 'n':
        # A kernel configuration that is not set is not present in the config file
        # or is commented out
        data['should_check_absence'] = True
    return data
