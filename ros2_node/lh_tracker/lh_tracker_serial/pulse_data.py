#!/usr/bin/env python3

from lh_tracker_msgs.msg import LHtracker


class Pulse_data:
    def __init__(self, data=None):
        if data != None:
            self.set_data(data)
        self.first_iterations_list = [0, 0, 0, 0, 0, 0, 0, 0]
        self.second_iterations_list = [0, 0, 0, 0, 0, 0, 0, 0]
        self.lh_msg = LHtracker()
        self.lh_msg.header.frame_id = "valve_lighthouse"
        self.lh_msg.sensors_nb_recovered = 0

    def set_data(self, data):
        self.first_iterations_list = [0, 0, 0, 0, 0, 0, 0, 0]
        self.second_iterations_list = [0, 0, 0, 0, 0, 0, 0, 0]

        self.sync_frame = data[:6]

        self.first_iterations_list[0] = int(data[6:12], 16)
        self.second_iterations_list[0] = int(data[12:18], 16)

        self.first_iterations_list[1] = int(data[18:24], 16)
        self.second_iterations_list[1] = int(data[24:30], 16)

        self.first_iterations_list[2] = int(data[30:36], 16)
        self.second_iterations_list[2] = int(data[36:42], 16)

        self.first_iterations_list[3] = int(data[42:48], 16)
        self.second_iterations_list[3] = int(data[48:54], 16)

        self.first_iterations_list[4] = int(data[54:60], 16)
        self.second_iterations_list[4] = int(data[60:66], 16)

        self.first_iterations_list[5] = int(data[66:72], 16)
        self.second_iterations_list[5] = int(data[72:78], 16)

        self.first_iterations_list[6] = int(data[78:84], 16)
        self.second_iterations_list[6] = int(data[84:90], 16)

        self.first_iterations_list[7] = int(data[90:96], 16)
        self.second_iterations_list[7] = int(data[96:102], 16)

        if self.is_sync():
            self.parse_data()

    def parse_data(self):
        self.lh_msg.sensors_nb_recovered = 0
        for i in range(len(self.first_iterations_list)):
            if self.first_iterations_list[i] != 0:
                self.lh_msg.sensors_nb_recovered += 1
                if self.lh_msg.sensors_nb_recovered == 1:
                    self.lh_msg.id_first_sensor = i
                    self.lh_msg.first_sensor_first_iteration = (
                        self.first_iterations_list[i]
                    )
                    self.lh_msg.first_sensor_second_iteration = (
                        self.second_iterations_list[i]
                    )

                elif self.lh_msg.sensors_nb_recovered == 2:
                    self.lh_msg.id_second_sensor = i
                    self.lh_msg.second_sensor_first_iteration = (
                        self.first_iterations_list[i]
                    )
                    self.lh_msg.second_sensor_second_iteration = (
                        self.second_iterations_list[i]
                    )

                elif self.lh_msg.sensors_nb_recovered == 3:
                    self.lh_msg.id_third_sensor = i
                    self.lh_msg.third_sensor_first_iteration = (
                        self.first_iterations_list[i]
                    )
                    self.lh_msg.third_sensor_second_iteration = (
                        self.second_iterations_list[i]
                    )

                elif self.lh_msg.sensors_nb_recovered == 4:
                    self.lh_msg.id_fourth_sensor = i
                    self.lh_msg.fourth_sensor_first_iteration = (
                        self.first_iterations_list[i]
                    )
                    self.lh_msg.fourth_sensor_second_iteration = (
                        self.second_iterations_list[i]
                    )

    def is_sync(self):
        return True if int(self.sync_frame, 16) == 0xFFFFFF else False
