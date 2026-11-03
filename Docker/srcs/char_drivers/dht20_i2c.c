#include <linux/module.h>
#include <linux/init.h>
#include <linux/i2c.h>
#include <linux/hwmon.h>

// Links used to learn:
// https://www.adafruit.com/product/5183
// I2C address of 0x38
// https://www.kernel.org/doc/html/latest/i2c/writing-clients.html
// https://www.youtube.com/watch?v=pESMpoQnfDU
// https://github.com/torvalds/linux/blob/master/drivers/hwmon/aht10.c

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

// 3. Register driver struct
static struct i2c_driver dht20_driver = {
	.driver = {
		.name = "dht20",
	},
	.id_table = dht20_idtable,
	.probe = dht20_probe,
	.remove = dht20_remove,
};

// 4. Register the new driver: Automatically creates init and exit function with the provided module
module_i2c_driver(dht20_driver);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Nicholas W");
MODULE_DESCRIPTION("Simple device driver used to read the temperature and humidity sensors on the DHT20 I2C module.);
