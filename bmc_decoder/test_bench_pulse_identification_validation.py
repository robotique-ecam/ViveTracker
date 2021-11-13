from bmc_decoder import BMC_decoder

bmc_decoder = BMC_decoder("test")

bmc_decoder.decode_whole_document()

words = bmc_decoder.get_first_and_last_word_from_beam(0)

for word in words:
    print(hex(int(word.start_timestamp * 96000000)))
    print(word)

print(words[1].start_timestamp - words[0].start_timestamp)
print((0x9DE58 - 0x9C388) / 96000000)
print(0x9DE58 - 0x9C388)

"""
first word: 0x2955,
ts: 0x9c388

second_word: 0x17b3d,
ts: 0x9de58

iteration between both: 429
polynomial: 1d258

iteration first: 45388
iteration second: 45817
"""
