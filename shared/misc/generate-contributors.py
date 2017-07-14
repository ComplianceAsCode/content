#!/usr/bin/env python2

import subprocess
import re
import os.path
import codecs
import datetime

MANUAL_EDIT_WARNING = \
"""
This file is generated using the %s script. DO NOT MANUALLY EDIT!!!!
Last Modified: %s
""" % (os.path.basename(__file__), datetime.datetime.now().strftime("%Y-%m-%d %H:%M"))

email_mappings = {
    # Dave / David Smith
    "dsmith@secure-innovations.net": "dsmith@eclipse.ncsc.mil",
    "dsmith@fornax.eclipse.ncsc.mil": "dsmith@eclipse.ncsc.mil",
    # Frank Caviggia
    "fcaviggia@users.noreply.github.com": "fcaviggi@ra.iad.redhat.com",
    # Greg Elin
    "greg@fotonotes.net": "gregelin@gitmachines.com",
    # Jean-Baptiste Donnette
    "donnet_j@epita.fr": "jean-baptiste.donnette@epita.fr",
    # Marek Haicman
    "dahaic@users.noreply.github.com": "mhaicman@redhat.com",
    # Martin Preisler
    "martin@preisler.me": "mpreisle@redhat.com",
    # Philippe Thierry
    "phil@internal.reseau-libre.net": "phil@reseau-libre.net",
    "philippe.thierry@reseau-libre.net": "phil@reseau-libre.net",
    "philippe.thierry@thalesgroup.com": "phil@reseau-libre.net",
    # Robin Price II
    "rprice@users.noreply.github.com": "robin@redhat.com",
    "rprice@redhat.com": "robin@redhat.com",
    # Zbynek Moravec
    "ybznek@users.noreply.github.com": "zmoravec@redhat.com",
    "moraveczbynek@gmail.com": "zmoravec@redhat.com",
    # Jeff Blank
    "jeff@t440.local": "blank@eclipse.ncsc.mil",
    # Shawn Wells
    "shawn@localhost.localdomain": "shawn@redhat.com",
    "shawnw@localhost.localdomain": "shawn@redhat.com",
    # Simon Lukasik
    "isimluk@fedoraproject.org": "slukasik@redhat.com",
    # Andrew Gilmore
    "agilmore@ecahdb2.bor.doi.net": "agilmore2@gmail.com",

    # No idea / ignore
    "lyd@chippy.(none)": "",
    "nick@null.net": "",
    "root@localhost.localdomain": "",
    "root@rhel6.(none)": "",
}

name_mappings = {
    "Gabe": "Gabe Alford"
}


def main():
    emails = {}
    output = subprocess.check_output(["git", "shortlog", "-se"]).decode("utf-8")
    for line in output.split("\n"):
        match = re.match(r"[\s]*([0-9]+)[\s+](.+)[\s]+\<(.+)\>", line)
        if match is None:
            continue

        commits, name, email = match.groups()

        if email in email_mappings:
            email = email_mappings[email]

        if email == "":
            continue  # ignored

        if email not in emails:
            emails[email] = []

        emails[email].append((int(commits), name))

    contributors = {}
    # We will use the most used full name
    for email in emails:
        _, name = sorted(emails[email], reverse=True)[0]
        if name in name_mappings:
            name = name_mappings[name]

        contributors[name] = email

    contributors_md = "<!---%s--->\n\n" % MANUAL_EDIT_WARNING
    contributors_md += \
        "The following people have contributed to the SCAP Security Guide project\n"
    contributors_md += "(listed in alphabetical order):\n\n"
    
    contributors_xml = "<!--%s-->\n\n" % MANUAL_EDIT_WARNING 
    contributors_xml += "<text>\n"

    for name in sorted(contributors.keys(), key=lambda x: x.split(" ")[-1].upper()):
        email = contributors[name]
        contributors_md += "* %s <%s>\n" % (name, email)
        contributors_xml += "<contributor>%s &lt;%s&gt;</contributor>\n" % (name, email)

    contributors_xml += "</text>\n"

    root_dir = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))
    with codecs.open(os.path.join(root_dir, "Contributors.md"),
                     mode="w", encoding="utf-8") as f:
        f.write(contributors_md)
    with codecs.open(os.path.join(root_dir, "Contributors.xml"),
                     mode="w", encoding="utf-8") as f:
        f.write(contributors_xml)

    print("Don't forget to commit Contributors.md and Contributors.xml!")

if __name__ == "__main__":
    main()
