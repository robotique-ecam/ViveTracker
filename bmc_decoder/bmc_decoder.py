#!/usr/bin/env python3


""" BMC decoder package """


import pandas as pd
import numpy as np

from copy import deepcopy

freq = 12e6
#csv_doc = "../data/12MHz_100ms"
csv_doc = "test"

period = 1/freq

class BMC_decoder:
    """Biphase Mark Code decoder class from data extracted from Logic 2 software."""

    def __init__(self, csv_path: str):
        self.period = 1/(12e6)
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
            ts = self.time_column[borders_indexes[0]] + 1e-8 #adding 10ns to be sure to fall into an established new state (each state is 83ns at 12MHz)
            # Note: the time deviation between captures isn't high enough to interfere with the period in this algorithm

            while ts < self.time_column[borders_indexes[1]]:
                potential_bmc.append(self.data_column[state_index])
                ts += self.period

                if ts > self.time_column[state_index+1]:
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
                        if pot_bmc[i] == pot_bmc[i+1]:
                            validity_indexes.append([i])
                            start = True
                            skip = True
                    else:
                        if pot_bmc[i+1] == pot_bmc[i+2]:
                            if i-1 - validity_indexes[-1][0] < self.min_bit_required*2:
                                validity_indexes.pop(-1)
                            else:
                                validity_indexes[-1].append(i-1)
                            start = False
                        else:
                            skip = True
                else:
                    skip = False

            if len(validity_indexes[-1]) == 1:
                if len(pot_bmc) - validity_indexes[-1][0] > self.min_bit_required*2:
                    validity_indexes[-1].append(len(pot_bmc))
                else:
                    validity_indexes.pop(-1)

            self.bmc_beams_indexes.append(validity_indexes)

    def __str__(self):
        string = "BMC decoder:\n"

        if hasattr(self, 'indexes_0_envelope'):
            string += "\nindexes of envelope at low state ([start, end]):\n"
            for i in range(len(self.indexes_0_envelope)):
                string += f"\tBeam n°{i}: "
                string += str(self.indexes_0_envelope[i])
                string += "\n"

        if hasattr(self, 'bmc_beams_indexes'):
            string += "\nindexes of valid bmc interval found per beam:\n"
            for i in range(len(self.bmc_beams_indexes)):
                string += f"\tBeam n°{i}: "
                string += str(self.bmc_beams_indexes[i])
                string += "\n"

        string += "\n"
        return string

#csv_doc = "../data/12MHz_100ms"
csv_doc = "test"

bmc_decoder = BMC_decoder(csv_doc)
bmc_decoder.envelope_0_finder()
bmc_decoder.periodic_filler()
bmc_decoder.get_valid_bmc_indexes()

print(bmc_decoder)
