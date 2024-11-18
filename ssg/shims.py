from __future__ import absolute_import
from __future__ import print_function

import subprocess

try:
    import queue as Queue
except ImportError:
    import Queue


def subprocess_check_output(*popenargs, **kwargs):
    """
    Run command with arguments and return its output as a byte string.

    This function is a backport of subprocess.check_output from Python 2.7 standard library,
    compatible with BSD-3.

    Args:
        *popenargs: Variable length argument list to pass to subprocess.Popen.
        **kwargs: Arbitrary keyword arguments to pass to subprocess.Popen.

    Returns:
        bytes: The output of the command.

    Raises:
        subprocess.CalledProcessError: If the command exits with a non-zero status.
    """
    # Backport of subprocess.check_output taken from
    # https://gist.github.com/edufelipe/1027906
    #
    # Originally from Python 2.7 stdlib under PSF, compatible with BSD-3
    # Copyright (c) 2003-2005 by Peter Astrand <astrand@lysator.liu.se>
    # Changes by Eduardo Felipe

    process = subprocess.Popen(stdout=subprocess.PIPE, *popenargs, **kwargs)
    output, unused_err = process.communicate()
    retcode = process.poll()
    if retcode:
        cmd = kwargs.get("args")
        if cmd is None:
            cmd = popenargs[0]
        error = subprocess.CalledProcessError(retcode, cmd)
        error.output = output
        raise error
    return output


if hasattr(subprocess, "check_output"):
    # if available we just use the real function
    subprocess_check_output = subprocess.check_output


def input_func(prompt=None):
    try:
        return str(raw_input(prompt))
    except NameError:
        return input(prompt)


unicode_func = str
try:
    unicode_func = unicode
except NameError:
    pass
