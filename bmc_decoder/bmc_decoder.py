#!/usr/bin/env python3


""" BMC decoder package """

import sys

sys.path.append("../")

import pandas as pd
import numpy as np

from copy import deepcopy
from lfsr.constants import bmc_period


class SingleWord:
    """Single Word class is a class storing details of a 17 bit word from decoded BMC"""

    def __init__(self, waveform: list, start_timestamp: np.float64) -> None:
        if len(waveform) != 17:
            raise Exception("Illegal word size (!= 17)")
        self.waveform = waveform
        self.start_timestamp = start_timestamp
        self.data = self.__get_value_from_waveform()

    def __get_value_from_waveform(self) -> int:
        """Private function converting the waveform to the 17 bit int type data"""

        data = 0
        for i in range(len(self.waveform)):
            data = (self.waveform[-1 - i] << i) | data
        return data

    def __str__(self) -> str:
        string = f"waveform: {self.waveform}\n"
        string += f"start_timestamp {self.start_timestamp}\n"
        string += f"data:\n\t binary -> {bin(self.data)},\n\t hex -> {hex(self.data)},\n\t int -> {self.data}\n"
        return string


class SingleBeamBMC:
    """Single Beam Biphase Mark Code class storing data of valid bmc for this beam"""

    def __init__(self, waveform: list, start_timestamp: np.float64):
        self.values = waveform
        self.start_timestamp = start_timestamp


