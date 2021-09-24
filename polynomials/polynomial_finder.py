import sys
from typing import List

sys.path.append("../")

import numpy as np

from bmc_decoder.bmc_decoder import BMC_decoder, SingleWord
from lfsr.lfsr import LFSR
from lfsr.constants import polys, data_period, lfsr_iteration_approx, bmc_period


class Polynomial_identifier:
    def __init__(self, first_word: SingleWord, second_word: SingleWord) -> None:
        self.w_1 = first_word
        self.w_2 = second_word
        self.iteration_estimation = self.__iteration_estimator()
        print(f"estimated number of iteration {self.iteration_estimation}")

    def __find_diff_timestamp(self) -> np.float64:
        return abs(self.w_1.start_timestamp - self.w_2.start_timestamp)

    def __iteration_estimator(self) -> int:
        diff_ts = self.__find_diff_timestamp()
        print(f"diff_ts {diff_ts}")
        return int(diff_ts / data_period)

    def __init_LFSRs(self) -> list:
        initial_LFSR_value = (
            self.w_1.data
            if self.w_1.start_timestamp < self.w_2.start_timestamp
            else self.w_2.data
        )
        return [LFSR(poly, initial_LFSR_value) for poly in polys]

    def search_polynomial(self):
        lfsrs = self.__init_LFSRs()
        final_LFSR_value = (
            self.w_1.data
            if self.w_1.start_timestamp > self.w_2.start_timestamp
            else self.w_2.data
        )
        for lfsr in lfsrs:
            for _ in range(self.iteration_estimation - lfsr_iteration_approx):
                lfsr.next()
            for _ in range(2 * lfsr_iteration_approx):
                if lfsr.next() == final_LFSR_value:
                    print(f"{hex(lfsr.poly)} found")
                    print(f"cpt {lfsr.cpt_for(final_LFSR_value)}")

