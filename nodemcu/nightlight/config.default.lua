
-- hardware setup
PIN_PIR = 2 -- PIR sensor
PIN_LED_WARM = 7 -- warm light
PIN_LED_COLD = 5 -- cold light
PIN_DS18B20 = 1 -- DS18B20 temperature sensor

-- settings
tzOffset = 0*3600 -- local time zone offset in seconds
motionDelay = 90 -- seconds since last motion to start turning off

-- local wifi settings
WIFI_SSID = ""
WIFI_PASSWORD = ""

-- data.sparkfun.com (leave empty to disable)
PUBLIC_KEY = ""
PRIVATE_KEY = ""

-- enable telnet (set to 0 to disable)
TELNET_PORT = 21
