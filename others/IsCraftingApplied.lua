local botName = "Bob"

local mon = peripheral.find("monitor")
print("["..botName.."] inventoryManager encontrado")
local me = peripheral.find("meBridge")
print("["..botName.."] meBridge encontrada")

--if mon == nil then error("["..botName.."] O \"monitor\" não foi encontrado [x]") end
if me == nil then error("["..botName.."] O \"meBridge\" não foi encontrado [x]") end

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

local tabela = me.listCraftableItems()

print(dump(tabela[1]))