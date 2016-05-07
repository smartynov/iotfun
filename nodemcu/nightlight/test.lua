-- RGB

gpio.mode(5, gpio.OUTPUT)
gpio.mode(6, gpio.OUTPUT)
gpio.mode(7, gpio.OUTPUT)

gpio.write(5, gpio.HIGH)
gpio.write(5, gpio.LOW)

gpio.write(7, gpio.HIGH)
gpio.write(7, gpio.LOW)


pwm.setup(5, 1000, 50) pwm.start(5)

-- PYR

gpio.mode(2, gpio.INPUT)

=gpio.read(2)

-- test

tmr.alarm(0, 500, 1, function() print(gpio.read(2)) end )

tmr.stop(0)

tmr.alarm(1, 500, 1, function() gpio.write(7, gpio.read(2)) end )

tmr.stop(1)

-- sleep

node.restart()

node.dsleep(10000000, 4)

=node.bootreason()

tmr.delay(10000000)


-- ds



-- adc

=adc.read(0)

=adc.readvdd33()


-- rtc / sntp

sntp.sync()
sntp.sync('185.22.60.71')

=rtctime.get()

rtctime.dsleep(10000000, 2)
rtctime.dsleep(1000000, 1)
rtctime.dsleep(1000000, 4)

rtctime.set(1436430589, 0)


-- wifi

wifi.setmode(wifi.STATION)
=wifi.STATION

wifi.sleeptype(wifi.NONE_SLEEP)
wifi.sleeptype(wifi.MODEM_SLEEP)

wifi.sta.config("smartwihome", "smartnet")

=wifi.sta.getip()
=wifi.sta.status()

wifi.sta.disconnect()

