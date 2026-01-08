local modules = {}
function module(rsc, path) -- load a LUA resource file as module
  if path == nil then -- shortcut for vrp, can omit the resource parameter
    path = rsc
    rsc = "vrp"
  end

  local key = rsc..path

  if modules[key] then -- cached module
    return table.unpack(modules[key])
  else
    local f,err = load(LoadResourceFile(rsc, path..".lua"))
    if f then
      local ar = {pcall(f)}
      if ar[1] then
        table.remove(ar,1)
        modules[key] = ar
        return table.unpack(ar)
      else
        modules[key] = nil
        print("[vRP] error loading module "..rsc.."/"..path..":"..ar[2])
      end
    else
      print("[vRP] error parsing module "..rsc.."/"..path..":"..err)
    end
  end
end

-- generate a task metatable (helper to return delayed values with timeout)
--- dparams: default params in case of timeout or empty cbr()
--- timeout: milliseconds, default 5000
function Task(callback, dparams, timeout) 
  if timeout == nil then timeout = 5000 end

  local r = {}
  r.done = false

  local finish = function(params) 
    if not r.done then
      if params == nil then params = dparams or {} end
      r.done = true

      if callback then
        callback(table.unpack(params))
      end
    end
  end

  setmetatable(r, {__call = function(t,params) finish(params) end })
  SetTimeout(timeout, function() finish(dparams) end)

  return r
end

function parseInt(v)
--  return cast(int,tonumber(v))
  local n = tonumber(v)
  if n == nil then 
    return 0
  else
    return math.floor(n)
  end
end

function parseDouble(v)
--  return cast(double,tonumber(v))
  local n = tonumber(v)
  if n == nil then n = 0 end
  return n
end

function parseFloat(v)
  return parseDouble(v)
end

-- will remove chars not allowed/disabled by strchars
-- if allow_policy is true, will allow all strchars, if false, will allow everything except the strchars
local sanitize_tmp = {}
function sanitizeString(str, strchars, allow_policy)
  local r = ""

  -- get/prepare index table
  local chars = sanitize_tmp[strchars]
  if chars == nil then
    chars = {}
    local size = string.len(strchars)
    for i=1,size do
      local char = string.sub(strchars,i,i)
      chars[char] = true
    end

    sanitize_tmp[strchars] = chars
  end

  -- sanitize
  size = string.len(str)
  for i=1,size do
    local char = string.sub(str,i,i)
    if (allow_policy and chars[char]) or (not allow_policy and not chars[char]) then
      r = r..char
    end
  end

  return r
end

function splitString(str, sep)
  if sep == nil then sep = "%s" end

  local t={}
  local i=1

  for str in string.gmatch(str, "([^"..sep.."]+)") do
    t[i] = str
    i = i + 1
  end

  return t
end

function joinStrings(list, sep)
  if sep == nil then sep = "" end

  local str = ""
  local count = 0
  local size = #list
  for k,v in pairs(list) do
    count = count+1
    str = str..v
    if count < size then str = str..sep end
  end

  return str
end

function startsWith(str, prefferable) 
    return str:find('^' .. prefferable) ~= nil
end

function table.len(t)
  local count = 0
  for _, _ in pairs(t) do
    count = count + 1
  end
  return count
end

function daysToSeconds(days)
  return (days or 1) * 24 * 60 * 60
end

function remainingTime(tsX, tsY)
  local delta = tsY - tsX
  local days = math.floor(delta / 86400)
  local hours = math.floor((delta % 86400) / 3600)
  local minutes = math.floor(((delta % 86400) % 3600) / 60)

  -- [days, hours, minutes]
  return days, hours, minutes
end

function passedTime(tsX, tsY)
    local timeDiff = tsY - tsX
  
    local years = math.floor(timeDiff / 31536000) -- 31.536.000 seconds in a year
    timeDiff = timeDiff - (years * 31536000)

    local months = math.floor(timeDiff / 2592000) -- 2.592.000 seconds in a month
    timeDiff = timeDiff - (months * 2592000)

    local days = math.floor(timeDiff / 86400) -- 86.400 seconds in a day
    timeDiff = timeDiff - (days * 86400)

    local hours = math.floor(timeDiff / 3600) -- 3.600 seconds in an hour
    timeDiff = timeDiff - (hours * 3600)

    local minutes = math.floor(timeDiff / 60) -- 60 seconds in a minute
    timeDiff = timeDiff - (minutes * 60)

    local seconds = timeDiff

    -- [years, months, days, hours, minutes, seconds]
    return years, months, days, hours, minutes, seconds
end

function benchmark(name, time, fnc)
  print("--- Benchmark '"..name.."' start: "..os.date("%d/%m/%Y %H:%M:%S").." ---")
  local start = os.clock()
  
  if not fnc or not time then
    print("No function or time provided for benchmarking.")
    return
  end
  
  for i=1, time do
    fnc()  
  end

  local durr = os.clock() - start
  print("--- Done benchmark '"..name.."' in "..string.format("%f",durr).." ---")
end

-- Luaseq like for FiveM

local function wait(self)
  local r = Citizen.Await(self.p)
  if not r then
    if self.r then
      r = self.r
    else
      print("[ERROR] async wait(): Citizen.Await returned (nil) before the areturn call.")
    end
  end
  return table.unpack(r, 1, r.n)
end

local function areturn(self, ...)
  self.r = table.pack(...)
  self.p:resolve(self.r)
end

function concat(...)
  local retval = {}

  for i = 1, select('#', ...) do
      local arg = select(i, ...)

      if type(arg) == 'table' then
          for k, v in pairs(arg) do
              retval[k] = v
          end
      end
  end

  return retval
end

function map(func, array)
  if not array then return {} end
  local newArray = {}
  for i, v in ipairs(array) do
      newArray[i] = func(v)
  end
  return newArray
end

-- create an async returner or a thread (Citizen.CreateThreadNow)
-- func: if passed, will create a thread, otherwise will return an async returner
function async(func)
  if func then
    Citizen.CreateThreadNow(func)
  else
    return setmetatable({ wait = wait, p = promise.new() }, { __call = areturn })
  end
end


function time_diff_in_hours_and_minutes(start_time, end_time)
  local diff_in_seconds = os.difftime(end_time, start_time)
  local diff_in_minutes = diff_in_seconds / 60
  local hours = math.floor(diff_in_minutes / 60)
  local minutes = math.floor(diff_in_minutes % 60)
  return hours, minutes
end

function time_diff_in_hours_minutes_seconds(start_time, end_time)
  local diff_in_seconds = os.difftime(end_time, start_time)
  local diff_in_minutes = math.floor(diff_in_seconds / 60)
  local hours = math.floor(diff_in_minutes / 60)
  local minutes = math.floor(diff_in_minutes % 60)
  local seconds = diff_in_seconds % 60
  return hours, minutes, seconds
end


function firstToUpper(str)
  return (str:gsub("^%l", string.upper))
end

function isUpperCase(str)
  return (str == str:upper())
end
