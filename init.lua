PIN_LED = 4

-- Each setting is saved as a file in the "settings" pseudo-directory
function getSetting(name)
    local f = file.open("settings/"..name, "r")
    if f == nil then
        return nil
    end
    local res = f:readline()
    f:close()
    return res
end

function setSetting(key,value)
    local f = file.open("settings/"..key, "w")
    if f ~= nil then
        f:write(value)
        f:close()
    else
        print("Error while setting property")
    end
end

-- Executes a lua file if it exists
function doFileSafe(path)
    if file.exists(path) then
        dofile(path)
    end
end

-- Opens a tcp server on port 2323, which can be connected to by netcat or telnet to remotely enter lua commands.
-- https://github.com/nodemcu/nodemcu-firmware/blob/master/lua_examples/telnet.lua
function startServer()
    if telnet_srv ~= nil then
        telnet_srv:close()
    end
    telnet_srv = net.createServer(net.TCP, 180)
    telnet_srv:listen(2323, function(socket)
        local fifo = {}
        local fifo_drained = true

        local function sender(c)
            if #fifo > 0 then
                c:send(table.remove(fifo, 1))
            else
                fifo_drained = true
            end
        end

        local function s_output(str)
            table.insert(fifo, str)
            if socket ~= nil and fifo_drained then
                fifo_drained = false
                sender(socket)
            end
        end

        node.output(s_output, 0)   -- re-direct output to function s_ouput.
        socket:on("receive", function(c, l)
            node.input(l)           -- works like pcall(loadstring(l)) but support multiple separate line
        end)
        socket:on("disconnection", function(c)
            node.output(nil)        -- un-regist the redirect output function, output goes to serial
        end)
        socket:on("sent", sender)

        print("Welcome to NodeMCU world.")
    end)
end

-- Attempts to connect to the wifi specified in the settings "wifi_ssid" and "wifi_pwd"
function connectWifi()
    local ssid = getSetting("wifi_ssid")
    local pwd = getSetting("wifi_pwd")
    if (ssid == nil) or (pwd == nil) or (ssid:len() < 1) or (pwd:len() < 1) then
        print("Error while loading wifi settings")
    else
        wifi.setmode(wifi.STATION)
        wifi.sta.autoconnect(1)
        local cfg = {}
        cfg.ssid = ssid
        cfg.pwd = pwd
        cfg.got_ip_cb = function(t)
            print("Connected to network, received ip:", t.IP)
            wifiTimer:stop()
            if mqttClient ~= nil then
                mqttClient:connect(getSetting("mqtt_server"), 1883)
            end
        end
        wifi.sta.config(cfg)
        wifi.sta.connect(function(x) print("Connected to wifi, waiting for ip...") end)
    end
end

-- Attempt to connect to wifi every 10s. connectWifi() automatically stops the timer if successful.
wifiTimer = tmr.create()
wifiTimer:register(10000,tmr.ALARM_AUTO,connectWifi)

-- Gives you 3s of time before connecting to Wifi, starting the telnet server
-- and compiling + running start.lua, where the complex initialization should be.
local initTimer = tmr.create()
initTimer:alarm(3000, tmr.ALARM_SINGLE, function(t)
    if wifi.sta.getip() == nil then
        connectWifi()
        wifiTimer:start()
    end
    startServer()
    doFileSafe("start.lua")
end)