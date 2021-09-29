import sys

sys.path.append("../")

import numpy as np

from bmc_decoder.bmc_decoder import BMC_decoder, SingleWord
from lfsr.lfsr import LFSR
from lfsr.constants import polys, data_period, lfsr_iteration_approx, bmc_period


class BeamAnalyzed:
    def __init__(
        self, iteration_estim_2_words: int, lfsr=None, iteration_2_words=-1
    ) -> None:
        self.beam_number = -1
        self.iteration_estim_2_words = iteration_estim_2_words

        if lfsr != None and iteration_2_words != -1:
            self.polynomial = lfsr.poly
            real_iteration_lfsr = LFSR(lfsr.poly)
            self.lfsr_iteration = real_iteration_lfsr.cpt_for(lfsr.start)
            self.iteration_2_words = iteration_2_words

    def is_messy(self) -> bool:
        return not hasattr(self, "polynomial")

    def __str__(self) -> str:
        string = f"Beam n°{self.beam_number}\n"

        if hasattr(self, "polynomial"):
            string += f"\tPolynomial of this beam: {hex(self.polynomial)}\n"
            string += f"\tNumber of LFSR iterations: {self.lfsr_iteration}\n\n"
        else:
            string += "No polys found for this beam\n"

        string += f"\tEstimated LFSR iterations between 2 words analyzed: {self.iteration_estim_2_words}\n"

        if hasattr(self, "iteration_2_words"):
            string += f"\tReal LFSR iterations between 2 words analyzed: {self.iteration_2_words}\n\n"
        return string


class SynthetizedBeamsAnalyzed:
    def __init__(self) -> None:
        self.cleanAnalyzedBeams = []
        self.messyAnalyzedBeams = []
        self.polynomials_used = {}

    def __number_of_beam(self) -> int:
        return len(self.cleanAnalyzedBeams) + len(self.messyAnalyzedBeams)

    def add_beam(self, beamsAnalyzed: list[BeamAnalyzed]):
        beam_number = self.__number_of_beam()
        for beam in beamsAnalyzed:
            beam.beam_number = beam_number
            if beam.is_messy():
                self.messyAnalyzedBeams.append(beam)
            else:
                if hex(beam.polynomial) in self.polynomials_used:
                    self.polynomials_used[hex(beam.polynomial)] += 1
                else:
                    self.polynomials_used[hex(beam.polynomial)] = 1
                self.cleanAnalyzedBeams.append(beam)

    def save_synthesis(self, path: str) -> None:
        text_file = open(path, "w")
        text_file.write(self.__str__())
        text_file.close()
        print(f"Synthesis saved in {path}")

    def __str__(self) -> str:
        string = ""
        if len(self.cleanAnalyzedBeams) != 0:
            string += "Clean analysed beam\n"
            for i in self.cleanAnalyzedBeams:
                string += str(i)
        if len(self.messyAnalyzedBeams) != 0:
            string += "Messy analysed beam\n"
            for i in self.messyAnalyzedBeams:
                string += str(i)
        if hasattr(self, "polynomials_used"):
            string += "\nPolynomials used:\n"
            for key in self.polynomials_used.keys():
                string += f"\t-Polynomial: {key}, number of time found: {self.polynomials_used[key]}\n"
        number_of_sweeps = self.__number_of_beam()
        string += f"\nNumber of sweep: {number_of_sweeps}:\n"
        string += f"\tNumber of sweep fully analyzed: {len(self.cleanAnalyzedBeams)}, ({round((len(self.cleanAnalyzedBeams)/number_of_sweeps)*100)}%):\n"
        string += f"\tNumber of sweep not clean for analysis: {len(self.messyAnalyzedBeams)}, ({round((len(self.messyAnalyzedBeams)/number_of_sweeps)*100)}%):\n"
        return string


class PolynomialIdentifier:
    def __init__(self, first_word: SingleWord, second_word: SingleWord) -> None:
        self.w_1 = first_word
        self.w_2 = second_word
        self.iteration_estimation = self.__iteration_estimator()

    def __find_diff_timestamp(self) -> np.float64:
        return abs(self.w_1.start_timestamp - self.w_2.start_timestamp)

    def __iteration_estimator(self) -> int:
        diff_ts = self.__find_diff_timestamp()
        return int(diff_ts / data_period)

    def __init_LFSRs(self) -> list[LFSR]:
        initial_LFSR_value = (
            self.w_1.data
            if self.w_1.start_timestamp < self.w_2.start_timestamp
            else self.w_2.data
        )
        return [LFSR(poly, initial_LFSR_value) for poly in polys]

    def search_polynomial(self) -> list[BeamAnalyzed]:
        found_polys = []
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
                    found_polys.append(
                        BeamAnalyzed(
                            self.iteration_estimation,
                            lfsr=lfsr,
                            iteration_2_words=lfsr.cpt_for(final_LFSR_value),
                        )
                    )
        if len(found_polys) == 0:
            found_polys.append(BeamAnalyzed(self.iteration_estimation))

        return found_polys


bmc_decoder = BMC_decoder("../data/12MHz_100ms")
bmc_decoder.decode_whole_document()

print(bmc_decoder)

synthesis = SynthetizedBeamsAnalyzed()

for i in range(len(bmc_decoder.indexes_0_envelope)):
    words = bmc_decoder.get_first_and_last_word_from_beam(i)
    if words != None:
        polynomial_identifier1 = PolynomialIdentifier(words[0], words[1])
        synthesis.add_beam(polynomial_identifier1.search_polynomial())

print(synthesis)
