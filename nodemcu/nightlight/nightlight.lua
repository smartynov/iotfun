-- NightLight PIR sensor LED control

-- hardware setup

local pinPIR = 2 -- gpio4
local pinWarm = 7 -- warm light
local pinCold = 5 -- cold light

-- settings

local fadeInTime = 2000 -- ms to turn light on
local fadeOutTime = 7000 -- ms to turn light off
local fadeStep = 35 -- fade step in ms
local watchStep = 1000 -- PIR watch step in ms

local motionDelay = 5 -- seconds since last motion to start turning off

local maxPower = 10000


-- constants

local OFF, ON, FADEIN, FADEOUT = 0, 1, 2, 3

-- vars

local state = OFF
local lastMotion = 0
local curPower = 0
local colorTemp = 0 -- 0 = cold, 1000 = warm
local nextTimeSync = 0
local isPwm = 0


-- init pins

gpio.mode(pinPIR, gpio.INPUT)
gpio.mode(pinWarm, gpio.OUTPUT)
gpio.mode(pinCold, gpio.OUTPUT)
--print("+nightlight")


function setPower (power)
  --print("+setPower "..power)
  -- TODO: add color temp variation
  if power <= 0 then
    pwm.stop(pinWarm)
    gpio.write(pinWarm, gpio.LOW)
    pwm.stop(pinCold)
    gpio.write(pinCold, gpio.LOW)
    isPwm = 0
  else
    if isPwm == 0 then
      pwm.setup(pinWarm, 1000, power / 100)
      pwm.start(pinWarm)
      pwm.setup(pinCold, 1000, power / 100)
      pwm.start(pinCold)
      isPwm = 1
    else
      pwm.setduty(pinWarm, power / 100)
      pwm.setduty(pinCold, power / 100)
    end
  end
end


function turnOn ()
  print("+turnOn")
  state = FADEIN
  tmr.stop(2)
  tmr.alarm(2, fadeStep, tmr.ALARM_AUTO, function()
    curPower = curPower + 1 + maxPower * fadeStep / fadeInTime
    if curPower >= maxPower then
      curPower = maxPower
      state = ON
      tmr.stop(2)
    end
    setPower(curPower)
  end)
end


function turnOff ()
  print("+turnOff")
  state = FADEOUT
  tmr.stop(2)
  tmr.alarm(2, fadeStep, tmr.ALARM_AUTO, function()
    curPower = curPower - 1 - maxPower * fadeStep / fadeOutTime
    if curPower <= 0 then
      curPower = 0
      state = OFF
      tmr.stop(2)
    end
    setPower(curPower)
  end)
end


function getTime ()
  local t = rtctime.get()
  if 0 == t then
    print("init time")
    t = 123456789
    rtctime.set(t, 0)
  end
  if t >= nextTimeSync then
    print("sync time")
    sntp.sync('185.22.60.71')
    if t < 1234567890 then
      nextTimeSync = t + 10
    else
      nextTimeSync = t + 7200
    end
  end
  return t
end


-- main loop – watch PIR senor
-- TODO: try rewriting it with interrupts, not timer
tmr.alarm(1, watchStep, tmr.ALARM_AUTO, function()
  local t = getTime()
  local PIR = gpio.read(pinPIR)
  if gpio.HIGH == PIR then
    lastMotion = t
  end
  if lastMotion + motionDelay < t then
    if state == ON or state == FADEIN then
      turnOff()
    end
  else
    if state == OFF or state == FADEOUT then
      turnOn()
    end
  end
  --print("PIR="..PIR.."; t="..t.."; lastMotion="..lastMotion.."; curPower="..curPower.."; state="..state)
end)


-- collect data and send to cloud
tmr.alarm(3, 300*1000, tmr.ALARM_AUTO, function()
  print("TODO: collect data and send to cloud")
end)


