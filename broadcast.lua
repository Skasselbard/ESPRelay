local bc = {}

bc.collectors = {}

function bc.sendBroadcast()
    local srv = net.createUDPSocket()
    srv:send(5053, wifi.sta.getbroadcast(), "Blblblbl")
    srv:close()
end

function bc.collectData()
    local data = {}
    for k,f in pairs(bc.collectors) do
        data[k] = f()
    end
    return data
end

return bc