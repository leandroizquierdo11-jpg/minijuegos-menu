-- surge-tuneo/server.lua
-- Recurso mínimo: solo guarda y devuelve tuneos por jugador.
-- No tiene client_script: el cliente va por Susano y llama con TriggerServerEvent.

local PREFIX = "surge_t:"

local function Ident(src)
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id:sub(1, 8) == "license:" then return id end
    end
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id:sub(1, 6) == "steam:" then return id end
    end
    return nil
end

RegisterNetEvent("surge:tuneoGuardar", function(modelo, datos)
    local id = Ident(source)
    if not id then return end
    local key = PREFIX .. id .. ":" .. tostring(modelo)
    if datos then
        SetResourceKvp(key, json.encode(datos))
    else
        DeleteResourceKvp(key)
    end
end)

RegisterNetEvent("surge:tuneoCargar", function()
    local src = source
    local id = Ident(src)
    if not id then TriggerClientEvent("surge:tuneosDatos", src, {}); return end
    local pre = PREFIX .. id .. ":"
    local todos = {}
    local h = StartFindKvp(pre)
    if h ~= -1 then
        while true do
            local k = FindKvp(h)
            if not k then break end
            local modelo = k:sub(#pre + 1)
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

RegisterNetEvent("surge:tuneoOlvidar", function(modelo)
    local id = Ident(source)
    if not id then return end
    DeleteResourceKvp(PREFIX .. id .. ":" .. tostring(modelo))
end)
