from __future__ import absolute_import
from __future__ import print_function

import collections
import datetime
import re
import os.path

from .shims import subprocess_check_output


MANUAL_EDIT_WARNING = """This file is generated using the %s script. DO NOT MANUALLY EDIT!!!!
Last Modified: %s
""" % (os.path.basename(__file__), datetime.datetime.now().strftime("%Y-%m-%d %H:%M"))

email_mappings = {
    # People here are sorted by last name
    # Firas AlShafei
    "firas.alshafei@gmail.com": "firas.alshafei@us.abb.com",
    # Dominique Blaze
    "dominique.blaze@edu.devinci.fr": "dominique.blaze@devinci.fr",
    # Ted Brunell
    "tbrunell@tbrunell.corp.redhat.com": "tbrunell@redhat.com",
    # Jeff Blank
    "jeff@t440.local": "blank@eclipse.ncsc.mil",
    # Frank Caviggia
    "fcaviggia@users.noreply.github.com": "fcaviggi@ra.iad.redhat.com",
    # Jean-Baptiste Donnette
    "donnet_j@epita.fr": "jean-baptiste.donnette@epita.fr",
    # Greg Elin
    "greg@fotonotes.net": "gregelin@gitmachines.com",
    # Andrew Gilmore
    "agilmore@ecahdb2.bor.doi.net": "agilmore2@gmail.com",
    # Marek Haicman
    "dahaic@users.noreply.github.com": "mhaicman@redhat.com",
    # John Hooks
    "hooksie11@gmail.com": "jhooks@starscream.pa.jhbcomputers.com",
    # Simon Lukasik
    "isimluk@fedoraproject.org": "slukasik@redhat.com",
    # Milan Lysonek
    "milan.lysonek@gmail.com": "mlysonek@redhat.com",
    # Zbynek Moravec
    "ybznek@users.noreply.github.com": "zmoravec@redhat.com",
    "moraveczbynek@gmail.com": "zmoravec@redhat.com",
    # Nathan Peters
    "nathan@nathanpeters.com": "Nathaniel.Peters@ca.com",
    "petna01@ca.com": "Nathaniel.Peters@ca.com",
    # Vojtech Polasek
    "Vojtech.Polasek@gmail.com": "vpolasek@redhat.com",
    "krecoun@gmail.com": "vpolasek@redhat.com",
    # Martin Preisler
    "martin@preisler.me": "mpreisle@redhat.com",
    # Robin Price II
    "rprice@users.noreply.github.com": "robin@redhat.com",
    "rprice@redhat.com": "robin@redhat.com",
    # Dave / David Smith
    "dsmith@secure-innovations.net": "dsmith@eclipse.ncsc.mil",
    "dsmith@fornax.eclipse.ncsc.mil": "dsmith@eclipse.ncsc.mil",
    # Philippe Thierry
    "phil@internal.reseau-libre.net": "phil@reseau-libre.net",
    "philippe.thierry@reseau-libre.net": "phil@reseau-libre.net",
    "philippe.thierry@thalesgroup.com": "phil@reseau-libre.net",
    # Shawn Wells
    "shawn@localhost.localdomain": "shawn@redhat.com",
    "shawnw@localhost.localdomain": "shawn@redhat.com",
    "shawndwells@gmail.com": "shawn@redhat.com",

    # No idea / ignore
    "lyd@chippy.(none)": "",
    "nick@null.net": "",
    "root@localhost.localdomain": "",
    "root@rhel6.(none)": "",
}

name_mappings = {
    "Gabe": "Gabe Alford",
    "Olivier": "Olivier Bonhomme",
    "OnceUponALoop": "Firas AlShafei",
    "lkinser": "Lee Kinser",
}


def _get_contributions_by_canonical_email(output):
    contributions_by_email = collections.defaultdict(list)
    for line in output.split("\n"):
        match = re.match(r"[\s]*([0-9]+)\s+(.+)\s+\<(.+)\>", line)
        if match is None:
            continue

        commits_count, author_name, email = match.groups()

        canonical_email = email_mappings.get(email, email)

        if canonical_email == "":
            continue  # ignored

        contributions_by_email[canonical_email].append((int(commits_count), author_name))
    return contributions_by_email


def _get_name_used_most_in_contributions(contribution_sets):
    _, name_used_most = sorted(contribution_sets, reverse=True)[0]
    return name_used_most


def _get_contributor_email_mapping(contributions_by_email):
    contributors = {}
    for email in contributions_by_email:
        name_used_most = _get_name_used_most_in_contributions(contributions_by_email[email])
        canonical_name_used_most = name_mappings.get(name_used_most, name_used_most)

        contributors[canonical_name_used_most] = email
    return contributors


def _names_sorted_by_last_name(names):
    return sorted(names, key=lambda x: tuple(n.upper() for n in x.split(" "))[::-1])


def generate():
    output = subprocess_check_output(["git", "shortlog", "-se"]).decode("utf-8")
    contributions_by_email = _get_contributions_by_canonical_email(output)
    contributors = _get_contributor_email_mapping(contributions_by_email)

    contributors_md = "<!---%s--->\n\n" % MANUAL_EDIT_WARNING
    contributors_md += \
        "The following people have contributed to the SCAP Security Guide project\n"
    contributors_md += "(listed in alphabetical order):\n\n"

    contributors_xml = "<!--%s-->\n\n" % MANUAL_EDIT_WARNING
    contributors_xml += "<text>\n"

    for name in _names_sorted_by_last_name(list(contributors.keys())):
        email = contributors[name]
        contributors_md += "* %s <%s>\n" % (name, email)
        contributors_xml += "<contributor>%s &lt;%s&gt;</contributor>\n" % (name, email)

    contributors_xml += "</text>\n"

    return contributors_md, contributors_xml
