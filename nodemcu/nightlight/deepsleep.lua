-- deep sleep proof of a concept

local pinPIR = 2 -- gpio4
local pinWarm = 5 -- warm light
local pinCold = 6 -- cold light


print("+deepsleep")

-- some init
 
gpio.mode(pinPIR, gpio.INPUT)

gpio.mode(pinWarm, gpio.OUTPUT)
gpio.mode(pinCold, gpio.OUTPUT)

local stateOn = false
local lastMotion = 0
local motionDelay = 15
local realTime = false
local t

while true do
  -- current time
  local t = rtctime.get()
  if 0 == t then
    print("sntp.sync")
    t = 99999999
    rtctime.set(t, 0)
    sntp.sync('185.22.60.71')
  end
  
  realTime = t > 999999999
  
  -- check in in motion
  tmr.delay(100000)
  local PIR = gpio.read(pinPIR)
  if gpio.HIGH == PIR then
    lastMotion = t
  end
  
  stateOn = t < lastMotion + motionDelay

  -- control leds
  if stateOn then
    gpio.write(pinWarm, gpio.HIGH)
  else
    gpio.write(pinWarm, gpio.LOW)
  end

  -- debug
  print("PIR="..PIR.."; t="..t.."; lastMotion="..lastMotion.."; realTime="..tostring(realTime).."; stateOn="..tostring(stateOn))

  if stateOn then
    tmr.delay(1000000)
  else
    tmr.delay(100000)
    rtctime.dsleep(1000000)
  end

end
