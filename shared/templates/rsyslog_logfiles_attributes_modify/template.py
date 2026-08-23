def preprocess(data, lang):
    if lang == "oval" and data["attribute"] == 'permissions':
        # create STATEMODE used in the OVAL template by processing the octal permission and
        # creating the equivalent permission fields of "unix:file_state" element.
        mode = data["value"]
        fields = [
            'oexec', 'owrite', 'oread', 'gexec', 'gwrite', 'gread',
            'uexec', 'uwrite', 'uread', 'sticky', 'sgid', 'suid']
        mode_int = int(mode, 8)
        mode_str = ""
        for field in fields:
            if mode_int & 0x01 == 0:
                mode_str = (
                    "<unix:{field} datatype=\"boolean\">false</unix:{field}>\n{mode_str}".format(
                        field=field, mode_str=mode_str))
            mode_int = mode_int >> 1
        data["statemode"] = mode_str.rstrip("\n")
    return data
