#!/usr/bin/env python3

import numpy as np

from lh_tracker_geometry.constants import periods, data_frequency
from geometry_msgs.msg import Point


class LH2Geometry:
    def __init__(self):
        self.rotor_frequency = float(48e6 / periods[0])
        self.tilt = np.pi / 4
        self.tilt_1 = (90.0 - 58.00686257) * np.pi / 180
        self.tilt_2 = (180.0 - 148.00825208) * np.pi / 180
        self.phase = 119.26042336 * np.pi / 180
        self.start_angle = 29.46566866 * np.pi / 180

    def update_intrinsic_parameters(self, tilt1, tilt2, phase, start_angle):
        self.tilt_1 = (90 - tilt1) * np.pi / 180
        self.tilt_2 = (180 - tilt2) * np.pi / 180
        self.phase = phase * np.pi / 180
        self.start_angle = start_angle * np.pi / 180

    def create_point(self, x=0.0, y=0.0, z=0.0):
        point = Point()
        point.x = float(x)
        point.y = float(y)
        point.z = float(z)
        return point

    def get_theta_motor_from_lfsr_iteration(self, iteration: int) -> float:
        return float(2 * np.pi * iteration * self.rotor_frequency / data_frequency)

    def compute_azimuth_elevation(self, a1: float, a2: float):
        Q = self.create_point(x=np.cos(a1), y=np.sin(a1))
        P = self.create_point(x=np.cos(a2), y=np.sin(a2))

        F = self.create_point(
            x=np.sin(self.tilt_2) * np.cos(a2 - np.pi / 2),
            y=np.sin(self.tilt_2) * np.sin(a2 - np.pi / 2),
            z=np.cos(self.tilt_2),
        )
        D = self.create_point(
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

        M = self.create_point(
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
            - self.start_angle
        )
        a2 = (
            self.get_theta_motor_from_lfsr_iteration(second_iteration)
            - np.pi / 2
            - self.start_angle
            - self.phase
        )
        return self.compute_azimuth_elevation(a1, a2)
