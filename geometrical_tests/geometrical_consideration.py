import sys
import numpy as np

sys.path.append("../")

from bmc_decoder.bmc_decoder import SingleWord
from polynomials.polynomial_finder import PolynomialIdentifier
from timestamp_computing import TimestampComputing
from lfsr.lfsr import LFSR
from lh_geometry import LH2Geometry, Point
from datetime import datetime

"""
words = [[0x006BD3, 0x820257], [0x002435, 0x8AA081]] #1600, 0
words = [[0x007FFF, 0x99DCAE], [0x01107C, 0x9EC059]] #700, 0
words = [[0x0035B6, 0x972C5B], [0x005ADA, 0x9FF167]] #1600, 800
words = [[0x00D430, 0x550232], [0x00848A, 0x5DBB7D]] #1600, -800
00 00 D4 - 30 00 55 02 32 00 00 84    E.@w....  0.U.2...
8A 00 5D BB 7D
"""
clock_frequency = 96e6

words = [[0x0035B6, 0x972C5B], [0x005ADA, 0x9FF167]]  # 1600, 800

now = datetime.now()
first_word = SingleWord(
    waveform=[], start_timestamp=words[0][1] / clock_frequency, data=words[0][0]
)
second_word = SingleWord(
    waveform=[], start_timestamp=words[1][1] / clock_frequency, data=words[1][0]
)

identifier = PolynomialIdentifier(first_word, second_word, first_two_polys=True)
resulting_polys = identifier.search_polynomial()
later = datetime.now()

for i in resulting_polys:
    print(i)

print((later - now).total_seconds())
if not hasattr(resulting_polys[0], "polynomial"):
    exit()
poly = resulting_polys[0].polynomial
print(hex(poly))


lfsr = LFSR(poly)

first_iteration = lfsr.cpt_for(words[0][0])
second_iteration = lfsr.cpt_for(words[1][0])

print(f"iteration1 {first_iteration} iteration2 {second_iteration}")
geometry = LH2Geometry()

a_e = geometry.get_azimuth_elevation_from_iteration(first_iteration, second_iteration)

print(a_e[0] * 180 / np.pi)
print(a_e[1] * 180 / np.pi)

lh2_coords = Point(x=365, y=0, z=323.5)
sensor_coords = Point(x=1600, y=800, z=20)

needed_azimuth = np.arccos(
    np.sqrt(
        ((lh2_coords.x - sensor_coords.x) ** 2)
        / (
            (lh2_coords.x - sensor_coords.x) ** 2
            + (lh2_coords.y - sensor_coords.y) ** 2
        )
    )
)
needed_elevation = np.arccos(
    np.sqrt(
        (
            (lh2_coords.x - sensor_coords.x) ** 2
            + ((lh2_coords.y - sensor_coords.y) ** 2)
        )
        / (
            (lh2_coords.x - sensor_coords.x) ** 2
            + (lh2_coords.y - sensor_coords.y) ** 2
            + (lh2_coords.z - sensor_coords.z) ** 2
        )
    )
)

print(f"needed_azimuth {needed_azimuth*180/np.pi}")
print(f"needed_elevation {needed_elevation*180/np.pi}")

print(229.02757038581862 - 90 - 26.68681060186392 + 6.333335383537537)
