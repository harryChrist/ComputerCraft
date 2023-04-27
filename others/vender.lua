local toChest = "SOUTH"
local toPlayer = "EAST"
local sleep = 1
local playerName = "ManoLeo"
local botName = "Bob"

local im = peripheral.find("inventoryManager")
print("["..botName.."] inventoryManager encontrado")
local cb = peripheral.find("chatBox")
print("["..botName.."] ChatBox encontrada")
local me = peripheral.find("meBridge")
print("["..botName.."] meBridge encontrada")

if im == nil then error("["..botName.."] O \"inventoryManager\" não foi encontrado [x]") end
if cb == nil then error("["..botName.."] O \"chatBox\" não foi encontrado [x]") end
if me == nil then error("["..botName.."] O \"meBridge\" não foi encontrado [x]") end

print("["..botName.."] Iniciando...")

local HDPE = false
local COKE = false
local FLINT = false
local POLONIUM = false

while true do
    local e, player, msg = os.pullEvent("chat")

    if msg == "pegar flint" and player == playerName  then FLINT = true
    elseif msg == "pegar coke" and player == playerName then COKE = true
    elseif msg == "pegar hdpe" and player == playerName then HDPE = true
    elseif msg == "pegar polonium" and player == playerName then POLONIUM = true
    end

    while HDPE or COKE or FLINT or POLONIUM do
        print("["..botName.."] Ok enviando items")
        local item = im.getItemInHand().name
        if item ~= "minecraft:flint" and item ~= "thermal:coal_coke" and item ~= "mekanism:hdpe_sheet" and item ~= "mekanism:pellet_polonium" and item ~= nil then
            HDPE = false
            COKE = false
            FLINT = false
            POLONIUM = false
        end
        if FLINT then
            me.exportItem({ name = "minecraft:flint", count = 2304 }, toChest)
            print("["..botName.."] Flint Exportado para o bau")
            im.addItemToPlayer(toPlayer, 2304, -1, "minecraft:flint")
            print("["..botName.."] Flint Exportado para o player")
        elseif COKE then
            me.exportItem({ name = "thermal:coal_coke", count = 2304 }, toChest)
            print("["..botName.."] Coke Exportado para o bau")
            im.addItemToPlayer(toPlayer, 2304, -1, "thermal:coal_coke")
            print("["..botName.."] Coke Exportado para o player")
        elseif HDPE then
            me.exportItem({ name = "mekanism:hdpe_sheet", count = 2304 }, toChest)
            print("["..botName.."] HDPE Exportado para o bau")
            im.addItemToPlayer(toPlayer, 2304, -1, "mekanism:hdpe_sheet")
            print("["..botName.."] HDPE Exportado para o player")
        elseif POLONIUM then
            me.exportItem({ name = "mekanism:pellet_polonium", count = 2304 }, toChest)
            print("["..botName.."] Polonium Exportado para o bau")
            im.addItemToPlayer(toPlayer, 2304, -1, "mekanism:pellet_polonium")
            print("["..botName.."] Polonium Exportado para o player")
        end
        os.sleep(sleep)
    end
end
