#include <stdio.h>
#include <unistd.h>

#include <rcl/rcl.h>
#include <rcl/error_handling.h>
#include <lh_tracker_msgs/msg/l_htracker.h>


#include <rclc/rclc.h>
#include <rclc/executor.h>
#include <time.h>

#ifdef ESP_PLATFORM
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "driver/uart.h"
#include "driver/gpio.h"
#include "esp_log.h"
#include "driver/gpio.h"
#endif

#define RCCHECK(fn) { rcl_ret_t temp_rc = fn; if((temp_rc != RCL_RET_OK)){printf("Failed status on line %d: %d. Aborting.\n",__LINE__,(int)temp_rc);vTaskDelete(NULL);}}
#define RCSOFTCHECK(fn) { rcl_ret_t temp_rc = fn; if((temp_rc != RCL_RET_OK)){printf("Failed status on line %d: %d. Continuing.\n",__LINE__,(int)temp_rc);}}

rcl_publisher_t publisher;
uint8_t* data;
static uint32_t first_iteration_list[8];
static uint32_t second_iteration_list[8];
static lh_tracker_msgs__msg__LHtracker lh_tracker_msg;
static bool parsing;
static bool msg_ready;
static bool processing_calibration;
static bool led_state;

void timer_callback(rcl_timer_t * timer, int64_t last_call_time)
{
	RCLC_UNUSED(last_call_time);
	if (timer != NULL) {
		if (processing_calibration){
			led_state = !led_state;
			gpio_set_level(22, led_state);
		}
	}
}

static void rx_task(void *arg)
{
    while (1) {
        const int rxBytes = uart_read_bytes(UART_NUM_0, data, 51, 1000 / portTICK_PERIOD_MS);

        if (rxBytes == 51) {
						if (data[0] == 0xff && data[1] == 0xff && data[2] == 0xff) {
							parsing = true;
							lh_tracker_msg.sensors_nb_recovered = 0;

							first_iteration_list[0] = (int)( (data[3] << 16) | (data[4] << 8) | (data[5]) );
							second_iteration_list[0] = (int)( (data[6] << 16) | (data[7] << 8) | (data[8]) );

							first_iteration_list[1] = (int)( (data[9] << 16) | (data[10] << 8) | (data[11]) );
							second_iteration_list[1] = (int)( (data[12] << 16) | (data[13] << 8) | (data[14]) );

							first_iteration_list[2] = (int)( (data[15] << 16) | (data[16] << 8) | (data[17]) );
							second_iteration_list[2] = (int)( (data[18] << 16) | (data[19] << 8) | (data[20]) );

							first_iteration_list[3] = (int)( (data[21] << 16) | (data[22] << 8) | (data[23]) );
							second_iteration_list[3] = (int)( (data[24] << 16) | (data[25] << 8) | (data[26]) );

							first_iteration_list[4] = (int)( (data[27] << 16) | (data[28] << 8) | (data[29]) );
							second_iteration_list[4] = (int)( (data[30] << 16) | (data[31] << 8) | (data[32]) );

							first_iteration_list[5] = (int)( (data[33] << 16) | (data[34] << 8) | (data[35]) );
							second_iteration_list[5] = (int)( (data[36] << 16) | (data[37] << 8) | (data[38]) );

							first_iteration_list[6] = (int)( (data[39] << 16) | (data[40] << 8) | (data[41]) );
							second_iteration_list[6] = (int)( (data[42] << 16) | (data[43] << 8) | (data[44]) );

							first_iteration_list[7] = (int)( (data[45] << 16) | (data[46] << 8) | (data[47]) );
							second_iteration_list[7] = (int)( (data[48] << 16) | (data[49] << 8) | (data[50]) );

							for (uint8_t i = 0; i<8; i++){
								if (first_iteration_list[i] != 0){
									lh_tracker_msg.sensors_nb_recovered ++;
									if (lh_tracker_msg.sensors_nb_recovered == 1) {
										lh_tracker_msg.id_first_sensor = i;
										lh_tracker_msg.first_sensor_first_iteration = first_iteration_list[i];
										lh_tracker_msg.first_sensor_second_iteration = second_iteration_list[i];
									} else if (lh_tracker_msg.sensors_nb_recovered == 2) {
										lh_tracker_msg.id_second_sensor = i;
										lh_tracker_msg.second_sensor_first_iteration = first_iteration_list[i];
										lh_tracker_msg.second_sensor_second_iteration = second_iteration_list[i];
									} else if (lh_tracker_msg.sensors_nb_recovered == 3) {
										lh_tracker_msg.id_third_sensor = i;
										lh_tracker_msg.third_sensor_first_iteration = first_iteration_list[i];
										lh_tracker_msg.third_sensor_second_iteration = second_iteration_list[i];
									} else if (lh_tracker_msg.sensors_nb_recovered == 4) {
										lh_tracker_msg.id_fourth_sensor = i;
										lh_tracker_msg.fourth_sensor_first_iteration = first_iteration_list[i];
										lh_tracker_msg.fourth_sensor_second_iteration = second_iteration_list[i];
									}
								}
							}
							if (lh_tracker_msg.sensors_nb_recovered >= 2){
								msg_ready = true;
							}
							parsing = false;
						} else {
							//not in sync
						}
        } else {
					//unable to read the full msg
				}
    }
    free(data);
}