class BMC_decoder:
    """Biphase Mark Code decoder class from data extracted from Logic 2 software."""

    def __init__(self, csv_path: str):
        self.period = 1 / (12e6)
        self.min_bit_required = 17
        self.df = pd.read_csv(f"{csv_path}.csv", dtype={"Time [s]": np.float64})
        self.time_column = self.df["Time [s]"]
        self.envelope_column = self.df["Channel 0"]
        self.data_column = self.df["Channel 1"]

    def envelope_0_finder(self):
        """Function extracting indexes of the dataframe in which "envelope" (Channel 0) is 0
        storing array of array of indexes in self.indexes_0_envelope, ex:
        [[start_index_0, end_index_0], [start_index_1, end_index_1], [start_index_2, end_index_2]]"""

        self.indexes_0_envelope = []
        tmp_list_storing_low_state = []
        previous_envelope_state = self.envelope_column[0]

        for i in range(len(self.envelope_column)):
            envelope_state = self.envelope_column[i]

            if envelope_state != previous_envelope_state:
                tmp_list_storing_low_state.append(i)

                if envelope_state == 1:
                    self.indexes_0_envelope.append(deepcopy(tmp_list_storing_low_state))
                    tmp_list_storing_low_state.clear()

            previous_envelope_state = envelope_state

    def periodic_filler(self):
        """Function filling an array periodically based instead of state changement based"""

        self.potential_bmcs = []

        for borders_indexes in self.indexes_0_envelope:
            potential_bmc = []
            state_index = borders_indexes[0]
            ts = (
                self.time_column[borders_indexes[0]] + 1e-8
            )  # adding 10ns to be sure to fall into an established new state (each state is 83ns at 12MHz)
            # Note: the time deviation between captures isn't high enough to interfere with the period in this algorithm

            while ts < self.time_column[borders_indexes[1]]:
                potential_bmc.append(self.data_column[state_index])
                ts += self.period

                if ts > self.time_column[state_index + 1]:
                    state_index += 1

            self.potential_bmcs.append(potential_bmc)

    def get_valid_bmc_indexes(self):
        """Looking for bmc validity through each element of self.potential_bmcs.
        Store valid interval indexes into self.bmc_beams_indexes"""

        self.bmc_beams_indexes = []

        for pot_bmc in self.potential_bmcs:
            validity_indexes = []
            start = False
            skip = False

            for i in range(len(pot_bmc) - 2):
                if not skip:
                    if not start:
                        if pot_bmc[i] == pot_bmc[i + 1]:
                            validity_indexes.append([i])
                            start = True
                            skip = True
                    else:
                        if pot_bmc[i + 1] == pot_bmc[i + 2]:
                            if (
                                i - 1 - validity_indexes[-1][0]
                                < self.min_bit_required * 2
                            ):
                                validity_indexes.pop(-1)
                            else:
                                validity_indexes[-1].append(i - 1)
                            start = False
                        else:
                            skip = True
                else:
                    skip = False
            if (len(validity_indexes)) != 0:
                if len(validity_indexes[-1]) == 1:
                    if (
                        len(pot_bmc) - validity_indexes[-1][0]
                        > self.min_bit_required * 2
                    ):
                        validity_indexes[-1].append(len(pot_bmc))
                    else:
                        validity_indexes.pop(-1)

            self.bmc_beams_indexes.append(validity_indexes)

    def decode_bmc(self):
        """Decode self.potential_bmcs considering indexes given by self.bmc_beams_indexes
        decoding algorithm: goes through the self.potential_bmcs[single_beam_bmc_indexes] list by a step of 2
        checks the value of the next index: if it's the same value, the decoded value is 0, else 1"""

        self.decoded_bmc = []

        for single_beam_bmc_indexes in range(len(self.bmc_beams_indexes)):
            single_beam_decoded_bmc = []

            for bmc_beam_index in self.bmc_beams_indexes[single_beam_bmc_indexes]:
                bmc_decoded = []

                for i in range(bmc_beam_index[0] + 1, bmc_beam_index[1], 2):
                    potential_bmc_this_beam = self.potential_bmcs[
                        single_beam_bmc_indexes
                    ]

                    if (
                        potential_bmc_this_beam[i] == potential_bmc_this_beam[i - 1]
                    ):  # not i+1 to avoid "out of range"
                        bmc_decoded.append(0)
                    else:
                        bmc_decoded.append(1)

                single_beam_decoded_bmc.append(bmc_decoded)

            self.decoded_bmc.append(single_beam_decoded_bmc)

    def __str__(self):
        string = "BMC decoder:\n"

        if hasattr(self, "indexes_0_envelope"):
            string += "\nindexes of envelope at low state ([start, end]):\n"
            for i in range(len(self.indexes_0_envelope)):
                string += f"\tBeam n°{i}: "
                string += str(self.indexes_0_envelope[i])
                string += "\n"

        if hasattr(self, "bmc_beams_indexes"):
            string += "\nindexes of valid bmc interval found per beam:\n"
            for i in range(len(self.bmc_beams_indexes)):
                string += f"\tBeam n°{i}: "
                string += str(self.bmc_beams_indexes[i])
                string += "\n"

        if hasattr(self, "decoded_bmc"):
            string += (
                "\nDecoded Biphase Mark Code availible in object.decoded_bmc list\n"
            )

        string += "\n"
        return string

    def decode_whole_document(self):
        """Call all functions in order to get the decoded object state"""

        self.envelope_0_finder()
        self.periodic_filler()
        self.get_valid_bmc_indexes()
        self.decode_bmc()

    def get_timestamp_from_index(
        self, beam: int, index: int, first_word: bool
    ) -> np.float64:
        """Function returning timestamp of a given beam an periodic index of this beam"""

        return (
            self.time_column[self.indexes_0_envelope[beam][0]]
            + (
                index
                + (self.min_bit_required if first_word else -self.min_bit_required)
            )
            * bmc_period
        )

    def get_first_and_last_word_from_beam(self, beam: int) -> list[SingleWord]:
        """Returns the first and last decoded words of a given beam"""

        if len(self.decoded_bmc[beam]) != 0:
            return [
                SingleWord(
                    self.decoded_bmc[beam][0][:17],
                    self.get_timestamp_from_index(
                        beam, self.bmc_beams_indexes[beam][0][0], True
                    ),
                ),
                SingleWord(
                    self.decoded_bmc[beam][-1][-17:],
                    self.get_timestamp_from_index(
                        beam, self.bmc_beams_indexes[beam][-1][-1], False
                    ),
                ),
            ]
        else:
            print(f"Unable to get words on beam {beam}")
            return None
