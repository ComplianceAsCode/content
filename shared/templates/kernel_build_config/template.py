def preprocess(data, lang):
    data['existence'] = "at_least_one_exists"
    if data['value'] == 'n':
        # A kernel configuration that is not set is not present in the config file
        # or is commented out
        data['existence'] = "none_exist"
    return data
