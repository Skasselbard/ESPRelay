doFileSafe("mqtt.lua")

if file.exists("loop.lua") then
    loop = require("loop")
    print("Loaded loop object")
else
    print("Loop object is empty")
    loop = {}
end

local loopTimer = tmr.create()
loopTimer:alarm(5000, tmr.ALARM_AUTO, function(t)
    for _,fun in pairs(loop) do
        fun()
    end
end)
    
