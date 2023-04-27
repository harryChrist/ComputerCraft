local m1 = 54235
local m2 = 34
local modem = peripheral.find("modem")
if modem == nil then print("modem not found") else print("Modem encontrado!") end
modem.open(m1, m2)

local function play()
    local e, p,channel, replyChannel, message, distance = os.pullEvent("modem_message")
    if (message ~= nil or message ~= "Finished") then
        print(message)
        shell.run('speaker play '..message)
        modem.transmit(m1, m2, "Finished")
    end
end

local function runtime()
    while true do
        play()
    end
end


runtime()