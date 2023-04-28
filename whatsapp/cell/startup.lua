local m1 = 25565
local m2 = 10

modem = peripheral.find("modem")
modem.open(m1, m2)

-- horaAtual - ultimaHoraComando >= tempoMinimo
-- local horaAtual = os.time()
date = {
  tempoMinimo = 30,
  Lista = 0,
  Salas = 0
}

pages = {
  command = "", -- entrar, deletar, criar, salas
  page = 0, -- vai ser usado em: entrar, deletar, salas.
  second = 0,
  chat = '', -- pra saber em qual chat você entrou.
  create = {
    name = "",
    pass = ""
  },
}

Salas = {}
AllRooms = {}

local playerConfig

-- Registrar Usuário
if not fs.exists("player.lua") then
  print("Qual seu nickname no Minecraft?")
  local nickname = read()
  local newTable = { player = nickname }
  local arquivo = fs.open("player.lua", "w")
  arquivo.write(textutils.serialize(newTable))
  arquivo.close()
  playerConfig = nickname
else
  local arquivo = fs.open("player.lua", "r")
  tabela = textutils.unserialize(arquivo.readAll())
  playerConfig = tabela.player
  arquivo.close()
end

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

function centerTextOnScreen(text, screenWidth)
  local spacesToAdd = math.floor((screenWidth - #text) / 2)
  local spaces = string.rep(" ", spacesToAdd)
  return spaces .. text .. "\n"
end

function send(tabela)
  modem.transmit(m1, m2, tabela)
end

function teste(mensagem)
  modem.transmit(m1, m2, { command = "sendf", player = "HarryKaray", message = mensagem })
end

function exibirPagina()
  term.clear()
  term.setCursorPos(1, 1)
  term.setTextColor(4)
  --minhaString = string.upper(string.sub(pages.command, 1, 1)) .. string.sub(pages.command, 2)
  commandName = string.upper(string.sub(pages.command, 1, 1)) .. string.sub(pages.command, 2)
  if not (pages.chat == "") then
    print(centerTextOnScreen(pages.chat, 24))
  elseif pages.command == "" then
    print(centerTextOnScreen("Home", 24))
    local cmd = { "Salas     (room)", "Entrar    (join)", "Criar     (cr)", "Remover   (rm)" }
    term.setTextColor(1)
    print("\n")
    for comando = 1, #cmd, 1 do
      print(" " .. cmd[comando])
    end
  elseif pages.command == "entrar" then
    print(centerTextOnScreen(commandName, 24))
    term.setTextColor(1)
    list = AllRooms
    if not (#list == 0) then
      -- Cálculo do índice inicial e final dos itens a serem exibidos
      local inicio = (pages.page - 1) * 10 + 1
      local fim = inicio + 9

      -- Verificação para não ultrapassar o tamanho da tabela
      if fim > #list then
        fim = #list
      end

      local QuantPaginas = math.ceil(#list / 10)
      for i = inicio, fim do
        term.setTextColor(list[i].color)
        print(i .. ". " .. list[i].channel .. " [" .. #list[i].users .. "]")
      end
      term.setTextColor(4)
      print("\n?. Ajuda\nuse: [number] [password]")
      term.setTextColor(1)
      term.setCursorPos(1, 16)
      print("> page: " .. pages.page .. "/" .. QuantPaginas)
      print("\n    <       []       >")
    end
  elseif pages.command == "salas" then
    print(centerTextOnScreen(commandName, 24))
    term.setTextColor(1)
    list = Salas
    if not (#list == 0) then
      -- Cálculo do índice inicial e final dos itens a serem exibidos
      local inicio = (pages.page - 1) * 10 + 1
      local fim = inicio + 9

      -- Verificação para não ultrapassar o tamanho da tabela
      if fim > #list then
        fim = #list
      end

      local QuantPaginas = math.ceil(#list / 10)
      for i = inicio, fim do
        term.setTextColor(list[i].color)
        print(i .. ". " .. list[i].channel .. " [" .. #list[i].users .. "]")
      end
      term.setTextColor(4)
      print("\n?. Ajuda\n")
      term.setTextColor(1)
      term.setCursorPos(1, 16)
      print("> page: " .. pages.page .. "/" .. QuantPaginas)
      print("\n    <       []       >")
    else
      print("No momento, você não está em nenhuma sala!")
    end
  elseif pages.command == "create" then
    print(centerTextOnScreen(commandName, 24))
    -- create = { name = "", pass = "" },
    term.setTextColor(4)
    print("\nQual o nome da sala?")
    if not (pages.create.name == "") then
      term.setTextColor(1)
      print(pages.create.name)
      term.setTextColor(4)
      print("\nQual a senha? sim é obrigatório.")
    end
    if not (pages.create.pass == "") then
      term.setTextColor(1)
      print(pages.create.pass)
      term.setTextColor(8)
      print("\nDigite algo para confirmar, ou 'n' para cancelar!")
      term.setTextColor(1)
    end
    term.setTextColor(1)
  elseif pages.command == "delete" then
    print(centerTextOnScreen(commandName, 24))
  end
end

-- função para receber mensagens
local function receiveMessage()
  while true do
    local e, p, channel, replyChannel, input, distance = os.pullEvent("modem_message")
    if input.command == "receive" then
    end
    if input.player == playerConfig and input.command == "listReceive" then
      AllRooms = input.tabela
      exibirPagina()
    end
    if input.player == playerConfig and input.command == "roomReceive" then
      Salas = input.tabela
      exibirPagina()
    end
  end
end

-- função para transmitir mensagens
local function sendMessage()
  while true do
    exibirPagina()
    local msg = read()
    local msgNotLower = msg
    msg = tostring(msg)
    if not tonumber(msg) then msg = string.lower(msg) end
    -- Global Chat
    -- Pages System
    if msg == "<" or msg == "back" then
      if not (pages.chat == "") then
        pages.chat = ""
      elseif pages.second > 1 then
        if pages.second == 1 then
          pages.second = 0
        else
          paginas.second = paginas.second - 1
        end
      elseif pages.page > 1 then
        if pages.page == 1 then
          pages.page = 0
          pages.command = ""
        else
          paginas.page = paginas.page - 1
        end
      elseif not (pages.command == "") then
        pages.command = ""
      end
    elseif msg == ">" or msg == "next" then
    elseif msg == "esc" then
      pages = {
        command = "",
        page = 0,
        second = 0,
        chat = '',
        create = {
          name = "",
          pass = ""
        }
      }
    elseif not (pages.chat == "") then
      send({ command = "send", player = playerConfig, channel = pages.chat, message = msgNotLower })
    -- nas Salas
    elseif pages.command == "entrar" then
      local primeiro, resto = msg:match("(%d+)%s(.*)")
      -- Verifique se a separação foi bem sucedida e exiba o resultado
      if primeiro ~= nil and resto ~= nil then
        if AllRooms[tonumber(primeiro)] then
          send({ command = "join", player = playerConfig, channel = AllRooms[tonumber(primeiro)].channel, pass = resto })
        end
      end
    elseif pages.command == "salas" then
      local numberRoom = tonumber(msg)
      if (tonumber(msg)) then
        if (#Salas >= 1) and (numberRoom <= #Salas and numberRoom >= 1) then
          pages.chat = Salas[numberRoom].channel
        end
      end
      -- Se estiver no Canal
    elseif pages.command == "create" then
      -- Se estiver no Canal
      if pages.create.name == "" then
        pages.create.name = msg
      elseif pages.create.pass == "" then
        pages.create.pass = msg
      else
        if msg == "n" then -- para literalmente cancelar.
          pages.create.name = ""
          pages.create.pass = ""
          pages.command = ""
        else
          send({ command = "create", player = playerConfig, channel = pages.create.name, pass = pages.create.pass })
          pages.create.name = ""
          pages.create.pass = ""
          pages.command = ""
        end
      end
    elseif msg == "entrar" or msg == "join" then
      local horaAtual = os.time()
      --if (horaAtual - date.Lista) >= date.tempoMinimo then
      send({ command = "list", player = playerConfig })
      --end
      pages.command = "entrar"
      pages.page = 1
    elseif msg == "salas" or msg == "room" then
      local horaAtual = os.time()
      --if (horaAtual - date.Salas) >= date.tempoMinimo then
      send({ command = "room", player = playerConfig })
      --end
      pages.command = "salas"
      pages.page = 1
    elseif msg == "criar" or msg == "cr" then
      pages.command = "create"
    elseif msg == "remover" or msg == "rm" then
      pages.command = "delete"
    end
  end
end

os.setComputerLabel("Zap - "..playerConfig)
-- executar as duas funções em paralelo
parallel.waitForAny(receiveMessage, sendMessage)
