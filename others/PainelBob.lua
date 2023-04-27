--by: Player_rs, Reavik, zResckBR
local botName = "Bob"

local modem = peripheral.find("modem")
modem.open(150, 250)

local monitor = peripheral.wrap("left")
local pos = 1
print("Positivo e Operando")

monitor.clear()
--editado
function ler()
    if not fs.exists(botName.."/log.lua") then
        monitor.setTextScale(0.5)
        monitor.setTextColour(32)
        monitor.setCursorPos(1,pos+1)
        monitor.write("Arquivo de log não encontrado, criando log.lua")

        fs.makeDir(botName.."/log.lua")
        local f = fs.open(botName.."/log.lua", "w")
        f.write("{\"Positivo e operante\"}")
        f.close()
    end
    -----------------------------------------
local f = fs.open(botName.."/log.lua", "r")
local data = textutils.unserialize(f.readAll())
        for i = 1, #data do
            monitor.setBackgroundColour(32768)
            monitor.setTextScale(0.5)
            monitor.setTextColour(math.random(1, 16000))
            monitor.setCursorPos(1,pos+1)
            pos = pos+1
            monitor.write(data[i])
        end
    f.close()
end
ler()
function escrever(resposta)
    local time = os.date('*t')
    local f = fs.open(botName.."/log.lua", "r")
    local data = textutils.unserialize(f.readAll())
    f.close()
    local a = fs.open(botName.."/log.lua", "w")

    for _, v in pairs({"day", "month", "year", "hour", "min", "sec"}) do
        if time[v] < 10 then
            time[v] = "0"..time[v]
        end
    end
    if #data >= 79 then
        table.remove(data, 1)
        table.insert(data, string.format("[%s/%s/%s-%s:%s:%s]: %s", time.day, time.month, time.year, time.hour, time.min, time.sec, message))
        a.write(textutils.serialize(data))
    else
        table.insert(data, string.format("[%s/%s/%s-%s:%s:%s]: %s", time.day, time.month, time.year, time.hour, time.min, time.sec, resposta))
        a.write(textutils.serialize(data))
    end
    a.close()
end

    while true do
        local e, p,channel, replyChannel, message, distance = os.pullEvent("modem_message")
        print(message)
        if message == "mon" then
            monitor.clear()
            local f = fs.open(botName.."/log.lua", "w")
            f.write("{}")
            f.close()
            monitor.write("["..botName.."] Monitor e log limpos com sucesso.")
            os.reboot()
        end
        if message ~= new then
        escrever(message)
        local time = os.date('*t')
        for _, v in pairs({"day", "month", "year", "hour", "min", "sec"}) do
            if time[v] < 10 then
                time[v] = "0"..time[v]
            end
        end
        monitor.setBackgroundColour(32768)
        monitor.setTextScale(0.5)
        monitor.setTextColour(math.random(1,16000))
        monitor.setCursorPos(1,pos+1)
        pos = pos+1
        monitor.write(string.format("[%s/%s/%s-%s:%s:%s]: %s", time.day, time.month, time.year, time.hour, time.min, time.sec, message))
        if pos >= 79 then
            monitor.scroll(1)
            pos = 78
        end
    end
end