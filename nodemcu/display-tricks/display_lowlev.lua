sda = 3
scl = 2
sla = 0x3c


function plot(x, y, z)
  ln = x % 16
  hn = x/16
  pg = y/8
  bt = 2 ^ (y % 8)
  command(0x00 + ln, 0x10 + hn, 0xb0 + pg)
  if (z==0) then 
   if(x~=63) then bt=0 else bt=0x99 end
  end
  if(pg == 0) then bt = bit.bor(bt,1) end
  if(pg == 7) then bt = bit.bor(bt,128) end
  data(bt)
end

function data(...)
     i2c.start(0)
     i2c.address(0, sla, i2c.TRANSMITTER)
     i2c.write(0, 0x40, arg)
     i2c.stop(0)
end

function command(...)
     i2c.start(0)
     i2c.address(0, sla, i2c.TRANSMITTER)
     i2c.write(0, 0, arg)
     i2c.stop(0)
end

function oled_clear()
     command(0x20, 0x01)           
     command(0xB0, 0x00, 0x10)     -- home
    command(0x21, 0x00, 0x7f)  
     for i=0,127 do
     command(0x21, 0x00 + i, 0x7f)  
         data(1,2,3,4,5,6,7,0)
     end
     command(0x20, 0x02)           -- page addressing mode
end

function oled_init()
     i2c.setup(0, sda, scl, i2c.SLOW)
     command(0x8d, 0x14) -- enable charge pump   
     command(0xaf)       -- display on, resume to RAM
     command(0xd3, 0x00) -- set vertical shift to 0
     command(0x40)       -- set display start line to 0
     command(0xa1)       -- column 127 is mapped to SEG0
     command(0xc8)       -- remapped mode
    command(0xda, 0x12) -- alternative COM pin configuration, disable left/right remap
    command(0x81, 0xff) -- set contrast to 255
     command(0x20, 0x02) -- page addressing mode
end

oled_init()
oled_clear()

--command(0xaf) -- on
command(0x26, 0x00, 0x01, 0x04, 0x03, 0x15, 0x6f) -- scroll
command(0x26, 0x00, 0x00, 0x06, 0x07, 0x00, 0xff) -- scroll all
command(0x2f) -- scroll on
command(0x2e) -- scroll off

     command(0xda, 0x12)

for i=8,55 do
  plot(i,i,1)
  plot(126-i,i,1)
  tmr.wdclr()
end
