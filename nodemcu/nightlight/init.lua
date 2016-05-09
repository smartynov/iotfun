-- init
dofile("config.lua")

-- init pins
gpio.mode(PIN_PIR, gpio.INPUT)
gpio.mode(PIN_LED_WARM, gpio.OUTPUT)
gpio.mode(PIN_LED_COLD, gpio.OUTPUT)
gpio.write(PIN_LED_WARM, gpio.LOW)
gpio.write(PIN_LED_COLD, gpio.LOW)
gpio.mode(PIN_DS18B20, gpio.OUTPUT)
gpio.write(PIN_DS18B20, gpio.HIGH)

wifi.setmode(wifi.STATION)
wifi.sta.config(WIFI_SSID, WIFI_PASSWORD)
wifi.sleeptype(wifi.MODEM_SLEEP)

uart.setup(0,115200,8,0,1)

print("init")
local i = 0
local runNightLight = 1

tmr.alarm(0, 500, tmr.ALARM_AUTO, function()
  i = i + 1
  if i == 1 then
    node.compile("nightlight.lua")
  end

  if TELNET_PORT > 0 then
    local ip = wifi.sta.getip()
    if ip == nil or ip == "0.0.0.0" then
      print("Waiting for IP...")
    else
      print("IP:" .. wifi.sta.getip())
      telnet = require("telnet-server")
      telnet.start(TELNET_PORT)
      TELNET_PORT = 0
    end
  end

  if i > 5 and runNightLight > 0 then
    runNightLight = 0
    dofile("nightlight.lc")
  end

  if runNightLight == 0 and TELNET_PORT == 0 then
    tmr.stop(0)
  end

  collectgarbage()
end)


