doFileSafe("utils.lua")

local mqttName = getSetting("mqtt_name")
if mqttName == nil then
    print("Unable to load mqtt_name from settings")
else 
    mqttClient = mqtt.Client(mqttName, 120)
    if file.exists("loop.lua") then
        loop = require("loop")
        print("Loaded loop object")
    else
        print("Loop object is empty")
        loop = {}
    end

    client = nil

    mqttClient:on("connect", function(c) 
        print("mqtt connected")
        client = c
        client:publish("status/ip/"..mqttName, wifi.sta.getip(),0,0)
        client:subscribe("control/"..mqttName, 0)
        client:subscribe("control/all", 0)
        mqttTimer:stop()
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

    mqttTimer = tmr.create()
    mqttTimer:alarm(5000,tmr.ALARM_AUTO, function(t) 
        print("Attempting to connect to mqtt")
        mqttClient:connect(getSetting("mqtt_server"), 1883)
    end)

    loopTimer = tmr.create()
    loopTimer:alarm(5000, tmr.ALARM_AUTO, function(t)
        for _,fun in pairs(loop) do
            fun()
        end
    end)
end
