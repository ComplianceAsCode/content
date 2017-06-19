import logging
import os
import os.path

log = logging.getLogger('SSGTestSuite')
__formatter = logging.Formatter('%(levelname)s - %(message)s')
log.setLevel(logging.DEBUG)

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
