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

    for i in range(len(pot_bmc) - 2):
        if not skip:
            if not start:
                if pot_bmc[i] == pot_bmc[i+1]:
                    validity_indexes.append([i])
                    start = True
                    skip = True
            else:
                if pot_bmc[i+1] == pot_bmc[i+2]:
                    if i-1 - validity_indexes[-1][0] < 17*2:
                        validity_indexes.pop(-1)
                    else:
                        validity_indexes[-1].append(i-1)
                    start = False
                else:
                    skip = True
        else:
            skip = False
    if len(validity_indexes[-1]) == 1:
        validity_indexes.pop(-1)


for i in range(len(df["Channel 0"])):
    channel_0_state = df["Channel 0"][i]
    if channel_0_state != previous_channel_0_state:
        tmp_list_storing_low_state.append(i)
        if channel_0_state == 1:
            indexes_0_channel_0.append(deepcopy(tmp_list_storing_low_state))
            tmp_list_storing_low_state.clear()
        print(i)
    previous_channel_0_state = channel_0_state

print(indexes_0_channel_0)

for low_state in indexes_0_channel_0:
    potential_bmc = []
    state = low_state[0]
    nb_of_period = ( df["Time [s]"][low_state[1]] - df["Time [s]"][low_state[0]] ) / period
    #print(f"nb of period in this low_state: {nb_of_period}")

    ts = df["Time [s]"][low_state[0]] + 1e-8
    while ts < df["Time [s]"][low_state[1]]:
        potential_bmc.append(df["Channel 1"][state])
        ts += period
        if ts > df["Time [s]"][state+1]:
            state += 1
    #print(potential_bmc)

    validity_indexes = []
    bmc_validity(potential_bmc, validity_indexes)
    print(validity_indexes)
