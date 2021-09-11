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
