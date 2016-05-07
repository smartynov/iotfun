-- init

--wifi.setmode(wifi.STATION)
--wifi.sta.config("smartwihome","smartnet")
uart.setup(0,115200,8,0,1)

local runfiles={
"deepsleep"
}

for i, f in ipairs(runfiles) do
  local luafile = f..".lua"
  if file.open(luafile) then
    file.close()
    --print("Compiling "..luafile)
    node.compile(luafile)
  end
end

print("init")

tmr.alarm(1,2000,0,function() 
    for i, f in ipairs(runfiles) do
      local lcfile = f..".lc"
      if file.open(lcfile) then
        --print("Running "..lcfile)
        dofile(lcfile)
      else
        print("Error: "..lcfile.." does not exist!")
      end
    end
end)

exefiles=nil
collectgarbage()
