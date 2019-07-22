#!/usr/bin/env python2

#
# create_timers_enabled.py
#   automatically generate checks for enabling systemd timers

import sys

from template_common import FilesGenerator, UnknownTargetError, CSVLineError


class TimerEnabledGenerator(FilesGenerator):
    def generate(self, target, timerinfo):
        try:
            # get the items out of the list
            timername, packagename = timerinfo
            if not packagename:
                packagename = timername
        except ValueError as e:
            print("\tEntry: %s\n" % timerinfo)
            print("\tError unpacking timername and packagename: " + str(e))
            raise CSVLineError()

        if target == "oval":
            self.file_from_template(
                "./template_OVAL_timer_enabled",
                {
                    "TIMERNAME": timername,
                    "PACKAGENAME": packagename
                },
                "./oval/timer_{0}_enabled.xml", timername
            )
        elif target == "bash":
            self.file_from_template(
                "./template_BASH_timer_enabled",
                {
                    "TIMERNAME": timername
                },
                "./bash/timer_{0}_enabled.sh", timername
            )

        elif target == "ansible":
            self.file_from_template(
                "./template_ANSIBLE_timer_enabled",
                {
                    "TIMERNAME": timername
                },
                "./ansible/timer_{0}_enabled.yml", timername
            )

        else:
            raise UnknownTargetError(target)

    def csv_format(self):
        return("CSV should contains lines of the format: " +
               "timername,packagename")
