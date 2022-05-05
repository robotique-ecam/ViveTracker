#!/usr/bin/env python3

import rclpy
from rclpy.node import Node
from serial import Serial
from lh_tracker_msgs.msg import LHtracker
from lh_tracker_serial.pulse_data import Pulse_data


class LH_tracker_serial(Node):
    def __init__(self):
        """Init LH_tracker_serial node"""
        super().__init__("lh_tracker_serial")
        self.ser = Serial(port="/dev/ttyACM0", baudrate=1000000)
        self.lh_pb = self.create_publisher(LHtracker, "lh_msgs", 10)
        self.get_logger().info("lh_tracker_serial node is ready")
        self.start_loop()

    def start_loop(self):
        self.pulse_data = Pulse_data()
        self.synchronized = False
        self.sync()
        self.waiting_for_data = False
        self.create_timer(959 / 48000, self.loop)

    def loop(self):
        if self.waiting_for_data:
            return
        else:
            self.waiting_for_data = True
            self.pulse_data.set_data(self.ser.read(size=51).hex())
            self.pulse_data.ts = self.get_clock().now().to_msg()
            if not self.pulse_data.is_sync():
                self.synchronized = False
                self.sync()
            else:
                self.publish_data()
            self.waiting_for_data = False

    def sync(self):
        nb_of_ff = 0

        while not self.synchronized:
            read = self.ser.read().hex()
            if read == "ff":
                nb_of_ff += 1
            else:
                nb_of_ff = 0
            if nb_of_ff == 2:
                self.ser.read(size=49)
                self.synchronized = True

    def publish_data(self):
        self.lh_pb.publish(self.pulse_data.lh_msg)


def main(args=None):
    """Entrypoint."""
    rclpy.init(args=args)
    lh_tracker_serial = LH_tracker_serial()
    try:
        rclpy.spin(lh_tracker_serial)
    except KeyboardInterrupt:
        pass
    rclpy.shutdown()
