local sda = 3
local scl = 2
local sla = 0x3c
i2c.setup(0, sda, scl, i2c.SLOW)
local disp = u8g.ssd1306_128x64_i2c(sla)

file.open("scull.bit","r")
local scull = file.read(16*16/8)
file.close()

function psin(idx)
    idx = idx % 128
    lookUp = 32 - idx % 64
    val = 256 - (lookUp * lookUp) / 4
    if (idx > 64) then
        val = - val;
    end
    return 256+val
end

local psw = 5
local pdt = 6
local pcl = 7

gpio.mode(psw, gpio.INPUT)
gpio.mode(pdt, gpio.INPUT)
gpio.mode(pcl, gpio.INPUT)

local prev = 0

local value = 100
local prev_value = value

tmr.stop(1)
tmr.alarm(1,1,1,function() 
    local sw = gpio.read(psw) == 0
    local dt = gpio.read(pdt)
    local cl = gpio.read(pcl)
    if (cl == 1) then cur = 3 - dt else cur = dt end
    local dir = cur - prev
    if not(dir == 0) then dir = dir % 4 - 2 end
    prev = cur

    value = value + dir
    if not(prev_value == value) and cl == dt then
        disp:firstPage()
        repeat
            local x = value % (128+16) - 16
            local y = 20 -- + psin(4*x) / 32
            disp:drawBitmap(x, y, 16/8, 16, scull)
--            if (sw) then disp:drawDisc(value % 127, 40, 7)
--                  else disp:drawCircle(value % 127, 40, 7) end
            tmr.wdclr()
        until disp:nextPage() == false
    end
    prev_value = value
    --print ("sw="..sw.."; dt="..dt.."; cl="..cl..";")
--]]
    tmr.wdclr()
end)
