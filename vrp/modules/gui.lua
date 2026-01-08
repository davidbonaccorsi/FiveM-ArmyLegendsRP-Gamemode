local Tools = module("lib/Tools")

-- MENU

local menu_ids = Tools.newIDGenerator()
local client_menus = {}
local rclient_menus = {}

-- open dynamic menu to client
-- menudef: .name and choices as key/{callback,description} (optional element html description) 
-- menudef optional: .css{ .top, .header_color }
function vRP.openMenu(source,menudef)
  local menudata = {}
  menudata.choices = {}

  -- send menudata to client
  -- choices
  for k,v in pairs(menudef) do
    if k ~= "name" and k ~= "onclose" and k ~= "css" then
      table.insert(menudata.choices,{k,v[2],v[3]})
    end
  end

  -- sort choices per entry name
  table.sort(menudata.choices, function(a,b)
    return string.upper(a[1]) < string.upper(b[1])
  end)
  
  -- name
  menudata.name = menudef.name or "Menu"
  menudata.css = menudef.css or {}

  -- set new id
  menudata.id = menu_ids:gen() 

  -- add client menu
  client_menus[menudata.id] = {def = menudef, source = source}
  rclient_menus[source] = menudata.id

  -- openmenu
  vRPclient.openMenuData(source,{menudata})
end

-- force close player menu
function vRP.closeMenu(source)
  vRPclient.closeMenu(source,{})
end

-- PROMPT

local prompts = {}
local function default_fnc() end

-- prompt textual (and multiline) information from player
function vRP.prompt(source,title,description,response,cb,focus)
  local prompt = {
    on_respond = cb,
  }

  prompts[source] = prompt
  vRPclient.prompt(source, {title, description, response, focus})
end

-- REQUEST

local request_ids = Tools.newIDGenerator()
local requests = {}

-- ask something to a player with a limited amount of time to answer (yes|no request)
-- time: request duration in seconds
-- cb_ok: function(player,ok)
function vRP.request(source, text, title, cb, keepFocus)
  local id = request_ids:gen()
  if id then
    local req = {
      source = source,
      on_respond = cb,
      done = false
    }

    requests[id] = req
    vRPclient.request(source, {id, text, title, keepFocus})

    SetTimeout(60000, function()
      if requests[id] and not req.done then
        req.on_respond(source, false)
        requests[id] = nil

        request_ids:free(id)
      end
    end)
  end
end

-- GENERIC MENU BUILDER

local menu_builders = {}

-- register a menu builder function
--- name: menu type name
--- builder(add_choices, data) (callback, with custom data table)
---- add_choices(choices) (callback to call once to add the built choices to the menu)
function vRP.registerMenuBuilder(name, builder)
  local mbuilders = menu_builders[name]
  if not mbuilders then
    mbuilders = {}
    menu_builders[name] = mbuilders
  end

  table.insert(mbuilders, builder)
end

-- build a menu
--- name: menu name type
--- data: custom data table
-- cbreturn built choices
function vRP.buildMenu(name, data, cbr)
  -- the task will return the built choices even if they aren't complete
  local choices = {}
  local task = Task(cbr, {choices})

  local mbuilders = menu_builders[name]
  if mbuilders then
    local count = #mbuilders

    for k,v in pairs(mbuilders) do -- trigger builders
      -- get back the built choices
      local done = false
      local function add_choices(bchoices)
        if not done then -- prevent a builder to add things more than once
          done = true

          if bchoices then
            for k,v in pairs(bchoices) do
              choices[k] = v
            end
          end

          count = count-1
          if count == 0 then -- end of build
            task({choices})
          end
        end
      end

      v(add_choices, data) -- trigger
    end
  else
    task()
  end
end

-- MAIN MENU

-- open the player main menu
function vRP.openMainMenu(source)
  vRP.buildMenu("main", {player = source}, function(menudata)
    menudata.name = "Main menu"
    menudata.css = {top="75px",header_color="rgba(0,125,255,0.75)"}
    vRP.openMenu(source,menudata) -- open the generated menu
  end)
end

-- SERVER TUNNEL API

function tvRP.closeMenu(id)
  local menu = client_menus[id]
  if menu and menu.source == source then

    -- call callback
    if menu.def.onclose then
      menu.def.onclose(source)
    end

    menu_ids:free(id)
    client_menus[id] = nil
    rclient_menus[source] = nil
  end
end

function tvRP.validMenuChoice(id,choice)
  local menu = client_menus[id]
  if menu and menu.source == source then
    -- call choice callback
    local ch = menu.def[choice]
    if ch then
      local cb = ch[1]
      if cb then
        cb(source,choice)
      end
    end
  end
end

-- receive prompt result
RegisterServerEvent("vRP:promptResult", function(response)
  if prompts and source then
      local data = prompts[source]
      if not data then return end

      local prompt = data.on_respond
      if prompt then
          prompts[source] = nil

          if vRP.getUserId(source) then
            prompt(response)
          end
      end
  end
end)

-- receive request result
RegisterServerEvent("vRP:requestResult", function(id, ok)
  local obj = requests[id]

  if obj and (obj.source == source) then
    obj.on_respond(source, ok)
    requests[id] = nil

    request_ids:free(id)
  end
end)


local items_menu = {}

