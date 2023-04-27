local version = 1.6
local m1 = 90
local m2 = 55
local modem = peripheral.find("modem")
if modem == nil then print("modem not found") end
modem.open(m1, m2)

local woner = "Reavik"
local nameBot = "Bob"

print("<=====|-<["..nameBot.."]>-|=====>\nCurrent version: "..version)
while true do
    local e, p, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    local color = 1
    if message[1] == "Goodinhoo" or message[1] == "Night_" or message[1] == "Kanix" then
        color = 16384
    elseif message[1] == "Player_rs" or message[1] == "HarryKaray" or message[1] == "zResckBR" or message[1] == "PegaNoLive" or message[1] == "Reavik" then
        color = 2
    end
    if message[1] == woner then
        color = 32
    end
    if message[3] ~= nil then
        if message[3] == 1 then
            color = 1024
        end
    end
    term.setTextColor(color)
    print("["..message[1].."]: "..message[2])
end