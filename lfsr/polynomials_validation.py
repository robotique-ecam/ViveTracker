from lfsr import LFSR
from constants import polys
from datetime import datetime

polynomial_to_analysis = polys[0]

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

