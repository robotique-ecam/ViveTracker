import numpy as np
import struct

fw_version = int(0b1000100000001000)  # fw_version
id = int(0b01110110110010110110010011001101)  # id
focal_phase_0_str = "0000000000000000"  # focal_phase[0]
focal_phase_1_str = "1001011000010001"  # focal_phase[1]
focal_tilt_0_str = "1011100010101010"  # focal_tilt[0]
focal_tilt_1_str = "1100001000101001"  # focal_tilt[1]
sys_unlock_count = int(0b00000001)  # sys_unlock_count
ootx_model = int(0b00001111)  # ootx_model
focal_curve_0_str = "0001010010100110"  # focal_curve[0]
focal_curve_1_str = "1000001000110111"  # focal_curve[1]
accel_dir_0 = int(0b11111110)  # accel_dir[0]
accel_dir_1 = int(0b01111111)  # accel_dir[1]
accel_dir_2 = int(0b00000000)  # accel_dir[2]
focal_gibbous_phase_0_str = "1101100000111100"  # focal_gibbous_phase[0]
focal_gibbous_phase_1_str = "0001010100111110"  # focal_gibbous_phase[1]
focal_gibbous_magnitude_0_str = "1000101110011011"  # focal_gibbous_magnitude[0]
focal_gibbous_magnitude_1_str = "1100101010011101"  # focal_gibbous_magnetude[1]
mode_current = int(0b10000000)  # mode_current
sys_faults = int(0b00000000)  # sys_faults
focal_ogee_phase_0_str = "1110010000110110"  # focal_ogee_phase[0]
focal_ogee_phase_1_str = "0000101000111110"  # focal_ogee_phase[1]
focal_ogee_magnitude_0_str = "0010001000101111"  # focal_ogee_magnitude[0]
focal_ogee_magnitude_1_str = "0110101000110000"  # focal_ogee_magnitude[1]
nonce = int(0b1101010010000101)  # nonce


def transform_to_float16(input: str):
    a = struct.pack("H", int(input, 2))
    return np.frombuffer(a, dtype=np.float16)[0]


focal_phase_0 = transform_to_float16(focal_phase_0_str)
focal_phase_1 = transform_to_float16(focal_phase_1_str)
focal_tilt_0 = transform_to_float16(focal_tilt_0_str)
focal_tilt_1 = transform_to_float16(focal_tilt_1_str)
focal_curve_0 = transform_to_float16(focal_curve_0_str)
focal_curve_1 = transform_to_float16(focal_curve_1_str)
focal_gibbous_phase_0 = transform_to_float16(focal_gibbous_phase_0_str)
focal_gibbous_phase_1 = transform_to_float16(focal_gibbous_phase_1_str)
focal_gibbous_magnitude_0 = transform_to_float16(focal_gibbous_magnitude_0_str)
focal_gibbous_magnitude_1 = transform_to_float16(focal_gibbous_magnitude_1_str)
focal_ogee_phase_0 = transform_to_float16(focal_ogee_phase_0_str)
focal_ogee_phase_1 = transform_to_float16(focal_ogee_phase_1_str)
focal_ogee_magnitude_0 = transform_to_float16(focal_ogee_magnitude_0_str)
focal_ogee_magnitude_1 = transform_to_float16(focal_ogee_magnitude_1_str)

print(f"focal_phase_0 {focal_phase_0}")
print(f"focal_phase_1 {focal_phase_1*360*48e6/959000}")
print(f"focal_tilt_0 {(focal_tilt_0-np.pi/6)*180/np.pi}")
print(f"focal_tilt_1 {(focal_tilt_1+np.pi/6)*180/np.pi}")
print(f"focal_curve_0 {focal_curve_0}")
print(f"focal_curve_1 {focal_curve_1}")
print(f"focal_gibbous_phase_0 {focal_gibbous_phase_0}")
print(f"focal_gibbous_phase_1 {focal_gibbous_phase_1}")
print(f"focal_gibbous_magnitude_0 {focal_gibbous_magnitude_0}")
print(f"focal_gibbous_magnitude_1 {focal_gibbous_magnitude_1}")
print(f"focal_ogee_phase_0 {focal_ogee_phase_0}")
print(f"focal_ogee_phase_1 {focal_ogee_phase_1}")
print(f"focal_ogee_magnitude_0 {focal_ogee_magnitude_0}")
print(f"focal_ogee_magnitude_1 {focal_ogee_magnitude_1}")
print(f"ootx_model {ootx_model}")
