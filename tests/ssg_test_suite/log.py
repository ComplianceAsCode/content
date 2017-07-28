from __future__ import print_function
import logging
logging.getLogger(__name__).addHandler(logging.NullHandler())
import os
import os.path
import sys


class LogHelper(object):
    FORMATTER = logging.Formatter('%(levelname)s - %(message)s')
    INTERMEDIATE_LOGS = {'pass': [], 'fail': []}
    LOG_DIR = None
    LOG_FILE = None

    @classmethod
    def find_name(cls, original_path, suffix=""):
        log_number = 0
        # search for valid log directory, as we can run more than one
        # run per minute, first has only timestamp, rest has numbered suffix
        logging.debug("Searching for viable {0}{1}".format(original_path,
                                                           suffix))
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
        logging.debug("Found {0}".format(path))
        return path

    @classmethod
    def add_console_logger(cls, logger, level):
        console_handler = logging.StreamHandler()
        console_handler.setFormatter(cls.FORMATTER)
        console_handler.setLevel(level)
        print('Setting console output to log level {0}'.format(level,
                                                               sys.stderr))
        logger.addHandler(console_handler)

    @classmethod
    def add_logging_dir(cls, logger, _dirname):
        os.makedirs(_dirname)
        logfile = os.path.join(_dirname, 'test_suite.log')

        file_handler = logging.FileHandler(logfile)
        file_handler.setLevel(logging.DEBUG)
        file_handler.setFormatter(cls.FORMATTER)
        logger.info('Logging into {0}'.format(logfile))
        logger.addHandler(file_handler)
        cls.LOG_DIR = _dirname
        cls.LOG_FILE = logfile

    @classmethod
    def preload_log(cls, log_level, log_line, log_target=None):
        if log_target is None:
            # None means "All"
            for target in cls.INTERMEDIATE_LOGS:
                cls.INTERMEDIATE_LOGS[target] += [(log_level, log_line)]
        else:
            cls.INTERMEDIATE_LOGS[log_target] += [(log_level, log_line)]

    @classmethod
    def log_preloaded(cls, log_target):
        for log_level, log_line in cls.INTERMEDIATE_LOGS[log_target]:
            logging.log(log_level, log_line)
        # cleanup
        for target in cls.INTERMEDIATE_LOGS:
            cls.INTERMEDIATE_LOGS[target] = []
