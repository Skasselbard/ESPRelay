local loop = {}
loop.gas = function()
    if client ~= nil then
        local val = adc.read(0)
        client:publish(getSetting("mqtt_topic"), val, 0, 0)
    end
end

gpio.mode(3,gpio.INPUT)
gpio.mode(PIN_LED,gpio.OUTPUT)
gpio.write(PIN_LED,1)

local motionSinceLastReset = 0
local irTimer = tmr.create()
irTimer:alarm(250, tmr.ALARM_AUTO, function()
    if gpio.read(3) == 1 then
        motionSinceLastReset = 1
    end
    gpio.write(PIN_LED,1-motionSinceLastReset)
end)

loop.ir = function()
    if client ~= nil then
        client:publish("sensors/ir", motionSinceLastReset, 0, 0)
        motionSinceLastReset = 0
    end
end

return loop