void appMain(void * arg)
{
	rcl_allocator_t allocator = rcl_get_default_allocator();
	rclc_support_t support;

	gpio_config_t io_conf = {
	  .intr_type = GPIO_INTR_DISABLE,
	  .mode = GPIO_MODE_OUTPUT,
	  .pin_bit_mask = (1ULL<<22),
	  .pull_down_en = 0,
	  .pull_up_en = 0
	};
  gpio_config(&io_conf);

	io_conf.mode = GPIO_MODE_INPUT;
	io_conf.pin_bit_mask = (1ULL<<23);
	gpio_config(&io_conf);
	led_state = false;
	gpio_set_level(22, led_state);

	// create init_options
	RCCHECK(rclc_support_init(&support, 0, NULL, &allocator));

	// create node
	rcl_node_t node;
	RCCHECK(rclc_node_init_default(&node, "first_enemy_lh_msgs", "", &support));

	// create publisher
	RCCHECK(rclc_publisher_init_default(
		&publisher,
		&node,
		ROSIDL_GET_MSG_TYPE_SUPPORT(lh_tracker_msgs, msg, LHtracker),
		"/first_enemy/lh_msgs"));

	// create timer,
	rcl_timer_t timer;
	const unsigned int timer_timeout = 200;
	RCCHECK(rclc_timer_init_default(
		&timer,
		&support,
		RCL_MS_TO_NS(timer_timeout),
		timer_callback));

	// create executor
	rclc_executor_t executor;
	RCCHECK(rclc_executor_init(&executor, &support.context, 1, &allocator));
	RCCHECK(rclc_executor_add_timer(&executor, &timer));

	uart_config_t uart_config = {
        .baud_rate = 1000000,
        .data_bits = UART_DATA_8_BITS,
        .parity    = UART_PARITY_DISABLE,
        .stop_bits = UART_STOP_BITS_1,
        .flow_ctrl = UART_HW_FLOWCTRL_DISABLE,
        .source_clk = UART_SCLK_APB,
    };

	uart_driver_install(UART_NUM_0, 2*1024, 0, 0, NULL, 0);
  uart_param_config(UART_NUM_0, &uart_config);
	uart_set_pin(UART_NUM_0, 1, 3, UART_PIN_NO_CHANGE, UART_PIN_NO_CHANGE);

	data = (uint8_t*) malloc(51);
	parsing = false;
	msg_ready = false;
	struct timespec ts;
	struct timespec last_ts = {
		.tv_sec = 0,
		.tv_nsec = 0
	};
	uint32_t ns_diff_min = 1e8;

	xTaskCreate(rx_task, "uart_rx_task", 1024*2, NULL, 1, NULL);

	processing_calibration = false;
	bool start_async_wait = false;
	struct timespec wait_ts = {
		.tv_sec = 0,
		.tv_nsec = 0
	};
	uint16_t calibration_send_counter = 0;

	while(1){
		rclc_executor_spin_some(&executor, RCL_MS_TO_NS(100));
		clock_gettime(CLOCK_REALTIME, &ts);

		if (gpio_get_level(23) == 1) {
			if (!processing_calibration) gpio_set_level(22, false);
			if (!start_async_wait) {
				start_async_wait = true;
				wait_ts = ts;
			} else if (ts.tv_sec - wait_ts.tv_sec > 2) {
				processing_calibration = true;
				calibration_send_counter = 0;
				ns_diff_min = 0;
				start_async_wait = false;
			}
		}
		else {
			if (!processing_calibration) {
				start_async_wait = false;
				gpio_set_level(22, true);
			}
		}

		if (msg_ready && !parsing && abs(ts.tv_nsec-last_ts.tv_nsec)>ns_diff_min){
			if (processing_calibration) {
				lh_tracker_msg.sensors_nb_recovered = 8;
				calibration_send_counter ++;
				if (calibration_send_counter > 300){
					ns_diff_min = 1e8;
					processing_calibration = false;
				}
			}
			lh_tracker_msg.header.stamp.sec = ts.tv_sec;
			lh_tracker_msg.header.stamp.nanosec = ts.tv_nsec;
			RCSOFTCHECK(rcl_publish(&publisher, &lh_tracker_msg, NULL));
			msg_ready = false;
			last_ts = ts;
		}
	}

	// free resources
	RCCHECK(rcl_publisher_fini(&publisher, &node))
	RCCHECK(rcl_node_fini(&node))

  	vTaskDelete(NULL);
}
