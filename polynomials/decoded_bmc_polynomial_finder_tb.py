import sys

sys.path.append("../")

from bmc_decoder.bmc_decoder import SingleWord
from polynomials.polynomial_finder import PolynomialIdentifier

data = [
    [0x0149D0, 0x9C586A],
    [0x01C8F9, 0xA3B827],
    [0x017949, 0xB99CF1],
    [0x016765, 0xC0FC1B],
    [0x01F75D, 0xD6E27E],
    [0x01C8F9, 0xDE4049],
    [0x017949, 0xF42514],
    [0x01B29F, 0xFB84AE],
    [0x0149D0, 0x1168A9],
    [0x0191F2, 0x18C872],
]

clock_frequency = 96e6

first_word = SingleWord(
    waveform=[], start_timestamp=0x9C388 / clock_frequency, data=0x2955
)
second_word = SingleWord(
    waveform=[], start_timestamp=0x9DE58 / clock_frequency, data=0x17B3D
)

identifier = PolynomialIdentifier(first_word, second_word)
resulting_polys = identifier.search_polynomial()
for i in resulting_polys:
    print(i)
