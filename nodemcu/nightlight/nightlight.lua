-- NightLight PIR sensor LED control

-- settings
local fadeInTime = 2700 -- ms to turn light on
local fadeOutTime = 9100 -- ms to turn light off
local fadeStep = 35 -- fade step in ms
local watchStep = 590 -- PIR watch step in ms
local sendStep = 60*1000 -- send data each ms

-- constants
local OFF, ON, FADEIN, FADEOUT = 0, 1, 2, 3

-- vars
local state = OFF
local lastMotion = 0
local curPower = 0
local colorTemp = 0 -- 0 = warm, 1000 = cold
local maxPower = 1000
local nextTimeSync = 0
local isPwm = 0
local isRealTime = 0

local temperature = 0
local illuminance = 0

--print("+nightlight")

local http = require("http-client")

local ds18b20 = require("ds18b20")
ds18b20.setup(PIN_DS18B20)

function setPower ()
  --print("+setPower "..curPower)
  if curPower <= 0 then
    pwm.stop(PIN_LED_WARM)
    gpio.write(PIN_LED_WARM, gpio.LOW)
    pwm.stop(PIN_LED_COLD)
    gpio.write(PIN_LED_COLD, gpio.LOW)
    isPwm = 0
  else
    if isPwm == 0 then
      pwm.setup(PIN_LED_WARM, 1000, 0)
      pwm.start(PIN_LED_WARM)
      pwm.setup(PIN_LED_COLD, 1000, 0)
      pwm.start(PIN_LED_COLD)
      isPwm = 1
    end
    local power = maxPower * curPower / 10000
    pwm.setduty(PIN_LED_WARM, power * (1000 - colorTemp) / 1000)
    pwm.setduty(PIN_LED_COLD, power * colorTemp / 1000)
  end
end


function calcColorTemp (t)
  local tl = t + tzOffset - 3600
  local s = tl - (tl / 86400) * 86400
  s = s - (5*3600)
  if s < 0 or isRealTime == 0 then
    return 0
  end
  if s < (3*3600) then
    return 1000 * s / (3*3600)
  end
  s = s - (6*3600)
  if s < 0 then
    return 1000
  end
  return 1000 - 1000 * s / (13*3600)
end


function calcMaxPower (t)
  local tl = t + tzOffset
  local s = tl - (tl / 86400) * 86400
  s = s - (5*3600)
  if s < 0 or isRealTime == 0 then
    return 250
  end
  if s < (5*3600) then
    return 250 + 750 * s / (5*3600)
  end
  s = s - (13*3600)
  if s < 0 then
    return 1000
  end
  return 1000 - 750 * s / (6*3600)
end


function turnOn ()
  print("+turnOn")
  state = FADEIN
  tmr.stop(2)
  tmr.alarm(2, fadeStep, tmr.ALARM_AUTO, function()
    curPower = curPower + 1 + 10000 * fadeStep / fadeInTime
    if curPower >= 10000 then
      curPower = 10000
      state = ON
      tmr.stop(2)
    end
    setPower()
  end)
end


function turnOff ()
  print("+turnOff")
  state = FADEOUT
  tmr.stop(2)
  tmr.alarm(2, fadeStep, tmr.ALARM_AUTO, function()
    curPower = curPower - 1 - 10000 * fadeStep / fadeOutTime
    if curPower <= 0 then
      curPower = 0
      state = OFF
      tmr.stop(2)
    end
    setPower()
  end)
end


function getTime ()
  local t = rtctime.get()
  if 0 == t then
    print("init time")
    t = 123456789
    rtctime.set(t, 0)
    isRealTime = 0
  end
  if t >= 1234567890 then
    isRealTime = 1
  end
  if t >= nextTimeSync then
    print("sync time")
    -- TODO: randomize time servers
    sntp.sync('185.22.60.71')
    nextTimeSync = t + (isRealTime and 7200 or 10)
  end
  return t
end


function updateData ()
  temperature = ds18b20.read() or 0
  illuminance = adc.read(0) or 0
end


function sendData ()
  --print("sendData")
  if PRIVATE_KEY ~= "" then
    local url = "/input/"..PUBLIC_KEY.."?private_key="..PRIVATE_KEY
      .."&colortemp="..colorTemp
      .."&illuminance="..illuminance
      .."&maxpower="..maxPower
      .."&lastmotion="..lastMotion
      .."&state="..state
      .."&temperature="..(temperature/10).."."..(temperature%10)
    --print(url)
    http.get("data.sparkfun.com", url, function(res)
      print("published:"..res)
      end)
  end
end


-- main loop – watch PIR senor
tmr.alarm(1, watchStep, tmr.ALARM_AUTO, function()
  local t = getTime()
  local PIR = gpio.read(PIN_PIR)
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
  maxPower = calcMaxPower(t)
  colorTemp = calcColorTemp(t)
  setPower()
  updateData()
  --print("maxPower="..maxPower.."; colorTemp="..colorTemp.."; temperature="..tostring(temperature).."; illuminance="..tostring(illuminance))
  --print("PIR="..PIR.."; t="..t.."; lastMotion="..lastMotion.."; curPower="..curPower.."; state="..state)
end)


-- collect data and send to cloud
tmr.alarm(3, sendStep, tmr.ALARM_AUTO, function()
  print("send data to cloud")
  sendData()
end)