function vRP.selectorMenu(player, title, items, cb, keepFocus)
  if items_menu[player] then Wait(500) end
  
  items_menu[player] = {
    on_respond = cb,
    items = {}
  }

  for index, item in pairs(items) do
    items_menu[player].items[index] = {
      index = index,
      name = item[1],
      item = item[2]
    }
  end

  -- openmenu
  vRPclient.openSelectorMenu(player,{title, items_menu[player].items, keepFocus})
end

RegisterServerEvent("vRP:selectorResult", function(item)
  local player = source
  local selector = items_menu[player]

  if (selector and item ~= nil and vRP.getUserId(player)) then
    local select = selector.on_respond
    
    if not item then select(nil) else
      
      local items = selector.items[item]

      if items then
        select(items.item)
      end
    end

    items_menu[player] = nil
  end
end)

RegisterServerEvent("vRP:openMainMenu", function()
  vRP.openMainMenu(source)
end)

AddEventHandler("vRP:playerLeave", function(user_id, source)
  -- force close opened menu on leave
  local id = rclient_menus[source]
  if id ~= nil then
    local menu = client_menus[id]
    if menu and menu.source == source then
      -- call callback
      if menu.def.onclose then
        menu.def.onclose(source)
      end

      menu_ids:free(id)
      client_menus[id] = nil
      rclient_menus[source] = nil
    end
  end
end)

-- ACTIONS MENU

local menu_ids = Tools.newIDGenerator()
local client_menus = {}
local rclient_menus = {}

-- open dynamic menu to client
-- menudef: .name and choices as key/{callback,description} (optional element html description) 
function vRP.openActionsMenu(source,menudef)
  local menudata = {}
  menudata.choices = {}

  -- send menudata to client
  -- choices
  for k,v in pairs(menudef) do
    if k ~= "name" and k ~= "onclose" and k ~= "css" then
      table.insert(menudata.choices,{k,v[2]})
    end
  end

  -- sort choices per entry name
  table.sort(menudata.choices, function(a,b)
    return string.upper(a[1]) < string.upper(b[1])
  end)
  
  -- set new id
  menudata.id = menu_ids:gen()

  -- add client menu
  client_menus[menudata.id] = {def = menudef, source = source}
  rclient_menus[source] = menudata.id

  -- openmenu
  vRPclient.openActionsMenuData(source,{menudata})
end

-- force close player menu
function vRP.closeActionsMenu(source)
  vRPclient.closeActionsMenu(source,{})
end

-- ACTIONS MENU BUILDER

local menu_builders = {}

-- register a menu builder function
--- name: menu type name
--- builder(add_choices, data) (callback, with custom data table)
---- add_choices(choices) (callback to call once to add the built choices to the menu)
function vRP.registerActionsMenuBuilder(name, builder)
  local mbuilders = menu_builders[name]
  if not mbuilders then
    mbuilders = {}
    menu_builders[name] = mbuilders
  end

  table.insert(mbuilders, builder)
end

-- build a menu
--- name: menu name type
--- data: custom data table
-- cbreturn built choices
function vRP.buildActionsMenu(name, data, cbr)
  -- the task will return the built choices even if they aren't complete
  local choices = {}
  local task = Task(cbr, {choices})

  local mbuilders = menu_builders[name]
  if mbuilders then
    local count = #mbuilders

    for k,v in pairs(mbuilders) do -- trigger builders
      -- get back the built choices
      local done = false
      local function add_choices(bchoices)
        if not done then -- prevent a builder to add things more than once
          done = true

          if bchoices then
            for k,v in pairs(bchoices) do
              choices[k] = v
            end
          end

          count = count-1
          if count == 0 then -- end of build
            task({choices})
          end
        end
      end

      v(add_choices, data) -- trigger
    end
  else
    task()
  end
end

-- SERVER TUNNEL API

function tvRP.closeActionsMenu(id)
  local menu = client_menus[id]
  if menu and menu.source == source then

    -- call callback
    if menu.def.onclose then
      menu.def.onclose(source)
    end

    menu_ids:free(id)
    client_menus[id] = nil
    rclient_menus[source] = nil
  end
end

function tvRP.validActionsMenuChoice(id,choice)
  local menu = client_menus[id]
  if menu and menu.source == source then
    -- call choice callback
    local ch = menu.def[choice]
    if ch then
      local cb = ch[1]
      if cb then
        cb(source,choice)
      end
    end
  end
end

AddEventHandler("vRP:playerLeave", function(user_id, source)
  -- force close opened menu on leave
  local id = rclient_menus[source]
  if id ~= nil then
    local menu = client_menus[id]
    if menu and menu.source == source then
      -- call callback
      if menu.def.onclose then
        menu.def.onclose(source)
      end

      menu_ids:free(id)
      client_menus[id] = nil
      rclient_menus[source] = nil
    end
  end
end)


function tvRP.openNearestPlayerMenu()
  local player = source

  vRP.buildActionsMenu("nearply", {player = player}, function(menu)
  menu.onclose = function(player) end

      menu["Basic Actions"] = {function()
          
          vRP.buildActionsMenu("basicply", {player = player}, function(menu)
              menu.onclose = function(player) end

              if menu then
                  vRP.openActionsMenu(player, menu)
              end
          end)

      end, "basic_actions.svg"}

      vRP.openActionsMenu(player, menu)
  end)
end
