-- local arquivos = fs.readdir(caminho_pasta)
-- chat vai ser => {createdBy="Reavik", users={}, mensagens=Tabela=> {user:"Reavik", mensagem:"texto"}, pass, color}
local nameBot = "WhatsApp"

local m1 = 25565
local m2 = 10
local modem = peripheral.find("modem")
if modem == nil then print("modem not found") else print("Modem encontrado!") end
modem.open(m1, m2)

local detector = peripheral.find("playerDetector")
if detector == nil then print("playerDetector not found") else print("playerDetector encontrado!") end

local cb = peripheral.find("chatBox")
print("[" .. nameBot .. "]" .. " ChatBox Encontrado!")

local ALLTABLES

function dump(o)
  if type(o) == "table" then
    local s = "{ "
    for k, v in pairs(o) do
      if type(k) ~= "number" then
        k = '"' .. k .. '"'
      end
      s = s .. "[" .. k .. "] = " .. dump(v) .. "\n"
    end
    return s .. "} "
  else
    return tostring(o)
  end
end

local caminho_pasta = "chats/"

-- Criar diretório dos chats, para caso não exista no PC.
if not fs.isDir(caminho_pasta) then
  fs.makeDir(caminho_pasta)
end

function VerifyPlayer(player)
  local listPlayers = detector.getOnlinePlayers()
  local pSearch
  for playerItem = 1, #listPlayers, 1 do
    if listPlayers[playerItem] == player then
      pSearch = listPlayers[playerItem]
    end
  end
  if pSearch then
    return true
  else
    return false
  end
end

function createChat(player, text, pass)
  text = string.lower(text)
  if fs.exists(caminho_pasta .. text .. ".lua") then
    return { response = 404 }
  else
    local newTable = { createdBy = player, mensagens = {}, users = { player }, pass = pass, color = 1 }
    local arquivo = fs.open(caminho_pasta .. text .. ".lua", "w")
    arquivo.write(textutils.serialize(newTable))
    arquivo.close()
    return { response = 200 }
  end
end

function deleteChat(player, text)
  text = string.lower(text)
  if fs.exists(caminho_pasta .. text .. ".lua") then
    local arquivo = fs.open(caminho_pasta .. text .. ".lua", "w")
    tabela = textutils.unserialize(arquivo.readAll())
    arquivo.close()
    if player == tabela.createdBy then
      fs.remove(caminho_pasta .. text .. ".lua")
      return { response = 200 }
    else
      return { response = 404 }
    end
  else
    return { response = 404 }
  end
end

function insertUser(player, text, pass)
  text = string.lower(text)
  if fs.exists(caminho_pasta .. text .. ".lua") then
    local arquivo = fs.open(caminho_pasta .. text .. ".lua", "w")
    tabela = textutils.unserialize(arquivo.readAll())

    -- Verificar se o usuário ja foi colocado nessa merda
    searchP = false
    for i, name in ipairs(tabela.users) do
      if name == player then
        searchP = true
        break
      end
    end

    if searchP then
      -- Esse player ja está ali
      return false
    else
      table.insert(tabela.users, player)
      arquivo.write(textutils.serialize(newTable))
      arquivo.close()
      return true
    end
  else
    -- Caso a tabela não existe, ou o chat não exista.
    return false
  end
end

function lerChat(text)
  text = string.lower(text)
  if fs.exists(caminho_pasta .. text .. ".lua") then
    local arquivo = fs.open(caminho_pasta .. text .. ".lua", "r")
    tabela = textutils.unserialize(arquivo.readAll())
    arquivo.close()
    return { response = 200, tabela = tabela }
  else
    -- Caso a tabela não existe, ou o chat não exista.
    return { response = 404, tabela = {} }
  end
end

