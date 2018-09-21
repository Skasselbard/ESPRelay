local mqttName = getSetting("mqtt_name")

mqttClient = mqtt.Client(mqttName, 120)
loop = require("loop")

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

tmr.alarm(3, 5000, tmr.ALARM_AUTO, function(t)
    for _,fun in pairs(loop) do
        fun()
    end
end)