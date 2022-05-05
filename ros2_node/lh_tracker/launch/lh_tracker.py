#!/usr/bin/env python3


"""LH_tracker launcher."""


import launch
from launch_ros.actions import Node


def generate_launch_description():

    launch_description = [
        Node(
            package="lh_tracker",
            executable="lh_tracker_serial",
            output="screen",
            arguments=[],
        ),
        Node(
            package="lh_tracker",
            executable="lh_tracker_geometry",
            output="screen",
            arguments=[],
        ),
    ]

    return launch.LaunchDescription(launch_description)