function CatchAllChats()
  local arquivos = fs.list(caminho_pasta)
  local tabelaArquivos = {}
  for i, nomeArquivo in ipairs(arquivos) do
    local caminhoArquivo = caminho_pasta .. "/" .. nomeArquivo
    if fs.exists(caminhoArquivo) and nomeArquivo:match("%.lua$") then
      local arquivo = fs.open(caminhoArquivo, "r")
      local tabela = textutils.unserialize(arquivo.readAll())
      tabela.channel = string.gsub(nomeArquivo, "%.lua$", "")
      --table.insert(tabela, { channel = string.gsub(nomeArquivo, "%.lua$", "") })
      --tabelaArquivos[#tabelaArquivos + 1] = tabela
      table.insert(tabelaArquivos, tabela)
      arquivo.close()
    end
  end
  return tabelaArquivos
end

function send(tabela)
  modem.transmit(m1, m2, tabela)
end

function sendAdm(player, message)
  cb.sendMessageToPlayer("§b[" .. "ADMIN" .. "]§f " .. message, player, "§6" .. nameBot, "[]", "§4")
end

function sendMessage(player, message, channel, tabela)
  for players = 1, #tabela, 1 do
    if cb ~= nil then
      cb.sendMessageToPlayer("§b[" .. player .. "]§f " .. message, tabela[players], "§6" .. channel, "[]", "§4")
    end
  end

  print("[" .. channel .. "]" .. "[" .. player .. "] " .. message)
  if modem ~= nil then
    send({ command = "receive", channel = channel, player = player })
  end
end

ALLTABLES = CatchAllChats()

local function CreateSystem()
  while true do
    -- Analisar cada modem_message.
    local e, p, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    -- {command="", player="", id="", channel="", text=""}
    local command = message.command
    print(command)
    if command == "create" then
      print("> Criando um novo canal!\nBy:" .. message.player .. " Nome:" .. message.channel .. " Senha:" .. message.pass)
      local creating = createChat(message.player, message.channel, message.pass)
      if creating.response == 200 then
        print("+ Criado com sucesso!")
        sendAdm(message.player, "§fO Canal §a" .. message.channel .. "§f foi criado com sucesso!")
      else
        sendAdm(message.player,
          "§fSorry, Não foi possivel criar o canal " ..
          message.channel .. " talvez ja exista um canal com este nome ou falta informações")
        --"§fSorry, Seu canal: §b" ..message.channel.. "§4 não foi possivel criar, ou já existe ou tem coisas incoerentes!")
      end
      send(creating)
    elseif command == "delete" then
    elseif command == "join" then --player, channel, pass
      local inserttochannel = insertUser(player, channel, pass)
      if inserttochannel then
        sendAdm(message.player, "§fO Eh isso, agora você está conectado no canal: §a" .. message.channel)
      else
        sendAdm(message.player,
          "§fSorry, Não foi possivel entrar no canal §4" ..
          message.channel .. "§f ;(")
      end
      --modem.transmit({command = })
    end
  end
end

function ListAwaits()
  while true do
    -- Analisar cada modem_message.
    local e, p, channel, replyChannel, input, distance = os.pullEvent("modem_message")
    local command = input.command
    if (command == "list") then
      local TabelaTratada = {}
      for t = 1, #ALLTABLES, 1 do
        table.insert(TabelaTratada, {
          channel = ALLTABLES[t].channel,
          createdBy = ALLTABLES[t].createdBy,
          color = ALLTABLES[t].color,
          users = ALLTABLES[t].users,
          mensagens = ALLTABLES[t].mensagens
        })
      end
      --local jogador = VerifyPlayer(input.player)
      print("Lista enviada para " .. input.player .. "! " .. #TabelaTratada)
      send({ command = "listReceive", player = input.player, tabela = TabelaTratada })
      --print("User: " .. input.player .. " conectado no Sistema!")
    elseif command == "room" then
      local TabelaTratada = {}
      for t = 1, #ALLTABLES, 1 do
        local searchP = false -- Search Player.
        for i, name in ipairs(ALLTABLES[t].users) do
          if name == input.player then
            searchP = true
            break
          end
        end

        if searchP then
          table.insert(TabelaTratada, {
            channel = ALLTABLES[t].channel,
            createdBy = ALLTABLES[t].createdBy,
            color = ALLTABLES[t].color,
            users = ALLTABLES[t].users,
            mensagens = ALLTABLES[t].mensagens
          })
        end
      end
      --local jogador = VerifyPlayer(input.player)
      print("Salas enviadas para " .. input.player .. "! " .. #TabelaTratada)
      send({ command = "roomReceive", player = input.player, tabela = TabelaTratada })
      --print("User: " .. input.player .. " conectado no Sistema!")
    end
  end
end

-- => {createdBy="Reavik", users={}, mensagens=Tabela=> {user:"Reavik", mensagem:"texto"}, pass, color}
local function MessageSystem()
  while true do
    local e, p, channel, replyChannel, input, distance = os.pullEvent("modem_message")
    -- mensagem que vai ser recebida, vai ser uma tabela
    -- {command="", player="", id="", channel="", message=""}
    local command = input.command
    if (command == "send") then -- player, channel, message.
      local tabela = lerChat(input.channel).tabela
      if not (tabela == nil) then
        local searchP = false
        for i, name in ipairs(tabela.users) do
          if name == input.player then
            searchP = true -- Se tiver na lista
            break
          end
        end

        if searchP then -- Envia mensagem a todos do canal.
          print("[" .. input.channel .. "]" .. "[" .. input.player .. "] " .. input.message)
          sendMessage(input.player, input.message, input.channel, tabela.users)
        end
      end
      --sendMessage(input.player, input.message, input.channel, lerChat(input.channel))
    end
    if (command == "sendf") then
      sendAdm(input.player, input.message)
    end
  end
end

parallel.waitForAny(ListAwaits, MessageSystem, CreateSystem)