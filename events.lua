-- here you can add global variables, run one time initializations,
-- and configure custom events

-- also you can define your mqtt logic here
-- add your subscription to the others in the "connect" event and
-- add your logic to the message event

location = "wohnzimmer/"
purpose = "licht/"

pwm.setup(1, 220, 512)
pwm.setup(2, 220, 512)
pwm.setup(3, 220, 512)
pwm.setup(4, 220, 512)
pwm.start(1)
pwm.start(2)
pwm.start(3)
pwm.start(4)

red = 0
green = 0
blue = 0
white = 0

function sendStatus(r, g, b, w)
    local message = "{" .. r .. "," .. g .. "," .. b .. "," .. w .. "}"
    if client ~= nil then
        client:publish("status/" .. location .. purpose .. mqttName, message, 0, 0)
    end
end

function led(r, g, b, w)
    pwm.setduty(1, g)
    pwm.setduty(2, r)
    pwm.setduty(3, b)
    pwm.setduty(4, w)
    red = r
    green = g
    blue = b
    white = w
    sendStatus(r, g, b, w)
end
led(0, 0, 0, 0)

mqttClient:on(
    "connect",
    function(c)
        mqttTimer:stop()
        print("mqtt connected as: " .. mqttName)
        client = c
        client:publish("status/" .. location .. purpose .. mqttName .. "/ip", wifi.sta.getip(), 0, 0)
        -- add your subscription here
        client:subscribe(
            {
                ["control/" .. location .. purpose .. mqttName .. "/#"] = 0,
                ["control/" .. location .. purpose .. "all/#"] = 0,
                ["control/" .. location .. "all/#"] = 0,
                ["control/all/#"] = 0,
                ["status/" .. location .. purpose .. mqttName] = 0
            }
        )
    end
)

mqttClient:on(
    "offline",
    function(c)
        print("mqtt disconnected")
        client = nil
        mqttTimer:start()
    end
)

mqttClient:on(
    "message",
    function(client, topic, message)
        if topic == "control/" .. location .. purpose .. mqttName or topic == "control/all" then
            node.input(message)
        elseif
            topic == "control/" .. location .. purpose .. mqttName .. "/sendStatus" or
                (string.find(topic, "control") ~= nil and string.find(topic, "all") ~= nil and
                    string.find(topic, "sendStatus") ~= nil)
         then
            sendStatus(red, green, blue, white)
        else
            print(topic .. ":")
            if message ~= nil then
                print(message)
            end
        end
    end
)
