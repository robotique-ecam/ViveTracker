import pandas as pd
import numpy as np

from copy import deepcopy

freq = 12e6
#csv_doc = "../data/12MHz_100ms"
csv_doc = "test"

period = 1/freq

df = pd.read_csv(f"{csv_doc}.csv", dtype={"Time [s]": np.float64})

indexes_0_channel_0 = []
tmp_list_storing_low_state = []

previous_channel_0_state = df["Channel 0"][0]

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
