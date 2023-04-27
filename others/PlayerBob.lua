-- Created by Player_rs
-- License MIT
-- V: 2.5
-- Supports AE2 and Refined Storage


local langs = {
    {name = "pt_BR", pb = "wWYY291c"},
    {name = "en_US", pb = "Z8kvRen1"}
}


if not fs.exists('language.lua') then
    local stringLangs = "\n-- "
    for _,v in pairs(langs) do
        stringLangs = stringLangs..v.name..", "
    end


    local config = fs.open('language.lua', 'w')
    config.write([=[--[[write, save, exit...]]

local language = "pt_BR" ]=]..stringLangs..'\n\n\nreturn language')
    config.close()

    shell.run("edit language.lua")
end

local codeLang = require('language')
local dirMessage

local function downloadLang()

    local language = {}
    for _,v in pairs(langs) do
        if v.name == codeLang then
            language = v
            break
        end
    end

    if language.name == nil then
        error([[THIS LANGUAGE IS NOT AVALIABLE FOR DOWNLOAD,
        if you want to add your language, just make the file add it in the languages folder
        and change the name in the language.lua]])
    end

    shell.run('pastebin get '..language.pb..' languages/'..language.name)
    shell.run('clear')
    dirMessage = 'languages/'..language.name
end

if not fs.exists('/languages/') then
    fs.makeDir('languages')

    downloadLang()
else
    if fs.exists('/languages/'..codeLang) or fs.exists('/languages/'..codeLang..'.lua') then
        dirMessage = 'languages/'..codeLang
    else
        downloadLang()
    end
end

local message = require(dirMessage)

if not fs.exists('config') then
    shell.run('label set "CC:IM criado por: Player_rs"')
    term.clear()
    term.setCursorPos(1,1)
    print('Creating the "config" file')
    local config_txt = [===[CHAT_NAME = "SYSTEM"  --Coloque: CHAT_NAME = nil Se quiser desativar o chat
--Put: CHAT_NAME = nil If you want to disable the system chat

chestIn = "back"
chestOut = "right"
sysDirectionOut = ""
--A direção em que o baú que está do lado do Bridge está
--exemplo: "north", "west", "east" ou "south".

--The direction the chest on the Bridge side is in
--example: "north", "west", "east" or "south".

]===]
    local favorites_txt = [===[{
    ["hdpe"] = "mekanism:hdpe_sheet",

}]===]
    local config = fs.open('config', 'w')
    config.write(config_txt)
    config.close()

    if not fs.exists('favorites') then
        local favorites = fs.open('favorites', 'w')
        favorites.write(favorites_txt)
        favorites.close()
    end

    print(message.systemPrint[1])
    sleep(2)
    shell.run("edit config")
end

-- Loaders
local im = peripheral.find("inventoryManager")
local cb = peripheral.find("chatBox")
local rs = peripheral.find("rsBridge")
local me = peripheral.find("meBridge")

if im == nil then error(message.error[1]) end
if cb == nil then error(message.error[2]) end
if rs == nil and me == nil then error(message.error[3]) end
if rs ~= nil and me ~= nil then error(message.error[4]) end

local system
if rs ~= nil then system = rs else system = me end
local Player = im.getOwner() or error(message.error[4])

local commands = {
    {name = "HELP", chat = "", description = ""},
    {name = "CLEAR", chat = "", description = ""},
    {name = "TAKE", chat = "", description = ""},
    {name = "CONSULT", chat = "", description = ""},
    {name = "CRAFT", chat = "", description = ""},
    {name = "ADDFAV", chat = "", description = ""},
    {name = "LISTFAV", chat = "", description = ""},
    {name = "REMOVEFAV", chat = "", description = ""},
    {name = "FORCE", chat = "", description = ""},
}

os.loadAPI("config")
local cbName = config.CHAT_NAME
print(message.systemPrint[2])

for _,v in pairs(commands) do
    v.description = message.commandsDescription[v.name]
    v.chat = message.commandsCall[v.name]
