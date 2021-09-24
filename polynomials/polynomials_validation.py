import sys
sys.path.append('../')

from lfsr.lfsr import LFSR
from lfsr.constants import polys
from datetime import datetime

polynomial_to_analysis = polys[3]

class SameValue:
    def __init__(self, value, index1, index2) -> None:
        self.value = value
        self.indexes = [index1, index2]
    
    def __eq__(self, o: object) -> bool:
        if self.value != o.value:
            return False
        if o.indexes[0] in self.indexes and o.indexes[1] in self.indexes:
            return True
        return False

    def __str__(self) -> str:
        return f"{self.value} at index {self.indexes[0]} and {self.indexes[1]}"

lfsr = LFSR(polynomial_to_analysis)
pos = [1]

for i in range(2**17):
    pos.append(lfsr.next())

pourcent = 0
initial_time = saved_time = datetime.now()        
same_values = []

for i in range(len(pos)):
    if (i/len(pos) > pourcent + 0.05):
        pourcent += 0.05
        saved_time = datetime.now()
        time_diff = (saved_time - initial_time).total_seconds()
        estimated_time_remaining = time_diff * ( 1 / pourcent - 1 )
        print(f"{round(pourcent*100)}% done, elapsed time: {round(time_diff/60, 1)} minutes, estimated remaining time: {round(estimated_time_remaining/60, 1)} minutes")

    for j in range(len(pos)):
        if pos[i]==pos[j] and i != j:
            potential_same_value = SameValue(pos[i], i, j)
            if potential_same_value not in same_values:
                same_values.append(potential_same_value)
                print(f"Same value detected: " + str(potential_same_value))


to_print = "Same value of polynomial " + hex(polynomial_to_analysis) + ":\n"
for i in same_values:
    to_print += str(i) + '\n'

print(to_print)

"""
Results:

Mode 1:
    Same value of polynomial 0x1D258:
        1 at index 0 and 131071
        2 at index 1 and 131072

    Same value of polynomial 0x17e04:
        1 at index 0 and 131071
        2 at index 1 and 131072


Mode2:
    Same value of polynomial 0x1ff6b:
        1 at index 0 and 131071
        3 at index 1 and 131072

    Same value of polynomial 0x13f67:
        1 at index 0 and 131071
        3 at index 1 and 131072


Mode3:
    Same value of polynomial 0x1b9ee:
        1 at index 0 and 131071
        2 at index 1 and 131072

    Same value of polynomial 0x198d1:
        1 at index 0 and 131071
        3 at index 1 and 131072


Mode4:
    Same value of polynomial 0x178c7:
        1 at index 0 and 131071
        3 at index 1 and 131072

    Same value of polynomial 0x18a55:
        1 at index 0 and 131071
        3 at index 1 and 131072


Mode5:
    Same value of polynomial 0x15777:
        1 at index 0 and 131071
        3 at index 1 and 131072

    Same value of polynomial 0x1d911:
        1 at index 0 and 131071
        3 at index 1 and 131072


Mode6:
    Same value of polynomial 0x15769:
        1 at index 0 and 131071
        3 at index 1 and 131072

    Same value of polynomial 0x1991f:
        1 at index 0 and 131071
        3 at index 1 and 131072


Mode7:
    Same value of polynomial 0x12bd0:
        1 at index 0 and 131071
        2 at index 1 and 131072

    Same value of polynomial 0x1cf73:
        1 at index 0 and 131071
        3 at index 1 and 131072


Mode8:
    Same value of polynomial 0x1365d:
        1 at index 0 and 131071
        3 at index 1 and 131072

    Same value of polynomial 0x197f5:
        1 at index 0 and 131071
        3 at index 1 and 131072


Mode9:
    Same value of polynomial 0x194a0:
        1 at index 0 and 131071
        2 at index 1 and 131072

    Same value of polynomial 0x1b279:
        1 at index 0 and 131071
        3 at index 1 and 131072


Mode10:
    Same value of polynomial 0x13a34:
        1 at index 0 and 131071
        2 at index 1 and 131072

    Same value of polynomial 0x1ae41:
        1 at index 0 and 131071
        3 at index 1 and 131072


Mode11:
    Same value of polynomial 0x180d4:
        1 at index 0 and 131071
        2 at index 1 and 131072

    Same value of polynomial 0x17891:
        1 at index 0 and 131071
        3 at index 1 and 131072


Mode12:
    Same value of polynomial 0x12e64:
        1 at index 0 and 131071
        2 at index 1 and 131072

    Same value of polynomial 0x17c72:
        1 at index 0 and 131071
        2 at index 1 and 131072


Mode13:
    Same value of polynomial 0x19c6d:
        1 at index 0 and 131071
        3 at index 1 and 131072

    Same value of polynomial 0x13f32:
        1 at index 0 and 131071
        2 at index 1 and 131072


Mode14:
    Same value of polynomial 0x1ae14:
        1 at index 0 and 131071
        2 at index 1 and 131072

    Same value of polynomial 0x14e76:
        1 at index 0 and 131071
        2 at index 1 and 131072


Mode15:
    Same value of polynomial 0x13c97:
        1 at index 0 and 131071
        3 at index 1 and 131072

    Same value of polynomial 0x130cb:
        1 at index 0 and 131071
        3 at index 1 and 131072


Mode16:
    Same value of polynomial 0x13750:
        1 at index 0 and 131071
        2 at index 1 and 131072

    Same value of polynomial 0x1cb8d:
        1 at index 0 and 131071
        3 at index 1 and 131072
"""