m = mqtt.Client(getSetting("mqtt_name"), 120)

client = nil

m:on("connect", function(c) 
    print("mqtt connected")
    client = c
end)
m:on("offline", function(c)
    print("mqtt disconnected")
    client = nil
end)

m:connect(getSetting("mqtt_server"), 1883)

tmr.alarm(3, 5000, tmr.ALARM_AUTO, function(t)
    if client ~= nil then
        local val = adc.read(0)
        print("read: ",val)
        client:publish(getSetting("mqtt_topic"), val, 0, 0)
    end
end)