local sda = 3
local scl = 2
local sla = 0x3c
i2c.setup(0, sda, scl, i2c.SLOW)
disp = u8g.ssd1306_128x64_i2c(sla)

file.open("hello.bit","r")
local background = file.read(128*64/8)


--disp:setFontRefHeightExtendedText()
--disp:setDefaultForegroundColor()
--disp:setFontPosTop()
disp:firstPage()
repeat

--disp:drawCircle(40, 30, 20)
--disp:setFont(u8g.font_6x10)
--disp:drawStr(70, 50, "Test 123")
--disp:setFont(u8g.font_chikita)
--disp:drawStr(30, 30, "86!")

-- u8g.setFont(u8g_font_unifont);
-- u8g.drawStr( 0, 20, "Hello World!");

disp:drawBitmap(0, 0, 128/8, 64, test1)
until disp:nextPage() == false
