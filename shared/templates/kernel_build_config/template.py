def preprocess(data, lang):
    if data['value'] == 'n':
        # A kernel configuration that is not set is not present in the config file
        # or is commented out
        data['should_check_absence'] = True
    return data
