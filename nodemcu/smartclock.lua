-- SmartClock for ESP8266 with nodeMCU
-- Written by Sergey Martynov http://martynov.info

http = require("http-client")
--bmp180 = require("bmp180")

-- hardware settings
local disp_sla = 0x3c
local sda_pin = 2 -- i2c display pins
local scl_pin = 1
local dht_pin = 5 -- dht22 data pin

-- software settings
local timer_interval = 100 -- timer interval in ms
local sync_interval = 90 -- sync time every n seconds
local temp_interval = 3 -- update temperature/humidity/pressure every n seconds
local send_interval = 60 -- send data to cloud every n seconds
local draw_interval = 1 -- update display every second

-- global variables
local timekeep = 0 -- holds time since last sync in ms
local timestamp = 0 -- holds current time in epoch seconds
local timezone = 0 -- tz offset
local epoch = 0 -- holds epoch of last sync
local next_sync = 5 -- epoch time of next time sync
local next_temp = temp_interval -- epoch time of next temp/hum/press reading 
local next_send = send_interval -- epoch time of next temp/hum/press sending 
local next_draw = draw_interval -- epoch time of next display update
local tmr_prev = 0
local temperature = 0
local humidity = 0
local pressure = 0
local temperature2 = 0
local disp


local function sync_time()
  --print("sync()")
  -- get current timestamp in GMT
  http.get("www.timeapi.org","/z/now?\\s", function(res)
    res = tonumber(res)
    if res ~= nil and res > 1444444444 then -- constant equals some past epoch
      local timediff = timestamp - res
      if timediff > 1000 or timediff < -1000 then
        epoch = res
        timekeep = 0
        next_sync = epoch + sync_interval
      else
        local url = "/update?key=KZ6YC9VGXFCABF06"
          .. "&field1=" .. timediff
        http.get("api.thingspeak.com", url, function(res)
          --print("published:"..res)
          end)
      end
      --print("sync: epoch="..epoch)
    end
  end)
  -- get current timezone (works poorly)
  timezone = 3 -- XXX
  --[[
  http.get("www.telize.com","/geoip", function(res)
    local data = cjson.decode(res)
    timezone = 0 + data.offset
    --print("sync: timezone="..timezone)
  end)
  --]]
end


local function read_temp()
  --print("read_temp()"..dht_pin)
  local status,t,h,td,hd = dht.readxx(dht_pin)
  --print("read: status="..status)
  if status == dht.OK then
    temperature = 10 * t + td / 100
    humidity    = 10 * h + hd / 100
    --print("read_temp: temperature="..temperature.." humidity="..humidity)
  end
--[[
  bmp180.read(3) -- oversampling=3, i.e. 8 measurements
  pressure = bmp180.getPressure()
  temperature2 = bmp180.getTemperature()
--]]
end


local function send_temp()
  --print("send_temp()")
  if temperature == 0 and humidity == 0 then return nil end
  local temp_int = temperature / 10
  local hum_int = humidity / 10
  local url = "/update?key=DQWUD59A3V9HXAYC"
    .. "&field1=" .. temp_int .. "." .. (temperature - 10 * temp_int)
    .. "&field2=" .. hum_int .. "." .. (humidity - 10 * hum_int)
    .. "&field5=" .. node.heap()
    .. "&field6=" .. tmr.now()
    .. "&field7=" .. tmr.time()
    .. "&field8=" .. timekeep
  http.get("api.thingspeak.com", url, function(res)
    --print("published:"..res)
    end)
end


local function init()
  i2c.setup(0, sda_pin, scl_pin, i2c.SLOW)

  --bmp180.init(sda_pin, scl_pin)

  disp = u8g.ssd1306_128x64_i2c(disp_sla)
  disp:setFont(u8g.font_6x10)
  disp:setFontRefHeightExtendedText()
  disp:setDefaultForegroundColor()
  disp:setFontPosTop()
end


local function disp_draw()
  -- prepare time as a string
  local ts = timestamp + 3600 * timezone
  local h = ts % 86400 / 3600
  local m = ts % 3600 / 60
  local s = ts % 60
  local time_str = string.format("%02u:%02u:%02u", h, m, s)
  -- prepare temp and humidity as strings
  local temp_str = (temperature / 10).."."..(temperature % 10)..string.char(176).."C"
  local hum_str = (humidity / 10).."%"
  --local press_str = (pressure / 100).." hPa = "..(p * 75 / 10000).."."..((p * 75 % 10000) / 1000).." mmHg"
  -- draw on screen
  disp:firstPage()
  repeat
    tmr.wdclr()
    disp:setScale2x2()
    disp:drawStr(5, 5, time_str)
    disp:undoScale()
    disp:drawStr(10, 38, temp_str)
    disp:drawStr(80, 38, hum_str)
    --disp:drawStr(30, 52, press_str)
  until disp:nextPage() == false
end


local function main_loop()
  tmr.stop(1)
  --tmr.wdclr()
  --print("KK")
  -- time keeping
  local tmr_now = tmr.now()
  local diff = ( tmr_now - tmr_prev ) / 1000
  if diff <= 0 or diff > 1000 + 2 * timer_interval then
    diff = timer_interval end
  tmr_prev = tmr_now
  timekeep = timekeep + diff
  timestamp = epoch + timekeep / 1000
  
  --print(node.heap())
  --print(diff)
  --print("main_loop(): tmr_now="..tmr_now.." diff="..diff.." timekeep="..timekeep.." timestamp="..timestamp)
  --print("next_sync="..next_sync.." next_temp="..next_temp.." next_draw="..next_draw)

  -- time to do something else?
  tmr.wdclr()
  if timestamp >= next_sync then
    next_sync = timestamp + sync_interval
    sync_time()
--    collectgarbage()
  elseif timestamp >= next_temp then
    next_temp = timestamp + temp_interval
    read_temp()
  elseif timestamp >= next_send then
    next_send = timestamp + send_interval
    send_temp()
  elseif timestamp >= next_draw then
    next_draw = timestamp + draw_interval
    disp_draw()
  end

  -- set timer for next loop
  -- XXX try dsleep?
  --tmr.wdclr()
  tmr.alarm(1,timer_interval,0,function() main_loop() end)
end


init()
main_loop()

