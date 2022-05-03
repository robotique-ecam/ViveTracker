import numpy as np
import sys

sys.path.append("../")

from lfsr.constants import periods, data_frequency


class Point:
    def __init__(self, x=0.0, y=0.0, z=0.0):
        self.x = x
        self.y = y
        self.z = z


class LH2Geometry:
    def __init__(self):
        self.rotor_frequency = float(48e6 / periods[0])
        self.tilt_1 = (90 - 63.40388707940443) * np.pi / 180
        self.tilt_2 = (180 - 146.47547713306804) * np.pi / 180

    def get_theta_motor_from_lfsr_iteration(self, iteration: int) -> float:
        return float(2 * np.pi * iteration * self.rotor_frequency / data_frequency)

    def compute_azimuth_elevation(self, a1: float, a2: float):
        Q = Point(x=np.cos(a1), y=np.sin(a1))
        P = Point(x=np.cos(a2), y=np.sin(a2))

        F = Point(
            x=np.sin(self.tilt_2) * np.cos(a2 - np.pi / 2),
            y=np.sin(self.tilt_2) * np.sin(a2 - np.pi / 2),
            z=np.cos(self.tilt_2),
        )
        D = Point(
            x=np.sin(self.tilt_1) * np.cos(a1 + np.pi / 2),
            y=np.sin(self.tilt_1) * np.sin(a1 + np.pi / 2),
            z=np.cos(self.tilt_1),
        )

        deno_sweep_1 = np.float32(F.x * P.y - P.x * F.y)
        deno_sweep_2 = np.float32(D.x * Q.y - Q.x * D.y)

        coeff_a = np.float32(P.y * F.z / deno_sweep_1)
        coeff_b = np.float32(-P.x * F.z / deno_sweep_1)

        coeff_d = np.float32(Q.y * D.z / deno_sweep_2)
        coeff_e = np.float32(-Q.x * D.z / deno_sweep_2)

        M = Point(
            x=np.float32(
                -(coeff_b - coeff_e) / (coeff_e * coeff_a - coeff_b * coeff_d)
            ),
            y=np.float32(
                -(coeff_d - coeff_a) / (coeff_e * coeff_a - coeff_b * coeff_d)
            ),
            z=1,
        )

        negative_quadrants = a1 > a2

        azimuth = np.arccos(np.sqrt((M.x**2) / (M.x**2 + M.y**2)))
        azimuth = -azimuth if M.y < 0 else azimuth
        azimuth = -azimuth if negative_quadrants else azimuth

        elevation = np.arccos(
            np.sqrt((M.x**2 + M.y**2) / (M.x**2 + M.y**2 + M.z**2))
        )
        elevation = -elevation if negative_quadrants else elevation

        return (azimuth, elevation)

    def get_azimuth_elevation_from_iteration(
        self, first_iteration: int, second_iteration: int
    ):
        a1 = (
            self.get_theta_motor_from_lfsr_iteration(first_iteration)
            - np.pi / 2
            - 26.68681060186392 * np.pi / 180
        )
        a2 = (
            self.get_theta_motor_from_lfsr_iteration(second_iteration)
            - np.pi / 2
            - 26.68681060186392 * np.pi / 180
            - 122.445 * np.pi / 180
        )
        return self.compute_azimuth_elevation(a1, a2)
