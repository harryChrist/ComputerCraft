local mon = peripheral.find("monitor")
local W, H = mon.getSize()
local var = "- Botanic - Magic - Mana "
local ben = "<- Bem Vindo ->"
local x = math.floor((W - string.len(ben)))

function moveFirstToLast(str)
    -- Remova a primeira letra da string
    local first = string.sub(str, 1, 1)
    local rest = string.sub(str, 2)
    -- Adicione a primeira letra ao final da string
    return rest .. first
end

while true do
    var = moveFirstToLast(var)
    mon.clear()
    mon.setCursorPos(2, 3)
    mon.setTextScale(1)
    mon.setTextColor(math.random(1, 16))
    mon.write(var)
    mon.setTextScale(1)
    mon.setCursorPos(x/2, 1)
    mon.write(ben)
    sleep(0.3)
end