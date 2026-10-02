-- Entorno simulado: cualquier nativa desconocida devuelve un valor "comodín" que aguanta aritmética
local Z = {}
local function nuevo() return setmetatable({}, Z) end
local zero = nuevo()
Z.__index = function(t, k) if k == "x" or k == "y" or k == "z" then return 0.0 end return zero end
Z.__call = function() return zero end
for _, op in ipairs{"add","sub","mul","div","mod","pow","unm","idiv"} do Z["__"..op] = function() return 0.0 end end
Z.__len = function() return 0 end
Z.__lt = function() return false end
Z.__le = function() return true end
Z.__concat = function(a, b) return (type(a)=="string" and a or "?") .. (type(b)=="string" and b or "?") end
Z.__tostring = function() return "0" end

_FRAME = 0
CUENTA = {}
local errores, vistos = {}, {}
local hilos = {}
local reloj = 1000
local env
env = setmetatable({
  Citizen = {
    CreateThread = function(fn, ...) local co = coroutine.create(fn); hilos[#hilos+1] = co
      local ok, e = coroutine.resume(co, ...); if not ok then errores[#errores+1] = "hilo: "..tostring(e) end end,
    Wait = function() coroutine.yield() end,
    InvokeNative = function() return nil end, ResultAsObject = function() return 0 end,
  },
  GetFinalRenderedCamCoord = function() CUENTA['GetFinalRenderedCamCoord']=(CUENTA['GetFinalRenderedCamCoord'] or 0)+1; return vector3(0.0,0.0,1.0) end,
  GetGameplayCamCoord = function() CUENTA['GetGameplayCamCoord']=(CUENTA['GetGameplayCamCoord'] or 0)+1; return vector3(0.0,0.0,1.0) end,
  GetGameplayCamRot = function() CUENTA['GetGameplayCamRot']=(CUENTA['GetGameplayCamRot'] or 0)+1; return vector3(0.0,0.0,1.0) end,
  GetFinalRenderedCamRot = function() CUENTA['GetFinalRenderedCamRot']=(CUENTA['GetFinalRenderedCamRot'] or 0)+1; return vector3(0.0,0.0,1.0) end,
  GetOffsetFromEntityInWorldCoords = function() CUENTA['GetOffsetFromEntityInWorldCoords']=(CUENTA['GetOffsetFromEntityInWorldCoords'] or 0)+1; return vector3(0.0,0.0,1.0) end,
  GetOffsetFromEntityGivenWorldCoords = function() CUENTA['GetOffsetFromEntityGivenWorldCoords']=(CUENTA['GetOffsetFromEntityGivenWorldCoords'] or 0)+1; return vector3(0.0,0.0,1.0) end,
  GetEntityVelocity = function() CUENTA['GetEntityVelocity']=(CUENTA['GetEntityVelocity'] or 0)+1; return vector3(0.0,0.0,1.0) end,
  GetEntityRotation = function() CUENTA['GetEntityRotation']=(CUENTA['GetEntityRotation'] or 0)+1; return vector3(0.0,0.0,1.0) end,
  GetEntityForwardVector = function() CUENTA['GetEntityForwardVector']=(CUENTA['GetEntityForwardVector'] or 0)+1; return vector3(0.0,0.0,1.0) end,
  GetPedBoneCoords = function() CUENTA['GetPedBoneCoords']=(CUENTA['GetPedBoneCoords'] or 0)+1; return vector3(0.0,0.0,1.0) end,
  GetWorldPositionOfEntityBone = function() CUENTA['GetWorldPositionOfEntityBone']=(CUENTA['GetWorldPositionOfEntityBone'] or 0)+1; return vector3(0.0,0.0,1.0) end,
  GetGameTimer = function() return reloj end,
  GetHashKey = function(s) local h = 5381; for i = 1, #s do h = (h * 33 + s:byte(i)) % 4294967296 end return h end,
  GetEntityModel = function() return 1 end,
  DoesEntityExist = function() return true end,
  IsPedAPlayer = function() return false end,
  IsPedDeadOrDying = function() return false end,
  IsEntityDead = function() return false end,
  GetActivePlayers = function() return {} end,
  GetGamePool = function(t) if t == 'CVehicle' then return {101,102,103,104,105,106,107,108} end return {} end,
  NetworkHasControlOfEntity = function() return true end, IsEntityAVehicle = function(e) return e >= 100 end,
  GetModelDimensions = function() return vector3(-1.0,-2.0,-0.5), vector3(1.0,2.0,0.5) end,
  PlayerPedId = function() return 1 end, PlayerId = function() return 0 end,
  GetPlayerPed = function() return 1 end,
  GetEntityCoords = function(e) if e >= 100 then return vector3((e-100)*12.0, 5.0, 0.0) end return vector3(0.0, 0.0, 0.0) end,
  vector3 = function(x, y, z) return setmetatable({x=x,y=y,z=z}, {
      __add=function(a,b) return vector3(a.x+(b.x or b),a.y+(b.y or b),a.z+(b.z or b)) end,
      __sub=function(a,b) return vector3(a.x-b.x,a.y-b.y,a.z-b.z) end,
      __mul=function(a,b) if type(a)=="number" then a,b=b,a end return vector3(a.x*b,a.y*b,a.z*b) end,
      __len=function(a) return math.sqrt(a.x*a.x+a.y*a.y+a.z*a.z) end,
      __unm=function(a) return vector3(-a.x,-a.y,-a.z) end }) end,
  GetNumberOfPedDrawableVariations = function() return 5 end,
  GetNumberOfPedTextureVariations = function() return 3 end,
  GetNumberOfPedPropDrawableVariations = function() return 5 end,
  GetNumberOfPedPropTextureVariations = function() return 3 end,
  GetPedDrawableVariation = function() return 0 end, GetPedTextureVariation = function() return 0 end,
  GetPedPaletteVariation = function() return 0 end, GetPedPropIndex = function() return -1 end,
  GetPedPropTextureIndex = function() return -1 end, IsPedComponentVariationValid = function() return true end,
  GetNumHairColors = function() return 64 end, GetVehicleModelNumberOfSeats = function() return 4 end,
  GetPedInVehicleSeat = function() return 0 end, GetLastPedInVehicleSeat = function() return 0 end,
  IsPedInAnyVehicle = function() return false end, GetVehiclePedIsIn = function() return 0 end,
  GetVehiclePedIsTryingToEnter = function() return 0 end,
  NetworkIsSessionStarted = function() return true end,
  GetActiveScreenResolution = function() return 1920, 1080 end,
  IsDisabledControlJustPressed = function() return false end, IsDisabledControlPressed = function() return false end,
  GetDisabledControlNormal = function() return 0.0 end,
  GetPlayerName = function() return "x" end, GetPlayerServerId = function() return 1 end,
  Susano = setmetatable({
    GetAsyncKeyState = function(k) local f = _FRAME or 0; if k == 0x4C and ((f > 40 and f < 46) or (f > 300 and f < 306)) then return true end; if k == 0x47 and f > 200 and f < 206 then return true end; return false end,
    LoadTextureFromBuffer = function() return 1 end, LoadFontFromBuffer = function() return 1 end, LoadFont = function() return 1 end,
    WorldToScreen = function() return false, 0, 0 end, GetClipboardText = function() return "" end,
  }, { __index = function() return function() return 0 end end }),
  print = function(...) local t = {...}; for i=1,#t do t[i]=tostring(t[i]) end
    local m = table.concat(t, " "); if m:find("ERROR") or m:find("MontarTodos") then errores[#errores+1] = m end end,
  math = math, string = string, table = table, utf8 = utf8, os = os, io = nil, pcall = pcall, error = error,
  type = type, pairs = pairs, ipairs = ipairs, tostring = tostring, tonumber = tonumber, select = select,
  setmetatable = setmetatable, getmetatable = getmetatable, rawget = rawget, rawset = rawset, next = next, assert = assert,
  collectgarbage = collectgarbage, load = load, unpack = table.unpack,
}, { __index = function(t, k)       -- cualquier nativa que no esté arriba: comodín
  if type(k) == "string" and k:match("^%u") then return function() CUENTA[k] = (CUENTA[k] or 0) + 1; if k:match('^Is') or k:match('^Has') or k:match('^Does') or k:match('^Get.*Exists') then return false end return zero end end end })
env._G = env
vector3 = env.vector3

local f = io.open(arg[1]):read("a")
local chunk, err = load(f, "=cargar_coches", "t", env)
assert(chunk, err)
local ok, e = pcall(chunk)
print("carga del script:", ok and "OK" or ("FALLO: "..tostring(e)))
local ticks = tonumber(arg[2]) or 300
for i = 1, ticks do
  _FRAME = i; reloj = reloj + 16
  for j = #hilos, 1, -1 do local co = hilos[j]
    if coroutine.status(co) == "suspended" then
      local ok2, e2 = coroutine.resume(co)
      if not ok2 then local m = tostring(e2); if not vistos[m] then vistos[m] = true; errores[#errores+1] = "hilo: "..m end end
    end
    if coroutine.status(co) == "dead" then table.remove(hilos, j) end
  end
end
print("hilos vivos tras "..ticks.." frames:", #hilos)
print("errores distintos:", #errores)
for i, m in ipairs(errores) do if i <= 15 then print("  - "..m:sub(1,300)) end end

for _, k in ipairs{"FreezeEntityPosition","SetEntityCollision","AttachEntityToEntity","DetachEntity","SetEntityVelocity","NetworkRequestControlOfEntity","SetVehicleDoorsLocked","TaskPlayAnim","SetEntityCoordsNoOffset"} do print(k, CUENTA[k] or 0) end
