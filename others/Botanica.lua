local reader0 = peripheral.wrap("blockReader_20")
local reader1 = peripheral.wrap("blockReader_21")
local reader2 = peripheral.wrap("blockReader_21")
local reader3 = peripheral.wrap("blockReader_23")
local reader4 = peripheral.wrap("blockReader_24")
local reader5 = peripheral.wrap("blockReader_25")
local reader6 = peripheral.wrap("blockReader_26")
local reader7 = peripheral.wrap("blockReader_27")

local mon = peripheral.find("monitor")
mon.setTextScale(0.5)
local W, H = mon.getSize()

local modem = peripheral.wrap("left")
modem.open(145)

local function drawBar(x,y,length,color)
    local oldBgColor = mon.getBackgroundColor()
    for i = x, (length + x) do
        mon.setCursorPos(i,y)
        mon.setBackgroundColor(color)
        mon.write(" ")
    end
    mon.setBackgroundColor(oldBgColor)
end

local function regra3(cur, total, wid)
    local porcent = cur/total
    if wid then
        return porcent*wid
    else
        return porcent
    end
end

local function printar(y ,str)
    mon.setCursorPos(math.ceil(W/2 - str:len()/2), y)
    mon.write(str)
end

print("Iniciando")
mon.setBackgroundColor(colors.black)
while true do
    mon.setCursorPos(1, 1)
    --mon.clear()

    local data0 = reader0.getBlockData()
    local data1 = reader1.getBlockData()
    local data2 = reader2.getBlockData()
    local data3 = reader3.getBlockData()
    local data4 = reader4.getBlockData()
    local data5 = reader5.getBlockData()
    local data6 = reader6.getBlockData()
    local data7 = reader7.getBlockData()
    local var1 = data0.mana + data1.mana + data2.mana + data3.mana + data4.mana + data5.mana + data6.mana + data7.mana
    local var2 = 10000000*8 -- Can be used data.manaCap in a Mana Pool or this number in a Mana Battery
    
    modem.transmit(165, 165, {var1, var2})
    
    mon.clear()
    drawBar(2, 2, W-3, colors.white)
    drawBar(2, 2, regra3(var1, var2, W-3), colors.green)

    local percent = regra3(var1, var2)*100
    printar(4, var1.." / "..var2)
    printar(5, string.format("%0.0f", percent).."%")
    printar(7, "Pools: "..string.format("%0.1f", var1/1000000))

    sleep(0.6)
end