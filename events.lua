-- here you can add global variables, run one time initializations,
-- and configure custom events

-- also you can define your mqtt logic here
-- add your subscription to the others in the "connect" event and
-- add your logic to the message event

mqttClient:on("connect", function(c) 
    mqttTimer:stop()
    print("mqtt connected as: "..mqttName)
    client = c
    client:publish("status/ip/"..mqttName, wifi.sta.getip(),0,0)
    -- add your subscription here
    client:subscribe({
      ["control/"..mqttName] = 0,
      ["control/all"] = 0,
      ["#"] = 0
    })
end)

mqttClient:on("offline", function(c)
    print("mqtt disconnected")
    client = nil
end)

mqttClient:on("message", function(client, topic, message)
    if topic == "control/"..mqttName or topic == "control/all" then
        node.input(message)
    else
      print(topic .. ":" ) 
      if message ~= nil then
          print(message)
      end
    end
end)