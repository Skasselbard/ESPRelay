-- pwm control for leds

PwmMax = 1023
PwmFrequency = 500

-- https://nodemcu.readthedocs.io/en/release/modules/gpio/
-- https://www.make-it.ca/nodemcu-arduino/nodemcu-details-specifications/
pwm.setup(5, PwmFrequency, 0)
pwm.setup(6, PwmFrequency, 0)
pwm.start(5)
pwm.start(6)

-- function SendStatus(client, ww, cw)
--     local message = "[" .. ww .. "," .. cw .. "]"
--     if client ~= nil then
--         client:publish("status/" .. location .. purpose .. MqttName, message, 0, 0)
--     end
-- end

-- Example source JSON
-- {"light":{"red":1.0,"green":1.0,"blue":1.0,"white":1.0,"temperature":0.5,"intensity":0.75}}
function HandleLight(table)
    local light = table["light"]
    local intensity = tonumber(light["intensity"])
    local temperature = tonumber(light["temperature"])
    local white = tonumber(light["white"])
    local warm = PwmMax * intensity * temperature * white
    local cold = PwmMax * intensity * (1-temperature) * white
    if warm <= 1023 and cold <= 1023 then
        led(warm, cold)
    else
        print("wrong light values")
    end
end

function led(ww, cw)
    -- print("set led ww: " .. ww .. "; cw: " .. cw)
    pwm.setduty(5, ww)
    pwm.setduty(6, cw)
    -- SendStatus(ww, cw)
end