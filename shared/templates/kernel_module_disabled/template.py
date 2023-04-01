import ssg.utils


def preprocess(data, lang):
    # modprobe(5)
    #    there is no difference between _ and - in module names
    kernmodule_parts = []
    for item1 in data['kernmodule'].split('_'):
        for item2 in item1.split('-'):
            kernmodule_parts.append(ssg.utils.escape_regex(item2))
    data['kernmodule_rx'] = '[_-]'.join(kernmodule_parts)
    return data
