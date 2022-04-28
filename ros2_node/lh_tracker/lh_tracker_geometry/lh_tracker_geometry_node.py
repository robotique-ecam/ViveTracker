#!/usr/bin/env python3

import rclpy
import numpy as np
import cv2
import random
import copy
import lh_tracker_geometry.constants as csts

from tf2_kdl import PyKDL, do_transform_frame, transform_to_kdl, do_transform_vector
from rclpy.node import Node
from lh_tracker_msgs.msg import LHtracker
from geometry_msgs.msg import Point, TransformStamped
from visualization_msgs.msg import Marker, MarkerArray
from std_msgs.msg import ColorRGBA
from lh_tracker_geometry.lh_geometry import LH2Geometry
from tf2_ros import TransformBroadcaster, StaticTransformBroadcaster
class LH_tracker_geometry(Node):
    def __init__(self):
        """Init LH_tracker_geometry node"""
        super().__init__("lh_tracker_geometry")
        self.subscription = self.create_subscription(
            LHtracker, "lh_msgs", self.lh_sub_callback, 10
        )

        self.possible_pairs = [[0, 1], [2, 3], [4, 5], [6, 7]]
        self.geometry = LH2Geometry()

        self.marker_estimated_pose = Marker()
        self.marker_estimated_pose.id = 1
        self.marker_estimated_pose.header.frame_id = "map"
        self.marker_estimated_pose.type = 0  # arrow
        self.marker_estimated_pose.scale.x = 0.3
        self.marker_estimated_pose.scale.y = 0.1
        self.marker_estimated_pose.scale.z = 0.1
        self.marker_estimated_pose.color.a = 1.0
        self.marker_estimated_pose.lifetime.sec = 5
        self.marker_estimated_pose.color.r = 1.0
        self.init_line_list()
        self.sensor_height = 0.415
        self.init_sensors_markers()
        self.lh_lines_pb = self.create_publisher(Marker, "lh_lines", 10)
        self.lh_est_pose_pb = self.create_publisher(Marker, "lh_est_pose", 10)
        self.sensors_est_position_pb = self.create_publisher(
            Marker, "sensors_est_position", 10
        )
        self.tf_broadcaster = TransformBroadcaster(self)

        self.avg_nb = 200
        self.global_index = 0
        self.calibration_done = False

        self.initial_tf = self.kdl_to_transform(
            PyKDL.Frame(
                R=PyKDL.Rotation().EulerZYX(np.deg2rad(45), 0.0, 0.0),
                V=PyKDL.Vector(x=1.5, y=0.1, z=self.sensor_height),
            )
        )

        self.saved_iteration_list = LHtracker()

        # self.create_timer(959 / 48000, self.loop)
        self.iterations = LHtracker()
        self.iterations.sensors_nb_recovered = 4
        self.iterations.id_first_sensor = 0
        self.iterations.id_second_sensor = 1
        self.iterations.id_third_sensor = 2
        self.iterations.id_fourth_sensor = 3
        self.final_tf = TransformStamped()

        self.inial_skip_nb = 0
        self.inial_nb_to_skip = 200

        self.get_logger().info("lh_tracker_geometry node is ready")
        self.tracker_pose = Point()
    def init_line_list(self):
        self.line_list = Marker()
        self.line_list.header.frame_id = "map"
        self.line_list.type = 5  # line_list
        self.line_list.color.r = 1.0
        self.line_list.color.g = 1.0
        self.line_list.color.b = 1.0
        self.line_list.color.a = 1.0
        self.line_list.scale.x = 0.005
        self.line_list.lifetime.sec = 10
        for _ in range(4):
            self.line_list.colors.append(ColorRGBA())
            self.line_list.colors[-1].a = 1.0
        self.line_list.colors[0].r = 1.0
        self.line_list.colors[1].g = 1.0
        self.line_list.colors[2].b = 1.0
        for _ in range(8):
            self.line_list.points.append(Point())

    def init_sensors_markers(self):
        self.sensors_est_position = Marker()
        self.sensors_est_position.header.frame_id = "map"
        self.sensors_est_position.type = 7  # line_list
        self.sensors_est_position.color.a = 1.0
        self.sensors_est_position.scale.x = 0.015
        self.sensors_est_position.scale.y = 0.015
        self.sensors_est_position.scale.z = 0.015
        self.sensors_est_position.lifetime.sec = 10
        for _ in range(4):
            self.sensors_est_position.colors.append(ColorRGBA())
            self.sensors_est_position.colors[-1].r = 1.0
            self.sensors_est_position.colors[-1].a = 1.0
            self.sensors_est_position.points.append(Point())
            self.sensors_est_position.points[-1].z = self.sensor_height

    def lh_sub_callback(self, msg):
        if self.inial_skip_nb < self.inial_nb_to_skip:
            self.inial_skip_nb += 1
        elif not self.calibration_done:
            self.calibration_process(msg)
        else:
            self.nominal_localisation(msg)

    def calibration_process(self, msg):
        if msg.sensors_nb_recovered > 3 and self.global_index < self.avg_nb:
            # self.get_logger().info(f"[{msg.first_sensor_first_iteration}, {msg.first_sensor_second_iteration}, {msg.second_sensor_first_iteration}, {msg.second_sensor_second_iteration}, {msg.third_sensor_first_iteration}, {msg.third_sensor_second_iteration}, {msg.fourth_sensor_first_iteration}, {msg.fourth_sensor_second_iteration}],")
            self.global_index += 1
            self.saved_iteration_list.first_sensor_first_iteration += (
                msg.first_sensor_first_iteration
            )
            self.saved_iteration_list.first_sensor_second_iteration += (
                msg.first_sensor_second_iteration
            )

            self.saved_iteration_list.second_sensor_first_iteration += (
                msg.second_sensor_first_iteration
            )
            self.saved_iteration_list.second_sensor_second_iteration += (
                msg.second_sensor_second_iteration
            )

            self.saved_iteration_list.third_sensor_first_iteration += (
                msg.third_sensor_first_iteration
            )
            self.saved_iteration_list.third_sensor_second_iteration += (
                msg.third_sensor_second_iteration
            )

            self.saved_iteration_list.fourth_sensor_first_iteration += (
                msg.fourth_sensor_first_iteration
            )
            self.saved_iteration_list.fourth_sensor_second_iteration += (
                msg.fourth_sensor_second_iteration
            )
        else:
            self.saved_iteration_list.first_sensor_first_iteration = int(
                self.saved_iteration_list.first_sensor_first_iteration / self.avg_nb
            )
            self.saved_iteration_list.first_sensor_second_iteration = int(
                self.saved_iteration_list.first_sensor_second_iteration / self.avg_nb
            )

            self.saved_iteration_list.second_sensor_first_iteration = int(
                self.saved_iteration_list.second_sensor_first_iteration / self.avg_nb
            )
            self.saved_iteration_list.second_sensor_second_iteration = int(
                self.saved_iteration_list.second_sensor_second_iteration / self.avg_nb
            )

            self.saved_iteration_list.third_sensor_first_iteration = int(
                self.saved_iteration_list.third_sensor_first_iteration / self.avg_nb
            )
            self.saved_iteration_list.third_sensor_second_iteration = int(
                self.saved_iteration_list.third_sensor_second_iteration / self.avg_nb
            )

            self.saved_iteration_list.fourth_sensor_first_iteration = int(
                self.saved_iteration_list.fourth_sensor_first_iteration / self.avg_nb
            )
            self.saved_iteration_list.fourth_sensor_second_iteration = int(
                self.saved_iteration_list.fourth_sensor_second_iteration / self.avg_nb
            )

            angles_list = [(0.0, 0.0), (0.0, 0.0), (0.0, 0.0), (0.0, 0.0)]
            azimuth1, elevation1 = self.geometry.get_azimuth_elevation_from_iteration(
                self.saved_iteration_list.first_sensor_first_iteration,
                self.saved_iteration_list.first_sensor_second_iteration,
            )
            angles_list[msg.id_first_sensor] = (-np.tan(azimuth1), -np.tan(elevation1))

            azimuth2, elevation2 = self.geometry.get_azimuth_elevation_from_iteration(
                self.saved_iteration_list.second_sensor_first_iteration,
                self.saved_iteration_list.second_sensor_second_iteration,
            )
            angles_list[msg.id_second_sensor] = (-np.tan(azimuth2), -np.tan(elevation2))

            azimuth3, elevation3 = self.geometry.get_azimuth_elevation_from_iteration(
                self.saved_iteration_list.third_sensor_first_iteration,
                self.saved_iteration_list.third_sensor_second_iteration,
            )
            angles_list[msg.id_third_sensor] = (-np.tan(azimuth3), -np.tan(elevation3))

            azimuth4, elevation4 = self.geometry.get_azimuth_elevation_from_iteration(
                self.saved_iteration_list.fourth_sensor_first_iteration,
                self.saved_iteration_list.fourth_sensor_second_iteration,
            )
            angles_list[msg.id_fourth_sensor] = (-np.tan(azimuth4), -np.tan(elevation4))
            previous_final_tf = copy.deepcopy(self.final_tf)
            self.triangulate(angles_list)
            if self.final_tf.transform.translation.x != 0:
                self.calibration_done = True
                for i in range(len(self.line_list.points)):
                    self.line_list.points[i].x = self.final_tf.transform.translation.x
                    self.line_list.points[i].y = self.final_tf.transform.translation.y
                    self.line_list.points[i].z = self.final_tf.transform.translation.z
            if previous_final_tf.transform.translation.x != 0:
                kdl_previous_final_tf = transform_to_kdl(previous_final_tf)
                kdl_final_tf = transform_to_kdl(self.final_tf)
                # self.get_logger().info(f"translation diff: x:{(kdl_previous_final_tf.p.x()-kdl_final_tf.p.x())*100}, y:{(kdl_previous_final_tf.p.y()-kdl_final_tf.p.y())*100}, z:{(kdl_previous_final_tf.p.z()-kdl_final_tf.p.z())*100}")

                rot_previous_final_tf = kdl_previous_final_tf.M.GetEulerZYX()
                rot_final_tf = kdl_final_tf.M.GetEulerZYX()

                # self.get_logger().info(f"rotation diff: z:{float((rot_previous_final_tf[0] - rot_final_tf[0]))*180/np.pi}, y:{(rot_previous_final_tf[1] - rot_final_tf[1])*180/np.pi}, x:{(rot_previous_final_tf[2] - rot_final_tf[2])*180/np.pi}")
            else:
                self.saved_iteration_list = LHtracker()
                self.global_index = 0

    def triangulate(self, angles_list):
        points_3D = np.array(
            [
                csts.sensor_id_to_position[0],
                csts.sensor_id_to_position[1],
                csts.sensor_id_to_position[2],
                csts.sensor_id_to_position[3],
            ]
        )
        points_2D = np.array(
            angles_list,
            dtype="double",
        )
        camera_matrix = np.array(
            [
                [1, 0, 0],
                [0, 1, 0],
                [0, 0, 1],
            ],
            dtype="double",
        )
        dist_coeffs = np.zeros((4, 1))

        ref_frame = PyKDL.Frame(
            R=PyKDL.Rotation().EulerZYX(
                -180 * np.pi / 180, 45 * np.pi / 180, -90 * np.pi / 180
            ),
            V=PyKDL.Vector(0.0, 0.585, 0.1),
        )
        ref_frame = ref_frame.Inverse()

        ref_rot = ref_frame.M
        ref_rot_axis = ref_rot.GetRot()
        ref_tr = ref_frame.p

        rvec_ref = np.array(
            [ref_rot_axis.x(), ref_rot_axis.y(), ref_rot_axis.z()],
            dtype="double",
        )

        tvec_ref = np.array(
            [ref_tr.x(), ref_tr.y(), ref_tr.z()],
            dtype="double",
        )

        LM_criteria = (
            cv2.TERM_CRITERIA_EPS + cv2.TERM_CRITERIA_MAX_ITER,
            100000000,
            0.000000001,
        )

        rotation_vector, translation_vector = cv2.solvePnPRefineLM(
            objectPoints=points_3D,
            imagePoints=points_2D,
            cameraMatrix=camera_matrix,
            distCoeffs=dist_coeffs,
            rvec=rvec_ref,
            tvec=tvec_ref,
            criteria=LM_criteria,
        )  # refined solvepnp using Levenberg-Marquardt iterative minimization process

        rot_vec = PyKDL.Vector(
            x=rotation_vector[0],
            y=rotation_vector[1],
            z=rotation_vector[2],
        )
        tf_ = PyKDL.Frame(
            R=PyKDL.Rotation().Rot(
                vec=rot_vec,
                angle=rot_vec.Norm(),
            ),
            V=PyKDL.Vector(
                x=translation_vector[0],
                y=translation_vector[1],
                z=translation_vector[2],
            ),
        )

        rot_vec_to_euler = tf_.M.GetEulerZYX()
        if rot_vec_to_euler[1] != 0:
            calibration_tf = self.kdl_to_transform(tf_)

            lh_to_v_camera_frame = self.kdl_to_transform(
                PyKDL.Frame(R=PyKDL.Rotation().EulerZYX(-np.pi / 2, 0, -np.pi / 2))
            )

            kdl_tf_tracker_to_camera = transform_to_kdl(calibration_tf)
            kdl_tf_tracker_to_lh = do_transform_frame(
                kdl_tf_tracker_to_camera, lh_to_v_camera_frame
            )
            kdl_tf_lh_to_tracker = kdl_tf_tracker_to_lh.Inverse()
            kdl_tf_map_to_lh = do_transform_frame(kdl_tf_lh_to_tracker, self.initial_tf)

            self.final_tf.child_frame_id = "lh_frame"
            self.final_tf.header.frame_id = "map"
            self.final_tf.header.stamp = self.get_clock().now().to_msg()
            self.final_tf.transform = self.kdl_to_transform(kdl_tf_map_to_lh).transform

            test = StaticTransformBroadcaster(self)
            test.sendTransform(self.final_tf)

    def kdl_to_transform(self, kdl_frame):
        q = kdl_frame.M.GetQuaternion()
        tf_stamped = TransformStamped()
        tf_stamped.transform.rotation.x = q[0]
        tf_stamped.transform.rotation.y = q[1]
        tf_stamped.transform.rotation.z = q[2]
        tf_stamped.transform.rotation.w = q[3]
        tf_stamped.transform.translation.x = kdl_frame.p.x()
        tf_stamped.transform.translation.y = kdl_frame.p.y()
        tf_stamped.transform.translation.z = kdl_frame.p.z()
        return tf_stamped

    def get_x_y_z_from_azimuth_elevation(self, azimuth, elevation):
        radius = 2.5
        latitude = np.pi / 2 - elevation
        x = radius * np.cos(azimuth) * np.sin(latitude)
        y = radius * np.sin(azimuth) * np.sin(latitude)
        z = radius * np.cos(latitude)
        return (x, y, z)

    def project_vector_to_map(self, triplet):
        kdl_vector = PyKDL.Vector(x=triplet[0], y=triplet[1], z=triplet[2])
        projected_vector = do_transform_vector(kdl_vector, self.final_tf)
        return (projected_vector.x(), projected_vector.y(), projected_vector.z())


def main(args=None):
    """Entrypoint."""
    rclpy.init(args=args)
    lh_tracker_geometry = LH_tracker_geometry()
    try:
        rclpy.spin(lh_tracker_geometry)
    except KeyboardInterrupt:
        pass
    rclpy.shutdown()
