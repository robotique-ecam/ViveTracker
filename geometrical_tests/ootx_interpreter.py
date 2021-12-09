slow_ootx_bits = "00000000000000000100 010  000000001 0001000000010001011101 01100 0111011001001100110110000000000000000110010110000 0001110111000101010101110000 00010100110000000 00001111100010100 0100110 1000001000 10 1    1111100111111 100000000  0 00010 1 1100000101011001 1110100010111100110111 001010110011101 00000001000000001110010010011011000001010 00111110001000101001011110   10101001100001 0 0100 100001010000000011110000011101000100000 0111110010 0000000000000000010010 0110000000011000 00000001000101110110 100101 10 100 001100110110000000000000000110010 1000010001110 1100010 010101110000100010100110000000 000011 11000 0100101001101 0000010001101111111111100 11111110000000011011000100 1110000010101 001111101000101 1 00110111 001010110011 0 1000000010000000011100 001001101100000 0101001111100010001010010 11101101010100 100 01 010100110000101000000001111000001110100010000010111 10010100000000000000000100101011000000001 000100000001000 011101101100101110 1001001100110110000000000000000110 1011000010001110111000101010101110000100010100110000000 000011111000101001010011011000001 001 01111111 1110011111111000000001101 00010011110000010101100  111010001011 1001 011 10010101 0011 0110000000100000000 11001001001101 0000010 01001111100010001010010111101101010 0011000011010100110000101000000001111000001110 00010000010 11 1001010000000000000000010010101100000 00 10001000000010001011101101100101110110010011001101100000000000000001100101100001000111011100010 010101110000100010100110000000100001111100010100101001 011000001000110111111 1 11001 1 11 100000000110110001001  10000010101100111110100010111100110111 0010101100 110 10000  01000000 0111001 0100 101100000101 1001111100010001 10010 111 11010101001 00001101010011000010100000000 111000001 10 00010000010 11 100101000000000000000001001010 10000000 110001000000010001011101101100 01110 1001001100  011000 0000000000001100 0 10000100011101 1000101010101110 001000 0100110000000 00001111 0001010010100110110 000 000110 1"

number_of_bits = 443

print(slow_ootx_bits[:number_of_bits])
print()
print(slow_ootx_bits[number_of_bits:2*number_of_bits])
print()
print(slow_ootx_bits[2*number_of_bits:3*number_of_bits])
print()
print(slow_ootx_bits[3*number_of_bits:4*number_of_bits])
print()
print(slow_ootx_bits[4*number_of_bits:5*number_of_bits])
print()

ootx1 = slow_ootx_bits[number_of_bits:2*number_of_bits]
ootx2 = slow_ootx_bits[2*number_of_bits:3*number_of_bits]
ootx3 = slow_ootx_bits[3*number_of_bits:4*number_of_bits]

full_ootx = ""

for i in range(len(ootx1)):
    if ootx1[i] != " ":
        full_ootx += ootx1[i]
    elif ootx2[i] != " ":
        full_ootx += ootx2[i]
    elif ootx3[i] != " ":
        full_ootx += ootx3[i]
    else:
        full_ootx += " "

print(full_ootx)

"""
full_ootx = "
000000000000000001
00101011000000001

10001000000010001 #fw_version
01110110110010111
01100100110011011 #id
00000000000000001 #focal_phase[0]
10010110000100011 #focal_phase[1]
10111000101010101 #focal_tilt[0]
11000010001010011 #focal_tilt[1]
00000001000011111 #sys_unlock_count / ootx_model
00010100101001101 #focal_curve[0]
10000010001101111 #focal_curve[1]
11111110011111111 #accel_dir[0] / accel_dir[1]
00000000110110001 #accel_dir[2] / focal_gibbous_phase[0]
00111100000101011 #focal_gibbous_phase[0] / focal_gibbous_phase[1]
00111110100010111 #focal_gibbous_phase[1] / focal_gibbous_magnitude[0]
10011011110010101 #focal_gibbous_magnetude[0] / focal_gibbous_magnetude[1]
10011101100000001 #focal_gibbous_magnetude[1] / mode_current
00000000111001001 #sys_faults / focal_ogee_phase[0]
00110110000010101 #focal_ogee_phase[0] / focal_ogee_phase[1]
00111110001000101 #focal_ogee_phase[1] / focal_ogee_magnitude[0]
00101111011010101 #focal_ogee_magnitude[0] / focal_ogee_magnitude[1]
00110000110101001 #focal_ogee_magnitude[1] / nonce
10000101000000001 #nonce / null

11100000111010001
0000010111 100101"
"""
