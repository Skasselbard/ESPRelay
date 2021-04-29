-- Executes a lua file if it exists
function doFileSafe(path)
    if file.exists(path) then
        dofile(path)
    end
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

doFileSafe("utils.lua")

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
    doFileSafe("start.lua")
end)