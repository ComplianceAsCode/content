from __future__ import print_function
import logging
import os
import os.path
import sys

logging.getLogger(__name__).addHandler(logging.NullHandler())


class LogHelper(object):
    """Provide focal point for logging. LOG_DIR is useful when output of script
    is saved into file. Log preloading is a way to log outcome before
    the output itself.
    """
    FORMATTER = logging.Formatter('%(levelname)s - %(message)s')
    INTERMEDIATE_LOGS = {'pass': [], 'fail': [], 'notapplicable': []}
    LOG_DIR = None
    LOG_FILE = None

    @staticmethod
    def find_name(original_path, suffix=""):
        """Find file name which is still not present in given directory

        Returns
        path -- original_path + number + suffix
        """
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
        """Convenience function to set defaults for console logger"""
        console_handler = logging.StreamHandler()
        console_handler.setFormatter(cls.FORMATTER)
        console_handler.setLevel(level)
        print('Setting console output to log level {0}'.format(level,
                                                               sys.stderr))
        logger.addHandler(console_handler)

    @classmethod
    def add_logging_dir(cls, logger, _dirname):
        """Convenience function to set default logging into file.

        Also sets LOG_DIR and LOG_FILE
        """
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
        """Save log for later use. Fill named buffer `log_target`with the log
        line for later use.

        Special case:
        If `log_target` is default, i.e. None, all buffers will be filled with
        the same log line.
        """

        if log_target is None:
            # None means "All"
            for target in cls.INTERMEDIATE_LOGS:
                cls.INTERMEDIATE_LOGS[target] += [(log_level, log_line)]
        else:
            cls.INTERMEDIATE_LOGS[log_target] += [(log_level, log_line)]

    @classmethod
    def log_preloaded(cls, log_target):
        """Log messages preloaded in one of the named buffers. Wipe out all
        buffers afterwards.
        """
        for log_level, log_line in cls.INTERMEDIATE_LOGS[log_target]:
            logging.log(log_level, log_line)
        # cleanup
        for target in cls.INTERMEDIATE_LOGS:
            cls.INTERMEDIATE_LOGS[target] = []
