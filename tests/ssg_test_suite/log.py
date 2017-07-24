import logging
import os
import os.path

log = logging.getLogger('SSGTestSuite')
__formatter = logging.Formatter('%(levelname)s - %(message)s')
log.setLevel(logging.DEBUG)

__intermediate_logs = {'pass': [], 'fail': []}


def find_name(original_path, suffix=""):
    log_number = 0
    # search for valid log directory, as we can run more than one
    # run per minute, first has only timestamp, rest has numbered suffix
    log.debug("Searching for viable {0}{1}".format(original_path, suffix))
    while True:
        if not log_number:
            log_number_suffix = ""
        else:
            log_number_suffix = "-{0}".format(log_number)

        path = original_path + log_number_suffix + suffix
        if os.path.exists(path):
            log_number += 1
        else:
            break
    log.debug("Found {0}".format(path))
    return path


def add_console_logger(level):
    console_handler = logging.StreamHandler()
    console_handler.setFormatter(__formatter)
    console_handler.setLevel(level)
    log.addHandler(console_handler)


def add_logging_dir(_dirname):
    global log
    os.makedirs(_dirname)
    logfile = os.path.join(_dirname, 'test_suite.log')

    file_handler = logging.FileHandler(logfile)
    file_handler.setLevel(logging.DEBUG)
    file_handler.setFormatter(__formatter)
    log.info('Logging into {0}'.format(logfile))
    log.addHandler(file_handler)
    log.log_dir = _dirname
    log.logfile = logfile


def preload_log(log_level, log_line, log_target=None):
    if log_target is None:
        # None means "All"
        for target in __intermediate_logs:
            __intermediate_logs[target] += [(log_level, log_line)]
    else:
        __intermediate_logs[log_target] += [(log_level, log_line)]


def log_preloaded(log_target):
    for log_level, log_line in __intermediate_logs[log_target]:
        log.log(log_level, log_line)
    # cleanup
    for target in __intermediate_logs:
        __intermediate_logs[target] = []
