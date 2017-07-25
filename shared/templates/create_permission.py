#
# create_permission.py
#        generate template-based checks for file permissions/ownership

import re

from template_common import FilesGenerator, UnknownTargetError


class PermissionGenerator(FilesGenerator):
    def generate(self, target, path_info):
        # the csv file contains lines that match the following layout:
        #    directory,file_name,uid,gid,mode
        dir_path, file_name, uid, gid, mode = path_info

        # build a string out of the path that is suitable for use in id tags
        # example:	/etc/resolv.conf --> _etc_resolv_conf
        # path_id maps to FILEID in the template
        if file_name == '[NULL]':
            path_id = re.sub('[-\./]', '_', dir_path)
        elif re.match(r'\^.*\$', file_name, 0):
            path_id = re.sub('[-\./]', '_', dir_path) + '_' + re.sub('[-\\\./^$*(){}|]',
                                                                     '_', file_name)
            # cleaning trailing end multiple underscores, make sure id is lowercase
            path_id = re.sub(r'_+','_', path_id)
            path_id = re.sub(r'_$','', path_id)
            path_id = path_id.lower()
        else:
            path_id = re.sub('[-\./]', '_', dir_path) + '_' + re.sub('[-\./]',
                                                                     '_', file_name)
            path_id = path_id.lower()

        # build a string that contains the full path to the file
        # full_path maps to FILEPATH in the template
        if file_name == '[NULL]':
            full_path = dir_path
        else:
            full_path = dir_path + '/' + file_name

        if target == "bash":
            if not re.match(r'\^.*\$', file_name, 0):
                self.file_from_template(
                    "./template_BASH_permissions",
                    {
                        "%FILEPATH%":      full_path,
                        "%FILEMODE%":      mode,
                    },
                    "./bash/file_permissions{0}.sh", path_id
                )
            else:
                file_name = re.sub('^\^', '', file_name)
                self.file_from_template(
                    "./template_BASH_regex_permissions",
                    {
                        "%FILEPATH%":      dir_path,
                        "%FILENAME%":      file_name,
                        "%FILEMODE%":      mode,
                    },
                    "./bash/file_permissions{0}.sh", path_id
                )

        elif target == "ansible" and not re.match(r'\^.*\$', file_name, 0):
            self.file_from_template(
                "./template_ANSIBLE_permissions",
                {
                    "%FILEPATH%":      full_path,
                    "%FILEMODE%":      mode,
                },
                "./ansible/file_permissions{0}.yml", path_id
            )

        elif target == "oval":
            # build the state that describes our mode
            # mode_str maps to STATEMODE in the template
            fields = ['oexec', 'owrite', 'oread', 'gexec', 'gwrite', 'gread',
                      'uexec', 'uwrite', 'uread', 'sticky', 'sgid', 'suid']
            mode_int = int(mode, 8)
            mode_str = "  </unix:file_state>"
            for field in fields:
                if mode_int & 0x01 == 1:
                    mode_str = "	<unix:" + field + " datatype=\"boolean\">true</unix:" + field + ">\n" + mode_str
                else:
                    mode_str = "	<unix:" + field + " datatype=\"boolean\">false</unix:" + field + ">\n" + mode_str
                mode_int = mode_int >> 1

            # support pattern matching, requiring that the filename starts with '^'
            # and fichishes with '$'
            if file_name == '[NULL]':
                unix_filename = "<unix:filename xsi:nil=\"true\" />"
            elif re.match( r'\^.*\$', file_name, 0):
                unix_filename = "<unix:filename operation=\"pattern match\">" + file_name + "</unix:filename>"
            else:
                unix_filename = "<unix:filename>" + file_name + "</unix:filename>"

            # we are ready to create the check
            # open the template and perform the conversions
            self.file_from_template(
                "./template_OVAL_permissions",
                {
                    "%FILEID%":        path_id,
                    "%FILEPATH%":      full_path,
                    "%FILEDIR%":       dir_path,
                    "%FILEUID%":       uid,
                    "%FILEGID%":       gid,
                    "%FILEMODE%":      mode,
                    "%STATEMODE%":     mode_str,
                    "%UNIX_FILENAME%": unix_filename
                },
                "./oval/file_permissions{0}.xml", path_id
            )

        else:
            raise UnknownTargetError(target)

    def csv_format(self):
        return("CSV should contains lines of the format: "
               "directory path,file name,owner uid (numeric),group "
               "owner gid (numeric),mode")
