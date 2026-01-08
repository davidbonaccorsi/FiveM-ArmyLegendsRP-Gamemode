
-- this module describe the group/permission system

-- group functions are used on connected players only
-- multiple groups can be set to the same player, but the gtype config option can be used to set some groups as unique

-- api

local cfg = module("cfg/groups")
local groups = cfg.groups
local users = cfg.users

-- get groups keys of a connected user
function vRP.getUserGroups(user_id)
  if vRP.usersData[user_id] then
    if not vRP.usersData[user_id].userGrades then
      vRP.usersData[user_id].userGrades = {} -- init groups
    end

    return vRP.usersData[user_id].userGrades
  else
    return {}
  end
end

-- add a group to a connected user
function vRP.addUserGroup(user_id,group,expire)
  if not vRP.hasGroup(user_id,group) then
    local user_groups = vRP.getUserGroups(user_id)
    local ngroup = groups[group]
    if ngroup then
      if ngroup._config and ngroup._config.gtype ~= nil then 
        -- copy group list to prevent iteration while removing
        local _user_groups = {}
        for k,v in pairs(user_groups) do
          _user_groups[k] = v
        end

        for k,v in pairs(_user_groups) do -- remove all groups with the same gtype
          local kgroup = groups[k]
          if kgroup and kgroup._config and ngroup._config and kgroup._config.gtype == ngroup._config.gtype then
            vRP.removeUserGroup(user_id,k)
          end
        end
      end

      -- add group
      user_groups[group] = {grade = group, expireTime = expire, time = os.time()}
      local player = vRP.getUserSource(user_id)
      if ngroup._config and ngroup._config.onjoin and player ~= nil then
        ngroup._config.onjoin(player) -- call join callback
      end

      -- trigger join event
      local gtype = nil
      if ngroup._config then
        gtype = ngroup._config.gtype 
      end
      TriggerEvent("vRP:playerJoinGroup", user_id, group, gtype)
    end
  end
end

-- get user group by type
-- return group name or an empty string
function vRP.getUserGroupByType(user_id,gtype)
  local user_groups = vRP.getUserGroups(user_id)
  for k,v in pairs(user_groups) do
    local kgroup = groups[k]
    if kgroup then
      if kgroup._config and kgroup._config.gtype and kgroup._config.gtype == gtype then
        return k
      end
    end
  end

  return ""
end

-- return list of connected users by group
function vRP.getUsersByGroup(group)
  local users = {}

  for k,v in pairs(vRP.rusers) do
    if vRP.hasGroup(tonumber(k),group) then table.insert(users, tonumber(k)) end
  end

  return users
end

-- return list of connected users by permission
function vRP.getUsersByPermission(perm)
  local users = {}

  for k,v in pairs(vRP.rusers) do
    if vRP.hasPermission(tonumber(k),perm) then table.insert(users, tonumber(k)) end
  end

  return users
end

-- remove a group from a connected user
function vRP.removeUserGroup(user_id,group)
  local user_groups = vRP.getUserGroups(user_id)
  if tostring(group) then
	  local groupdef = groups[group]
	  if groupdef and groupdef._config and groupdef._config.onleave then
  		local source = vRP.getUserSource(user_id)
  		if source ~= nil then
  		  groupdef._config.onleave(source) -- call leave callback
  		end
	  end

	  -- trigger leave event
	  local gtype = nil
	  if groupdef and groupdef._config then
		  gtype = groupdef._config.gtype 
	  end
	  TriggerEvent("vRP:playerLeaveGroup", user_id, group, gtype)

	  user_groups[group] = nil -- remove reference
  end
end

-- check if the user has a specific group
function vRP.hasGroup(user_id,group)
  local user_groups = vRP.getUserGroups(user_id)
  return (user_groups[group] ~= nil)
end

exports("getUserGroup", function(user_id, group)
  local user_groups = vRP.getUserGroups(user_id)

  if user_groups[group] then
    return user_groups[group]
  end

  return false
end)

-- check if the user has a specific permission
function vRP.hasPermission(user_id, perm)
  local user_groups = vRP.getUserGroups(user_id)

  local fchar = string.sub(perm,1,1)
    -- precheck negative permission
    local nperm = "-"..perm
    for k,v in pairs(user_groups) do
      if v then -- prevent issues with deleted entry
        local group = groups[k]
        if group then
          for l,w in pairs(group) do -- for each group permission
            if l ~= "_config" and w == nperm then return false end
          end
        end
      end
    end

    -- check if the permission exists
    for k,v in pairs(user_groups) do
      if v then -- prevent issues with deleted entry
        local group = groups[k]
        if group then
          for l,w in pairs(group) do -- for each group permission
            if l ~= "_config" and w == perm then return true end
          end
        end
      end
    end

  return false
end

-- check if the user has a specific list of permissions (all of them)
function vRP.hasPermissions(user_id, perms)
  for k,v in pairs(perms) do
    if not vRP.hasPermission(user_id, v) then
      return false
    end
  end

  return true
end

-- check if the user has a specific list of permissions (at least one)
function vRP.hasOnePermission(user_id, perms)
  for k,v in pairs(perms) do
    if vRP.hasPermission(user_id, v) then
      return true
    end
  end

  return (#perms == 0)
end

-- events

-- player spawn
AddEventHandler("vRP:playerSpawn", function(user_id, source, first_spawn)
	-- first spawn
	if first_spawn then
		-- add groups on user join 
		local user = users[user_id]
		if user ~= nil then
			for k,v in pairs(user) do
				vRP.addUserGroup(user_id,v)
			end
		end
	
		-- call group onspawn callback at spawn
		local user_groups = vRP.getUserGroups(user_id)
		for k,v in pairs(user_groups) do
			local group = groups[k]
			if group and group._config and group._config.onspawn then
				group._config.onspawn(source)
			end
		end
		-- add default group user
		vRP.addUserGroup(user_id,"user")
	end
end)


AddEventHandler("vRP:playerSpawn", function(user_id, player, first_spawn, dbdata)

	if first_spawn then

		  local allGrades = dbdata.userGrades or {}
      
		  for k, v in pairs(allGrades) do
          if v.expireTime and tonumber(v.expireTime) <= os.time() then
            vRPclient.notify(player, {"Tocmai ti-a expirat gradul de "..v.grade})
            vRP.removeUserGroup(user_id, v.grade)
          
            exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {
              ["$unset"] = {["userGrades."..v.grade] = 1}
            }})
          else
            vRPclient.notify(player, {"Te-ai logat cu gradul "..v.grade.."\nExpira in: "..os.date("%d/%m/%Y", tonumber(v.expireTime))})
          end
		  end
	end
end)
