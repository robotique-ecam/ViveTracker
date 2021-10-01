"""
Polynomials used in all base station 2.0
2 polynomials for 1 mode/channel ex: if you identifiate polynomial at index polys[1] it means that your base station is in mode 1
generalization: channel of the base station = int(nPoly / 2) + 1 (nPoly = index of the polys you identifiate)
"""
polys = [
    0x0001D258,
    0x00017E04,
    0x0001FF6B,
    0x00013F67,
    0x0001B9EE,
    0x000198D1,
    0x000178C7,
    0x00018A55,
    0x00015777,
    0x0001D911,
    0x00015769,
    0x0001991F,
    0x00012BD0,
    0x0001CF73,
    0x0001365D,
    0x000197F5,
    0x000194A0,
    0x0001B279,
    0x00013A34,
    0x0001AE41,
    0x000180D4,
    0x00017891,
    0x00012E64,
    0x00017C72,
    0x00019C6D,
    0x00013F32,
    0x0001AE14,
    0x00014E76,
    0x00013C97,
    0x000130CB,
    0x00013750,
    0x0001CB8D,
]

# period number based on a 48MHz clock
periods = [
    959000,
    957000,
    953000,
    949000,
    947000,
    943000,
    941000,
    939000,
    937000,
    929000,
    919000,
    911000,
    907000,
    901000,
    893000,
    887000,
]

data_frequency = 6e6
bmc_frequency = 2 * data_frequency

data_period = 1 / data_frequency
bmc_period = 1 / bmc_frequency

lfsr_iteration_approx = 3
