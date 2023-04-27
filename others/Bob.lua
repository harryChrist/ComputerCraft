local nameBot = "Bob"
local namePlayer = "HarryKaray"
--local namePlayer = "HarryKaray"
local limpar = "NORTH"
local toChest = "WEST"
local toInv = "SOUTH"
-- Printa tudo oque o player escreve
local debug = false
-- Não mude, apenas digite "mon"
local monitor = true
-- Tamanho do texto
local scale = 0.5
-- Entre 1 e 16
local color = 2

local im = peripheral.find("inventoryManager")
print("[" .. nameBot .. "]" .. " Localizando InventoryManager...")
local cb = peripheral.find("chatBox")
print("[" .. nameBot .. "]" .. " Localizando ChatBox...")
local rs = peripheral.find("rsBridge")
print("[" .. nameBot .. "]" .. " Localizando ponte RS...")
local modem = peripheral.wrap("right")
print("[" .. nameBot .. "]" .. " Localizando Moden...")
modem.open(150, 200)
local mon = peripheral.find("monitor")
print("[" .. nameBot .. "]" .. " Localizando Monitor...")

if mon == nil then
    print("[" .. nameBot .. "]" .. " Monitor não encontrado")
else
    mon.setTextColor(color)
    mon.setTextScale(scale)
    term.redirect(mon)
    print("[" .. nameBot .. "]" .. " Monitor encontrado")
end

if im == nil then
    print("[" .. nameBot .. "]" .. " Gerenciandor de inventario não encontrado")
else
    print("[" .. nameBot .. "]" .. " inventoriManager encontrado")
end

if cb == nil then
    print("[" .. nameBot .. "]" .. " Caixa de Chat não encontrada")
else
    print("[" .. nameBot .. "]" .. " chatBox encontrada")
end

if rs == nil then
    print("[" .. nameBot .. "]" .. " Ponte RS não encontrada")
else
    print("[" .. nameBot .. "]" .. " Ponte RS localizada")
end

if modem == nil then
    print("[" .. nameBot .. "]" .. " Modem não encontrado")
else
    print("[" .. nameBot .. "]" .. " Modem localizado")
end

function dump(o)
    if type(o) == "table" then
        local s = "{ "
        for k, v in pairs(o) do
            if type(k) ~= "number" then
                k = '"' .. k .. '"'
            end
            s = s .. "[" .. k .. "] = " .. dump(v) .. ","
        end
        return s .. "} "
    else
        return tostring(o)
    end
end

function Split(s, delimiter)
    result = {};
    for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match);
    end
    return result;
end

function sendMessage(message)
    if cb ~= nil then
    cb.sendMessageToPlayer(message, namePlayer, nameBot)
    end
    print("[" .. nameBot .. "]" .. message)
    if modem ~= nil then
    modem.transmit(150, 250, "[" .. nameBot .. "]" .. message)
    end
end

function MensagemPlayer(message, player)
    print("[" .. player .. "]" .. message)
    if modem ~= nil then
    modem.transmit(150, 250, "[" .. player .. "] " .. message)
    end
end

sendMessage(" Já estou online e pronto para trabalhar!")

