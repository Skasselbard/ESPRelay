m = mqtt.Client("node1", 120)

client = nil

m:on("connect", function(c) 
    print("mqtt connected")
    client = c
end)
m:on("offline", function(c)
    print("mqtt disconnected")
    client = nil
end)

m:connect("192.168.0.13", 1883)

tmr.alarm(3, 1000, tmr.ALARM_AUTO, function(t)
    if client ~= nil then
        local val = adc.read(0)
        print("read: ",val)
        client:publish("sensors/mq135", val, 0, 0)
    end
end)