end

local f = fs.open('favorites', 'r')
local favorites = textutils.unserialize(f.readAll())
f.close()

-- Stuff
local function sendChat(string)
    print(string)
    if cbName then
        cb.sendMessageToPlayer(string, Player, cbName)
    end
end

local function matchFavorite(string)
    if favorites ~= nil then
        for k,v in pairs(favorites) do
            if string == k then
                return v
            end
        end
    else
        return string
    end
    return string
end

-- Functions
local functions = {}

function functions.FORCE(system, args) -- Made by Harry and Reavik
    local command = args[1]
    local item = args[2]
    table.remove(args, 1)
    table.remove(args, 2)

    local Tabela = system.listItems()
    if string.lower(command) == "craft" then
        Tabela = system.listCraftableItems()
    end
    
    local search
    local exato
    local parecido
    local parecido2

    for a = 1, #Tabela, 1 do
        local splitOn = Tabela[a]["displayName"]
        -- Ajusto na string.
        local t = {}
        for w in string.gsub(item, "([%u][%l]*)", "%1 "):gmatch("%S+") do
            table.insert(t, w)
        end
        local ItemTextoGrande = ""
        for i, word in ipairs(t) do
            ItemTextoGrande = ItemTextoGrande .. word .. " "
        end
        ItemTextoGrande = string.sub(ItemTextoGrande, 1, -2) -- remove o último espaço em branco

        -- Buscando Item
        local inicio = string.find(string.lower(Tabela[a]["displayName"]), string.lower(t[1])) -- First Word
        local inicio2 = nil
        local inicio3 = nil
        if t[2] ~= nil then inicio2 = string.find(string.lower(Tabela[a]["displayName"]), string.lower(t[2])) end -- Second Word
        if t[3] ~= nil then inicio3 = string.find(string.lower(Tabela[a]["displayName"]), string.lower(t[3])) end -- Third Word

        if inicio and inicio2 then print(inicio.." - "..inicio2) end

        if (string.lower(splitOn) == string.lower("[" .. ItemTextoGrande .. "]") and exato == nil) then
            exato = Tabela[a]
        elseif inicio3 ~= nil and inicio2 ~= nil and inicio ~= nil then
            parecido = Tabela[a]
            parecido2 = Tabela[a]
        elseif inicio2 ~= nil and inicio ~= nil and parecido2 == nil then
            parecido = Tabela[a]
        elseif inicio ~= nil and parecido == nil then
            parecido = Tabela[a]
        end
    end

    if exato ~= nil then
        search = exato
    elseif parecido ~= nil then
        search = parecido
    end
    if search == nil then
        sendChat(message.messages["notfound"])
    else
        for _, comando in ipairs(commands) do
            if command == comando.chat then
                for k,v in pairs(functions) do
                    if k == comando.name then
                        table.insert(args, 1, search["name"])
                        v(system, args)
                        return
                    end
                end
                break
            end
        end
    end
end

