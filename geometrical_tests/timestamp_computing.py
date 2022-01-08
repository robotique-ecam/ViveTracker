import sys

sys.path.append("../")

from bmc_decoder.bmc_decoder import SingleWord
from polynomials.polynomial_finder import PolynomialIdentifier


class TimestampComputing:
    def __init__(self):
        self.fpga_frequency = 96e6

    def is_ts_overflowing(self, first_ts: int, second_ts: int) -> bool:
        if first_ts < second_ts:
            return False
        else:
            return True

    def compute_diff_between_ts(self, first_ts: int, second_ts: int) -> int:
        if not self.is_ts_overflowing(first_ts, second_ts):
            return second_ts - first_ts
        else:
            return 0xFFFFFF - first_ts + second_ts

    def get_real_time_ts(self, data: int) -> float:
        return data / self.fpga_frequency

    def get_ts_diff(self, first_ts: int, second_ts: int) -> float:
        diff_ts = self.compute_diff_between_ts(first_ts, second_ts)
        return self.get_real_time_ts(diff_ts)
