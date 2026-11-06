/* 
 * This is the first driver I'm "writing". Those quotes indicate I'm heavily basing my learning on the read-and-mimic of the official AHT10 drivers in the kernel found here...
 * https://github.com/torvalds/linux/blob/master/drivers/hwmon/aht10.c
 * When possible I'll insert comments indicating when I learned something new and (perhaps more importantly) where the included data came from.
 * These inclusions will predominantly come from sparkfun's datasheet on the sensor found here...
 * https://cdn.sparkfun.com/assets/8/a/1/5/0/DHT20.pdf
 * ... or the currently used driver above. 
 * Other links used (like the site the sensor was purchased from) can be found at the end of this program.
 */


/* Pre-processor Directives
 * The includes can be found at https://github.com/torvalds/linux/blob/master/include/linux/<header>
 * The datasheet refers to the passage of time in milliseconds (1/1000), but waiting in the kernel (with usleep) occurs in microseconds (1/1000000). So the datasheets times should be multiplied by 1000
 * 	Page 11 of the datasheet states a delay more than 80 ms before polling again. The status bit [Bit7] will indicate if the sensor can be polled again (0 means ready, 1 means busy)
 */
// What I had prior to looking at AHT20.c
// Each of these provides macros/ functions for...
#include <linux/module.h>	// dynamic loading of modules into the kernel
#include <linux/init.h>		// the initialization of the kernel and modules
#include <linux/i2c.h>		// the i2c bus interface
// What AHT20.c included
#include <linux/delay.h>	// delay/ sleep routines using timers. (Provides usleep to prevent too frequent polling of the sensor)
#include <linux/ktime.h>	// nanosecond representation of kernel time values. (Helps manage time keeping with delay.h)
#include <linux/crc8.h>		// calculating CRC (Cyclic Redundancy Check) values that use the CRC-8 algorithm. (Provides error detection in data transmission between the board and sensor)
#include <linux/hwmon.h>	// hardware monitoring. (Specifically provides the class "hwmon")

// AHT10.c includes most of the datasheet's bits, hexcodes, and wait periods as pre-processor directives.
// 	I'm guessing because they should NEVER be changed from whatever the datasheet stipulates(unless an erratas is released)
#define DHT20_POLL_WAIT 		80000	// 80 ms wait between polls
#define DHT20_POWER_ON_WAIT		100000	// 100 ms wait after power on
#define DHT20_BUS_BIT 			BIT(7)	// 0 means ready, 1 means busy
#define DHT20_CALIBRATION_BIT		BIT(3)	// 0 means uncalibrated, 1 means calibrated
#define DHT20_CMD_INITIALIZE		0x71	// AHT10.c uses binary, while the datasheet for DHT20 uses hex. For consistency sake to those following along with the datasheet (me) I'm opting to use hex
#define DHT20_CMD_MEASURE 		0xAC	// Used to indicate to the sensor a measurement is requested


// 1. Determine Compatible Devices: What device(s) this driver supports
static const struct i2c_device_id dht20_idtable[] = {
	{ "dht20", },
	{},
};
MODULE_DEVICE_TABLE(i2c, dht20_idtable);

// 2. Implement Probe and Remove Function: What is started when a device in the table from step 1 is found and what is started when a device in the table from step 1 is no longer detected
static int dht20_probe(struct 12c_client *client, const struct i2c_device_id *id) {
	
}

static void dht20_remove(struct i2c_client *client) {
}

// 3.a. Register driver struct
static struct i2c_driver dht20_driver = {
	.driver = {
		.name = "dht20",
	},
	.id_table = dht20_idtable,
	.probe = dht20_probe,
	.remove = dht20_remove,
};

/*
 * From 7.4 (Page 10) of https://cdn.sparkfun.com/assets/8/a/1/5/0/DHT20.pdf
 */
// 3.b. Extra Client Data: Additional data stored by the driver
struct DHT20_exData {
	struct i2c_client *client;	// Stores the devices address and driver
	int temp;			// Temparture measurement (Must be calculated based on the formula on the datasheet) 
	int humid;			// Humidity measurement (Also must be calculated based on the provided formula)
	u8 init_command;		// The hex used by the i2c bus to initialize the sensor (DHT20_CMD_INITIALIZE)
	ktime_t min_poll_diff;		// The minimum wait time between polls (pulled from datasheet (DHT20_POLL_WAIT))
	ktime_t last_poll;		// The last time the sensor was polled
	bool crc8;			// Determines if the CRC8 algorithm passed, confirming data was not lost in transit
}

// 4. Register the new driver: Automatically creates init and exit function with the provided module
module_i2c_driver(dht20_driver);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Nicholas W");
MODULE_DESCRIPTION("Simple device driver used to read the temperature and humidity sensors on the DHT20 I2C module.");

/*
 * Other links used to build this out...
 * https://www.adafruit.com/product/5183
 * https://www.kernel.org/doc/html/latest/i2c/writing-clients.html
 */