while true do
    local e, player, msg = os.pullEvent("chat")
    MensagemPlayer(msg, player)
    local split_string = Split(msg, " ")
    local msg = string.lower(split_string[1])
    local item = split_string[2]
    local quantity = tonumber(split_string[3])

    if debug  and player == namePlayer then
        print(player..": "..msg)
        sendMessage(" "..player..": "..msg)
    end


    if msg == "ajuda" and player == namePlayer then
        li = {
            "       Esses são meus comandos       ",
            " --------------- 1 / 4 --------------",
            " pegar <item> <quantidade> EX: pegar glass 64",
            " --------------- 2 / 4 --------------",
            " limpar ou limpar <n1> EX: limpar 1/2/3/4",
            " --------------- 3 / 4 --------------",
            " craft <nomeDoItem> ou craftar <nomeDoItem> -> para craftar",
            " --------------- 4 / 4 --------------",
            " cons <nomeDoItem> -> para ver quantos desse item você possui",
            " ------------------------------------"
        }
        for i = 1, #li do
            sendMessage(li[i])
            os.sleep(1)
        end
    end
    if msg == "pegar" and player == namePlayer and rs ~= nil   and im ~= nil then
        local Tabela = rs.listItems()
        local search = nil
        local exato = nil
        local parecido = nil
        local parecido2 = nil

        for a = 1, #Tabela, 1 do
            local splitOn = Tabela[a]["displayName"]
            -- Ajusto na string.
            local t = {}
            for w in string.gsub(item, "([%u][%l]*)", "%1 "):gmatch("%S+") do
                table.insert(t, w)
            end
            ItemTextoGrande = ""
            for i, word in ipairs(t) do
                ItemTextoGrande = ItemTextoGrande .. word .. " "
            end
            ItemTextoGrande = string.sub(ItemTextoGrande, 1, -2) -- remove o último espaço em branco

            -- Buscando Item
            local inicio, fim = string.find(string.lower(Tabela[a]["displayName"]), string.lower(t[1])) -- First Word
            local inicio2 = nil
            local inicio3 = nil
            if t[2] ~= nil then inicio2 = string.find(string.lower(Tabela[a]["displayName"]), string.lower(t[2])) end -- Second Word
            if t[3] ~= nil then inicio3 = string.find(string.lower(Tabela[a]["displayName"]), string.lower(t[3])) end -- Third Word

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

        if (search == nil) then
            sendMessage(" Este item '" .. item .. "' não foi encontrado!")
        else
            if quantity == nil then quantity = 1 end
                rs.exportItem({ name = search["name"], count = quantity }, (toChest))
                im.addItemToPlayer(toInv, quantity, 0, search["name"])
            if quantity > search["amount"]then
                sendMessage(" Você apenas possui [" .. search["amount"] .. "] " .. search["displayName"] .. " no seu sistema.")
            end
            if search["amount"]< 1 then
                sendMessage(" Acabaram todos os itens de '" .. search["displayName"] .. "' do sistema!")
            else
                sendMessage(" Item " .. search["displayName"] .. " adicionado ao seu inventário.")
            end
        end
    end
    if msg == "limpar" and player == namePlayer  and rs ~= nil  and im ~= nil then
    sendMessage(" Ok, limpando seu inventário.")
    myInv = im.getItems()
    local foo = {}

    for k, v in pairs(myInv) do
        table.insert(foo, k, v.count)
    end

    local lines = {
        { min = 9, max = 17 },
        { min = 18, max = 26 },
        { min = 27, max = 35 },
        { min = 0, max = 8 },
        { min = 9, max = 35 }
    }
    local search = 5
    if item then
        search = tonumber(item)
    else
        search = 5
    end

    for k, v in pairs(myInv) do
        table.insert(foo, k, v.count)
    end

    for k, v in pairs(foo) do
        if k >= lines[search].min and k <= lines[search].max then
            im.removeItemFromPlayer(limpar, v, k)
        end
    end
    end
    if msg == "cons" and player == namePlayer  and rs ~= nil then
        local Tabela = rs.listItems()
        local search = nil
        local exato = nil
        local parecido = nil
        local parecido2 = nil

        for a = 1, #Tabela, 1 do
            local splitOn = Tabela[a]["displayName"]
            -- Ajusto na string.
            local t = {}
            for w in string.gsub(item, "([%u][%l]*)", "%1 "):gmatch("%S+") do
                table.insert(t, w)
            end
            ItemTextoGrande = ""
            for i, word in ipairs(t) do
                ItemTextoGrande = ItemTextoGrande .. word .. " "
            end
            ItemTextoGrande = string.sub(ItemTextoGrande, 1, -2) -- remove o último espaço em branco

            -- Buscando Item
            local inicio, fim = string.find(string.lower(Tabela[a]["displayName"]), string.lower(t[1])) -- First Word
            local inicio2 = nil
            local inicio3 = nil
            if t[2] ~= nil then inicio2 = string.find(string.lower(Tabela[a]["displayName"]), string.lower(t[2])) end -- Second Word
            if t[3] ~= nil then inicio3 = string.find(string.lower(Tabela[a]["displayName"]), string.lower(t[3])) end -- Third Word

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
        print(" Buscando por " .. item)
        if search == nil then
            sendMessage(" Não foi encontrado " .. item .. " no estoque.")
        else
            local craftavel = ""
            if search["isCraftable"] then
                craftavel = "Sim"
            else
                craftavel = "Não"
            end
            sendMessage(" Atualmente você tem " .. search["amount"] .. " " .. search["displayName"] .. " em estoque.")
            print("["..nameBot.."] Atualmente você tem " .. search["amount"] .. " " .. search["displayName"] .. " em estoque.")
            if modem ~= nil then
                local tag = ""
                if search["tags"] == nil then
                    tag = "[Tag não encontrada]"
                else
                    tag = search["tags"][1]
                end
                if modem ~= nil then
                    modem.transmit(150, 250, "         Informações sobre "..search["displayName"])
                    modem.transmit(150, 250, "         Nome:          "..search["displayName"])
                    modem.transmit(150, 250, "         Quantidade:    ["..search["amount"].."]")
                    modem.transmit(150, 250, "         Craftavel:     "..craftavel)
                    modem.transmit(150, 250, "         Tag do Item:   "..tag)
                end
            end
        end
    end
    if msg == "craft" and player == namePlayer  and rs ~= nil  then
        local Tabela = rs.listItems()
        local search = nil
        local exato = nil
        local parecido = nil
        local parecido2 = nil

        if quantity == nil then quantity = 1 end

        for a = 1, #Tabela, 1 do
            local splitOn = Tabela[a]["displayName"]
            -- Ajusto na string.
            local t = {}
            for w in string.gsub(item, "([%u][%l]*)", "%1 "):gmatch("%S+") do
                table.insert(t, w)
            end
            ItemTextoGrande = ""
            for i, word in ipairs(t) do
                ItemTextoGrande = ItemTextoGrande .. word .. " "
            end
            ItemTextoGrande = string.sub(ItemTextoGrande, 1, -2) -- remove o último espaço em branco

            -- Buscando Item
            local inicio, fim = string.find(string.lower(Tabela[a]["displayName"]), string.lower(t[1])) -- First Word
            local inicio2 = nil
            local inicio3 = nil
            if t[2] ~= nil then inicio2 = string.find(string.lower(Tabela[a]["displayName"]), string.lower(t[2])) end -- Second Word
            if t[3] ~= nil then inicio3 = string.find(string.lower(Tabela[a]["displayName"]), string.lower(t[3])) end -- Third Word

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
            sendMessage(" O item "..item.." não foi encontrado.")
        else
            if search["isCraftable"] == true then
                sendMessage(" Craftando [" .. quantity .."] unidades de " .. search["displayName"])
                rs.craftItem({ name = search["name"], count = quantity })
            else
                sendMessage(" O item " .. search["displayName"] .. " não é craftável.")
            end
        end
    end
    if msg == "restart" and player == namePlayer then
        if mon ~= nil then
            mon.clear()
        end
        print("[" .. nameBot .. "]" .. " Reiniciando o sistema.")
        os.reboot()
    end
    if msg == "mon" and player == namePlayer  and mon ~= nil then
        if monitor == true then
            print("[" .. nameBot .. "]" .. " Monitor encontrado, redirecionando.")
            term.current()
        else
            print("[" .. nameBot .. "]" .. " Voltando para o terminal")
            mon.setTextScale(scale)
            mon.setTextColor(color)
            term.redirect(mon)
            monitor = true
        end
        elseif msg == "mon" and player == namePlayer and modem ~= nil then
        modem.transmit(150, 250, "mon")
    end
    if msg == "debug" and player == namePlayer then
        debug = not debug
    end
end