function functions.HELP(_, args)
    local command = args[1]
    if command then
        for _,v in pairs(commands) do
            if command == v.chat then
                sendChat(string.format(">> %s =  %s", v.chat, v.description))
                return
            end
        end
        return sendChat(message.messages[1])
    end
    for k,v in pairs(commands) do
        sendChat(string.format("--------- [%s/%s] ---------", k, #commands))
        sleep(1)
        sendChat(string.format(">> %s =  %s", v.chat, v.description))
        sleep(1)
    end
end

function functions.CLEAR(_, args)
    local from = tonumber(args[1]) or 9
    local to = tonumber(args[2]) or 35
    local chestOut = config.chestOut
    local myInv = im.getItems()
    local foo = {}

    sendChat(string.format(message.messages[2], from, to))
    for k,v in pairs(myInv) do
        table.insert(foo,k,v.count)
    end
    if from == 0 then
        im.removeItemFromPlayer(chestOut, 1, 0)
    end
    for k,v in pairs(foo) do
        if k>=from and k<=to then
            im.removeItemFromPlayer(chestOut,v,k)
        end
    end
end

function functions.TAKE(system, args)
    local item = matchFavorite(args[1])
    local count = tonumber(args[2]) or 1
    local slots = tonumber(args[3])
    local content = system.getItem({name = item})
    local chestIn = config.chestIn
    local chestOut = config.sysDirectionOut

    if im.getEmptySpace() < count/64 then
        sendChat(string.format(message.messages[3], im.getEmptySpace(), im.getEmptySpace()*64))
        return
    end
    if content == nil then
        sendChat(message.messages["notfound"])
        return
    end
    if system == me then
        if content.amount == 0 then
            sendChat(message.messages[4])
            return
        end
    end
    if content.amount <= count then
        count = content.amount
    end
    local beenExported = system.exportItem({name = item, count = count}, chestOut)

    if beenExported >= 1 then
        sendChat(string.format(message.messages[5], item, count, slots or message.messages[6]))
        im.addItemToPlayer(chestIn, count, slots or -1, item)
    else
        sendChat(message.messages[7])
    end
end

function functions.CONSULT(system, args)
    local item = matchFavorite(args[1])
    local content = system.getItem({name = item})

    if content == nil then
        sendChat(message.messages["notfound"])
        return
    end

    sendChat(string.format(message.messages[8], content.name, content.amount, content.isCraftable))
end

function functions.CRAFT(system, args)
    local item = matchFavorite(args[1])
    local count = tonumber(args[2]) or 1

    local content = system.getItem({name = item})
    if content == nil then
        sendChat(message.messages["notfound"])
        return
    end
    if system ~= me then
        if not system.isItemCraftable({name = item, count = count}) then
            sendChat(message.messages[9])
            return
        end
    end
    local craft
    craft = system.craftItem({name = item, count = count})
    if craft then
        sendChat(string.format(message.messages[10], count, item))
    else
        sendChat(string.format(message.messages[11], count, item))
    end
end

function functions.LISTFAV()
    term.setTextColor(colors.yellow)
    sendChat("------ [ALIAS] ------")
    for k, v in pairs(favorites) do
        sleep(1)
        sendChat(string.format(">> %s = %s ", k, v))
    end
    sleep(1)
    sendChat("------ [FINAL] ------")
    term.setTextColor(colors.white)
end

function functions.ADDFAV(_, args)
    local alias = args[1]
    if not alias then
        sendChat(message.messages[12])
        return
    end
    local id = args[2] or im.getItemInHand().name
    favorites[alias] = id
    local f = fs.open('favorites', 'w')
    f.write(textutils.serialize(favorites))
    f.flush()
    f.close()
    sendChat(string.format(message.messages[13], alias, id))
end

function functions.REMOVEFAV(_, args)
    local alias = args[1]
    if not alias then
        sendChat(message.messages[14])
        return
    end
    favorites[alias] = nil
    local f = fs.open('favorites', 'w')
    f.write(textutils.serialize(favorites))
    f.flush()
    f.close()
    sendChat(string.format(message.messages[15], alias))
end

local m1 = 90
local m2 = 55
local modem = peripheral.find("modem")

if modem == nil then
    print("modem not found")
else
    print("Modem aberto, na porta "..m1..", "..m2)
    modem.open(m1, m2)
end

-- Roda Roda Jequitti
sendChat(message.systemPrint[3])
while true do
    local _, player, msg = os.pullEvent("chat")
    print("[ "..player.." ] "..msg)

    if modem ~= nil then modem.transmit(m1, m2, {player, msg}) end

    local args = {}
    for argumentos in msg:gmatch("%S+") do
        table.insert(args, argumentos)
    end

    if player == Player then
        for _, comando in ipairs(commands) do
            if args[1] == comando.chat then
                for k,v in pairs(functions) do
                    if k == comando.name then
                        table.remove(args, 1)
                        v(system, args)
                        break
                    end
                end
                break
            end
        end
    end
end