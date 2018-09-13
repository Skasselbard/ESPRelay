function sendBroadcast()
    local srv = net.createUDPSocket()
    srv:send(5053, wifi.sta.getbroadcast(), "Blblblbl")
    srv:close()
end

sendBroadcast()