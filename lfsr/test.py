from lfsr import LFSR

lfsr = LFSR(0x1D258, 1)

for _ in range(65789):
    print(hex(lfsr.next()))
