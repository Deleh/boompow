import sys
import logging
from logging.handlers import WatchedFileHandler, TimedRotatingFileHandler


class WatchedTimedRotatingFileHandler(TimedRotatingFileHandler, WatchedFileHandler):
    def __init__(self, filename, **kwargs):
        super().__init__(filename, **kwargs)
        self.dev, self.ino = -1, -1
        self._statstream()

    def emit(self, record):
        self.reopenIfNeeded()
        super().emit(record)


def get_logger():
    logger = logging.getLogger("bpow")
    logger.setLevel(logging.DEBUG)
    stream = logging.StreamHandler(stream=sys.stdout)
    stream.setFormatter(
        logging.Formatter("%(asctime)s %(levelname)s: %(message)s", "%H:%M:%S")
    )
    stream.setLevel(logging.INFO)
    logger.addHandler(stream)
    return logger
