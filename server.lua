-- server.lua  ·  Surge server: tuning persistence
-- Stores each player's vehicle tuning on the server using KVP.
-- All players see tuning changes because the driver applies them as network owner.
-- On restart the server sends saved tuning back to reconnecting clients.

local KVP_PREFIX = "surge_tuneo:"

local function Ident(src)
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id:sub(1, 6) == "steam:" or id:sub(1, 8) == "license:" then return id end
    end
    return nil
end

local function KvpKey(ident, modelo)
    return KVP_PREFIX .. ident .. ":" .. tostring(modelo)
end

RegisterNetEvent("surge:tuneoGuardar")
AddEventHandler("surge:tuneoGuardar", function(modelo, datos)
    local src = source
    local ident = Ident(src)
    if not ident then return end
    local key = KvpKey(ident, modelo)
    if datos then
        SetResourceKvp(key, json.encode(datos))
    else
        DeleteResourceKvp(key)
    end
end)

RegisterNetEvent("surge:tuneoCargar")
AddEventHandler("surge:tuneoCargar", function()
    local src = source
    local ident = Ident(src)
    if not ident then return end
    local prefix = KVP_PREFIX .. ident .. ":"
    local todos = {}
    local h = StartFindKvp(prefix)
    if h ~= -1 then
        while true do
            local k = FindKvp(h)
            if not k then break end
            local modelo = k:sub(#prefix + 1)
            local raw = GetResourceKvpString(k)
            if raw then
                local ok, d = pcall(json.decode, raw)
                if ok and d then todos[modelo] = d end
            end
        end
        EndFindKvp(h)
    end
    TriggerClientEvent("surge:tuneosDatos", src, todos)
end)

RegisterNetEvent("surge:tuneoOlvidar")
AddEventHandler("surge:tuneoOlvidar", function(modelo)
    local src = source
    local ident = Ident(src)
    if not ident then return end
    DeleteResourceKvp(KvpKey(ident, modelo))
end)
