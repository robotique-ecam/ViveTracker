import sys

sys.path.append("../")

from bmc_decoder.bmc_decoder import BMC_decoder
from polynomial_finder import SynthetizedBeamsAnalyzed, PolynomialIdentifier

bmc_decoder = BMC_decoder("../data/12MHz_2000ms")
bmc_decoder.decode_whole_document()

synthesis = SynthetizedBeamsAnalyzed()

for i in range(len(bmc_decoder.indexes_0_envelope)):
    words = bmc_decoder.get_first_and_last_word_from_beam(i)
    if words != None:
        polynomial_identifier1 = PolynomialIdentifier(words[0], words[1])
        synthesis.add_beam(polynomial_identifier1.search_polynomial())

synthesis.save_synthesis("synthesis.txt")
