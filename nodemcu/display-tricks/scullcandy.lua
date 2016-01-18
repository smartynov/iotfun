local sda = 3
local scl = 2
local sla = 0x3c
i2c.setup(0, sda, scl, i2c.SLOW)
disp = u8g.ssd1306_128x64_i2c(sla)

file.open("hello.bit","r")
local hello = file.read(128*64/8)
file.close()
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

local x = 0
local y = 0

for i=0,100 do
    disp:firstPage()
    repeat
        if i < 40 then
            disp:drawBitmap(0, 0, 128/8, 64, hello)
        end
        disp:drawBitmap(x, y, 16/8, 16, scull)
        for s = 1,64 do
            disp:drawLine(2*(s-1), psin(4*(s-1)) / 16, 2*s, psin(4*s) / 16)
        end
    until disp:nextPage() == false
    x = (x + 1) % (128 - 16) 
    y = (y + 1) % (64 - 16)
    tmr.wdclr()
end
