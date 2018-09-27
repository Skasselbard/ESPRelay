local mqttName = getSetting("mqtt_name")

mqttClient = mqtt.Client(mqttName, 120)
if file.exists("loop.lua") then
    loop = require("loop")
    print("Loaded loop object")
else
    print("Could not load loop object")
    loop = nil
end

client = nil

mqttClient:on("connect", function(c) 
    print("mqtt connected")
    client = c
    client:publish("status/ip/"..mqttName, wifi.sta.getip(),0,0)
    client:subscribe("control/"..mqttName, 0)
    client:subscribe("control/all", 0)
end)
mqttClient:on("offline", function(c)
    print("mqtt disconnected")
    client = nil
end)
mqttClient:on("message", function(client, topic, message)
    if topic == "control/"..mqttName or topic == "control/all" then
        node.input(message)
    end
end)

mqttClient:lwt("status/ip/"..mqttName, "offline")
mqttClient:connect(getSetting("mqtt_server"), 1883)

if loop ~= nil then
    tmr.alarm(3, 5000, tmr.ALARM_AUTO, function(t)
        for _,fun in pairs(loop) do
            fun()
        end
    end)
end