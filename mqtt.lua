-- you can define your mqtt logic here
-- add your subscription to the others in the "connect" event and
-- add your logic to the message event

Location = "wohnzimmer/"
Purpose = "licht/"

function OnMQTTConFail(_, reason)
    print ("mqtt connection failed", reason)
    mqttTimer:start()
end


function OnMQTTOffline(_)
    print("mqtt disconnected")
    mqttTimer:start()
end

function OnMQTTMessage(client, topic, message)
    if topic == "control/" .. Location .. Purpose .. MqttName 
    or topic == "control/" .. Location .. Purpose .. "all"
    or topic == "control/" .. Location .. "all"
    or topic == "control/all"
    then
        HandleLight(sjson.decode(message))
    else
        print(topic .. ":")
        if message ~= nil then
            print(message)
        end
    end
end

function OnMQTTConnect(client)
    mqttTimer:stop()
    print("mqtt connected as: " .. MqttName)
    client:on("message", OnMQTTMessage)
    client:on("offline", OnMQTTOffline)
    client:publish("status/" .. Location .. Purpose .. MqttName .. "/ip", wifi.sta.getip(), 0, 0)
    -- add your subscription here
    client:subscribe(
        {
            ["control/" .. Location .. Purpose .. MqttName .. "/#"] = 0,
            ["control/" .. Location .. Purpose .. "all/#"] = 0,
            ["control/" .. Location .. "all/#"] = 0,
            ["control/all/#"] = 0,
            ["status/" .. Location .. Purpose .. MqttName] = 0
        }
    )
end

MqttName = getSetting("mqtt_name")
if MqttName == nil then
        print("Unable to load mqtt_name from settings")
    else
    local mqttClient = mqtt.Client(MqttName, 120)
    mqttClient:lwt("status/ip/"..MqttName, "offline")
    mqttTimer = tmr.create()
    mqttTimer:alarm(5000,tmr.ALARM_AUTO, function(t)
        print("Attempting to connect to mqtt")
        mqttClient:connect(
            getSetting("mqtt_server"),
            1883,
            OnMQTTConnect
            -- OnMQTTConFail
        )
    end)
    doFileSafe("light.lua")
end