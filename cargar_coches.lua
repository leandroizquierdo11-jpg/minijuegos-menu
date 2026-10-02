-- cargar_coches.lua  ·  v11.0
-- Script para FiveM usando la API de Susano (susano.re)
--   v11.0: INTERFAZ NUEVA, TODO CON SUSANO · ventana de cristal oscuro (desenfoque, degradados, sombras, interruptores, sliders con tirador,
--          scroll con recorte) · ya no se usa el dibujo de GTA (ni DrawRect, ni texto, ni notificaciones, ni DrawMarker, ni contorno):
--          avisos como tarjetas arriba a la derecha · flechas y aros del mundo y contorno del coche (caja 3D) en el overlay ·
--          cuadro de texto de la matrícula con el teclado de Susano · errores en pantalla con Susano · cursor con Susano.GetCursorPos
--          (queda de GTA solo lo que Susano no ofrece: la rueda del ratón y bloquear controles del juego)
--   v10.12: Superman: antes de levantar un coche se vuelve a comprobar con el mismo criterio (pasajeros y último conductor) · los coches lejanos suben a ≤120 m/s en vez de teletransportarse
--   v10.11: Superman: solo coge coches que se pueden controlar (vacíos, de NPC o tuyos; salta los que lleva o usó por última vez otro jugador) · radio de búsqueda hasta 1000 m
--   v10.10: arreglo: la parte de "una sola copia" ya no depende de os/_G (en algunos executors no existen y el script no abría); si falla se desactiva sola
--   v10.9: una sola copia a la vez: al volver a ejecutar el script, la anterior se descarga sola (suelta todo) y esta toma el relevo; sin crash
--   v10.8: Personaje > [Uniformes]: policía, mecánico y médico (tabla UNIFORMES, fácil de ampliar)
--   v10.7: [Copiar ropa]: mochila y demás prendas addon se ponen sin comprobar "validez" (antes se saltaban), se verifican, se reintentan y se avisa de las que fallen
--   v10.6: [Copiar ropa] copia todo: cara, rasgos, maquillaje, ojos y forma de andar (con Fijar mi ropa se reponen)
--   v10.5 (+ reposición inmediata: se vigila en cada frame y los tatuajes se reponen al instante junto a la ropa)
--   v10.5: [Fijar mi ropa]: se compara con la ropa original del servidor: lo que cambie a propósito (quitar pantalón, ponga lo que ponga) se queda; si solo repone su ropa, se vuelve a poner la tuya (también la copiada)
--          · los tatuajes (los del menú y los que ya llevas) se vigilan cada segundo y se reponen siempre; se guardan los reales
--   v10.4: [Fijar mi ropa]: si el servidor te vuelve a poner su ropa, solo se queda lo que él haya cambiado (p. ej. quitar pantalones en su menú); lo demás se repone
--   v10.3: [Copiar ropa] también copia los tatuajes (nativa de FiveM GetPedDecorations)
--   v10.2: Personaje > [Copiar ropa]: lista de jugadores cercanos; al elegir uno te pone toda su ropa (mochila, accesorios, peinado y color de pelo)
--   v10.1: [Fijar mi ropa]: lo que te quites o cambies prenda a prenda (también en el menú del servidor) se queda; si te cambian la ropa de golpe o se te cae la gorra, se repone
--   v9.9: Superman: [L] solo levita (ya no se monta solo) · [M] forzar control montándose en los coches de la zona
--         (salta los que ya controlas) · [O] los coches orbitan al jugador/NPC al que apuntas (otra vez: vuelven a ti;
--         vuelan suaves de un centro a otro) · [G] lanza desde arriba del objetivo.
--   v9.8: MODO SUPERMAN · [L] los coches vacíos o de NPC de la zona suben volando, uno detrás de otro
--         (velocidad ajustable), a unos anillos que giran sobre tu cabeza · [G] los lanzas y caen en picado
--         sobre la cabeza del NPC marcado (o de la flechita, o donde apuntes) · [L] otra vez: los bajas.
--         Nunca coge un coche que conduzca un jugador (los del servidor con NPC al volante sí); apunta a NPCs y jugadores.
--   v9.7: coger coches también con la freecam de Susano (el coche del centro de la pantalla, sin límite)
--   v9.6: sin freecam propia: marcar funciona con la freecam de Susano (se apunta sobre la imagen que ves,
--         Susano.WorldToScreen) · marcas también en el overlay, visibles de lejos
--   v9.5: freecam de Susano (LockCameraPos/SetCameraPos) · marcar a varias personas (también desde la
--         freecam) · cañón real que persigue al objetivo y se coloca a ≤7 m de él (acierta)
--   v9.4: manguera con objetivo (marca a quien apuntas, fijar con clic rueda o desde la lista) · cañón real
--         sobre tu cabeza y camión borrado al soltar · patadas en moto solo con X + clic (sin tecla extra)
--   v9.3: patada en moto real (el menú pulsa X + clic) · manguera real: cañón del camión de bomberos
--         (camión invisible pegado a ti) y agua a presión del juego; lo ven y les afecta a todos
--   v9.2: sin cambio de modo de dibujo · Extras: patadas en moto siempre y manguera de bombero sin camión
--   v9.1: más optimizado (búsquedas caras menos veces, recolector generacional, un solo decodificador)
--   v9.0: optimizado (casi sin basura de memoria por frame, cachés de texto, búsquedas caras
--         limitadas a unas pocas veces por segundo y el overlay en reposo con el menú cerrado)
--
--   · Apuntas a un coche y lo levantas con las manos
--   · Lo llevas encima mientras andas
--   · Al soltarlo, queda apoyado en el suelo delante de ti
--   · Puedes lanzarlo hacia donde miras
--   · Taller de tuneo completo (rendimiento, carrocería, interior, ruedas, pintura, luces...)
--   · Personaje completo: toda la ropa (incluida la addon), cara, rasgos, maquillaje y tatuajes
--   · Control a distancia: maneja a cualquier NPC o animal sin moverte de tu sitio
--   · Animaciones divertidas para ti, los NPCs y con otros jugadores (lista de gente alrededor)
--   · Extras: patadas desde la moto aunque estén bloqueadas y agua del camión de bomberos sin camión
--   · Modo Superman: levitas los coches de alrededor sobre tu cabeza y se los tiras a un NPC
--   · Menú tipo ventana con ratón y teclado (F10)

-- ═════════════════════════════════════════════════════════
-- CONFIGURACIÓN
-- ═════════════════════════════════════════════════════════
-- ═════════════════════════════════════════════════════════
-- UNA SOLA COPIA A LA VEZ
--   Si se vuelve a ejecutar el script con otra copia ya cargada, la vieja se descarga sola:
--   al notar que ya no es la vigente suelta lo que tuviera (coches, cámara, camión de la manguera...)
--   y duerme todos sus hilos; esta copia toma el relevo. Así nunca corren dos a la vez.
--   (Todo va dentro de la tabla Citizen para no gastar variables locales: Lua permite 200 como máximo.)
--   Si el entorno no lo permite (sin _G, por ejemplo), esta parte se desactiva sola.
-- ═════════════════════════════════════════════════════════
local Citizen = (function()
    local Real = Citizen
    local T = setmetatable({ Real = Real }, { __index = Real })
    -- Todo esto es opcional: si el entorno no deja (sin _G, sin escribir globales...), se queda como antes
    pcall(function()
        local G = _G or _ENV
        if type(G) ~= "table" then return end
        local CLAVE = "__cargar_coches_instancia"
        local ID = {}                       -- objeto único de esta copia
        T.HABIA_OTRA = G[CLAVE] ~= nil
        G[CLAVE] = ID
        function T.Wait(ms)
            Real.Wait(ms)
            if G[CLAVE] ~= ID then
                -- Esta copia ya no es la vigente: se limpia una vez y el hilo se duerme para siempre
                local f = T.Limpieza; T.Limpieza = nil
                if f then pcall(f) end
                while true do Real.Wait(60000) end
            end
        end
    end)
    return T
end)()
if Citizen.HABIA_OTRA then print("[cargar coches] Había otra copia cargada: se descarga y esta toma el relevo") end

local Config = {
    activado       = false,  -- mod encendido (se activa desde el menú)
    contorno       = false,  -- iluminar el coche apuntado
    ayudaHud       = false,  -- ayuda de teclas abajo en pantalla
    alcance        = 12.0,   -- distancia máx. para coger un coche apuntado (m)
    alcanceCercano = 4.0,    -- si no apuntas a nada, coge el más cercano en este radio (0 = no)
    fuerzaLanzar   = 30.0,   -- velocidad del coche al lanzarlo (m/s)
    ajusteAltura   = 0.0,    -- afina la altura del coche sobre las manos (m)
    colorMenu      = 1,      -- 1 Morado suave, 2 Azul, 3 Morado, 4 Rojo, 5 Verde, 6 Naranja, 7 Rosa, 8 Blanco
    aparienciaAlIniciar = false, -- ponerse la apariencia guardada al cargar el script
    posesion       = false,  -- poder controlar NPCs apuntándolos
    contornoNpc    = true,   -- flecha sobre el NPC apuntado
    protegerCuerpo = true,   -- tu personaje no recibe daño mientras controlas a otro
    distanciaCamara = 4.5,   -- distancia de la cámara propia detrás del NPC (m)
    camaraPropia   = false,  -- false: la cámara del juego sigue al NPC · true: cámara propia
    npcAgresivo    = true,   -- al hacer clic sin nadie cerca, va a por el más cercano
    compartirNpc   = false,  -- registrar el NPC en red para que lo vean los demás (experimental)
    alcancePosesion = 50.0,  -- distancia máxima para coger un NPC apuntándolo (m)
    radioLista     = 200.0,  -- radio de la lista de NPCs cercanos (m)
    animBucle      = false,  -- repetir gestos y burlas sin parar
    animSoloArriba = false,  -- tus animaciones solo de cintura para arriba (puedes andar)
    descripciones  = true,   -- descripción de la opción abajo del menú
    ventanaX       = 0,      -- desplazamiento de la ventana (se cambia arrastrándola)
    ventanaY       = 0,
    patadasMoto    = false,  -- poder pegar patadas desde la moto siempre (aunque esté bloqueado)
    manguera       = false,  -- echar agua como el camión de bomberos, sin camión
    tipoAgua       = 1,      -- 1 cañón real + boca de incendios, 2 solo cañón real, 3 solo boca de incendios
    alcanceAgua    = 20.0,   -- hasta dónde llega el agua (m)
    -- ── Modo Superman ──────────────────────────────────────
    superman       = false,  -- modo Superman: recoger los coches de la zona y levitarlos sobre tu cabeza
    supermanVelocidad = 6.0, -- velocidad de recogida (coches por segundo: 1 = de uno en uno, 30 = casi de golpe)
    supermanMax    = 12.0,   -- cuántos coches levitas a la vez (hasta 36, en 4 anillos)
    supermanRadio  = 60.0,   -- hasta qué distancia se buscan coches (m)
    supermanFuerza = 60.0,   -- velocidad a la que salen al lanzarlos (m/s)
    supermanModo   = 1,      -- 1 = lanzar todos a la vez · 2 = de uno en uno (y el anillo se rellena)
    colorContorno  = { 60, 180, 255, 255 },
}

-- Guardado automático: cuando algo cambia se marca "pendiente" y se guarda a los pocos segundos
local Guardado = { pendiente = false }

local binds = {
    { id = "agarrar", nombre = "Coger / Soltar", tecla = 0x48 }, -- H
    { id = "lanzar",  nombre = "Lanzar",         tecla = 0x47 }, -- G
    { id = "poseer",  nombre = "Controlar NPC",  tecla = 0x4A }, -- J
    { id = "volver",  nombre = "Dejar de controlar", tecla = 0x4B }, -- K
    { id = "pararAnim", nombre = "Parar animación", tecla = 0x58 }, -- X
    { id = "agua",    nombre = "Echar agua (mantener)", tecla = 0x59 }, -- Y
    { id = "fijarAgua", nombre = "Marcar / desmarcar (agua y Superman)", tecla = 0x04 }, -- clic rueda
    { id = "superRecoger", nombre = "Superman: recoger / bajar coches", tecla = 0x4C }, -- L
    { id = "superLanzar",  nombre = "Superman: lanzar",                 tecla = 0x47 }, -- G
    { id = "superOrbitar", nombre = "Superman: orbitar en objetivo",    tecla = 0x4F }, -- O
    { id = "superMontar", nombre = "Superman: forzar control (montarse)", tecla = 0x4D }, -- M
}
local TECLA_MENU   = 0x79 -- F10

-- ═════════════════════════════════════════════════════════
-- NOMBRES DE TECLAS
-- ═════════════════════════════════════════════════════════
local nombresTeclas = {
    [0x04]="Clic rueda", [0x05]="Ratón X1", [0x06]="Ratón X2",
    [0x08]="Retroceso", [0x09]="Tab", [0x0D]="Enter", [0x10]="Shift", [0x11]="Ctrl",
    [0x12]="Alt", [0x14]="Bloq Mayús", [0x1B]="Esc", [0x20]="Espacio",
    [0x21]="RePág", [0x22]="AvPág", [0x23]="Fin", [0x24]="Inicio",
    [0x25]="Izquierda", [0x26]="Arriba", [0x27]="Derecha", [0x28]="Abajo", [0x2D]="Insert", [0x2E]="Supr",
    [0x6A]="NUM*", [0x6B]="NUM+", [0x6D]="NUM-", [0x6E]="NUM.", [0x6F]="NUM/",
    [0xA0]="Shift Izq", [0xA1]="Shift Der", [0xA2]="Ctrl Izq", [0xA3]="Ctrl Der",
    [0xA4]="Alt Izq", [0xA5]="Alt Der",
}
for i = 0, 9  do nombresTeclas[0x30 + i] = tostring(i) end
for i = 0, 9  do nombresTeclas[0x60 + i] = "NUM" .. i end
for i = 0, 25 do nombresTeclas[0x41 + i] = string.char(65 + i) end
for i = 1, 12 do nombresTeclas[0x6F + i] = "F" .. i end

local function NombreTecla(vk) return nombresTeclas[vk] or string.format("0x%02X", vk) end
local teclasBloqueadas = { [0x01] = true, [0x02] = true, [TECLA_MENU] = true }

-- ═════════════════════════════════════════════════════════
-- ESTADO
-- ═════════════════════════════════════════════════════════
local vehiculo = nil   -- coche que llevamos
local apuntado = nil   -- coche resaltado
local manoLocal = nil  -- posición medida de las manos respecto al personaje
local ultimoVeh = nil  -- último coche soltado/lanzado
local bloqueoEntrarHasta = 0

-- Modo Superman (las funciones están en EXTRAS; la tabla se declara aquí para que
-- el dibujado y el bucle principal puedan verla)
local Super = {
    activo = false,   -- brazos arriba: recogiendo / sujetando coches
    coches = {},      -- coches arriba (o subiendo): { veh, fase = "control" | "sube" | "orbita", ... }
    vuelo = {},       -- coches lanzados, guiados hasta el objetivo
    bajando = {},     -- coches que bajan despacio al soltarlos
    usados = {},      -- [veh] = true mientras el modo lo está usando
    vetados = {},     -- [veh] = hasta cuándo no se vuelve a intentar coger
    abrir = {},       -- [veh] = cuándo se le quitan los seguros de las puertas
    lista = {}, listaPos = 1, proxLista = 0, proxAdd = 0, acum = 1.0,
    girar = 0.0, turno = 0, nArriba = 0, linea = "",
    orbitObj = nil,  -- ped al que orbitan los coches (nil = al jugador)
}

-- Brazos estirados por encima de la cabeza (con otra de respaldo)
local ANIMS_CARGAR = {
    { dict = "anim@mp_rollarcoaster",  name = "hands_up_idle_a_player_one" },
    { dict = "missminuteman_1ig_2",    name = "handsup_base" },
}
local ANIM_CARGAR = ANIMS_CARGAR[1]
local ANIM_LANZAR = { dict = "reaction@shove", name = "shove_var_a" }

local HUESO_MANO_DER, HUESO_MANO_IZQ = 57005, 18905
local H_DESARMADO = GetHashKey("WEAPON_UNARMED")

local R -- render (se define más abajo)

-- ═════════════════════════════════════════════════════════
-- UTILIDADES
-- ═════════════════════════════════════════════════════════
-- Los avisos se dibujan con Susano (arriba a la derecha), no con las notificaciones del juego
local function Notificar(msg)
    if R and R.Aviso then R.Aviso((tostring(msg):gsub("~%a~", ""))) end
end

local bindPorId = {}
local function TeclaDe(id)
    local b = bindPorId[id]
    if not b then
        for _, x in ipairs(binds) do if x.id == id then b = x; bindPorId[id] = x; break end end
        if not b then return nil end
    end
    return b.tecla
end

local function Clamp(v, a, b) return math.max(a, math.min(b, v)) end

-- Base64 -> binario (un solo decodificador para imágenes, fuentes y la lista de animaciones)
local B64 = {}
do
    local abc = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    for i = 1, 64 do B64[abc:byte(i)] = i - 1 end
end
local function Base64Bin(s, ceder)
    s = s:gsub("[^%w%+/=]", "")
    local val, byte, char, floor = B64, string.byte, string.char, math.floor
    local out, n = {}, 0
    for i = 1, #s, 4 do
        local a, b, c, d = byte(s, i, i + 3)
        local vc, vd = val[c], val[d]
        local x = (val[a] or 0) * 262144 + (val[b] or 0) * 4096 + (vc or 0) * 64 + (vd or 0)
        n = n + 1
        if vd then out[n] = char(floor(x / 65536), floor(x / 256) % 256, x % 256)
        elseif vc then out[n] = char(floor(x / 65536), floor(x / 256) % 256)
        else out[n] = char(floor(x / 65536)) end
        if ceder and i % 100000 == 1 then ceder() end
    end
    return table.concat(out)
end

local function CargarAnim(dict)
    if HasAnimDictLoaded(dict) then return true end
    RequestAnimDict(dict)
    local t = 0
    while not HasAnimDictLoaded(dict) and t < 100 do Citizen.Wait(10); t = t + 1 end
    return HasAnimDictLoaded(dict)
end

-- Pide el control de un vehículo y también el de los NPCs que van dentro: un coche que conduce un NPC
-- de otro (p. ej. un coche del servidor) no pasa a ser tuyo si su conductor no lo es también.
local function PedirControlCoche(v)
    NetworkRequestControlOfEntity(v)
    local n = GetVehicleModelNumberOfSeats(GetEntityModel(v)) or 0
    for s = -1, math.max(n - 2, 0) do
        local p = GetPedInVehicleSeat(v, s)
        if p and p ~= 0 and not IsPedAPlayer(p) then NetworkRequestControlOfEntity(p) end
    end
end

local function PedirControl(ent)
    if NetworkHasControlOfEntity(ent) then return true end
    local esCoche = IsEntityAVehicle(ent)
    local t = 0
    while not NetworkHasControlOfEntity(ent) and t < 30 do
        if esCoche then PedirControlCoche(ent) else NetworkRequestControlOfEntity(ent) end
        Citizen.Wait(50); t = t + 1
    end
    return NetworkHasControlOfEntity(ent)
end

-- Dirección exacta en la que mira la cámara del juego
local function DirCamara()
    local rot = GetGameplayCamRot(2)
    local p, y = math.rad(rot.x), math.rad(rot.z)
    local c = math.abs(math.cos(p))
    return vector3(-math.sin(y) * c, math.cos(y) * c, math.sin(p))
end

local function Raycast(desde, hasta, flags, ignorar)
    local h = StartExpensiveSynchronousShapeTestLosProbe(
        desde.x, desde.y, desde.z, hasta.x, hasta.y, hasta.z, flags, ignorar or 0, 7)
    local _, hit, fin, _, ent = GetShapeTestResult(h)
    return hit == 1, fin, ent
end

-- El contorno del coche apuntado ya no usa el del juego: se dibuja una caja en el overlay de Susano (R.CajaEntidad).
-- Se deja esta función vacía porque se llama desde varios sitios.
local function Contorno() end

-- ── La imagen que ves (vale igual con la cámara normal que con la freecam de Susano) ──
-- Punto del mundo -> pantalla (píxeles). Susano.WorldToScreen usa la vista real que se ve;
-- si no está, la del juego.
local function Proyectar(x, y, z)
    local sw, sh = GetActiveScreenResolution()
    if type(Susano) == "table" and type(Susano.WorldToScreen) == "function" then
        local ok, en, sx, sy = pcall(Susano.WorldToScreen, x, y, z)
        if ok and en and sx then return true, sx, sy, sw, sh end
        return false
    end
    local en, nx, ny = GetScreenCoordFromWorldCoord(x, y, z)
    if en then return true, nx * sw, ny * sh, sw, sh end
    return false
end

-- Distancia de la cámara que ves a un punto, sacada de la propia imagen:
-- 1 m vertical en ese punto ocupa en pantalla (focal / distancia) píxeles.
local function DistanciaVista(x, y, z)
    local ok1, _, y1, _, sh = Proyectar(x, y, z)
    local ok2, _, y2 = Proyectar(x, y, z + 1.0)
    if not ok1 or not ok2 then return nil end
    local px = math.abs(y1 - y2)
    if px < 0.5 then return 100000.0 end
    local fov = GetFinalRenderedCamFov()
    if not fov or fov < 1.0 then fov = 50.0 end
    return (sh / 2) / math.tan(math.rad(fov / 2)) / px
end

-- ¿La cámara está lejos de tu personaje? (freecam de Susano o cualquier otra)
local camLejos = { t = -1, v = false }
local function CamaraLejos(ped)
    local ahora = GetGameTimer()
    if ahora - camLejos.t < 100 then return camLejos.v end
    camLejos.t = ahora
    local pc = GetEntityCoords(ped)
    local v
    if #(GetFinalRenderedCamCoord() - pc) > 15.0 then v = true            -- el juego ya lo sabe
    elseif GetFollowPedCamViewMode() == 4 then v = false                  -- primera persona
    else
        local d = DistanciaVista(pc.x, pc.y, pc.z)
        v = (d == nil) or d > 15.0                                         -- detrás de la cámara o lejos
    end
    camLejos.v = v
    return v
end

-- Lo que se ve más cerca del centro de la pantalla (lista de entidades; radio en fracción del alto)
local function MasCentrado(lista, ignorar, radio, alturaExtra, filtro)
    local mejor, mejorD = nil, nil
    for _, e in ipairs(lista) do
        if e ~= ignorar and (not filtro or filtro(e)) then
            local c = GetEntityCoords(e)
            local en, sx, sy, sw, sh = Proyectar(c.x, c.y, c.z + (alturaExtra or 0.0))
            if en then
                local dx, dy = (sx - sw / 2) / sh, (sy - sh / 2) / sh
                local d = math.sqrt(dx * dx + dy * dy)
                if d <= radio and (not mejorD or d < mejorD) then mejor, mejorD = e, d end
            end
        end
    end
    return mejor
end

-- ═════════════════════════════════════════════════════════
-- COCHES DE JUGADORES
--   Solo cuenta el CONDUCTOR: un coche que conduce un jugador no se coge (ni con las manos ni con
--   Superman). Todos los demás sí: vacíos o con un NPC al volante (también los del servidor),
--   vaya quien vaya en los otros asientos.
-- ═════════════════════════════════════════════════════════
local function ConduceJugador(v)
    if not v or v == 0 then return false end
    local p = GetPedInVehicleSeat(v, -1)
    if not p or p == 0 then return false end
    return IsPedAPlayer(p) and true or false
end

-- ═════════════════════════════════════════════════════════
-- APUNTAR
-- ═════════════════════════════════════════════════════════
local cercano = { prox = 0, veh = nil }
local rechazado = nil   -- coche que apuntabas pero lo conduce un jugador (para avisar al pulsar coger)
local function BuscarObjetivo(forzar)
    local ped   = PlayerPedId()
    rechazado = nil
    -- Freecam (la de Susano u otra): el coche que ves en el centro de la pantalla, esté donde esté
    if CamaraLejos(ped) then
        local mio = GetVehiclePedIsIn(ped, false)
        local v = MasCentrado(GetGamePool("CVehicle"), mio, 0.08, 0.3)
        if v and ConduceJugador(v) then rechazado = v; return nil end
        return v
    end
    local desde = GetGameplayCamCoord()
    local hasta = desde + DirCamara() * (Config.alcance + 8.0)

    local hit, _, ent = Raycast(desde, hasta, 1 + 2, ped)
    if hit and ent ~= 0 and IsEntityAVehicle(ent) then
        if #(GetEntityCoords(ent) - GetEntityCoords(ped)) <= Config.alcance then
            if ConduceJugador(ent) then rechazado = ent; return nil end
            return ent
        end
    end

    -- Sin nada apuntado: el más cercano muy pegado a ti.
    -- Recorrer todos los vehículos es lo caro: se hace 5 veces por segundo y se reutiliza.
    if Config.alcanceCercano <= 0 then return nil end
    local ahora = GetGameTimer()
    if forzar or ahora >= cercano.prox then
        cercano.prox = ahora + 200
        local pos = GetEntityCoords(ped)
        local mejor, md = nil, Config.alcanceCercano
        for _, v in ipairs(GetGamePool("CVehicle")) do
            local d = #(GetEntityCoords(v) - pos)
            if d < md and not ConduceJugador(v) then mejor, md = v, d end
        end
        cercano.veh = mejor
    elseif cercano.veh and not DoesEntityExist(cercano.veh) then
        cercano.veh = nil
    end
    return cercano.veh
end

-- ═════════════════════════════════════════════════════════
-- COGER / SOLTAR / LANZAR
-- ═════════════════════════════════════════════════════════
local function PonerAnimCargar(ped)
    for _, an in ipairs(ANIMS_CARGAR) do
        if CargarAnim(an.dict) then
            ANIM_CARGAR = an
            TaskPlayAnim(ped, an.dict, an.name, 4.0, -4.0, -1, 49, 0, false, false, false)
            return
        end
    end
end

-- Coloca el coche con el suelo (bajos) apoyado en las manos
local function Reenganchar()
    if not vehiculo or not DoesEntityExist(vehiculo) then return end
    local ped = PlayerPedId()
    local minD, maxD = GetModelDimensions(GetEntityModel(vehiculo))
    -- Hasta medir las manos, una estimación razonable
    local mx, my, mz = 0.0, 0.15, 1.30
    if manoLocal then mx, my, mz = manoLocal.x, manoLocal.y, manoLocal.z end
    -- Los bajos del coche quedan un poco por encima del punto más bajo (ruedas)
    local bajos = minD.z + (maxD.z - minD.z) * 0.14
    local oz = mz + 0.06 - bajos + Config.ajusteAltura
    AttachEntityToEntity(vehiculo, ped, GetPedBoneIndex(ped, 0),
        mx, my, oz, 0.0, 0.0, 0.0,
        false, false, false, false, 2, true)
end

-- Mide dónde están las manos cuando la animación ya ha levantado los brazos
local function MedirManos(veh)
    Citizen.CreateThread(function()
        for _ = 1, 3 do
            Citizen.Wait(250)
            if vehiculo ~= veh then return end
            local ped = PlayerPedId()
            local r = GetPedBoneCoords(ped, HUESO_MANO_DER, 0.0, 0.0, 0.0)
            local l = GetPedBoneCoords(ped, HUESO_MANO_IZQ, 0.0, 0.0, 0.0)
            local m = GetOffsetFromEntityGivenWorldCoords(ped, (r.x + l.x) / 2, (r.y + l.y) / 2, (r.z + l.z) / 2)
            -- Solo si los brazos están de verdad arriba (evita medir antes de la animación)
            if m.z > 0.9 then
                manoLocal = m
                Reenganchar()
            end
        end
    end)
end

-- Deja la física del vehículo lista para moverse libremente.
-- Barcos: quitar el ancla (anclados ignoran la velocidad). Helis/aviones: rotor y motor parados.
local function PrepararFisica(veh)
    local modelo = GetEntityModel(veh)
    FreezeEntityPosition(veh, false)
    SetEntityDynamic(veh, true)
    SetEntityHasGravity(veh, true)
    if IsThisModelABoat(modelo) or IsThisModelAJetski(modelo) then
        pcall(SetBoatAnchor, veh, false)
        pcall(SetBoatFrozenWhenAnchored, veh, false)
        pcall(SetForcedBoatLocationWhenAnchored, veh, false)
    end
    if IsThisModelAHeli(modelo) or IsThisModelAPlane(modelo) then
        pcall(SetVehicleEngineOn, veh, false, true, true)
        pcall(SetHeliBladesSpeed, veh, 0.0)
    end
    ActivatePhysics(veh)
end

local function Agarrar()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then Notificar("~r~Sal del vehículo primero"); return end

    local veh = apuntado or BuscarObjetivo()
    if not veh then
        if rechazado then Notificar("~r~Ese vehículo lo conduce un jugador")
        else Notificar("~r~Apunta a un coche (máx. " .. math.floor(Config.alcance) .. " m)") end
        return
    end
    -- Última comprobación justo antes de cogerlo: si lo conduce un jugador, no se toca
    if ConduceJugador(veh) then Notificar("~r~Ese vehículo lo conduce un jugador"); return end

    if not PedirControl(veh) then Notificar("~r~No se pudo obtener el control del vehículo"); return end
    if ConduceJugador(veh) then Notificar("~r~Ese vehículo lo conduce un jugador"); return end

    Contorno(veh, false)
    apuntado = nil
    vehiculo = veh

    SetEntityInvincible(veh, true)
    SetVehicleDoorsLocked(veh, 2)                 -- que no te puedas subir mientras lo llevas
    SetCurrentPedWeapon(ped, H_DESARMADO, true)
    ClearPedTasks(ped)
    PonerAnimCargar(ped)
    Reenganchar()
    MedirManos(veh)
end

-- Suelta el coche (lo desengancha). Si "enSitio" es true no lo recoloca en el suelo.
local function Soltar(enSitio)
    local ped = PlayerPedId()
    local veh = vehiculo
    vehiculo = nil
    StopAnimTask(ped, ANIM_CARGAR.dict, ANIM_CARGAR.name, 2.0)
    if not veh or not DoesEntityExist(veh) then return nil end

    DetachEntity(veh, true, true)
    ultimoVeh = veh
    bloqueoEntrarHasta = GetGameTimer() + 1500

    if not enSitio then
        -- Dejarlo apoyado en el suelo delante del jugador
        local pos  = GetEntityCoords(ped)
        local fwd  = GetEntityForwardVector(ped)
        local minD, maxD = GetModelDimensions(GetEntityModel(veh))
        local dist = 1.2 + math.max(maxD.x - minD.x, maxD.y - minD.y) / 2
        SetEntityCoords(veh, pos.x + fwd.x * dist, pos.y + fwd.y * dist, pos.z + 0.5, false, false, false, false)
        SetEntityHeading(veh, GetEntityHeading(ped) + 90.0)
        SetVehicleOnGroundProperly(veh)
        SetEntityVelocity(veh, 0.0, 0.0, 0.0)
    end
    SetEntityInvincible(veh, false)
    PrepararFisica(veh)

    -- Abrir las puertas otra vez cuando ya no haya peligro de subirse sin querer
    Citizen.CreateThread(function()
        Citizen.Wait(2000)
        if DoesEntityExist(veh) and vehiculo ~= veh then SetVehicleDoorsLocked(veh, 1) end
    end)
    return veh
end

-- Punto exacto del mundo que hay en el centro de tu pantalla.
-- El rayo empieza por delante del coche que llevas, para no chocar con él.
local function PuntoMira(veh, ped)
    local cam  = GetGameplayCamCoord()
    local dir  = DirCamara()
    local salto = #(GetEntityCoords(veh) - cam) + 4.0
    local desde = cam + dir * salto
    local hasta = cam + dir * 300.0
    local hit, fin = Raycast(desde, hasta, -1, ped)
    if hit then return fin end
    return hasta
end

local function Lanzar()
    if not vehiculo then return end
    local ped    = PlayerPedId()
    local veh0   = vehiculo
    local punto  = PuntoMira(veh0, ped)   -- se calcula antes de soltarlo
    local veh    = Soltar(true)
    if not veh then return end

    -- Dirección desde el coche hasta el punto al que miras
    local p = GetEntityCoords(veh)
    local v = punto - p
    local dist = #v
    if dist < 3.0 then
        v, dist = DirCamara(), 1.0
    end
    local d = v / dist

    -- Separarlo un poco antes de darle velocidad, para que no choque contigo
    SetEntityCoordsNoOffset(veh, p.x + d.x * 1.5, p.y + d.y * 1.5, p.z + d.z * 1.5, false, false, false)

    local f = Config.fuerzaLanzar
    -- Compensar la gravedad para que caiga donde apuntas (hasta ~80 m)
    local t = math.min(dist, 80.0) / f
    local vx, vy, vz = d.x * f, d.y * f, d.z * f + 0.5 * 9.81 * t
    SetEntityRotation(veh, 0.0, 0.0, GetEntityHeading(veh), 2, true)
    NetworkRequestControlOfEntity(veh)
    PrepararFisica(veh)
    SetEntityVelocity(veh, vx, vy, vz)

    -- Durante un momento: sin colisión contigo y velocidad sostenida.
    -- Barcos y helicópteros tardan unos frames en aceptar la velocidad, así que
    -- se reaplica hasta que el vehículo va de verdad a la velocidad pedida.
    Citizen.CreateThread(function()
        local inicio = GetGameTimer()
        local aceptada = 0
        while DoesEntityExist(veh) and GetGameTimer() - inicio < 700 do
            SetEntityNoCollisionEntity(veh, ped, true)
            if aceptada < 4 and GetGameTimer() - inicio < 400 then
                if GetEntitySpeed(veh) >= f * 0.8 then aceptada = aceptada + 1 else aceptada = 0 end
                NetworkRequestControlOfEntity(veh)
                ActivatePhysics(veh)
                SetEntityVelocity(veh, vx, vy, vz)
            end
            Citizen.Wait(0)
        end
    end)

    if CargarAnim(ANIM_LANZAR.dict) then
        TaskPlayAnim(ped, ANIM_LANZAR.dict, ANIM_LANZAR.name, 8.0, -8.0, 900, 48, 0, false, false, false)
    end
end

-- ═════════════════════════════════════════════════════════
-- ENTRADA DE TECLADO
-- ═════════════════════════════════════════════════════════
-- Detección propia de pulsaciones: se mira si la tecla está abajo ahora y no lo estaba antes.
-- (El aviso de "pulsada" de Windows lo consume el primer programa que lo lee, p. ej. el
--  propio Susano, y entonces el script no se enteraba de la pulsación.)
-- El estado de cada tecla se guarda en una tabla fija por tecla (sin crear tablas nuevas cada frame)
local Teclas = { frame = 0, antes = {}, ahora = {} }
local function Tecla(vk)
    local e = Teclas.ahora[vk]
    if not e then e = { f = -1, down = false, pressed = false }; Teclas.ahora[vk] = e end
    if e.f ~= Teclas.frame then
        local ok, abajo = pcall(Susano.GetAsyncKeyState, vk)
        abajo = (ok and abajo) and true or false
        e.f, e.down, e.pressed = Teclas.frame, abajo, abajo and not Teclas.antes[vk]
        Teclas.antes[vk] = abajo
    end
    return e.down, e.pressed
end
function Teclas.NuevoFrame() Teclas.frame = Teclas.frame + 1 end
-- Toma el estado actual de todas las teclas como "ya visto" (evita pulsaciones fantasma)
function Teclas.Instantanea()
    local ahora, antes = Teclas.ahora, Teclas.antes
    for vk = 0x01, 0xFE do
        local ok, abajo = pcall(Susano.GetAsyncKeyState, vk)
        antes[vk] = (ok and abajo) and true or false
        local e = ahora[vk]
        if e then e.f = -1 end
    end
end
local function Pulsada(vk) local _, p = Tecla(vk); return p end

-- Pulsación con auto-repetición al mantener (para flechas)
local repeticion = {}
local function Repetir(vk)
    local down, pressed = Tecla(vk)
    local t = GetGameTimer()
    if pressed then repeticion[vk] = t + 350; return true end
    if down and repeticion[vk] and t >= repeticion[vk] then repeticion[vk] = t + 55; return true end
    if not down then repeticion[vk] = nil end
    return false
end

local function EscanearTecla()
    for vk = 0x03, 0xFE do
        if not teclasBloqueadas[vk] then
            local _, p = Tecla(vk)
            if p then return vk end
        end
    end
end

-- ═════════════════════════════════════════════════════════
-- MENÚ (estilo ventana: barra lateral + paneles en dos columnas)
--   Se maneja con ratón (clic, arrastrar barras) o con teclado.
--   Para añadir una sección: una entrada más en "Secciones".
-- ═════════════════════════════════════════════════════════
local Menu = { abierto = false, seccion = 1, col = 0, pos = { 1, 1 }, dirSec = 1,
               esperandoTecla = false, aviso = nil, avisoHasta = 0 }

local function Avisar(t) Menu.aviso = t; Menu.avisoHasta = GetGameTimer() + 2200; if R and R.Aviso then R.Aviso(t) end end
local function Texto(v) if type(v) == "function" then return v() end return v end

-- Tipos de opción:
--   toggle  -> key (en Config)                   casilla
--   slider  -> key, min, max, paso, fmt          barra con valor
--   lista   -> key, opciones (nombres)           desplegable
--   bind    -> bind (entrada de la tabla binds)  tecla
--   accion  -> fn                                botón
--   texto   -> solo informativo (no seleccionable)
local function Toggle(label, key, desc) return { tipo = "toggle", label = label, key = key, desc = desc } end
local function Slider(label, key, min, max, paso, fmt, desc)
    return { tipo = "slider", label = label, key = key, min = min, max = max, paso = paso, fmt = fmt, desc = desc }
end
local function Lista(label, key, opciones, desc)
    return { tipo = "lista", label = label, key = key, opciones = opciones, desc = desc }
end
local function Accion(label, fn, desc) return { tipo = "accion", label = label, fn = fn, desc = desc } end
local function T(f) return { tipo = "texto", label = f } end

local bindsPorDefecto = {}
for i, b in ipairs(binds) do bindsPorDefecto[i] = b.tecla end
-- "[H]" de una acción; se guarda mientras no cambie la tecla
local cacheK = {}
local function K(id)
    local tecla = TeclaDe(id)
    local c = cacheK[id]
    if not c or c[1] ~= tecla then c = { tecla, "[" .. NombreTecla(tecla) .. "]" }; cacheK[id] = c end
    return c[2]
end

-- Colores de acento disponibles
local COLORES = {
    { "Morado suave", { 0.71, 0.60, 1.00 } },
    { "Azul",    { 0.04, 0.62, 1.00 } },
    { "Morado",  { 0.58, 0.36, 1.00 } },
    { "Rojo",    { 0.92, 0.20, 0.28 } },
    { "Verde",   { 0.18, 0.80, 0.45 } },
    { "Naranja", { 1.00, 0.55, 0.12 } },
    { "Rosa",    { 1.00, 0.33, 0.64 } },
    { "Blanco",  { 0.93, 0.93, 0.95 } },
}
local nombresColores = {}
for i, c in ipairs(COLORES) do nombresColores[i] = c[1] end

local itemsTeclas = {}
for _, b in ipairs(binds) do
    itemsTeclas[#itemsTeclas + 1] = { tipo = "bind", label = b.nombre, bind = b,
        desc = "Haz clic (o Enter) y pulsa la tecla que quieras usar." }
end
itemsTeclas[#itemsTeclas + 1] = Accion("Restaurar teclas",
    function() for i, b in ipairs(binds) do b.tecla = bindsPorDefecto[i] end; Guardado.pendiente = true; Avisar("Teclas restauradas") end,
    "Vuelve a poner las teclas como venían.")

-- ═════════════════════════════════════════════════════════
-- TUNEO (taller completo)
--   Se tunea el vehículo en el que vas; si vas a pie, el que llevas en las manos,
--   el que apuntas o el más cercano (6 m).
-- ═════════════════════════════════════════════════════════
local Tuneo, Nativa, NombreVehiculo, CATEGORIAS, panelCategorias, panelOpciones, ActualizarTuneo
do
Tuneo = { cat = 1, veh = nil, sucio = true, escribiendo = false }

-- Algunas funciones nativas cambian de nombre entre versiones: se usa la que exista
function Nativa(...)
    for _, nombre in ipairs({ ... }) do
        local ok, f = pcall(function() return (_ENV and _ENV[nombre]) or (_G and _G[nombre]) end)
        if ok and type(f) == "function" then return f end
    end
    return function() return 0 end
end
local N_GetXenon  = Nativa("GetVehicleXenonLightColorIndex", "GetVehicleXenonLightsColor", "GetVehicleXenonLightsColour", "GetVehicleHeadlightsColour")
local N_SetXenon  = Nativa("SetVehicleXenonLightColorIndex", "SetVehicleXenonLightsColor", "SetVehicleXenonLightsColour", "SetVehicleHeadlightsColour")
local N_GetInter  = Nativa("GetVehicleInteriorColour", "GetVehicleInteriorColor", "GetVehicleExtraColour5")
local N_SetInter  = Nativa("SetVehicleInteriorColour", "SetVehicleInteriorColor", "SetVehicleExtraColour5")
local N_GetSalpi  = Nativa("GetVehicleDashboardColour", "GetVehicleDashboardColor", "GetVehicleExtraColour6")
local N_SetSalpi  = Nativa("SetVehicleDashboardColour", "SetVehicleDashboardColor", "SetVehicleExtraColour6")

local function VehiculoTuneo()
    local ped = PlayerPedId()
    local v = GetVehiclePedIsIn(ped, false)
    if v ~= 0 then return v end
    if vehiculo and DoesEntityExist(vehiculo) then return vehiculo end
    if apuntado and DoesEntityExist(apuntado) then return apuntado end
    local pos, mejor, md = GetEntityCoords(ped), nil, 6.0
    for _, c in ipairs(GetGamePool("CVehicle")) do
        local d = #(GetEntityCoords(c) - pos)
        if d < md then mejor, md = c, d end
    end
    return mejor
end

function NombreVehiculo(v)
    local disp = GetDisplayNameFromVehicleModel(GetEntityModel(v))
    local txt = GetLabelText(disp)
    if not txt or txt == "NULL" or txt == "" then txt = disp end
    return txt
end

-- Ejecuta un cambio sobre el vehículo del taller (con control de red y kit de piezas)
local function Aplicar(fn)
    local v = Tuneo.veh
    if not v or not DoesEntityExist(v) then return end
    NetworkRequestControlOfEntity(v)
    SetVehicleModKit(v, 0)
    fn(v)
end

-- Nombre de una pieza (si el juego no tiene nombre, "Opción N")
local function NombrePieza(v, t, i, generico)
    local lbl = GetModTextLabel(v, t, i)
    if lbl and lbl ~= "" then
        local txt = GetLabelText(lbl)
        if txt and txt ~= "NULL" and txt ~= "" then return txt end
    end
    return (generico or "Opción") .. " " .. (i + 1)
end

-- Opción de pieza: lista "De serie" + todas las piezas que tiene este vehículo
local function Pieza(label, t, generico, desc)
    local v = Tuneo.veh
    local n = GetNumVehicleMods(v, t)
    if not n or n <= 0 then return nil end
    local ops = { "De serie" }
    for i = 0, n - 1 do ops[#ops + 1] = NombrePieza(v, t, i, generico) end
    return { tipo = "lista", label = label, opciones = ops, desc = desc or ("Pieza: " .. label .. "."),
        get = function() return GetVehicleMod(Tuneo.veh, t) + 2 end,
        set = function(i)
            Aplicar(function(veh)
                local custom = (t == 23 or t == 24) and GetVehicleModVariation(veh, t) or false
                SetVehicleMod(veh, t, i - 2, custom)
            end)
        end }
end

-- Mejora que se activa o desactiva (turbo, xenón, humo)
local function Mejora(label, t, desc)
    return { tipo = "toggle", label = label, desc = desc,
        get = function() return IsToggleModOn(Tuneo.veh, t) end,
        set = function(on) Aplicar(function(veh) ToggleVehicleMod(veh, t, on) end) end }
end

local function Casilla(label, get, set, desc)
    return { tipo = "toggle", label = label, desc = desc,
        get = function() return get(Tuneo.veh) end,
        set = function(on) Aplicar(function(veh) set(veh, on) end) end }
end

local function ListaV(label, opciones, get, set, desc)
    return { tipo = "lista", label = label, opciones = opciones, desc = desc,
        get = function() return get(Tuneo.veh) end,
        set = function(i) Aplicar(function(veh) set(veh, i) end) end }
end

local function Barra(label, min, max, paso, fmt, get, set, desc)
    return { tipo = "slider", label = label, min = min, max = max, paso = paso, fmt = fmt, desc = desc,
        get = function() return get(Tuneo.veh) end,
        set = function(val) Aplicar(function(veh) set(veh, val) end) end }
end

local function Boton(label, fn, desc)
    return { tipo = "accion", label = label, desc = desc,
        fn = function() Aplicar(fn) end }
end

-- ── Colores ───────────────────────────────────────────────
local PRESETS = {
    { "Negro", 12, 12, 12 }, { "Blanco", 240, 240, 240 }, { "Gris", 100, 100, 105 }, { "Plata", 175, 178, 184 },
    { "Rojo", 200, 20, 25 }, { "Rojo oscuro", 110, 10, 15 }, { "Naranja", 240, 110, 20 }, { "Amarillo", 245, 200, 20 },
    { "Verde", 30, 160, 60 }, { "Verde lima", 140, 220, 30 }, { "Azul", 20, 80, 210 }, { "Azul claro", 60, 165, 240 },
    { "Morado", 110, 40, 180 }, { "Rosa", 240, 80, 160 }, { "Marrón", 90, 55, 30 }, { "Dorado", 200, 160, 60 },
}
local nombresPresets = { "Personalizado" }
for _, p in ipairs(PRESETS) do nombresPresets[#nombresPresets + 1] = p[1] end

local COLORES_JUEGO = {}
for i = 0, 159 do COLORES_JUEGO[i + 1] = "Color " .. i end

-- Grupo de 4 opciones para un color RGB: color rápido + rojo/verde/azul
local function GrupoRGB(items, nombre, leer, escribir)
    items[#items + 1] = ListaV(nombre, nombresPresets,
        function(v)
            local r, g, b = leer(v)
            for i, p in ipairs(PRESETS) do
                if math.abs(p[2] - r) < 3 and math.abs(p[3] - g) < 3 and math.abs(p[4] - b) < 3 then return i + 1 end
            end
            return 1
        end,
        function(v, i) if i > 1 then local p = PRESETS[i - 1]; escribir(v, p[2], p[3], p[4]) end end,
        "Elige un color rápido o ajústalo con las barras de rojo, verde y azul.")
    local canales = { "Rojo", "Verde", "Azul" }
    for c = 1, 3 do
        items[#items + 1] = Barra("   " .. canales[c], 0, 255, 5, "%.0f",
            function(v) local rgb = { leer(v) }; return rgb[c] end,
            function(v, val)
                local rgb = { leer(v) }; rgb[c] = math.floor(val)
                escribir(v, rgb[1], rgb[2], rgb[3])
            end, "Canal " .. canales[c]:lower() .. " del color (0 a 255).")
    end
end

-- ── Categorías ────────────────────────────────────────────
local TIPOS_LLANTA = { "Deportivas", "Muscle", "Lowrider", "SUV", "Todoterreno", "Tuner", "Moto",
                       "Alta gama", "Benny's originales", "Benny's a medida", "Monoplaza", "Calle", "Circuito" }
local TIPOS_PINTURA = { "Normal", "Metalizada", "Perlada", "Mate", "Metal", "Cromo" }
local TINTADOS = { "Sin tintar", "Negro total", "Humo oscuro", "Humo claro", "De serie", "Limusina", "Verde" }
local MATRICULAS = { "Azul sobre blanco 1", "Amarillo sobre negro", "Amarillo sobre azul",
                     "Azul sobre blanco 2", "Azul sobre blanco 3", "Yankton" }
local COLORES_XENON = { "De serie", "Blanco", "Azul", "Azul eléctrico", "Verde menta", "Verde lima", "Amarillo",
                        "Dorado", "Naranja", "Rojo", "Rosa poni", "Rosa intenso", "Morado", "Luz negra" }

-- Pide un texto con un cuadro dibujado por Susano (el teclado se lee con Susano.GetAsyncKeyState)
local function PedirTexto(titulo, inicial, max, cb)
    Tuneo.escribiendo = true
    Menu.prompt = { titulo = titulo, texto = inicial or "", max = max or 8, cb = cb, t0 = GetGameTimer() }
end

local PIEZAS_CARROCERIA = {
    { 0, "Alerón" }, { 1, "Paragolpes delantero" }, { 2, "Paragolpes trasero" }, { 3, "Taloneras" },
    { 4, "Escape" }, { 5, "Jaula" }, { 6, "Rejilla" }, { 7, "Capó" }, { 8, "Aleta izquierda" },
    { 9, "Aleta derecha" }, { 10, "Techo" }, { 48, "Vinilo" },
}
local PIEZAS_INTERIOR = {
    { 25, "Soporte de matrícula" }, { 26, "Matrícula decorativa" }, { 27, "Molduras" }, { 28, "Adornos" },
    { 29, "Salpicadero" }, { 30, "Esferas" }, { 31, "Altavoces de puerta" }, { 32, "Asientos" },
    { 33, "Volante" }, { 34, "Palanca de cambios" }, { 35, "Placas" }, { 36, "Altavoces" },
    { 37, "Maletero" }, { 38, "Hidráulica" }, { 39, "Bloque del motor" }, { 40, "Filtro de aire" },
    { 41, "Puntales" }, { 42, "Tapa de arcos" }, { 43, "Antenas" }, { 44, "Molduras exteriores" },
    { 45, "Depósito" }, { 46, "Ventanillas" },
}

local function TodoAlMaximo(v)
    for _, t in ipairs({ 11, 12, 13, 15, 16 }) do
        local n = GetNumVehicleMods(v, t)
        if n > 0 then SetVehicleMod(v, t, n - 1, false) end
    end
    ToggleVehicleMod(v, 18, true)
    ToggleVehicleMod(v, 22, true)
    SetVehicleTyresCanBurst(v, false)
end

local function Aleatorio(v)
    for t = 0, 48 do
        if t ~= 17 and t ~= 18 and t ~= 19 and t ~= 20 and t ~= 21 and t ~= 22 and t ~= 23 and t ~= 24 then
            local n = GetNumVehicleMods(v, t)
            if n > 0 then SetVehicleMod(v, t, math.random(-1, n - 1), false) end
        end
    end
    local n = GetNumVehicleMods(v, 23)
    if n > 0 then SetVehicleMod(v, 23, math.random(-1, n - 1), false) end
    SetVehicleCustomPrimaryColour(v, math.random(0, 255), math.random(0, 255), math.random(0, 255))
    SetVehicleCustomSecondaryColour(v, math.random(0, 255), math.random(0, 255), math.random(0, 255))
    SetVehicleWindowTint(v, math.random(0, 6))
end

local function QuitarTodo(v)
    for t = 0, 48 do
        if t == 18 or t == 20 or t == 22 then ToggleVehicleMod(v, t, false)
        elseif GetNumVehicleMods(v, t) > 0 then RemoveVehicleMod(v, t) end
    end
    ClearVehicleCustomPrimaryColour(v)
    ClearVehicleCustomSecondaryColour(v)
    for i = 0, 3 do SetVehicleNeonLightEnabled(v, i, false) end
    SetVehicleWindowTint(v, 0)
    SetVehicleTyresCanBurst(v, true)
end

local function Reparar(v)
    SetVehicleFixed(v)
    SetVehicleDeformationFixed(v)
    SetVehicleUndriveable(v, false)
    SetVehicleEngineHealth(v, 1000.0)
    SetVehicleBodyHealth(v, 1000.0)
    SetVehiclePetrolTankHealth(v, 1000.0)
    SetVehicleDirtLevel(v, 0.0)
end

local function Anadir(lista, it) if it then lista[#lista + 1] = it end end

CATEGORIAS = {
    { "Rendimiento", function(I)
        Anadir(I, Pieza("Motor", 11, "Nivel", "Mejora el motor: más aceleración y velocidad."))
        Anadir(I, Pieza("Frenos", 12, "Nivel", "Frenos más potentes."))
        Anadir(I, Pieza("Transmisión", 13, "Nivel", "Cambios de marcha más rápidos."))
        Anadir(I, Pieza("Suspensión", 15, "Nivel", "Baja el coche y mejora el agarre."))
        Anadir(I, Pieza("Blindaje", 16, "Nivel", "Más resistencia a golpes y disparos."))
        Anadir(I, Mejora("Turbo", 18, "Más aceleración al salir."))
        Anadir(I, Boton("Todo al máximo", function(v) TodoAlMaximo(v); Avisar("Rendimiento al máximo") end,
            "Motor, frenos, transmisión, suspensión y blindaje al máximo, turbo, xenón y ruedas antipinchazos."))
    end },
    { "Carrocería", function(I)
        for _, p in ipairs(PIEZAS_CARROCERIA) do Anadir(I, Pieza(p[2], p[1])) end
        local nl = GetVehicleLiveryCount(Tuneo.veh)
        if nl and nl > 0 then
            local ops = {}
            for i = 1, nl do ops[i] = "Diseño " .. i end
            Anadir(I, ListaV("Diseño de fábrica", ops,
                function(v) return math.max(GetVehicleLivery(v), 0) + 1 end,
                function(v, i) SetVehicleLivery(v, i - 1) end, "Diseños de pintura que trae el vehículo."))
        end
        if #I == 0 then I[1] = { tipo = "texto", label = "Este vehículo no tiene piezas de carrocería" } end
    end },
    { "Interior", function(I)
        for _, p in ipairs(PIEZAS_INTERIOR) do Anadir(I, Pieza(p[2], p[1])) end
        if #I == 0 then I[1] = { tipo = "texto", label = "Este vehículo no tiene piezas de interior" } end
    end },
    { "Ruedas", function(I)
        Anadir(I, ListaV("Tipo de llanta", TIPOS_LLANTA,
            function(v) return GetVehicleWheelType(v) + 1 end,
            function(v, i) SetVehicleWheelType(v, i - 1); SetVehicleMod(v, 23, -1, false); Tuneo.sucio = true end,
            "Familia de llantas. Al cambiarla se cargan las llantas de ese tipo."))
        Anadir(I, Pieza("Llantas", 23, "Llanta", "Modelo de llanta."))
        if IsThisModelABike(GetEntityModel(Tuneo.veh)) then Anadir(I, Pieza("Llanta trasera", 24, "Llanta")) end
        Anadir(I, Casilla("Neumáticos personalizados",
            function(v) return GetVehicleModVariation(v, 23) end,
            function(v, on) SetVehicleMod(v, 23, GetVehicleMod(v, 23), on) end,
            "Neumáticos con dibujo especial."))
        Anadir(I, Casilla("Antipinchazos",
            function(v) return not GetVehicleTyresCanBurst(v) end,
            function(v, on) SetVehicleTyresCanBurst(v, not on) end,
            "Las ruedas no revientan con disparos."))
        Anadir(I, ListaV("Color de llantas", COLORES_JUEGO,
            function(v) local _, w = GetVehicleExtraColours(v); return w + 1 end,
            function(v, i) local p = GetVehicleExtraColours(v); SetVehicleExtraColours(v, p, i - 1) end,
            "Color de la paleta del juego para las llantas."))
        Anadir(I, Mejora("Humo de neumáticos", 20, "Humo de color al derrapar."))
        GrupoRGB(I, "Color del humo",
            function(v) return GetVehicleTyreSmokeColor(v) end,
            function(v, r, g, b) ToggleVehicleMod(v, 20, true); SetVehicleTyreSmokeColor(v, r, g, b) end)
    end },
    { "Pintura", function(I)
        GrupoRGB(I, "Color principal",
            function(v) return GetVehicleCustomPrimaryColour(v) end,
            function(v, r, g, b) SetVehicleCustomPrimaryColour(v, r, g, b) end)
        GrupoRGB(I, "Color secundario",
            function(v) return GetVehicleCustomSecondaryColour(v) end,
            function(v, r, g, b) SetVehicleCustomSecondaryColour(v, r, g, b) end)
        Anadir(I, ListaV("Acabado principal", TIPOS_PINTURA,
            function(v) local t = GetVehicleModColor_1(v); return Clamp((t or 0) + 1, 1, #TIPOS_PINTURA) end,
            function(v, i)
                local custom, r, g, b = GetIsVehiclePrimaryColourCustom(v), GetVehicleCustomPrimaryColour(v)
                SetVehicleModColor_1(v, i - 1, 0, 0)
                if custom then SetVehicleCustomPrimaryColour(v, r, g, b) end
            end, "Tipo de pintura: normal, metalizada, perlada, mate, metal o cromo."))
        Anadir(I, ListaV("Acabado secundario", TIPOS_PINTURA,
            function(v) local t = GetVehicleModColor_2(v); return Clamp((t or 0) + 1, 1, #TIPOS_PINTURA) end,
            function(v, i)
                local custom, r, g, b = GetIsVehicleSecondaryColourCustom(v), GetVehicleCustomSecondaryColour(v)
                SetVehicleModColor_2(v, i - 1, 0)
                if custom then SetVehicleCustomSecondaryColour(v, r, g, b) end
            end, "Tipo de pintura del color secundario."))
        Anadir(I, ListaV("Perlado", COLORES_JUEGO,
            function(v) local p = GetVehicleExtraColours(v); return p + 1 end,
            function(v, i) local _, w = GetVehicleExtraColours(v); SetVehicleExtraColours(v, i - 1, w) end,
            "Brillo perlado encima del color principal."))
        Anadir(I, ListaV("Color del interior", COLORES_JUEGO,
            function(v) return (N_GetInter(v) or 0) + 1 end,
            function(v, i) N_SetInter(v, i - 1) end, "Color de la tapicería."))
        Anadir(I, ListaV("Color del salpicadero", COLORES_JUEGO,
            function(v) return (N_GetSalpi(v) or 0) + 1 end,
            function(v, i) N_SetSalpi(v, i - 1) end, "Color del salpicadero."))
    end },
    { "Luces", function(I)
        Anadir(I, Mejora("Faros de xenón", 22, "Faros más brillantes."))
        Anadir(I, ListaV("Color del xenón", COLORES_XENON,
            function(v) local c = N_GetXenon(v); if type(c) ~= "number" or c < 0 or c > 12 then return 1 end; return c + 2 end,
            function(v, i) ToggleVehicleMod(v, 22, true); N_SetXenon(v, i == 1 and 255 or i - 2) end,
            "Color de los faros de xenón."))
        local lados = { "Neón izquierdo", "Neón derecho", "Neón delantero", "Neón trasero" }
        for i = 0, 3 do
            Anadir(I, Casilla(lados[i + 1],
                function(v) return IsVehicleNeonLightEnabled(v, i) end,
                function(v, on) SetVehicleNeonLightEnabled(v, i, on) end, "Luz de neón bajo el vehículo."))
        end
        GrupoRGB(I, "Color del neón",
            function(v) return GetVehicleNeonLightsColour(v) end,
            function(v, r, g, b) SetVehicleNeonLightsColour(v, r, g, b) end)
    end },
    { "Otros", function(I)
        Anadir(I, Pieza("Claxon", 14, "Claxon", "Sonido del claxon."))
        Anadir(I, ListaV("Tintado de lunas", TINTADOS,
            function(v) return Clamp(GetVehicleWindowTint(v) + 1, 1, #TINTADOS) end,
            function(v, i) SetVehicleWindowTint(v, i - 1) end, "Oscurece las ventanillas."))
        Anadir(I, ListaV("Tipo de matrícula", MATRICULAS,
            function(v) return Clamp(GetVehicleNumberPlateTextIndex(v) + 1, 1, #MATRICULAS) end,
            function(v, i) SetVehicleNumberPlateTextIndex(v, i - 1) end, "Estilo de la placa."))
        Anadir(I, { tipo = "accion", label = "Texto de la matrícula", desc = "Escribe el texto de la matrícula (máx. 8).",
            fn = function()
                local v = Tuneo.veh
                if not v then return end
                PedirTexto("Texto de la matrícula", GetVehicleNumberPlateText(v), 8, function(t)
                    Aplicar(function(veh) SetVehicleNumberPlateText(veh, t) end)
                    Avisar("Matrícula: " .. t)
                end)
            end })
        for id = 0, 14 do
            if DoesExtraExist(Tuneo.veh, id) then
                Anadir(I, Casilla("Extra " .. id,
                    function(v) return IsVehicleExtraTurnedOn(v, id) end,
                    function(v, on) SetVehicleExtra(v, id, not on) end, "Pieza extra de fábrica del vehículo."))
            end
        end
    end },
    { "Estado", function(I)
        Anadir(I, Boton("Reparar", function(v) Reparar(v); Avisar("Vehículo reparado") end,
            "Arregla motor, carrocería y depósito, y lo deja limpio."))
        Anadir(I, Boton("Limpiar", function(v) SetVehicleDirtLevel(v, 0.0); WashDecalsFromVehicle(v, 1.0); Avisar("Vehículo limpio") end,
            "Quita la suciedad."))
        Anadir(I, Boton("Todo al máximo", function(v) TodoAlMaximo(v); Avisar("Rendimiento al máximo") end,
            "Rendimiento al máximo, turbo, xenón y ruedas antipinchazos."))
        Anadir(I, Boton("Tuneo aleatorio", function(v) Aleatorio(v); Avisar("Tuneo aleatorio aplicado") end,
            "Piezas y colores al azar."))
        Anadir(I, Boton("Quitar todo el tuneo", function(v) QuitarTodo(v); Avisar("Vehículo de serie") end,
            "Deja el vehículo de serie."))
    end },
}

panelCategorias = { titulo = "Taller", items = {} }
panelOpciones   = { titulo = "Opciones", items = {} }

for i, c in ipairs(CATEGORIAS) do
    panelCategorias.items[i] = { tipo = "cat", label = c[1], desc = "Tuneo: " .. c[1]:lower() .. ".",
        activo = function() return Tuneo.cat == i end,
        fn = function() if Tuneo.cat ~= i then Tuneo.cat = i; Tuneo.sucio = true end end }
end

-- Rehace el panel de opciones si cambia el vehículo o la categoría
function ActualizarTuneo()
    if Tuneo.escribiendo then return end
    -- Buscar el vehículo cercano recorre todos los coches: 4 veces por segundo es suficiente
    local ahora = GetGameTimer()
    if ahora >= (Tuneo.proxBusqueda or 0) then
        Tuneo.proxBusqueda = ahora + 250
        local v = VehiculoTuneo()
        if v ~= Tuneo.veh then Tuneo.veh, Tuneo.sucio = v, true end
    end
    if Tuneo.veh and not DoesEntityExist(Tuneo.veh) then Tuneo.veh, Tuneo.sucio = nil, true end
    if not Tuneo.sucio then return end
    Tuneo.sucio = false
    panelOpciones._scroll, panelOpciones._scrollObj = 0, 0
    local cat = CATEGORIAS[Tuneo.cat]
    panelOpciones.titulo = cat[1]
    local items = {}
    if not Tuneo.veh then
        items[1] = { tipo = "texto", label = "Súbete a un vehículo o acércate a uno" }
    else
        SetVehicleModKit(Tuneo.veh, 0)
        local ok, err = pcall(cat[2], items)
        if not ok then items = { { tipo = "texto", label = "Error: " .. tostring(err) } } end
    end
    panelOpciones.items = items
end

end

-- ═════════════════════════════════════════════════════════
-- ROPA (vestidor completo)
--   Las cantidades se leen del juego en directo, así que aparece TODA la ropa
--   que tenga tu personaje, incluida la ropa añadida (addon) del servidor.
--   Mantén Shift para avanzar de 10 en 10.
-- ═════════════════════════════════════════════════════════
local Ropa, CATEGORIAS_ROPA, panelCatRopa, panelRopa, ActualizarRopa
do
Ropa = { cat = 1, sucio = true, modelo = nil, atuendos = {} }

-- Componentes y props que se guardan (atuendos, apariencia y ropa fija)
local COMPONENTES = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 }
local PROPS = { 0, 1, 2, 6, 7 }

-- ── Ropa fija: si algo te cambia la ropa de golpe, te la vuelve a poner ──
-- Prenda suelta cambiada (por el menú del servidor o por este) → se queda.
-- Muchas prendas a la vez (recarga de ropa del servidor, reaparecer) → se repone todo.
-- Accesorio caído al hacer ragdoll o caer → se repone.
Ropa.fijar, Ropa.fija = false, nil
local AdoptarTatuajes, ReponerTatuajes, ReponerApariencia   -- se definen más abajo, junto a los tatuajes y la cara
local ROPA_DE_GOLPE = 5   -- a partir de cuántas prendas cambiadas a la vez se considera un "reseteo"

local function FotoRopa(p)
    local f = { modelo = GetEntityModel(p), comp = {}, prop = {} }
    for _, c in ipairs(COMPONENTES) do
        f.comp[c] = { GetPedDrawableVariation(p, c), GetPedTextureVariation(p, c), GetPedPaletteVariation(p, c) }
    end
    for _, pr in ipairs(PROPS) do f.prop[pr] = { GetPedPropIndex(p, pr), GetPedPropTextureIndex(p, pr) } end
    return f
end

-- Se llama después de cada cambio de ropa hecho desde el menú
function Ropa.Refijar()
    if Ropa.fijar then Ropa.fija = FotoRopa(PlayerPedId()) end
end

local function PonerComp(p, c, v)
    if IsPedComponentVariationValid(p, c, v[1], v[2]) then SetPedComponentVariation(p, c, v[1], v[2], v[3] or 0) end
end
local function PonerProp(p, pr, v)
    if v[1] < 0 then ClearPedProp(p, pr)
    elseif v[1] < GetNumberOfPedPropDrawableVariations(p, pr) then SetPedPropIndex(p, pr, v[1], math.max(v[2], 0), true) end
end

local function LeerComp(p, c) return { GetPedDrawableVariation(p, c), GetPedTextureVariation(p, c), GetPedPaletteVariation(p, c) } end
local function IgualComp(a, b) return a and b and a[1] == b[1] and a[2] == b[2] end
local function IgualProp(a, b) return a and b and a[1] == b[1] and (a[1] < 0 or a[2] == b[2]) end

-- Mira qué ha cambiado y decide qué se queda y qué se repone.
-- Ropa.srv = la ropa ORIGINAL del servidor (la que llevabas antes de copiar o cambiar nada).
--   · Una prenda cambia a un valor IGUAL al original del servidor → solo está reponiendo su ropa:
--     se repone la tuya (aunque sea copiada).
--   · Una prenda cambia a un valor DISTINTO al original → el servidor la ha cambiado a propósito
--     (p. ej. le has dado a quitar pantalones en su menú, ponga lo que ponga): se queda,
--     y pasa a ser la nueva ropa original del servidor.
local ultimoAviso = 0

-- Guarda la ropa que tiene el servidor puesta (solo si aún no se conoce)
local function SembrarBase(p, f)
    local m = GetEntityModel(p)
    if not Ropa.srv or Ropa.srv.modelo ~= m then Ropa.srv = f or FotoRopa(p) end
end

local function VigilarRopa(p, f)
    SembrarBase(p)
    local srv = Ropa.srv
    local repuestas = 0
    for _, c in ipairs(COMPONENTES) do
        local v = f.comp[c]
        -- comprobación barata (sin crear tablas); solo si algo no cuadra se mira en detalle
        if v and (GetPedDrawableVariation(p, c) ~= v[1] or GetPedTextureVariation(p, c) ~= v[2]) then
            local nv = LeerComp(p, c)
            if IgualComp(nv, srv.comp[c]) then
                PonerComp(p, c, v); repuestas = repuestas + 1   -- el servidor repone lo suyo: se vuelve a poner lo tuyo
            else
                f.comp[c] = nv; srv.comp[c] = nv                -- cambio del servidor a propósito (p. ej. quitar pantalón)
            end
        end
    end

    -- Accesorios: dentro de un coche el juego pone/quita cascos y gorras solo, ahí no se toca nada
    local enCoche = IsPedInAnyVehicle(p, true) or GetVehiclePedIsTryingToEnter(p) ~= 0
    if not enCoche then
        local cayendo
        for _, pr in ipairs(PROPS) do
            local v = f.prop[pr]
            if v and (GetPedPropIndex(p, pr) ~= v[1] or (v[1] >= 0 and GetPedPropTextureIndex(p, pr) ~= v[2])) then
                local nv = { GetPedPropIndex(p, pr), GetPedPropTextureIndex(p, pr) }
                if cayendo == nil then
                    cayendo = IsPedRagdoll(p) or IsPedFalling(p) or IsPedInParachuteFreeFall(p) or IsPedBeingStunned(p, 0)
                end
                if (cayendo and nv[1] < 0) or IgualProp(nv, srv.prop[pr]) then
                    PonerProp(p, pr, v); repuestas = repuestas + 1   -- se te ha caído o el servidor repone lo suyo
                else
                    f.prop[pr] = nv; srv.prop[pr] = nv               -- cambio a propósito (tú o el menú del servidor)
                end
            end
        end
    end

    if repuestas > 0 then
        -- si el servidor te ha repuesto su ropa, también te habrá quitado los tatuajes: se ponen ya
        if ReponerTatuajes then pcall(ReponerTatuajes, true) end
        if ReponerApariencia then pcall(ReponerApariencia) end
        if GetGameTimer() - ultimoAviso > 3000 then
            ultimoAviso = GetGameTimer()
            Avisar("Ropa fija: repuestas " .. repuestas .. " prendas")
        end
    end
end

-- Al arrancar el script la ropa que llevas es la del servidor: se guarda como base
Citizen.CreateThread(function()
    Citizen.Wait(1500)
    local p = PlayerPedId()
    if DoesEntityExist(p) then pcall(SembrarBase, p) end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Ropa.fijar and 0 or 1000)   -- fijada: se mira en cada frame para que no se vea ni un instante la ropa del servidor
        local f = Ropa.fija
        if Ropa.fijar and f then
            local p = PlayerPedId()
            -- Si te cambian de personaje no se toca (la ropa de otro modelo no vale)
            if DoesEntityExist(p) and not IsEntityDead(p) and GetEntityModel(p) == f.modelo then VigilarRopa(p, f) end
        end
    end
end)


-- Componentes (ropa) y props (accesorios) de GTA
local function NumModelos(c) return GetNumberOfPedDrawableVariations(PlayerPedId(), c) end
local function NumTexturas(c, d) return GetNumberOfPedTextureVariations(PlayerPedId(), c, d) end
local function NumModelosProp(p) return GetNumberOfPedPropDrawableVariations(PlayerPedId(), p) end
local function NumTexturasProp(p, d) return GetNumberOfPedPropTextureVariations(PlayerPedId(), p, d) end

-- Prenda (componente): dos barras, modelo y textura
local function Prenda(items, nombre, c, desc)
    local ped = PlayerPedId()
    if NumModelos(c) <= 0 then return end
    items[#items + 1] = { tipo = "slider", label = nombre, min = 0, paso = 1,
        max = function() return math.max(NumModelos(c) - 1, 0) end,
        fmt = function(v) return string.format("%d / %d", v, math.max(NumModelos(c) - 1, 0)) end,
        desc = desc or ("Modelo de " .. nombre:lower() .. ". Mantén Shift para ir de 10 en 10."),
        get = function() return GetPedDrawableVariation(PlayerPedId(), c) end,
        set = function(v)
            local p = PlayerPedId()
            v = math.floor(v)
            if v ~= GetPedDrawableVariation(p, c) then
                -- Buscar la primera textura válida de esa prenda; si no hay ninguna, no se pone
                local nt = NumTexturas(c, v)
                for t = 0, math.max(nt - 1, 0) do
                    if IsPedComponentVariationValid(p, c, v, t) then
                        SetPedComponentVariation(p, c, v, t, GetPedPaletteVariation(p, c))
                        Ropa.Refijar()
                        return
                    end
                end
            end
        end }
    items[#items + 1] = { tipo = "slider", label = "   Textura", min = 0, paso = 1,
        max = function() local p = PlayerPedId(); return math.max(NumTexturas(c, GetPedDrawableVariation(p, c)) - 1, 0) end,
        fmt = function(v)
            local p = PlayerPedId()
            return string.format("%d / %d", v, math.max(NumTexturas(c, GetPedDrawableVariation(p, c)) - 1, 0))
        end,
        desc = "Variante de color o dibujo de esta prenda.",
        get = function() return GetPedTextureVariation(PlayerPedId(), c) end,
        set = function(v)
            local p = PlayerPedId()
            local d, t = GetPedDrawableVariation(p, c), math.floor(v)
            if IsPedComponentVariationValid(p, c, d, t) then
                SetPedComponentVariation(p, c, d, t, GetPedPaletteVariation(p, c))
                Ropa.Refijar()
            end
        end }
end

-- Accesorio (prop): modelo (con "Nada") y textura
local function Accesorio(items, nombre, pr, desc)
    if NumModelosProp(pr) <= 0 then return end
    items[#items + 1] = { tipo = "slider", label = nombre, min = -1, paso = 1,
        max = function() return math.max(NumModelosProp(pr) - 1, -1) end,
        fmt = function(v)
            if v < 0 then return "Nada" end
            return string.format("%d / %d", v, math.max(NumModelosProp(pr) - 1, 0))
        end,
        desc = desc or (nombre .. ". A la izquierda del todo: sin " .. nombre:lower() .. "."),
        get = function() return GetPedPropIndex(PlayerPedId(), pr) end,
        set = function(v)
            local p = PlayerPedId()
            v = math.floor(v)
            if v < 0 then ClearPedProp(p, pr)
            elseif v ~= GetPedPropIndex(p, pr) then SetPedPropIndex(p, pr, v, 0, true) end
            Ropa.Refijar()
        end }
    items[#items + 1] = { tipo = "slider", label = "   Textura", min = 0, paso = 1,
        max = function()
            local p = PlayerPedId(); local d = GetPedPropIndex(p, pr)
            if d < 0 then return 0 end
            return math.max(NumTexturasProp(pr, d) - 1, 0)
        end,
        fmt = function(v)
            local p = PlayerPedId(); local d = GetPedPropIndex(p, pr)
            if d < 0 then return "-" end
            return string.format("%d / %d", v, math.max(NumTexturasProp(pr, d) - 1, 0))
        end,
        desc = "Variante de color o dibujo de este accesorio.",
        get = function() return math.max(GetPedPropTextureIndex(PlayerPedId(), pr), 0) end,
        set = function(v)
            local p = PlayerPedId(); local d = GetPedPropIndex(p, pr)
            if d >= 0 then SetPedPropIndex(p, pr, d, math.floor(v), true); Ropa.Refijar() end
        end }
end

-- Atuendos guardados (mientras el script esté cargado)

local function GuardarAtuendo(n)
    local p, a = PlayerPedId(), { comp = {}, prop = {} }
    for _, c in ipairs(COMPONENTES) do
        a.comp[c] = { GetPedDrawableVariation(p, c), GetPedTextureVariation(p, c), GetPedPaletteVariation(p, c) }
    end
    for _, pr in ipairs(PROPS) do a.prop[pr] = { GetPedPropIndex(p, pr), GetPedPropTextureIndex(p, pr) } end
    Ropa.atuendos[n] = a
    Guardado.pendiente = true
    Avisar("Atuendo " .. n .. " guardado")
end

local function CargarAtuendo(n)
    local a = Ropa.atuendos[n]
    if not a then Avisar("El atuendo " .. n .. " está vacío"); return end
    local p = PlayerPedId()
    for c, v in pairs(a.comp) do
        if IsPedComponentVariationValid(p, c, v[1], v[2]) then SetPedComponentVariation(p, c, v[1], v[2], v[3] or 0) end
    end
    for pr, v in pairs(a.prop) do
        if v[1] < 0 then ClearPedProp(p, pr) else SetPedPropIndex(p, pr, v[1], math.max(v[2], 0), true) end
    end
    Ropa.Refijar()
    Avisar("Atuendo " .. n .. " puesto")
end

local function Btn(label, fn, desc) return { tipo = "accion", label = label, fn = fn, desc = desc } end

CATEGORIAS_ROPA = {
    { "Cabeza", function(I)
        Accesorio(I, "Sombreros", 0, "Gorras, cascos y sombreros.")
        Accesorio(I, "Gafas", 1, "Gafas de sol y de ver.")
        Accesorio(I, "Pendientes", 2, "Pendientes y accesorios de oreja.")
        Prenda(I, "Máscaras", 1, "Máscaras y pasamontañas.")
    end },
    { "Pelo", function(I)
        Prenda(I, "Peinado", 2, "Peinado del personaje.")
        local nc = GetNumHairColors()
        if nc and nc > 0 then
            I[#I + 1] = { tipo = "slider", label = "Color de pelo", min = 0, max = nc - 1, paso = 1,
                fmt = function(v) return string.format("%d / %d", v, nc - 1) end, desc = "Color del pelo.",
                get = function() return GetPedHairColor(PlayerPedId()) end,
                set = function(v) local p = PlayerPedId(); SetPedHairColor(p, math.floor(v), GetPedHairHighlightColor(p)) end }
            I[#I + 1] = { tipo = "slider", label = "Mechas", min = 0, max = nc - 1, paso = 1,
                fmt = function(v) return string.format("%d / %d", v, nc - 1) end, desc = "Color de las mechas.",
                get = function() return GetPedHairHighlightColor(PlayerPedId()) end,
                set = function(v) local p = PlayerPedId(); SetPedHairColor(p, GetPedHairColor(p), math.floor(v)) end }
        end
    end },
    { "Torso", function(I)
        Prenda(I, "Chaquetas", 11, "Prenda de arriba: chaquetas, sudaderas, camisas.")
        Prenda(I, "Camisetas", 8, "Prenda de debajo: camisetas y camisas interiores.")
        Prenda(I, "Brazos y guantes", 3, "Brazos del torso y guantes. Ajústalo si se ven cortes en los brazos.")
        Prenda(I, "Chalecos", 9, "Chalecos antibalas y similares.")
        Prenda(I, "Insignias", 10, "Parches, logos y calcomanías.")
    end },
    { "Piernas", function(I)
        Prenda(I, "Pantalones", 4, "Pantalones, faldas y shorts.")
        Prenda(I, "Zapatos", 6, "Calzado.")
    end },
    { "Accesorios", function(I)
        Prenda(I, "Cuello y cadenas", 7, "Collares, cadenas, corbatas y bufandas.")
        Prenda(I, "Mochilas y bolsas", 5, "Mochilas, bolsas y paracaídas.")
        Accesorio(I, "Relojes", 6, "Relojes.")
        Accesorio(I, "Pulseras", 7, "Pulseras.")
    end },
    { "Atuendos", function(I)
        I[#I + 1] = { tipo = "toggle", label = "Fijar mi ropa",
            desc = "Si te cambian la ropa de golpe o se te cae la gorra/gafas, te la vuelve a poner. Si te quitas o cambias una prenda (aquí o en el menú del servidor), se queda.",
            get = function() return Ropa.fijar end,
            set = function(on)
                Ropa.fijar = on and true or false
                Ropa.fija = Ropa.fijar and FotoRopa(PlayerPedId()) or nil
                if Ropa.fijar then SembrarBase(PlayerPedId(), Ropa.fija) end
                if Ropa.fijar and AdoptarTatuajes then AdoptarTatuajes() end
                Avisar(Ropa.fijar and "Ropa fijada" or "Ropa libre")
            end }
        for n = 1, 3 do
            I[#I + 1] = Btn("Guardar atuendo " .. n, function() GuardarAtuendo(n) end,
                "Guarda la ropa que llevas ahora (se pierde al recargar el script).")
            I[#I + 1] = Btn("Poner atuendo " .. n, function() CargarAtuendo(n) end, "Te pone el atuendo guardado.")
        end
    end },
    { "Utilidades", function(I)
        I[#I + 1] = Btn("Ropa aleatoria", function()
            local p = PlayerPedId(); SetPedRandomComponentVariation(p, 0); SetPedRandomProps(p); Ropa.Refijar(); Avisar("Ropa aleatoria")
        end, "Viste al personaje con ropa al azar.")
        I[#I + 1] = Btn("Ropa por defecto", function()
            SetPedDefaultComponentVariation(PlayerPedId()); Ropa.Refijar(); Avisar("Ropa por defecto")
        end, "Vuelve a la ropa por defecto del modelo.")
        I[#I + 1] = Btn("Quitar accesorios", function()
            ClearAllPedProps(PlayerPedId()); Ropa.Refijar(); Avisar("Accesorios quitados")
        end, "Quita sombrero, gafas, pendientes, reloj y pulsera.")
    end },
}

-- ═════════════════════════════════════════════════════════
-- CARA, RASGOS, DETALLES Y TATUAJES (personajes freemode)
-- ═════════════════════════════════════════════════════════
local M_FREEMODE, F_FREEMODE = GetHashKey("mp_m_freemode_01"), GetHashKey("mp_f_freemode_01")
local function EsFreemode()
    local m = GetEntityModel(PlayerPedId())
    return m == M_FREEMODE or m == F_FREEMODE
end
local function EsMujer() return GetEntityModel(PlayerPedId()) == F_FREEMODE end

-- Lee una estructura que devuelve una nativa (cada campo ocupa 8 bytes)
local function LeerEstructura(hash, huecos, ...)
    local blob = string.rep("\0", huecos * 8)
    local args = { ... }
    args[#args + 1] = blob
    local ok, ret = pcall(Citizen.InvokeNative, hash, table.unpack(args))
    if not ok or not ret then return nil end
    return blob
end
local function Entero(blob, hueco) return (string.unpack("<i4", blob, hueco * 8 + 1)) end
local function Decimal(blob, hueco) return (string.unpack("<f", blob, hueco * 8 + 1)) end

-- ── Herencia (padres y piel) ──────────────────────────────
Ropa.cara = nil     -- { madre, padre, pielMadre, pielPadre, parecido, mezclaPiel }
Ropa.rasgos = {}    -- 20 valores de -1 a 1
Ropa.detalles = {}  -- [id] = { valor, opacidad, color }
Ropa.ojos = nil
Ropa.tatuajes = {}  -- lista de { coleccion, nombre }
Ropa.vistaTatuaje = {}

local function LeerCara()
    if Ropa.cara then return Ropa.cara end
    local c = { madre = 21, padre = 0, pielMadre = 21, pielPadre = 0, parecido = 0.5, mezclaPiel = 0.5 }
    local blob = LeerEstructura(0x2746BD9D88C5C5D0, 16, PlayerPedId())  -- GET_PED_HEAD_BLEND_DATA (80 bytes + margen)
    if blob then
        c.madre, c.padre = Entero(blob, 0), Entero(blob, 1)
        c.pielMadre, c.pielPadre = Entero(blob, 3), Entero(blob, 4)
        c.parecido, c.mezclaPiel = Decimal(blob, 6), Decimal(blob, 7)
        -- Valores fuera de rango = lectura no válida: se usan los de por defecto
        if c.madre < 0 or c.madre > 45 or c.parecido ~= c.parecido or c.parecido < 0 or c.parecido > 1 then
            c = { madre = 21, padre = 0, pielMadre = 21, pielPadre = 0, parecido = 0.5, mezclaPiel = 0.5 }
        end
    end
    Ropa.cara = c
    return c
end

local function AplicarCara()
    local c = LeerCara()
    SetPedHeadBlendData(PlayerPedId(), c.madre, c.padre, 0, c.pielMadre, c.pielPadre, 0,
        c.parecido, c.mezclaPiel, 0.0, false)
end

local function BarraCara(label, campo, min, max, paso, fmt, desc)
    return { tipo = "slider", label = label, min = min, max = max, paso = paso, fmt = fmt, desc = desc,
        get = function() return LeerCara()[campo] end,
        set = function(v) LeerCara()[campo] = v; AplicarCara() end }
end

-- ── Rasgos de la cara ─────────────────────────────────────
local RASGOS = { "Anchura de la nariz", "Altura del pico de la nariz", "Longitud de la nariz",
    "Altura del puente nasal", "Punta de la nariz", "Desvío de la nariz", "Altura de las cejas",
    "Profundidad de las cejas", "Altura de los pómulos", "Anchura de los pómulos", "Mejillas",
    "Apertura de los ojos", "Grosor de los labios", "Anchura de la mandíbula", "Forma de la mandíbula",
    "Altura de la barbilla", "Longitud de la barbilla", "Anchura de la barbilla", "Hoyuelo de la barbilla",
    "Grosor del cuello" }

-- ── Detalles (cejas, barba, maquillaje...) ────────────────
-- { id, nombre, tipo de color: 0 ninguno, 1 pelo, 2 maquillaje }
local DETALLES = {
    { 2, "Cejas", 1 }, { 1, "Barba", 1 }, { 4, "Maquillaje de ojos", 0 }, { 5, "Colorete", 2 },
    { 8, "Pintalabios", 2 }, { 0, "Imperfecciones", 0 }, { 3, "Envejecimiento", 0 }, { 6, "Tez", 0 },
    { 7, "Daño solar", 0 }, { 9, "Lunares y pecas", 0 }, { 10, "Vello del pecho", 1 },
    { 11, "Manchas del cuerpo", 0 }, { 12, "Más manchas del cuerpo", 0 },
}

local function LeerDetalle(id)
    if Ropa.detalles[id] then return Ropa.detalles[id] end
    local d = { valor = -1, opacidad = 1.0, color = 0 }
    local ok, _, valor, _, color, _, opacidad = pcall(GetPedHeadOverlayData, PlayerPedId(), id)
    if ok and type(valor) == "number" then
        d.valor = (valor == 255) and -1 or valor
        d.color = color or 0
        if type(opacidad) == "number" and opacidad >= 0 and opacidad <= 1 then d.opacidad = opacidad end
    end
    Ropa.detalles[id] = d
    return d
end

local function AplicarDetalle(id, tipoColor)
    local d, p = LeerDetalle(id), PlayerPedId()
    SetPedHeadOverlay(p, id, d.valor < 0 and 255 or d.valor, d.opacidad)
    if tipoColor > 0 then SetPedHeadOverlayColor(p, id, tipoColor, d.color, d.color) end
end

-- ── Tatuajes (se leen de la tienda del juego: todos, incluidos DLC y addon) ──
local ZONAS = { { 1, "Cabeza" }, { 0, "Torso" }, { 2, "Brazo izquierdo" }, { 3, "Brazo derecho" },
                { 4, "Pierna izquierda" }, { 5, "Pierna derecha" } }
local catalogoTatuajes = {}  -- [personaje] = { [zona] = { {col, nombre}, ... } }

local function Catalogo()
    local tipo = EsMujer() and 4 or 3   -- 3 = freemode hombre, 4 = freemode mujer
    if catalogoTatuajes[tipo] then return catalogoTatuajes[tipo] end
    local porZona = {}
    for _, z in ipairs(ZONAS) do porZona[z[1]] = {} end
    local ok, total = pcall(GetNumTattooShopDlcItems, tipo)
    if ok and type(total) == "number" then
        for i = 0, total - 1 do
            local blob = LeerEstructura(0xFF56381874F82086, 16, tipo, i)  -- GET_TATTOO_SHOP_DLC_ITEM_DATA
            if blob then
                local col, nombre = Entero(blob, 2), Entero(blob, 3)
                if col ~= 0 and nombre ~= 0 then
                    local zona = GetPedDecorationZoneFromHashes(col, nombre)
                    if porZona[zona] then table.insert(porZona[zona], { col, nombre }) end
                end
            end
        end
    end
    catalogoTatuajes[tipo] = porZona
    return porZona
end

-- Los hashes pueden venir con signo o sin signo según de dónde salgan: se comparan igual
local function Hash32(h) h = (type(h) == "number" and math.tointeger(h)) or 0; if h < 0 then h = h + 4294967296 end; return h end
local function MismoTatuaje(a, b) return Hash32(a[1]) == Hash32(b[1]) and Hash32(a[2]) == Hash32(b[2]) end

-- Tatuajes que lleva otro ped (nativa de FiveM GET_PED_DECORATIONS). nil si no se pueden leer
local function LeerTatuajesDe(ped)
    local ok, r = false, nil
    if type(GetPedDecorations) == "function" then ok, r = pcall(GetPedDecorations, ped) end
    if (not ok or type(r) ~= "table") and Citizen.InvokeNative and Citizen.ResultAsObject then
        ok, r = pcall(Citizen.InvokeNative, 0x7CCE1163, ped, Citizen.ResultAsObject())
    end
    if not ok or type(r) ~= "table" then return nil end
    local lista = {}
    for _, t in ipairs(r) do
        local col, nom = t[1] or t.collection, t[2] or t.overlay
        if col and nom and Hash32(col) ~= 0 and Hash32(nom) ~= 0 then lista[#lista + 1] = { col, nom } end
    end
    return lista
end
local function LlevaTatuaje(t)
    for _, x in ipairs(Ropa.tatuajes) do if MismoTatuaje(x, t) then return true end end
    return false
end

-- Vuelve a poner los tatuajes guardados + los que estás mirando en cada zona
local function AplicarTatuajes()
    local p = PlayerPedId()
    ClearPedDecorations(p)
    for _, t in ipairs(Ropa.tatuajes) do AddPedDecorationFromHashes(p, t[1], t[2]) end
    for _, t in pairs(Ropa.vistaTatuaje) do
        if t and not LlevaTatuaje(t) then AddPedDecorationFromHashes(p, t[1], t[2]) end
    end
end

-- Mete en la lista los tatuajes que lleva tu personaje ahora (los del servidor también)
function AdoptarTatuajes()
    if not EsFreemode() then return end
    local act = LeerTatuajesDe(PlayerPedId())
    if not act then return end
    for _, t in ipairs(act) do
        if not LlevaTatuaje(t) then Ropa.tatuajes[#Ropa.tatuajes + 1] = { t[1], t[2] } end
    end
end

-- Con "Fijar mi ropa": los tatuajes de la lista siempre puestos (si el servidor te los quita, se reponen)
-- forzar = true: se ponen sin mirar si faltan (justo después de que el servidor te resetee la ropa)
local pedAnteriorTat = 0
function ReponerTatuajes(forzar)
    if not Ropa.fijar or #Ropa.tatuajes == 0 then return end
    local p = PlayerPedId()
    if not (DoesEntityExist(p) and not IsEntityDead(p) and EsFreemode()) then return end
    local faltan = forzar
    if not faltan then
        local act = LeerTatuajesDe(p)
        if act then
            for _, t in ipairs(Ropa.tatuajes) do
                local esta = false
                for _, x in ipairs(act) do if MismoTatuaje(x, t) then esta = true; break end end
                if not esta then faltan = true; break end
            end
        else
            faltan = (p ~= pedAnteriorTat)   -- no se pueden leer: se reponen al cambiar de ped (reaparecer)
        end
    end
    pedAnteriorTat = p
    if faltan then AplicarTatuajes() end
end

Citizen.CreateThread(function()
    local n = 0
    while true do
        Citizen.Wait(250)
        if Ropa.fijar then
            pcall(ReponerTatuajes, false)
            n = n + 1
            if n >= 6 and Ropa.andar then                        -- cada ~1,5 s se mantiene la forma de andar
                n = 0
                if not IsPedInAnyVehicle(PlayerPedId(), true) then pcall(SetPedMovementClipset, PlayerPedId(), Ropa.andar, 0.0) end
            end
        end
    end
end)

-- ── Cambiar a personaje freemode ──────────────────────────
local function CambiarModelo(nombre)
    if vehiculo then Soltar() end
    local h = GetHashKey(nombre)
    RequestModel(h)
    local t = 0
    while not HasModelLoaded(h) and t < 300 do Citizen.Wait(10); t = t + 1 end
    if not HasModelLoaded(h) then Avisar("No se pudo cargar el modelo"); return end
    SetPlayerModel(PlayerId(), h)
    SetModelAsNoLongerNeeded(h)
    local p = PlayerPedId()
    SetPedDefaultComponentVariation(p)
    SetPedHeadBlendData(p, 21, 0, 0, 21, 0, 0, 0.5, 0.5, 0.0, false)
    Ropa.cara, Ropa.rasgos, Ropa.detalles, Ropa.ojos = nil, {}, {}, nil
    Ropa.tatuajes, Ropa.vistaTatuaje = {}, {}
    Ropa.srv, Ropa.andar = nil, nil
    Ropa.Refijar()
    Ropa.sucio = true
    Avisar("Personaje cambiado")
end

local function AvisoFreemode(I)
    I[#I + 1] = { tipo = "texto", label = "Solo con personajes freemode (mp_m / mp_f)" }
    I[#I + 1] = { tipo = "accion", label = "Pasar a freemode hombre", desc = "Cambia tu personaje a mp_m_freemode_01.",
        fn = function() CambiarModelo("mp_m_freemode_01") end }
    I[#I + 1] = { tipo = "accion", label = "Pasar a freemode mujer", desc = "Cambia tu personaje a mp_f_freemode_01.",
        fn = function() CambiarModelo("mp_f_freemode_01") end }
end

local N_GetOjos = Nativa("GetPedEyeColor", "_GetPedEyeColor")

local CATEGORIAS_CARA = {
    { "Herencia", function(I)
        if not EsFreemode() then return AvisoFreemode(I) end
        I[#I + 1] = BarraCara("Madre", "madre", 0, 45, 1, "%d", "Cara de la madre (0-45).")
        I[#I + 1] = BarraCara("Padre", "padre", 0, 45, 1, "%d", "Cara del padre (0-45).")
        I[#I + 1] = BarraCara("Parecido", "parecido", 0, 1, 0.05, "%.2f", "0 = como la madre, 1 = como el padre.")
        I[#I + 1] = BarraCara("Piel de la madre", "pielMadre", 0, 45, 1, "%d", "Tono de piel de la madre.")
        I[#I + 1] = BarraCara("Piel del padre", "pielPadre", 0, 45, 1, "%d", "Tono de piel del padre.")
        I[#I + 1] = BarraCara("Mezcla de piel", "mezclaPiel", 0, 1, 0.05, "%.2f", "0 = piel de la madre, 1 = del padre.")
        I[#I + 1] = { tipo = "slider", label = "Color de ojos", min = 0, max = 31, paso = 1, fmt = "%d",
            desc = "Color de los ojos.",
            get = function()
                if Ropa.ojos then return Ropa.ojos end
                local ok, v = pcall(N_GetOjos, PlayerPedId())
                Ropa.ojos = (ok and type(v) == "number" and v >= 0 and v <= 31) and v or 0
                return Ropa.ojos
            end,
            set = function(v) Ropa.ojos = math.floor(v); SetPedEyeColor(PlayerPedId(), Ropa.ojos) end }
    end },
    { "Rasgos", function(I)
        if not EsFreemode() then return AvisoFreemode(I) end
        for i, nombre in ipairs(RASGOS) do
            local id = i - 1
            I[#I + 1] = { tipo = "slider", label = nombre, min = -1, max = 1, paso = 0.1, fmt = "%.1f",
                desc = "De -1 a 1. En 0 queda como la cara heredada.",
                get = function() return Ropa.rasgos[id] or 0.0 end,
                set = function(v) Ropa.rasgos[id] = v; SetPedFaceFeature(PlayerPedId(), id, v + 0.0) end }
        end
        I[#I + 1] = { tipo = "accion", label = "Restablecer rasgos", desc = "Pone todos los rasgos a 0.",
            fn = function()
                for id = 0, 19 do Ropa.rasgos[id] = 0.0; SetPedFaceFeature(PlayerPedId(), id, 0.0) end
                Avisar("Rasgos restablecidos")
            end }
    end },
    { "Detalles", function(I)
        if not EsFreemode() then return AvisoFreemode(I) end
        for _, d in ipairs(DETALLES) do
            local id, nombre, tipoColor = d[1], d[2], d[3]
            local n = GetNumHeadOverlayValues(id)
            if n and n > 0 then
                I[#I + 1] = { tipo = "slider", label = nombre, min = -1, max = n - 1, paso = 1,
                    fmt = function(v) if v < 0 then return "Nada" end; return string.format("%d / %d", v, n - 1) end,
                    desc = nombre .. ". A la izquierda del todo: nada.",
                    get = function() return LeerDetalle(id).valor end,
                    set = function(v) LeerDetalle(id).valor = math.floor(v); AplicarDetalle(id, tipoColor) end }
                I[#I + 1] = { tipo = "slider", label = "   Intensidad", min = 0, max = 1, paso = 0.05, fmt = "%.2f",
                    desc = "Cuánto se nota.",
                    get = function() return LeerDetalle(id).opacidad end,
                    set = function(v) LeerDetalle(id).opacidad = v; AplicarDetalle(id, tipoColor) end }
                if tipoColor > 0 then
                    local nc = (tipoColor == 1) and GetNumHairColors() or GetNumMakeupColors()
                    I[#I + 1] = { tipo = "slider", label = "   Color", min = 0, max = math.max((nc or 64) - 1, 0), paso = 1,
                        fmt = "%d", desc = "Color.",
                        get = function() return LeerDetalle(id).color end,
                        set = function(v) LeerDetalle(id).color = math.floor(v); AplicarDetalle(id, tipoColor) end }
                end
            end
        end
    end },
    { "Tatuajes", function(I)
        if not EsFreemode() then return AvisoFreemode(I) end
        local cat = Catalogo()
        local hay = false
        for _, z in ipairs(ZONAS) do
            local zona, nombre = z[1], z[2]
            local lista = cat[zona] or {}
            if #lista > 0 then
                hay = true
                I[#I + 1] = { tipo = "slider", label = nombre, min = 0, max = #lista, paso = 1,
                    fmt = function(v) if v < 1 then return "Ninguno" end; return string.format("%d / %d", v, #lista) end,
                    desc = "Mira los tatuajes de esta zona. Marca \"Llevar\" para quedártelo.",
                    get = function() return Ropa.vistaTatuaje[zona] and Ropa.vistaTatuaje[zona].i or 0 end,
                    set = function(v)
                        v = math.floor(v)
                        Ropa.vistaTatuaje[zona] = (v >= 1) and { lista[v][1], lista[v][2], i = v } or nil
                        AplicarTatuajes()
                    end }
                I[#I + 1] = { tipo = "toggle", label = "   Llevar este tatuaje", desc = "Añade o quita el tatuaje que estás mirando.",
                    get = function() local t = Ropa.vistaTatuaje[zona]; return t ~= nil and LlevaTatuaje(t) end,
                    set = function(on)
                        local t = Ropa.vistaTatuaje[zona]
                        if not t then Avisar("Elige primero un tatuaje"); return end
                        if on and not LlevaTatuaje(t) then
                            table.insert(Ropa.tatuajes, { t[1], t[2] })
                        elseif not on then
                            for k = #Ropa.tatuajes, 1, -1 do
                                if MismoTatuaje(Ropa.tatuajes[k], t) then table.remove(Ropa.tatuajes, k) end
                            end
                        end
                        AplicarTatuajes()
                    end }
            end
        end
        if not hay then
            I[#I + 1] = { tipo = "texto", label = "No se pudo leer la lista de tatuajes" }
        end
        I[#I + 1] = { tipo = "accion", label = "Quitar todos los tatuajes", desc = "Borra todos los tatuajes.",
            fn = function()
                Ropa.tatuajes, Ropa.vistaTatuaje = {}, {}
                ClearPedDecorations(PlayerPedId())
                Avisar("Tatuajes quitados")
            end }
    end },
}

-- Las categorías de la cara van después de "Accesorios" y antes de "Atuendos"
for k, cat in ipairs(CATEGORIAS_CARA) do table.insert(CATEGORIAS_ROPA, 5 + k, cat) end

-- ── Copiar cara, rasgos, maquillaje, ojos y forma de andar ──
-- Pone en tu personaje la cara del ped "origen" (freemode) y guarda los valores en Ropa.*
local function CopiarCaraDe(origen)
    local p = PlayerPedId()
    local copiado = 0
    -- Herencia (padres y piel)
    local blob = LeerEstructura(0x2746BD9D88C5C5D0, 16, origen)   -- GET_PED_HEAD_BLEND_DATA
    if blob then
        local c = { madre = Entero(blob, 0), padre = Entero(blob, 1), pielMadre = Entero(blob, 3),
                    pielPadre = Entero(blob, 4), parecido = Decimal(blob, 6), mezclaPiel = Decimal(blob, 7) }
        if c.madre >= 0 and c.madre <= 45 and c.parecido == c.parecido and c.parecido >= 0 and c.parecido <= 1 then
            Ropa.cara = c
            AplicarCara()
            copiado = copiado + 1
        end
    end
    -- Rasgos de la cara (nariz, cejas, pómulos, mandíbula...)
    if type(GetPedFaceFeature) == "function" then
        for i = 0, 19 do
            local ok, v = pcall(GetPedFaceFeature, origen, i)
            if ok and type(v) == "number" and v == v and v >= -1.01 and v <= 1.01 then
                Ropa.rasgos[i] = v
                SetPedFaceFeature(p, i, v + 0.0)
            end
        end
        copiado = copiado + 1
    end
    -- Detalles: cejas, barba, maquillaje, pecas, envejecimiento...
    for _, d in ipairs(DETALLES) do
        local ok, _, valor, _, color, _, opacidad = pcall(GetPedHeadOverlayData, origen, d[1])
        if ok and type(valor) == "number" then
            Ropa.detalles[d[1]] = { valor = (valor == 255) and -1 or valor, color = color or 0,
                opacidad = (type(opacidad) == "number" and opacidad >= 0 and opacidad <= 1) and opacidad or 1.0 }
            AplicarDetalle(d[1], d[3])
        end
    end
    -- Color de ojos
    local okO, ojos = pcall(N_GetOjos, origen)
    if okO and type(ojos) == "number" and ojos >= 0 and ojos <= 31 then
        Ropa.ojos = ojos
        SetPedEyeColor(p, ojos)
    end
    return copiado > 0
end

-- Estilos de andar conocidos (clipsets de movimiento). Se detecta cuál reproduce el otro ped
local ESTILOS_ANDAR = {
    "move_m@alien", "move_m@bag", "move_m@bounce", "move_m@brave", "move_m@business@a", "move_m@buzzed",
    "move_m@caution", "move_m@casual@a", "move_m@casual@b", "move_m@casual@c", "move_m@casual@d",
    "move_m@casual@e", "move_m@casual@f", "move_m@clipboard", "move_m@confident", "move_m@depressed@a",
    "move_m@depressed@b", "move_m@drunk@a", "move_m@drunk@moderatedrunk", "move_m@drunk@slightlydrunk",
    "move_m@drunk@verydrunk", "move_m@fat@a", "move_m@fat@bulky", "move_m@fire", "move_m@flee@a",
    "move_m@gangster@generic", "move_m@gangster@var_e", "move_m@gangster@var_f", "move_m@gangster@var_i",
    "move_m@hobo@a", "move_m@hurry@a", "move_m@injured", "move_m@intimidation@1h",
    "move_m@intimidation@cop@unarmed", "move_m@intimidation@unarmed", "move_m@jogger", "move_m@leaf_blower",
    "move_m@money", "move_m@multiplayer", "move_m@muscle@a", "move_m@non_chalant", "move_m@posh@",
    "move_m@power", "move_m@prison_gaurd", "move_m@quick", "move_m@sad@a", "move_m@sassy",
    "move_m@shadyped@a", "move_m@swagger", "move_m@tool_belt@a", "move_m@tough_guy@",
    "move_f@arrogant@a", "move_f@chubby@a", "move_f@depressed@a", "move_f@depressed@b", "move_f@fat@a",
    "move_f@femme@", "move_f@film_reel", "move_f@flee@a", "move_f@gangster@ng", "move_f@handbag",
    "move_f@heels@c", "move_f@heels@d", "move_f@hurry@a", "move_f@injured", "move_f@jogger",
    "move_f@maneater", "move_f@multiplayer", "move_f@posh@", "move_f@sad@a", "move_f@sassy",
    "move_f@scared", "move_f@sexy@a", "move_f@tool_belt@a", "move_f@tough_guy@",
    "move_characters@michael", "move_characters@franklin", "move_characters@trevor",
    "move_ped_crouched", "anim_group_move_ballistic", "move_lester_caneup",
}
local ANIMS_ANDAR = { "idle", "walk", "run" }

local function DetectarAndar(origen)
    for _, set in ipairs(ESTILOS_ANDAR) do
        for _, a in ipairs(ANIMS_ANDAR) do
            if IsEntityPlayingAnim(origen, set, a, 3) then return set end
        end
    end
    return nil
end

local function PonerAndar(set)
    Ropa.andar = set
    Citizen.CreateThread(function()
        RequestAnimSet(set)
        local t = 0
        while not HasAnimSetLoaded(set) and t < 300 do Citizen.Wait(10); t = t + 1 end
        if HasAnimSetLoaded(set) then SetPedMovementClipset(PlayerPedId(), set, 0.25) end
    end)
end

-- Con "Fijar mi ropa": si el servidor te resetea, vuelven la cara, los ojos y la forma de andar
function ReponerApariencia()
    if not Ropa.fijar or not EsFreemode() then
        if Ropa.fijar and Ropa.andar then PonerAndar(Ropa.andar) end
        return
    end
    local p = PlayerPedId()
    if Ropa.cara then AplicarCara() end
    for id, v in pairs(Ropa.rasgos) do SetPedFaceFeature(p, id, v + 0.0) end
    for _, d in ipairs(DETALLES) do if Ropa.detalles[d[1]] then AplicarDetalle(d[1], d[3]) end end
    if Ropa.ojos then SetPedEyeColor(p, Ropa.ojos) end
    if Ropa.andar then PonerAndar(Ropa.andar) end
end

-- ── Aplicar una "foto" de ropa (la de otro jugador) y comprobar qué ha quedado ──
local NOMBRE_COMP = { [1] = "Máscara", [2] = "Peinado", [3] = "Brazos", [4] = "Pantalón", [5] = "Mochila",
    [6] = "Zapatos", [7] = "Cuello", [8] = "Camiseta", [9] = "Chaleco", [10] = "Insignia", [11] = "Chaqueta" }
local NOMBRE_PROP = { [0] = "Sombrero", [1] = "Gafas", [2] = "Pendientes", [6] = "Reloj", [7] = "Pulsera" }

local function AplicarFotoRopa(p, f)
    for c, v in pairs(f.comp) do
        SetPedComponentVariation(p, c, v[1], v[2], v[3] or 0)
    end
    for pr, v in pairs(f.prop) do
        if v[1] < 0 then ClearPedProp(p, pr)
        else SetPedPropIndex(p, pr, v[1], math.max(v[2], 0), true) end
    end
end

local function FallosFotoRopa(p, f)
    local fallos = {}
    for c, v in pairs(f.comp) do
        if GetPedDrawableVariation(p, c) ~= v[1] or GetPedTextureVariation(p, c) ~= v[2] then
            fallos[#fallos + 1] = (NOMBRE_COMP[c] or ("comp " .. c)) .. " " .. v[1] .. ":" .. v[2]
        end
    end
    for pr, v in pairs(f.prop) do
        if GetPedPropIndex(p, pr) ~= v[1] then
            fallos[#fallos + 1] = (NOMBRE_PROP[pr] or ("prop " .. pr)) .. " " .. v[1]
        end
    end
    table.sort(fallos)
    return fallos
end

-- ── Copiar la ropa de otro jugador ────────────────────────
-- Copia todas las prendas (mochila incluida), accesorios, peinado y color de pelo
local function CopiarRopaDe(origen, nombre)
    if not origen or not DoesEntityExist(origen) then Avisar("Ese jugador ya no está cerca"); return end
    local mo = GetEntityModel(origen)
    if mo ~= GetEntityModel(PlayerPedId()) then
        -- La ropa solo vale para el mismo modelo: si es freemode, te cambias al suyo
        if mo == M_FREEMODE then CambiarModelo("mp_m_freemode_01")
        elseif mo == F_FREEMODE then CambiarModelo("mp_f_freemode_01")
        else Avisar("Lleva un personaje especial (no freemode): no se puede copiar"); return end
        if GetEntityModel(PlayerPedId()) ~= mo then return end
    end
    local p, f = PlayerPedId(), FotoRopa(origen)
    -- Se pone TODO sin comprobar si "es válido" (la ropa addon del servidor falla esa comprobación aunque se vea bien)
    AplicarFotoRopa(p, f)
    -- Se comprueba lo que ha quedado; lo que falle se reintenta y se avisa de qué no se pudo copiar
    Citizen.CreateThread(function()
        for intento = 1, 3 do
            Citizen.Wait(400)
            local q = PlayerPedId()
            if not DoesEntityExist(origen) or GetEntityModel(q) ~= f.modelo then return end
            local fallos = FallosFotoRopa(q, f)
            if #fallos == 0 then Ropa.Refijar(); return end
            if intento < 3 then
                AplicarFotoRopa(q, f)
            else
                print("[cargar coches] No se pudo copiar de " .. nombre .. ": " .. table.concat(fallos, ", "))
                Avisar("No se pudo copiar: " .. table.concat(fallos, ", "))
            end
        end
        Ropa.Refijar()
    end)
    SetPedHairColor(p, GetPedHairColor(origen), GetPedHairHighlightColor(origen))
    Ropa.Refijar()
    -- Tatuajes: se sustituyen los tuyos por los suyos (solo personajes freemode)
    local extra = ""
    if EsFreemode() then
        local tats = LeerTatuajesDe(origen)
        if tats then
            Ropa.tatuajes, Ropa.vistaTatuaje = tats, {}
            AplicarTatuajes()
            extra = " (+" .. #tats .. " tatuajes)"
        else
            extra = " (los tatuajes no se pueden leer aquí)"
        end
    end
    -- Cara, rasgos, maquillaje y ojos (solo freemode con freemode)
    if EsFreemode() and (mo == M_FREEMODE or mo == F_FREEMODE) then
        if CopiarCaraDe(origen) then extra = extra .. " + cara" else extra = extra .. " (la cara no se pudo leer)" end
    end
    -- Forma de andar
    local estilo = DetectarAndar(origen)
    if estilo then PonerAndar(estilo); extra = extra .. " + andar" else extra = extra .. " (andar: estilo no reconocido, no se cambia)" end
    Avisar("Copiado de " .. nombre .. extra)
end

local function CategoriaCopiar(I)
    I[#I + 1] = Btn("Actualizar lista", function() Ropa.sucio = true end, "Vuelve a buscar los jugadores que tienes cerca.")
    local pos = GetEntityCoords(PlayerPedId())
    local js = {}
    for _, pid in ipairs(GetActivePlayers()) do
        if pid ~= PlayerId() then
            local ped = GetPlayerPed(pid)
            if ped ~= 0 and DoesEntityExist(ped) then js[#js + 1] = { pid, #(GetEntityCoords(ped) - pos) } end
        end
    end
    table.sort(js, function(a, b) return a[2] < b[2] end)
    if #js == 0 then I[#I + 1] = { tipo = "texto", label = "No hay jugadores cerca" } end
    for _, j in ipairs(js) do
        local sid = GetPlayerServerId(j[1])
        local nombre = (GetPlayerName(j[1]) or "Jugador") .. " [" .. sid .. "]"
        I[#I + 1] = { tipo = "accion", label = nombre, derecha = string.format("%.0f m", j[2]),
            desc = "Te copia todo: ropa, mochila, accesorios, peinado, color de pelo, tatuajes, cara, rasgos, maquillaje, ojos y forma de andar.",
            fn = function()
                local pid = GetPlayerFromServerId(sid)
                local ped = (pid and pid ~= -1) and GetPlayerPed(pid) or 0
                CopiarRopaDe(ped ~= 0 and ped or nil, nombre)
            end }
    end
end

-- Va justo después de "Atuendos"
do
    local pos = #CATEGORIAS_ROPA
    for i, c in ipairs(CATEGORIAS_ROPA) do if c[1] == "Atuendos" then pos = i + 1 end end
    table.insert(CATEGORIAS_ROPA, pos, { "Copiar ropa", CategoriaCopiar })
end

-- ── Uniformes (trabajos) ──────────────────────────────────
-- Cada uniforme tiene versión hombre (H) y mujer (M), en el formato habitual de los scripts de trabajos:
--   tshirt = camiseta (8), torso = chaqueta (11), arms = brazos (3), pants = pantalón (4), shoes = zapatos (6),
--   decals = insignias (10), bproof = chaleco (9), chain = cuello (7), mask = máscara (1), bags = mochila (5),
--   helmet = sombrero (prop 0), glasses = gafas (prop 1), ears = pendientes (prop 2)
-- Lo que no se indica queda "desnudo" / sin accesorio. Para añadir o corregir uno, edita los números.
-- Son los de la ropa base del juego (freemode): con ropa addon del servidor pueden verse distinto.
local UNIFORMES = {
    { "Policía", "Uniforme de policía con gorra.",
      H = { tshirt = { 59, 1 }, torso = { 55, 0 }, arms = 41, pants = { 25, 0 }, shoes = { 25, 0 }, helmet = { 46, 0 }, ears = { 2, 0 } },
      M = { tshirt = { 36, 1 }, torso = { 48, 0 }, arms = 44, pants = { 34, 0 }, shoes = { 27, 0 }, helmet = { 45, 0 }, ears = { 2, 0 } } },
    { "Mecánico", "Mono de trabajo de mecánico.",
      H = { tshirt = { 15, 0 }, torso = { 65, 3 }, arms = 41, pants = { 38, 2 }, shoes = { 12, 0 } } },
    { "Médico", "Uniforme de sanitario.",
      H = { tshirt = { 15, 0 }, torso = { 146, 0 }, arms = 90, pants = { 24, 5 }, shoes = { 51, 0 } } },
}
local BASE_DESNUDO_H = { [1] = 0, [3] = 15, [4] = 21, [5] = 0, [6] = 34, [7] = 0, [8] = 15, [9] = 0, [10] = 0, [11] = 15 }
local BASE_DESNUDO_M = { [1] = 0, [3] = 15, [4] = 15, [5] = 0, [6] = 35, [7] = 0, [8] = 15, [9] = 0, [10] = 0, [11] = 15 }
local CAMPO_COMP = { mask = 1, arms = 3, pants = 4, bags = 5, shoes = 6, chain = 7, tshirt = 8, bproof = 9, decals = 10, torso = 11 }
local CAMPO_PROP = { helmet = 0, glasses = 1, ears = 2 }

local function PonerUniforme(u)
    if not EsFreemode() then Avisar("Los uniformes son solo para personajes freemode"); return end
    local mujer = EsMujer()
    local d = mujer and u.M or u.H
    if not d then Avisar(u[1] .. ": no hay versión " .. (mujer and "de mujer" or "de hombre")); return end
    local f = { modelo = GetEntityModel(PlayerPedId()), comp = {}, prop = {} }
    for c, n in pairs(mujer and BASE_DESNUDO_M or BASE_DESNUDO_H) do f.comp[c] = { n, 0, 0 } end
    for k, c in pairs(CAMPO_COMP) do
        local v = d[k]
        if type(v) == "number" then v = { v, 0 } end
        if v then f.comp[c] = { v[1], v[2] or 0, 0 } end
    end
    for _, pr in ipairs({ 0, 1, 2 }) do f.prop[pr] = { -1, -1 } end
    for k, pr in pairs(CAMPO_PROP) do
        local v = d[k]
        if v then f.prop[pr] = { v[1], v[2] or 0 } end
    end
    AplicarFotoRopa(PlayerPedId(), f)
    Ropa.Refijar()
    Citizen.CreateThread(function()
        Citizen.Wait(400)
        local q = PlayerPedId()
        if GetEntityModel(q) ~= f.modelo then return end
        if #FallosFotoRopa(q, f) > 0 then AplicarFotoRopa(q, f) end
        Ropa.Refijar()
    end)
    Avisar("Uniforme: " .. u[1])
end

do
    local pos = #CATEGORIAS_ROPA
    for i, c in ipairs(CATEGORIAS_ROPA) do if c[1] == "Atuendos" then pos = i + 1 end end
    table.insert(CATEGORIAS_ROPA, pos, { "Uniformes", function(I)
        if not EsFreemode() then return AvisoFreemode(I) end
        local mujer = EsMujer()
        for _, u in ipairs(UNIFORMES) do
            local hay = (mujer and u.M or u.H) ~= nil
            I[#I + 1] = Btn(u[1] .. (hay and "" or " (no disponible)"), function() PonerUniforme(u) end, u[2])
        end
    end })
end

panelCatRopa = { titulo = "Personaje", items = {} }
panelRopa    = { titulo = "Prendas", items = {} }

for i, c in ipairs(CATEGORIAS_ROPA) do
    panelCatRopa.items[i] = { tipo = "cat", label = c[1], desc = "Ropa: " .. c[1]:lower() .. ".",
        activo = function() return Ropa.cat == i end,
        fn = function() if Ropa.cat ~= i then Ropa.cat = i; Ropa.sucio = true end end }
end

-- Rehace el panel de prendas si cambia la categoría o el modelo del personaje
function ActualizarRopa()
    local modelo = GetEntityModel(PlayerPedId())
    if modelo ~= Ropa.modelo then
        -- Otro personaje: lo guardado de la cara ya no vale
        if Ropa.modelo then Ropa.cara, Ropa.rasgos, Ropa.detalles, Ropa.ojos, Ropa.vistaTatuaje = nil, {}, {}, nil, {} end
        Ropa.modelo, Ropa.sucio = modelo, true
    end
    if not Ropa.sucio then return end
    Ropa.sucio = false
    panelRopa._scroll, panelRopa._scrollObj = 0, 0
    local cat = CATEGORIAS_ROPA[Ropa.cat]
    panelRopa.titulo = cat[1]
    local items = {}
    local ok, err = pcall(cat[2], items)
    if not ok then items = { { tipo = "texto", label = "Error: " .. tostring(err) } } end
    if #items == 0 then items[1] = { tipo = "texto", label = "Tu personaje no tiene prendas de este tipo" } end
    panelRopa.items = items
end

-- ═════════════════════════════════════════════════════════
-- GUARDADO
--   Los ajustes, las teclas y los atuendos se guardan solos (en el almacenamiento
--   en un archivo de tu carpeta de Windows, si Susano deja escribir archivos) y se
--   cargan al iniciar el script. Siempre se pueden exportar/importar con el portapapeles.
--   IMPORTANTE: no se usa el almacenamiento de FiveM (SetResourceKvp): desde un
--   inyector no hay recurso y esa función cierra el juego.
--   La apariencia completa se guarda con su botón en Personaje > Utilidades.
-- ═════════════════════════════════════════════════════════
local CLAVE_AJUSTES    = "sg_menu_ajustes_v1"
local CLAVE_APARIENCIA = "sg_menu_apariencia_v1"

-- Convierte una tabla en texto (y de vuelta), sin depender de librerías
local function Serializar(v)
    local t = type(v)
    if t == "number" then
        if v ~= v or v == math.huge or v == -math.huge then return "0" end
        if math.type and math.type(v) == "integer" then return tostring(v) end
        return string.format("%.6f", v)
    elseif t == "boolean" then return tostring(v)
    elseif t == "string" then return string.format("%q", v)
    elseif t == "table" then
        local partes = {}
        for k, x in pairs(v) do
            local tk, tx = type(k), type(x)
            if (tk == "number" or tk == "string") and tx ~= "function" and tx ~= "userdata" then
                partes[#partes + 1] = "[" .. Serializar(k) .. "]=" .. Serializar(x)
            end
        end
        return "{" .. table.concat(partes, ",") .. "}"
    end
    return "nil"
end

local function Deserializar(s)
    if type(s) ~= "string" or s == "" then return nil end
    if load then
        local f = load("return " .. s, "ajustes", "t", {})
        if f then
            local ok, r = pcall(f)
            if ok and type(r) == "table" then return r end
        end
    end
    return nil
end

-- Archivo en %APPDATA% (solo si el entorno de Lua tiene io y os)
local function RutaArchivo(clave)
    local ok, base = pcall(function()
        if not (io and io.open and os and os.getenv) then return nil end
        return os.getenv("APPDATA") or os.getenv("LOCALAPPDATA") or os.getenv("TEMP")
    end)
    if not ok or type(base) ~= "string" or base == "" then return nil end
    return base .. "\\" .. clave .. ".txt"
end

local function Escribir(clave, texto)
    local ruta = RutaArchivo(clave)
    if not ruta then return false end
    local ok = pcall(function()
        local f = assert(io.open(ruta, "w"))
        f:write(texto)
        f:close()
    end)
    return ok
end

local function LeerArchivo(clave)
    local ruta = RutaArchivo(clave)
    if not ruta then return nil end
    local ok, texto = pcall(function()
        local f = io.open(ruta, "r")
        if not f then return nil end
        local t = f:read("*a")
        f:close()
        return t
    end)
    return ok and texto or nil
end

function Guardado.Disponible() return RutaArchivo("prueba") ~= nil end

local function GuardarKvp(clave, tabla) return Escribir(clave, Serializar(tabla)) end
local function CargarKvp(clave) return Deserializar(LeerArchivo(clave)) end

-- Valores por defecto (para "Restablecer")
local CONFIG_DEFECTO = {}
for k, v in pairs(Config) do if type(v) ~= "table" then CONFIG_DEFECTO[k] = v end end

function Guardado.Guardar(silencioso)
    local datos = { config = {}, teclas = {}, atuendos = Ropa.atuendos }
    for k, v in pairs(Config) do if type(v) ~= "table" then datos.config[k] = v end end
    for _, b in ipairs(binds) do datos.teclas[b.id] = b.tecla end
    local ok = GuardarKvp(CLAVE_AJUSTES, datos)
    Guardado.pendiente = false
    if not silencioso then Avisar(ok and "Ajustes guardados" or "Aquí no se pueden guardar archivos: usa Exportar ajustes") end
    return ok
end

local function CargarAjustes()
    local datos = CargarKvp(CLAVE_AJUSTES)
    if not datos then return false end
    if type(datos.config) == "table" then
        for k, v in pairs(datos.config) do
            -- Solo claves que existen y con el mismo tipo (por si cambia el script)
            if CONFIG_DEFECTO[k] ~= nil and type(v) == type(CONFIG_DEFECTO[k]) then Config[k] = v end
        end
        Config.colorMenu = Clamp(math.floor(Config.colorMenu), 1, #COLORES)
    end
    if type(datos.teclas) == "table" then
        for _, b in ipairs(binds) do
            local t = datos.teclas[b.id]
            if type(t) == "number" and t > 0 and t < 256 then b.tecla = t end
        end
    end
    if type(datos.atuendos) == "table" then Ropa.atuendos = datos.atuendos end
    return true
end

local function RestablecerAjustes()
    for k, v in pairs(CONFIG_DEFECTO) do Config[k] = v end
    for i, b in ipairs(binds) do b.tecla = bindsPorDefecto[i] end
    if vehiculo and not Config.activado then Soltar() end
    Guardado.Guardar(true)
    Avisar("Ajustes restablecidos")
end

-- ── Apariencia completa ───────────────────────────────────
local function CapturarApariencia()
    local p = PlayerPedId()
    local a = { modelo = GetEntityModel(p), comp = {}, prop = {},
                pelo = { GetPedHairColor(p), GetPedHairHighlightColor(p) } }
    for _, c in ipairs(COMPONENTES) do
        a.comp[c] = { GetPedDrawableVariation(p, c), GetPedTextureVariation(p, c), GetPedPaletteVariation(p, c) }
    end
    for _, pr in ipairs(PROPS) do a.prop[pr] = { GetPedPropIndex(p, pr), GetPedPropTextureIndex(p, pr) } end
    if EsFreemode() then
        a.cara = LeerCara()
        a.rasgos = Ropa.rasgos
        a.detalles = {}
        for _, d in ipairs(DETALLES) do a.detalles[d[1]] = LeerDetalle(d[1]) end
        a.ojos = Ropa.ojos
        AdoptarTatuajes()
        a.tatuajes = Ropa.tatuajes
    end
    return a
end

local function AplicarApariencia(a)
    if type(a) ~= "table" then return false end
    -- Cambiar al modelo guardado si es freemode y no es el actual
    if a.modelo and a.modelo ~= GetEntityModel(PlayerPedId()) then
        if a.modelo == M_FREEMODE then CambiarModelo("mp_m_freemode_01")
        elseif a.modelo == F_FREEMODE then CambiarModelo("mp_f_freemode_01") end
    end
    local p = PlayerPedId()
    if EsFreemode() and a.cara then
        Ropa.cara = a.cara; AplicarCara()
        Ropa.rasgos = a.rasgos or {}
        for id, v in pairs(Ropa.rasgos) do SetPedFaceFeature(p, id, v + 0.0) end
        Ropa.detalles = a.detalles or {}
        for _, d in ipairs(DETALLES) do if Ropa.detalles[d[1]] then AplicarDetalle(d[1], d[3]) end end
        if a.ojos then Ropa.ojos = a.ojos; SetPedEyeColor(p, a.ojos) end
    end
    for c, v in pairs(a.comp or {}) do
        if type(v) == "table" and IsPedComponentVariationValid(p, c, v[1], v[2]) then
            SetPedComponentVariation(p, c, v[1], v[2], v[3] or 0)
        end
    end
    for pr, v in pairs(a.prop or {}) do
        if v[1] < 0 then ClearPedProp(p, pr) else SetPedPropIndex(p, pr, v[1], math.max(v[2], 0), true) end
    end
    if a.pelo then SetPedHairColor(p, a.pelo[1], a.pelo[2]) end
    if EsFreemode() then
        Ropa.tatuajes, Ropa.vistaTatuaje = a.tatuajes or {}, {}
        AplicarTatuajes()
    end
    Ropa.Refijar()
    Ropa.sucio = true
    return true
end

local function GuardarApariencia()
    local ok = GuardarKvp(CLAVE_APARIENCIA, CapturarApariencia())
    Avisar(ok and "Apariencia guardada" or "Aquí no se pueden guardar archivos: usa Exportar ajustes")
end

local function CargarApariencia(silencioso)
    local a = CargarKvp(CLAVE_APARIENCIA)
    if not a then if not silencioso then Avisar("No hay apariencia guardada") end; return end
    AplicarApariencia(a)
    if not silencioso then Avisar("Apariencia cargada") end
end

-- Botones en Personaje > Utilidades
do
    local util = CATEGORIAS_ROPA[#CATEGORIAS_ROPA]
    local construir = util[2]
    util[2] = function(I)
        construir(I)
        I[#I + 1] = { tipo = "accion", label = "Guardar mi apariencia", fn = GuardarApariencia,
            desc = "Guarda ropa, cara, maquillaje y tatuajes para la próxima vez." }
        I[#I + 1] = { tipo = "accion", label = "Cargar mi apariencia", fn = function() CargarApariencia(false) end,
            desc = "Te pone la apariencia guardada." }
        I[#I + 1] = { tipo = "toggle", label = "Cargar al iniciar", key = "aparienciaAlIniciar",
            desc = "Al cargar el script, te pone la apariencia guardada automáticamente." }
    end
end

local PREFIJO = "SGMENU1:"

function Guardado.Exportar()
    if type(Susano.CopyToClipboard) ~= "function" then Avisar("Tu Susano no tiene portapapeles"); return end
    local datos = { config = {}, teclas = {}, atuendos = Ropa.atuendos, apariencia = CapturarApariencia() }
    for k, v in pairs(Config) do if type(v) ~= "table" then datos.config[k] = v end end
    for _, b in ipairs(binds) do datos.teclas[b.id] = b.tecla end
    local ok = pcall(Susano.CopyToClipboard, PREFIJO .. Serializar(datos))
    Avisar(ok and "Copiado: pégalo en un .txt para guardarlo" or "No se pudo copiar")
end

function Guardado.Importar()
    if type(Susano.GetClipboardText) ~= "function" then Avisar("Tu Susano no tiene portapapeles"); return end
    local ok, texto = pcall(Susano.GetClipboardText)
    if not ok or type(texto) ~= "string" or texto:sub(1, #PREFIJO) ~= PREFIJO then
        Avisar("Copia primero un texto exportado (empieza por " .. PREFIJO .. ")"); return
    end
    local datos = Deserializar(texto:sub(#PREFIJO + 1))
    if not datos then Avisar("El texto copiado no es válido"); return end
    if type(datos.config) == "table" then
        for k, v in pairs(datos.config) do
            if CONFIG_DEFECTO[k] ~= nil and type(v) == type(CONFIG_DEFECTO[k]) then Config[k] = v end
        end
        Config.colorMenu = Clamp(math.floor(Config.colorMenu), 1, #COLORES)
    end
    if type(datos.teclas) == "table" then
        for _, b in ipairs(binds) do
            local t = datos.teclas[b.id]
            if type(t) == "number" and t > 0 and t < 256 then b.tecla = t end
        end
    end
    if type(datos.atuendos) == "table" then Ropa.atuendos = datos.atuendos end
    if type(datos.apariencia) == "table" then AplicarApariencia(datos.apariencia) end
    if vehiculo and not Config.activado then Soltar() end
    Guardado.pendiente = true
    Avisar("Ajustes importados")
end

Guardado.Restablecer = RestablecerAjustes
Guardado.Capturar = CapturarApariencia
Guardado.Aplicar = AplicarApariencia
Guardado.Cargar = CargarAjustes
Guardado.CargarApariencia = CargarApariencia

end

local Pos, PosesionFrame, LineaPosesion, panelPosesion, panelCercanos, ActualizarCercanos, ResaltarLista
do
-- ═════════════════════════════════════════════════════════
-- CONTROLAR NPCs A DISTANCIA
--   Tú te quedas en tu sitio. El NPC se maneja con tus teclas y una cámara que le sigue:
--   WASD moverse · Shift correr · Espacio saltar · F subir/bajar de vehículo
--   Clic derecho apuntar · Clic izquierdo disparar/pelear · Ratón mover la cámara
--   No cambia el modelo del jugador ni clona personajes (más seguro en FiveM).
-- ═════════════════════════════════════════════════════════
Pos = { activo = false, npc = nil, cam = nil, yaw = 0.0, pitch = -10.0, apuntado = nil, animal = 1,
        ultimaOrden = 0, ultimaDir = nil, ultimaVel = 0, muerteDesde = nil, creado = false, ultimaLista = 0 }

local ANIMALES = {
    { "Husky", "a_c_husky" }, { "Retriever", "a_c_retriever" }, { "Rottweiler", "a_c_rottweiler" },
    { "Pastor", "a_c_shepherd" }, { "Caniche", "a_c_poodle" }, { "Gato", "a_c_cat_01" },
    { "Coyote", "a_c_coyote" }, { "Puma", "a_c_mtlion" }, { "Ciervo", "a_c_deer" }, { "Jabalí", "a_c_boar" },
    { "Vaca", "a_c_cow" }, { "Cerdo", "a_c_pig" }, { "Gallina", "a_c_hen" }, { "Conejo", "a_c_rabbit_01" },
    { "Rata", "a_c_rat" }, { "Chimpancé", "a_c_chimp" },
}
local nombresAnimales = {}
for i, a in ipairs(ANIMALES) do nombresAnimales[i] = a[1] end

local HUMANOS = {
    { "Skater", "a_m_y_skater_01" }, { "Deportista", "a_m_y_runner_01" }, { "Obrero", "s_m_y_construct_01" },
    { "Policía", "s_m_y_cop_01" }, { "Médico", "s_m_m_paramedic_01" }, { "Pandillero", "g_m_y_ballaorig_01" },
    { "Motero", "g_m_y_lost_01" }, { "Culturista", "a_m_y_musclbeac_01" }, { "Ejecutiva", "a_f_y_business_01" },
    { "Turista", "a_f_y_tourist_01" }, { "Vagabundo", "a_m_m_tramp_01" }, { "Payaso", "s_m_y_clown_01" },
}
local nombresHumanos = {}
for i, p in ipairs(HUMANOS) do nombresHumanos[i] = p[1] end
Pos.humano = 1

local function Paso(txt) print("[cargar coches] control: " .. txt) end

-- Flecha encima de la cabeza de un NPC (se dibuja en el mundo, no toca al personaje)
local function FlechaSobre(ped)
    if not ped or not DoesEntityExist(ped) then return end
    local c = GetEntityCoords(ped)
    R.Flecha(c.x, c.y, c.z + 1.25, 0.71, 0.59, 1.0)
end

-- NPC al que apuntas con la cámara (no jugadores)
local function BuscarNpc()
    local ped   = PlayerPedId()
    local desde = GetGameplayCamCoord()
    local hasta = desde + DirCamara() * Config.alcancePosesion
    local hit, _, ent = Raycast(desde, hasta, -1, ped)
    if hit and ent ~= 0 and IsEntityAPed(ent) and not IsPedAPlayer(ent) and not IsPedDeadOrDying(ent, true) then
        return ent
    end
    return nil
end

-- Dirección de la cámara del control (yaw/pitch propios)
local function DirControl()
    local y, p = math.rad(Pos.yaw), math.rad(Pos.pitch)
    return vector3(-math.sin(y) * math.cos(p), math.cos(y) * math.cos(p), math.sin(p))
end

-- ── Empezar / dejar de controlar ─────────────────────────
local Soltar_, DejarDePegar

-- Cámara propia: se crea, se ACTIVA y se pone a renderizar
local function IniciarCamPropia()
    if Pos.cam and DoesCamExist(Pos.cam) then DestroyCam(Pos.cam, false) end
    Pos.cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamActive(Pos.cam, true)
    SetCamFov(Pos.cam, 60.0)
    RenderScriptCams(true, false, 0, true, false)
end

-- Deja al MISMO NPC compartido en red (para que los demás lo vean) y a nosotros como dueños
-- (si otro cliente es el dueño, el juego ignora nuestras órdenes). Devuelve ok, motivo.
-- ¿El servidor comparte los NPCs de la calle? (onesync_population true → los ambientales vienen en red)
local cacheServidor = { t = -5000, v = nil }
local function ServidorComparteNpcs()
    if GetGameTimer() - cacheServidor.t < 1000 then return cacheServidor.v end
    cacheServidor.t = GetGameTimer()
    cacheServidor.v = nil
    if not NetworkIsSessionStarted() then cacheServidor.v = false; return false end
    local me = PlayerPedId()
    local vistos, enRed = 0, 0
    for _, o in ipairs(GetGamePool("CPed")) do
        if o ~= me and not IsPedAPlayer(o) and not IsEntityAMissionEntity(o) then
            vistos = vistos + 1
            if NetworkGetEntityIsNetworked(o) then enRed = enRed + 1 end
            if vistos >= 12 then break end
        end
    end
    if vistos == 0 then return nil end          -- no hay NPCs de la calle para saberlo
    cacheServidor.v = enRed > 0
    return cacheServidor.v
end
Pos.ServidorComparte = ServidorComparteNpcs

-- Que los demás lo vean aunque esté lejos de ellos (nativo de FiveM; si no existe, se ignora)
local function VerDesdeLejos(npc, radio)
    if type(SetEntityDistanceCullingRadius) == "function" then
        pcall(SetEntityDistanceCullingRadius, npc, radio)
    end
end

local function PrepararRed(npc)
    if NetworkIsSessionStarted() then
        if Config.compartirNpc and not NetworkGetEntityIsNetworked(npc) then
            -- Un NPC de la calle registrado en red lo BORRA el servidor si no comparte población.
            -- Solo se registra si el juego lo ha aceptado como NPC "de misión" (esos sí se admiten).
            SetEntityAsMissionEntity(npc, true, true)
            Citizen.Wait(0)
            if not IsEntityAMissionEntity(npc) then
                Paso("no se registra en red: el juego no lo acepta como NPC propio")
                Avisar("Este NPC no se puede compartir sin que el servidor lo borre. Usa 'Crear NPC compartido' o pon onesync_population true.")
            else
                Paso("registrando NPC en red")
                NetworkRegisterEntityAsNetworked(npc)
                local t = 0
                while not NetworkGetEntityIsNetworked(npc) and t < 20 do Citizen.Wait(25); t = t + 1 end
                if NetworkGetEntityIsNetworked(npc) then
                    SetNetworkIdExistsOnAllMachines(NetworkGetNetworkIdFromEntity(npc), true)
                end
            end
        end
        local t = 0
        while not NetworkHasControlOfEntity(npc) and t < 40 do
            NetworkRequestControlOfEntity(npc)
            Citizen.Wait(25); t = t + 1
        end
        if not NetworkHasControlOfEntity(npc) then
            Paso("sin control de red del NPC (se intenta igualmente)")
            Avisar("Aviso: otro cliente es el dueño de este NPC; puede que no obedezca")
            return true, nil, npc
        end
        if NetworkGetEntityIsNetworked(npc) then
            local id = NetworkGetNetworkIdFromEntity(npc)
            SetNetworkIdCanMigrate(id, false)          -- que no pase a otro jugador mientras lo usas
            SetNetworkIdExistsOnAllMachines(id, true)
            VerDesdeLejos(npc, 3000.0)
            Pos.redId = id
            -- El mismo NPC puede tener otro identificador local tras compartirlo
            local e = NetworkGetEntityFromNetworkId(id)
            if e and e ~= 0 and DoesEntityExist(e) then npc = e end
        else
            Pos.redId = nil
            if Config.compartirNpc then Avisar("Aviso: el servidor no deja compartir este NPC; solo lo verás tú") end
        end
    end
    return true, nil, npc
end

local ControlarAhora

-- Cómo está el NPC en la red: si el servidor lo conoce y si eres tú quien lo manda
local function EstadoRed(npc)
    if not npc or not DoesEntityExist(npc) then return "sin NPC" end
    if not NetworkIsSessionStarted() then return "sin sesión de red" end
    if not NetworkGetEntityIsNetworked(npc) then
        return "solo local: el servidor no lo conoce"
    end
    local dueno = NetworkGetEntityOwner(npc)
    if dueno == PlayerId() then return "compartido y tuyo (los demás lo ven)" end
    return "compartido, pero lo manda otro jugador"
end


-- Empieza a controlar un NPC (en segundo plano: hay que esperar a la red)
local function Controlar(npc, creadoPorMi)
    if Pos.ocupado then return end
    Pos.ocupado = true
    Citizen.CreateThread(function()
        local ok, err = pcall(ControlarAhora, npc, creadoPorMi)
        if not ok then print("[cargar coches] Error al controlar: " .. tostring(err)); Avisar("No se pudo controlar") end
        Pos.ocupado = false
    end)
end

function ControlarAhora(npc, creadoPorMi)
    if not npc or not DoesEntityExist(npc) or IsPedAPlayer(npc) then return end
    if Pos.activo then Soltar_() end
    Paso("empezando")
    SetEntityAsMissionEntity(npc, true, true)
    local modelo, pos0 = GetEntityModel(npc), GetEntityCoords(npc)
    local okRed, motivo, npcRed = PrepararRed(npc)
    if not okRed then Avisar(motivo); return end
    npc = npcRed or npc
    if not DoesEntityExist(npc) then
        -- Recuperar el mismo NPC por posición y modelo si el juego le cambió el identificador
        for _, o in ipairs(GetGamePool("CPed")) do
            if GetEntityModel(o) == modelo and #(GetEntityCoords(o) - pos0) < 2.0 and not IsPedAPlayer(o) then npc = o; break end
        end
        if not DoesEntityExist(npc) then Avisar("El NPC ha desaparecido al prepararlo"); Paso("desaparecido al prepararlo"); return end
    end
    if not IsPedInAnyVehicle(npc, false) then
        ClearPedTasksImmediately(npc)       -- deja de hacer lo que hacía (sentado, apoyado...)
        DetachEntity(npc, true, false)
    end
    SetBlockingOfNonTemporaryEvents(npc, true)  -- que no huya ni reaccione solo
    SetPedFleeAttributes(npc, 0, false)
    SetPedKeepTask(npc, true)
    -- Que no vuelva solo a sus animaciones (sentarse, fumar, apoyarse...)
    SetPedCanPlayAmbientAnims(npc, false)
    SetPedCanPlayAmbientBaseAnims(npc, false)
    if not IsPedInAnyVehicle(npc, false) then TaskStandStill(npc, -1) end
    -- Preparado para pelear de verdad
    SetPedCombatAbility(npc, 2)
    SetPedCombatMovement(npc, 2)
    SetPedCombatRange(npc, 0)
    SetPedCombatAttributes(npc, 5, true)    -- puede pelear con armas o a puños
    SetPedCombatAttributes(npc, 46, true)   -- siempre pelea
    SetPedCombatAttributes(npc, 17, false)  -- no huye
    Pos.entrando, Pos.peleandoHasta, Pos.ultimoIdle = nil, 0, 0
    Pos.victima, Pos.vehConducido, Pos.ultimaAccion = nil, nil, nil

    local me = PlayerPedId()
    if vehiculo then Soltar() end
    FreezeEntityPosition(me, true)
    if Config.protegerCuerpo then SetEntityInvincible(me, true) end

    Pos.npc, Pos.activo, Pos.creado = npc, true, creadoPorMi and true or false
    Pos.ultimaPos, Pos.modeloNpc = GetEntityCoords(npc), GetEntityModel(npc)
    Pos.yaw, Pos.pitch = GetEntityHeading(npc), -10.0
    Pos.ultimaDir, Pos.ultimaVel = nil, 0

    -- Cámara: la del juego siguiendo al NPC (por defecto) o una cámara propia
    Pos.modoCam = Config.camaraPropia and "propia" or "juego"
    if Pos.modoCam == "propia" then IniciarCamPropia() end
    SetFocusEntity(npc)   -- el mundo se carga alrededor del NPC
    Paso("camara: " .. Pos.modoCam)
    local estado = EstadoRed(npc)
    Paso("red: " .. estado)
    Avisar("Red del NPC: " .. estado)
    Avisar("Controlando NPC · " .. NombreTecla(TeclaDe("volver")) .. " para soltarlo")
end

function Soltar_(motivo)
    if not Pos.activo then return end
    Paso("soltando" .. (motivo and (": " .. motivo) or ""))
    if motivo then Avisar("Control soltado: " .. motivo) end
    local npc = Pos.npc
    if Pos.cam then
        RenderScriptCams(false, false, 0, true, false)
        if DoesCamExist(Pos.cam) then SetCamActive(Pos.cam, false); DestroyCam(Pos.cam, false) end
    end
    ClearFocus()
    local me = PlayerPedId()
    FreezeEntityPosition(me, false)
    SetEntityInvincible(me, false)
    if npc and DoesEntityExist(npc) then
        SetPedCanPlayAmbientAnims(npc, true)
        SetPedCanPlayAmbientBaseAnims(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, false)
        SetPedKeepTask(npc, false)
        if not IsPedInAnyVehicle(npc, false) then ClearPedTasks(npc) end
        if Pos.redId then SetNetworkIdCanMigrate(Pos.redId, true); VerDesdeLejos(npc, 0.0) end
        SetPedAsNoLongerNeeded(npc)
    end
    Pos.activo, Pos.npc, Pos.cam, Pos.redId = false, nil, nil, nil
    Pos.victima, Pos.vehConducido, Pos.ultimaAccion = nil, nil, nil
    Pos.ultimaPos, Pos.modeloNpc = nil, nil
end

-- A quién pegar: primero a quien mires; si no, al más cercano delante del NPC
local function BuscarVictima(npc, c, camPos, d)
    local _, _, ent = Raycast(camPos, camPos + d * 60.0, 4 + 8, npc)
    if ent and ent ~= 0 and IsEntityAPed(ent) and ent ~= npc and ent ~= PlayerPedId()
        and not IsPedDeadOrDying(ent, true) then return ent end
    local radio = Config.npcAgresivo and 20.0 or 4.0
    local mejor, md = nil, radio
    local fx, fy = -math.sin(math.rad(Pos.yaw)), math.cos(math.rad(Pos.yaw))
    for _, o in ipairs(GetGamePool("CPed")) do
        if o ~= npc and o ~= PlayerPedId() and not IsPedDeadOrDying(o, true) then
            local oc = GetEntityCoords(o)
            local dd = #(oc - c)
            local delante = dd < 2.0 or (((oc.x - c.x) * fx + (oc.y - c.y) * fy) / math.max(dd, 0.01)) > 0.3
            if dd < md and delante then mejor, md = o, dd end
        end
    end
    return mejor
end

-- Deja de pegar al momento y se queda de pie
function DejarDePegar(npc)
    Pos.victima, Pos.pegarMinimo, Pos.peleandoHasta = nil, 0, 0
    if not npc or not DoesEntityExist(npc) then return end
    ClearPedTasks(npc)
    if IsPedInMeleeCombat(npc) or IsPedInCombat(npc, 0) then ClearPedTasksImmediately(npc) end
    TaskStandStill(npc, -1)
end

-- ── Manejar al NPC cada frame ────────────────────────────
local function ManejarNpc(menuAbierto)
    local npc = Pos.npc
    if npc and not DoesEntityExist(npc) and Pos.ultimaPos then
        -- Mismo NPC con otro identificador: buscarlo donde estaba, con el mismo modelo
        for _, o in ipairs(GetGamePool("CPed")) do
            if GetEntityModel(o) == Pos.modeloNpc and #(GetEntityCoords(o) - Pos.ultimaPos) < 3.0 and not IsPedAPlayer(o) then
                Paso("NPC recuperado con otro identificador")
                npc = o; Pos.npc = o
                break
            end
        end
    end
    if not npc or not DoesEntityExist(npc) then Soltar_("el NPC ha desaparecido"); return end
    Pos.ultimaPos, Pos.modeloNpc = GetEntityCoords(npc), GetEntityModel(npc)

    -- Si muere, se suelta a los 2 segundos
    if IsPedDeadOrDying(npc, true) then
        Pos.muerteDesde = Pos.muerteDesde or GetGameTimer()
        if GetGameTimer() - Pos.muerteDesde > 2000 then Pos.muerteDesde = nil; Soltar_("el NPC ha muerto") end
    else
        Pos.muerteDesde = nil
    end

    DisableAllControlActions(0)       -- tu personaje no se mueve; las teclas van al NPC
    NetworkRequestControlOfEntity(npc)

    local c = GetEntityCoords(npc)
    local d, camPos
    if Pos.modoCam == "juego" then
        -- La cámara normal del juego sigue al NPC (SET_GAMEPLAY_CAM_FOLLOW_PED_THIS_UPDATE)
        Citizen.InvokeNative(0x8BBACBF51DA047A8, npc)
        if not menuAbierto then
            EnableControlAction(0, 1, true)   -- mirar con el ratón
            EnableControlAction(0, 2, true)
        end
        d, camPos = DirCamara(), GetGameplayCamCoord()
        Pos.yaw = GetGameplayCamRot(2).z
    else
        -- Cámara propia: comprobar cada frame que sigue activa y renderizando
        if not Pos.cam or not DoesCamExist(Pos.cam) then IniciarCamPropia() end
        if not IsCamActive(Pos.cam) then SetCamActive(Pos.cam, true) end
        if not IsCamRendering(Pos.cam) then RenderScriptCams(true, false, 0, true, false) end
        if not menuAbierto then
            Pos.yaw   = Pos.yaw - GetDisabledControlNormal(0, 1) * 8.0
            Pos.pitch = Clamp(Pos.pitch - GetDisabledControlNormal(0, 2) * 6.0, -70.0, 50.0)
        end
        d = DirControl()
        local foco = c + vector3(0.0, 0.0, 0.7)
        camPos = foco - d * Config.distanciaCamara + vector3(0.0, 0.0, 0.3)
        SetCamCoord(Pos.cam, camPos.x, camPos.y, camPos.z)
        PointCamAtCoord(Pos.cam, foco.x + d.x * 2.0, foco.y + d.y * 2.0, foco.z + d.z * 2.0)
    end

    if menuAbierto then return end

    local ahora = GetGameTimer()
    local lr = GetDisabledControlNormal(0, 30)   -- A/D
    local ud = GetDisabledControlNormal(0, 31)   -- W/S (W es negativo)
    local veh = GetVehiclePedIsIn(npc, false)

    -- F: subir o bajar de un vehículo
    if IsDisabledControlJustPressed(0, 23) then
        if veh ~= 0 then
            TaskLeaveVehicle(npc, veh, 0)
        else
            local mejor, md = nil, 7.0
            for _, v in ipairs(GetGamePool("CVehicle")) do
                local dv = #(GetEntityCoords(v) - c)
                if dv < md then mejor, md = v, dv end
            end
            if mejor then
                NetworkRequestControlOfEntity(mejor)
                SetVehicleDoorsLocked(mejor, 1)                  -- quitar el seguro
                SetVehicleDoorsLockedForAllPlayers(mejor, false)
                -- 1 = seguir si se interrumpe, 8 = sacar a quien esté en el asiento
                TaskEnterVehicle(npc, mejor, 6000, -1, 2.0, 1 + 8, 0)
                Pos.entrando = { veh = mejor, desde = ahora }
            end
        end
        return
    end

    if veh ~= 0 then
        -- Conducir: acciones temporales cortas, solo mientras pulsas algo.
        -- Sin teclas no se da ninguna orden y el coche sigue rodando (antes frenaba en seco).
        if GetPedInVehicleSeat(veh, -1) ~= npc then return end
        if Pos.vehConducido ~= veh then
            -- Nada más subirse: quitarle la ruta que llevaba para que no conduzca solo
            Pos.vehConducido, Pos.ultimaAccion = veh, nil
            ClearPedTasks(npc)
            SetVehicleEngineOn(veh, true, true, false)
        end
        if not NetworkHasControlOfEntity(veh) then NetworkRequestControlOfEntity(veh) end
        local adelante, atras = ud < -0.2, ud > 0.2
        local izq, der = lr < -0.2, lr > 0.2
        local turbo = IsDisabledControlPressed(0, 21)                   -- Shift: a tope
        local accion
        if IsDisabledControlPressed(0, 22) then accion = 6               -- freno de mano
        elseif adelante and atras then accion = 30                       -- quemar rueda
        elseif adelante and izq then accion = 7                          -- gira y acelera
        elseif adelante and der then accion = 8
        elseif adelante then accion = turbo and 23 or 9                  -- acelerar
        elseif atras and izq then accion = 13                            -- marcha atrás girando
        elseif atras and der then accion = 14
        elseif atras then accion = 22                                    -- frena y luego marcha atrás
        elseif izq then accion = 4                                       -- girar frenando
        elseif der then accion = 5
        end
        if accion then
            if accion ~= Pos.ultimaAccion or ahora - (Pos.ultimaAccionT or 0) > 80 then
                TaskVehicleTempAction(npc, veh, accion, 150)
                Pos.ultimaAccion, Pos.ultimaAccionT = accion, ahora
            end
        else
            Pos.ultimaAccion = nil
        end
        return
    end

    Pos.vehConducido = nil
    local hayMovimiento = math.abs(lr) > 0.15 or math.abs(ud) > 0.15

    -- Subiéndose a un vehículo: esperar, salvo que lo muevas tú
    if Pos.entrando then
        local e = Pos.entrando
        if hayMovimiento or not DoesEntityExist(e.veh) then
            Pos.entrando = nil
        elseif IsPedInVehicle(npc, e.veh, false) then
            Pos.entrando = nil
            return
        elseif ahora - e.desde > 5000 then
            -- Atascado (puerta, obstáculo...): meterlo directamente al asiento del conductor
            local conductor = GetPedInVehicleSeat(e.veh, -1)
            if conductor ~= 0 and conductor ~= npc and not IsPedAPlayer(conductor) then
                TaskLeaveVehicle(conductor, e.veh, 16)   -- 16 = salir al instante
                Citizen.Wait(0)
            end
            if IsVehicleSeatFree(e.veh, -1) then TaskWarpPedIntoVehicle(npc, e.veh, -1)
            else
                for sa = 0, GetVehicleMaxNumberOfPassengers(e.veh) - 1 do
                    if IsVehicleSeatFree(e.veh, sa) then TaskWarpPedIntoVehicle(npc, e.veh, sa); break end
                end
            end
            Pos.entrando = nil
            return
        else
            return
        end
    end

    -- A pie: salto, disparo/pelea, movimiento
    if IsDisabledControlJustPressed(0, 22) then TaskJump(npc, true, false, false); return end

    local apuntando = IsDisabledControlPressed(0, 25)
    local clic      = IsDisabledControlPressed(0, 24)
    local disparo   = IsDisabledControlJustPressed(0, 24) or (apuntando and clic)
    local _, arma   = GetCurrentPedWeapon(npc, true)
    local armado    = arma and arma ~= H_DESARMADO

    -- Con arma: apuntar con clic derecho, disparar con clic izquierdo
    if armado and (apuntando or disparo) then
        if Pos.victima then DejarDePegar(npc) end
        local _, fin = Raycast(camPos, camPos + d * 200.0, -1, npc)
        local objetivo = fin or (camPos + d * 200.0)
        if disparo then
            TaskShootAtCoord(npc, objetivo.x, objetivo.y, objetivo.z, 300, GetHashKey("FIRING_PATTERN_FULL_AUTO"))
        elseif ahora - Pos.ultimaOrden > 300 then
            TaskAimGunAtCoord(npc, objetivo.x, objetivo.y, objetivo.z, 1000, false, false)
            Pos.ultimaOrden = ahora
        end
        return
    end

    -- Sin arma: pega MIENTRAS mantienes el clic izquierdo; al soltarlo (o al moverte) deja de pegar
    if not armado and clic and not hayMovimiento then
        local v = Pos.victima
        local valida = v and DoesEntityExist(v) and not IsPedDeadOrDying(v, true)
        if IsDisabledControlJustPressed(0, 24) or not valida then
            local nueva = BuscarVictima(npc, c, camPos, d)
            if nueva then
                if nueva ~= v or not IsPedInMeleeCombat(npc) then
                    if #(GetEntityCoords(nueva) - c) < 3.0 then
                        -- Directo a los puños (TASK_PUT_PED_DIRECTLY_INTO_MELEE)
                        Citizen.InvokeNative(0x1C6CD14A876FFE39, npc, nueva, 0.0, -1.0, 0.0, false)
                    else
                        TaskCombatPed(npc, nueva, 0, 16)   -- va a por él
                    end
                end
                Pos.victima = nueva
            end
        end
        if Pos.victima then Pos.pegarMinimo = math.max(Pos.pegarMinimo or 0, ahora + 700) end
        Pos.peleandoHasta, Pos.ultimaDir = ahora + 1000, nil
        return
    end
    if Pos.victima then
        -- Un clic corto deja terminar el golpe; luego para
        if hayMovimiento or ahora > (Pos.pegarMinimo or 0) then
            DejarDePegar(npc)
        else
            return
        end
    end

    -- Moverse hacia donde mira la cámara
    if math.abs(lr) > 0.15 or math.abs(ud) > 0.15 then
        local y = math.rad(Pos.yaw)
        local fx, fy = -math.sin(y), math.cos(y)          -- delante
        local rx, ry = math.cos(y), math.sin(y)           -- derecha
        local mx, my = fx * (-ud) + rx * lr, fy * (-ud) + ry * lr
        local len = math.sqrt(mx * mx + my * my)
        mx, my = mx / len, my / len
        local vel = IsDisabledControlPressed(0, 21) and 3.0 or 1.0
        -- Atascado: con las teclas pulsadas y sin moverse durante un momento
        if Pos.ultimaDir and ahora - Pos.ultimaOrden > 600 and GetEntitySpeed(npc) < 0.3 then
            Paso("NPC atascado: forzando movimiento")
            ClearPedTasksImmediately(npc)
            DetachEntity(npc, true, false)
            FreezeEntityPosition(npc, false)
            Pos.ultimaDir = nil
        end
        -- Solo se da una orden nueva si cambia la dirección o la velocidad (movimiento suave)
        local cambio = not Pos.ultimaDir or (mx * Pos.ultimaDir[1] + my * Pos.ultimaDir[2]) < 0.97 or vel ~= Pos.ultimaVel
        if cambio or ahora - Pos.ultimaOrden > 1500 then
            TaskGoStraightToCoord(npc, c.x + mx * 25.0, c.y + my * 25.0, c.z, vel, -1,
                GetHeadingFromVector_2d(mx, my), 0.5)
            Pos.ultimaDir, Pos.ultimaVel, Pos.ultimaOrden = { mx, my }, vel, ahora
        end
    elseif Pos.ultimaDir then
        -- Al soltar las teclas: quedarse de pie (sin órdenes volvería a sentarse)
        TaskStandStill(npc, -1)
        Pos.ultimaDir, Pos.ultimaVel = nil, 0
    elseif ahora > (Pos.peleandoHasta or 0) and ahora - (Pos.ultimoIdle or 0) > 1000 then
        -- Cada segundo: si ha empezado a sentarse o a otra animación de ambiente, cortarla
        Pos.ultimoIdle = ahora
        -- Si se ha quedado pegando sin que lo pidas, pararlo
        if IsPedInMeleeCombat(npc) or IsPedInCombat(npc, 0) then
            ClearPedTasksImmediately(npc)
            TaskStandStill(npc, -1)
        end
        if IsPedUsingAnyScenario(npc) then
            ClearPedTasksImmediately(npc)
            TaskStandStill(npc, -1)
        end
    end
end

-- ── Cada frame ───────────────────────────────────────────
function PosesionFrame(ped, pPoseer, pVolver, menuAbierto)
    if Pos.activo then
        ManejarNpc(menuAbierto)
        if pVolver then Soltar_("tecla " .. NombreTecla(TeclaDe("volver"))) end
        return
    end
    if menuAbierto or not Config.posesion then Pos.apuntado = nil; return end
    -- El rayo es caro: se lanza 20 veces por segundo (y siempre al pulsar la tecla); la flecha se dibuja cada frame
    local ahora = GetGameTimer()
    if pPoseer or ahora >= (Pos.proxBusqueda or 0) then
        Pos.proxBusqueda = ahora + 50
        Pos.apuntado = BuscarNpc()
    elseif Pos.apuntado and not DoesEntityExist(Pos.apuntado) then
        Pos.apuntado = nil
    end
    local objetivo = Pos.apuntado
    if objetivo and Config.contornoNpc then FlechaSobre(objetivo) end
    if pPoseer and objetivo and not Pos.ocupado then Controlar(objetivo, false) end
end

-- Línea de ayuda para el HUD (o nil)
function LineaPosesion()
    if Pos.activo then
        local npc = Pos.npc
        if npc and DoesEntityExist(npc) and IsPedInAnyVehicle(npc, false) then
            return "WASD conducir   Shift a tope   Espacio freno   F bajar   " .. K("volver") .. " soltar"
        end
        return "WASD mover   Shift correr   Espacio saltar   F coche   Mantén clic pegar (suelta para parar)   " .. K("volver") .. " soltar"
    end
    if not Config.posesion then return nil end
    if Pos.apuntado then return K("poseer") .. " Controlar NPC" end
    return nil
end

-- Hace aparecer un NPC compartido (creado en red desde el principio) a tu lado y lo controlas.
-- Al nacer ya en red y como NPC propio, el servidor lo acepta y los demás jugadores lo ven.
local function AparecerPed(modelo, tipoPed, nombre)
    local h = GetHashKey(modelo)
    if not IsModelInCdimage(h) then Avisar(nombre .. " no existe en este juego"); return end
    RequestModel(h)
    local t = 0
    while not HasModelLoaded(h) and t < 300 do Citizen.Wait(10); t = t + 1 end
    if not HasModelLoaded(h) then Avisar("No se pudo cargar " .. nombre); return end
    local me = PlayerPedId()
    local c = GetOffsetFromEntityInWorldCoords(me, 0.0, 2.5, 0.0)
    local ped = CreatePed(tipoPed, h, c.x, c.y, c.z, GetEntityHeading(me), true, true)
    SetModelAsNoLongerNeeded(h)
    if not ped or ped == 0 then Avisar("No se pudo crear " .. nombre); return end
    SetEntityAsMissionEntity(ped, true, true)
    -- Esperar a que el servidor lo tenga
    t = 0
    while DoesEntityExist(ped) and NetworkIsSessionStarted() and not NetworkGetEntityIsNetworked(ped) and t < 40 do
        Citizen.Wait(25); t = t + 1
    end
    if not DoesEntityExist(ped) then
        Avisar("El servidor ha borrado el NPC (sv_entityLockdown strict). Ponlo en relaxed o inactive.")
        return
    end
    if NetworkIsSessionStarted() and not NetworkGetEntityIsNetworked(ped) then
        Avisar("El NPC no se ha podido compartir; solo lo verás tú")
    end
    Controlar(ped, true)
end

local function AparecerAnimal()
    local a = ANIMALES[Pos.animal]
    AparecerPed(a[2], 28, a[1])
end

local function AparecerHumano()
    local p = HUMANOS[Pos.humano]
    AparecerPed(p[2], 4, p[1])
end

panelPosesion = { titulo = "Control", items = {
    { tipo = "toggle", label = "Activado", key = "posesion",
      desc = "Apunta a un NPC y pulsa la tecla para controlarlo a distancia. También desde la lista." },
    { tipo = "toggle", label = "Flecha sobre el NPC apuntado", key = "contornoNpc",
      desc = "Pone una flecha encima del NPC al que apuntas." },
    { tipo = "toggle", label = "NPC agresivo", key = "npcAgresivo",
      desc = "Sin arma, al hacer clic pega a quien mires. Con esto, si no hay nadie cerca va a por el más cercano (20 m)." },
    { tipo = "texto", label = function()
          local s = Pos.ServidorComparte()
          if s == nil then return "Servidor: sin NPCs cerca para comprobarlo" end
          return s and "Servidor: comparte los NPCs (los demás los ven)" or "Servidor: NPCs de la calle solo locales"
      end },
    { tipo = "texto", label = function()
          if not Pos.activo then return "Red: sin NPC controlado" end
          return "Red: " .. EstadoRed(Pos.npc)
      end },
    { tipo = "lista", label = "Persona", opciones = nombresHumanos, desc = "Elige qué NPC crear.",
      get = function() return Pos.humano end, set = function(i) Pos.humano = i end },
    { tipo = "accion", label = "Crear NPC compartido y controlarlo",
      desc = "Aparece a tu lado ya compartido con el servidor: los demás jugadores lo ven moverse, pegar y conducir.",
      fn = function() Citizen.CreateThread(AparecerHumano) end },
    { tipo = "toggle", label = "Compartir NPCs de la calle", key = "compartirNpc",
      desc = "Intenta compartir un NPC de la calle que solo existe en tu juego. Si el servidor no comparte población, no se toca para que no desaparezca." },
    { tipo = "toggle", label = "Proteger tu cuerpo", key = "protegerCuerpo",
      desc = "Mientras controlas a un NPC, a tu personaje no le pueden hacer daño." },
    { tipo = "slider", label = "Alcance al apuntar", key = "alcancePosesion", min = 5, max = 150, paso = 5, fmt = "%.0f m",
      desc = "Distancia máxima para coger un NPC apuntándolo." },
    { tipo = "slider", label = "Radio de la lista", key = "radioLista", min = 25, max = 500, paso = 25, fmt = "%.0f m",
      desc = "Hasta qué distancia salen NPCs en la lista de la derecha." },
    { tipo = "toggle", label = "Usar cámara propia", key = "camaraPropia",
      desc = "Apagado: la cámara normal del juego sigue al NPC. Encendido: cámara propia (por si la otra no va). Se aplica al coger otro NPC." },
    { tipo = "slider", label = "Distancia de la cámara propia", key = "distanciaCamara", min = 2, max = 12, paso = 0.5, fmt = "%.1f m",
      desc = "Lo lejos que va la cámara propia detrás del NPC." },
    { tipo = "accion", label = "Dar pistola al NPC", desc = "El NPC que controlas recibe una pistola.",
      fn = function()
          if Pos.activo and Pos.npc then
              GiveWeaponToPed(Pos.npc, GetHashKey("WEAPON_PISTOL"), 120, false, true); Avisar("Pistola entregada")
          else Avisar("No estás controlando a nadie") end
      end },
    { tipo = "accion", label = "Dejar de controlar", desc = "Suelta al NPC y vuelves a tu cámara.",
      fn = function() if Pos.activo then Soltar_() else Avisar("No estás controlando a nadie") end end },
    { tipo = "lista", label = "Animal", opciones = nombresAnimales, desc = "Elige un animal.",
      get = function() return Pos.animal end, set = function(i) Pos.animal = i end },
    { tipo = "accion", label = "Aparecer animal y controlarlo", desc = "El animal aparece a tu lado y lo manejas tú.",
      fn = function() Citizen.CreateThread(AparecerAnimal) end },
} }

-- ── Lista de NPCs cercanos ───────────────────────────────
panelCercanos = { titulo = "NPCs cerca", items = {} }

local function TipoNpc(npc)
    local tipo
    if GetPedType(npc) == 28 then tipo = "Animal"
    elseif IsPedMale(npc) then tipo = "Hombre" else tipo = "Mujer" end
    local veh = GetVehiclePedIsIn(npc, false)
    if veh ~= 0 then
        tipo = tipo .. ((GetPedInVehicleSeat(veh, -1) == npc) and " conduciendo" or " en vehículo")
    elseif IsPedArmed(npc, 4) then
        tipo = tipo .. " armado"
    end
    return tipo
end

-- Rehace la lista cada segundo, salvo mientras la estás recorriendo (para que no se mueva)
function ActualizarCercanos(forzar)
    if not forzar then
        if GetGameTimer() - Pos.ultimaLista < 1000 then return end
        if Menu.col == 2 then return end
    end
    Pos.ultimaLista = GetGameTimer()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local lista = {}
    for _, n in ipairs(GetGamePool("CPed")) do
        if n ~= ped then
            local d = #(GetEntityCoords(n) - pos)
            if d <= Config.radioLista and not IsPedAPlayer(n) and not IsPedDeadOrDying(n, true) then
                lista[#lista + 1] = { n, d }
            end
        end
    end
    table.sort(lista, function(a, b) return a[2] < b[2] end)
    local items = {
        { tipo = "accion", label = "Actualizar lista", desc = "Vuelve a buscar NPCs cerca.",
          fn = function() ActualizarCercanos(true); Avisar("Lista actualizada") end },
    }
    for i = 1, math.min(#lista, 60) do
        local n, d = lista[i][1], lista[i][2]
        local red = NetworkGetEntityIsNetworked(n) and "red · " or "local · "
        items[#items + 1] = { tipo = "accion", label = TipoNpc(n), derecha = red .. string.format("%.0f m", d), npc = n,
            desc = "Contrólalo a distancia. Tú te quedas donde estás.",
            fn = function()
                if DoesEntityExist(n) and not IsPedDeadOrDying(n, true) then
                    Menu.abierto = false
                    Controlar(n, false)
                else Avisar("Ese NPC ya no está") end
            end }
    end
    if #lista == 0 then items[#items + 1] = { tipo = "texto", label = "No hay NPCs cerca" } end
    panelCercanos.titulo = "NPCs cerca (" .. #lista .. ")"
    panelCercanos.items = items
end

-- Marca en el mundo el NPC de la lista que tienes seleccionado
function ResaltarLista(it)
    local npc = it and it.npc
    if npc and DoesEntityExist(npc) then FlechaSobre(npc) end
end

end

local Animac, panelAnimCat, panelAnimOpc, ActualizarAnimaciones
do
-- ═════════════════════════════════════════════════════════
-- ANIMACIONES
--   Elige a alguien de la lista (tú, un NPC o un jugador) y ponle una animación.
--   · Tú y los NPCs: la hacen ellos (los NPCs compartidos los ven todos).
--   · Otros jugadores: el juego no deja mover el personaje de otro jugador, así que la
--     hace tu personaje mirándole.
-- ═════════════════════════════════════════════════════════
Animac = { obj = nil, animados = {}, ultimaLista = 0, ocupado = false }

-- ── Utilidades ────────────────────────────────────────────
local function Flecha(ped, r, g, b)
    if not ped or not DoesEntityExist(ped) then return end
    local c = GetEntityCoords(ped)
    R.Flecha(c.x, c.y, c.z + 1.25, (r or 180) / 255, (g or 150) / 255, (b or 255) / 255)
end

-- Ped del objetivo actual (nil si ya no existe) y si es otro jugador
local function Objetivo()
    local me = PlayerPedId()
    local o = Animac.obj
    if not o then return me, false end
    if o.jugador then
        local pid = GetPlayerFromServerId(o.jugador)
        local ped = (pid and pid ~= -1) and GetPlayerPed(pid) or 0
        if ped ~= 0 and DoesEntityExist(ped) then o.ped = ped; return ped, true end
        return nil
    end
    if o.ped and DoesEntityExist(o.ped) then return o.ped, false end
    return nil
end

local function NombreObjetivo()
    local o = Animac.obj
    if not o then return "Tú" end
    return o.nombre or "?"
end

local function Controlar(ped)
    if not NetworkIsSessionStarted() or not NetworkGetEntityIsNetworked(ped) then return true end
    local t = 0
    while not NetworkHasControlOfEntity(ped) and t < 40 do
        NetworkRequestControlOfEntity(ped); Citizen.Wait(25); t = t + 1
    end
    return NetworkHasControlOfEntity(ped)
end

-- Prepara a un NPC para que haga caso y no se vaya
local function PrepararNpc(npc)
    Controlar(npc)
    SetEntityAsMissionEntity(npc, true, true)
    if IsPedInAnyVehicle(npc, false) then ClearPedTasksImmediately(npc) end
    SetBlockingOfNonTemporaryEvents(npc, true)
    SetPedKeepTask(npc, true)
    SetPedCanPlayAmbientAnims(npc, false)
    Animac.animados[npc] = true
end

local function Mirar(a, b)
    local ca, cb = GetEntityCoords(a), GetEntityCoords(b)
    SetEntityHeading(a, GetHeadingFromVector_2d(cb.x - ca.x, cb.y - ca.y))
end

local function Reproducir(ped, dict, clip, bucle, soloArriba)
    if not CargarAnim(dict) then Avisar("No se pudo cargar la animación"); return false end
    local flag = bucle and 1 or 0
    if soloArriba then flag = flag + 48 end
    TaskPlayAnim(ped, dict, clip, 3.0, -3.0, -1, flag, 0.0, false, false, false)
    return true
end

-- ── Hacer una animación al objetivo ───────────────────────
local function Hacer(a)
    if Animac.ocupado then return end
    Animac.ocupado = true
    Citizen.CreateThread(function()
        local ok, err = pcall(function()
            local me = PlayerPedId()
            local ped, esJugador = Objetivo()
            if not ped then Avisar(NombreObjetivo() .. " ya no está"); Animac.obj = nil; return end
            local bucle = a[4] or Config.animBucle
            if ped == me then
                if IsPedInAnyVehicle(me, false) then Avisar("Bájate del vehículo primero"); return end
                ClearPedTasks(me)
                Reproducir(me, a[2], a[3], bucle, Config.animSoloArriba)
            elseif esJugador then
                -- No se puede animar a otro jugador: la haces tú mirándole
                if IsPedInAnyVehicle(me, false) then Avisar("Bájate del vehículo primero"); return end
                ClearPedTasks(me)
                Mirar(me, ped)
                Reproducir(me, a[2], a[3], bucle, false)
            else
                PrepararNpc(ped)
                ClearPedTasksImmediately(ped)
                Reproducir(ped, a[2], a[3], bucle, false)
            end
        end)
        if not ok then print("[cargar coches] animación: " .. tostring(err)) end
        Animac.ocupado = false
    end)
end

-- ── Parar ─────────────────────────────────────────────────
local function PararPed(ped)
    if not ped or not DoesEntityExist(ped) then return end
    if ped ~= PlayerPedId() then Controlar(ped) end
    ClearPedTasks(ped)
    ClearPedSecondaryTask(ped)
    ResetPedMovementClipset(ped, 0.0)
    if ped ~= PlayerPedId() and not IsPedAPlayer(ped) then
        ClearPedTasksImmediately(ped)
        SetBlockingOfNonTemporaryEvents(ped, false)
        SetPedKeepTask(ped, false)
        SetPedCanPlayAmbientAnims(ped, true)
        Animac.animados[ped] = nil
    end
end

local function Parar()
    Citizen.CreateThread(function()
        local ped, esJugador = Objetivo()
        if not ped or esJugador then ped = PlayerPedId() end
        PararPed(ped)
        if ped ~= PlayerPedId() then PararPed(PlayerPedId()) end
    end)
end

local function PararTodo()
    Citizen.CreateThread(function()
        PararPed(PlayerPedId())
        local n = 0
        for npc in pairs(Animac.animados) do
            if DoesEntityExist(npc) then PararPed(npc); n = n + 1 end
            Animac.animados[npc] = nil
        end
        Avisar("Animaciones paradas (" .. n .. " NPC" .. (n == 1 and "" or "s") .. ")")
    end)
end
Animac.Parar = Parar

-- ── Animaciones del servidor ──────────────────────────────
-- No lleva ninguna lista dentro: lee los scripts de cliente de los recursos del servidor
-- (menús de emotes, addons, trabajos...), saca las parejas diccionario/animación que usan
-- y se queda solo con los diccionarios que existen de verdad en el juego (base + addons
-- que el servidor ha cargado), comprobándolo con DoesAnimDictExist.
local Todas = { estado = "sin cargar", progreso = "", nombres = {}, lista = {}, origen = {} }

-- Nombres típicos para probar cuando el manifiesto usa comodines (client/*.lua)
local NOMBRES_TIPICOS = {
    "AnimationList", "AnimationListCustom", "animationlist", "animations", "Animations", "anims", "Anims",
    "emotes", "Emotes", "EmoteMenu", "emotemenu", "Emote", "emote", "customemotes", "CustomEmotes",
    "main", "client", "cl_main", "cl_emotes", "cl_anims", "Syncing", "Walk", "Expressions",
    "config", "Config", "shared", "data", "list", "utils", "functions",
}

local function Texto(v) return type(v) == "string" and v or nil end

-- Rutas de archivo a leer de un recurso (según su fxmanifest)
local function RutasDe(recurso)
    local rutas, vistas = {}, {}
    local function anadir(r)
        if r:sub(1, 1) == "@" then return end   -- archivo de otro recurso (p. ej. @ox_lib/init.lua)
        r = r:gsub("^%./", "")
        if r:match("%.lua$") or r:match("%.json$") or r:match("%.js$") then
            if not vistas[r] then vistas[r] = true; rutas[#rutas + 1] = r end
        end
    end
    for _, clave in ipairs({ "client_script", "shared_script", "file", "client_scripts", "shared_scripts", "files" }) do
        local n = GetNumResourceMetadata(recurso, clave) or 0
        for i = 0, n - 1 do
            local r = Texto(GetResourceMetadata(recurso, clave, i))
            if r then
                if r:find("*", 1, true) then
                    -- Comodín: probar nombres típicos en esa carpeta
                    local carpeta = r:match("^(.-)[^/]*%*") or ""
                    carpeta = carpeta:gsub("%*%*/", "")
                    local ext = r:match("%*(%.%a+)$") or ".lua"
                    for _, nombre in ipairs(NOMBRES_TIPICOS) do anadir(carpeta .. nombre .. ext) end
                else
                    anadir(r)
                end
            end
        end
    end
    return rutas
end

local function ClipValido(c) return c and #c > 1 and #c < 90 and c:match("^[%w_@%-%.%^/]+$") ~= nil end
local function DiccValido(d) return d and #d > 2 and #d < 120 and d:match("^[%w_@%-%.%^/]+$") ~= nil end

-- Saca parejas diccionario/animación del texto de un script
local function Extraer(txt, recurso, anadir)
    local Q = "[\"']"
    local S = "([^\"'\n]+)"
    -- 1) Tablas tipo menú de emotes: {"dicc", "clip", "Nombre", ...}
    for d, c, resto in txt:gmatch("{%s*" .. Q .. S .. Q .. "%s*,%s*" .. Q .. S .. Q .. "([^\n]*)") do
        local etq = resto:match("^%s*,%s*" .. Q .. S .. Q)
        anadir(d, c, etq, recurso)
    end
    -- 2) Llamadas directas: TaskPlayAnim(ped, "dicc", "clip", ...)
    for d, c in txt:gmatch("TaskPlayAnim%s*%(%s*[^,]+,%s*" .. Q .. S .. Q .. "%s*,%s*" .. Q .. S .. Q) do
        anadir(d, c, nil, recurso)
    end
    -- 3) Claves: dict = "...", anim = "..." (también JSON: "dict": "...")
    for pos in txt:gmatch("()[%a_]*[Dd][Ii][Cc][Tt][%a_]*[\"']?%s*[=:]%s*[\"']") do
        local ventana = txt:sub(math.max(1, pos - 300), pos + 300)
        local d, c
        for k, v in ventana:gmatch("[\"']?([%a_]+)[\"']?%s*[=:]%s*" .. Q .. S .. Q) do
            local kl = k:lower()
            if kl:find("dict") then d = d or v
            elseif kl:find("anim") or kl == "clip" or kl == "animname" or kl == "name" and d then c = c or v end
        end
        if d then anadir(d, c, nil, recurso) end
    end
    -- 4) Solo diccionario: RequestAnimDict("...") / lib.requestAnimDict('...')
    for d in txt:gmatch("[Rr]equestAnimDict%s*%(%s*" .. Q .. S .. Q) do anadir(d, nil, nil, recurso) end
end


-- ── Lista de TODAS las animaciones del GTA ────────────────
-- El juego no deja que un script le pida la lista de sus animaciones (solo comprueba
-- nombres que ya conoces), así que va dentro del menú, muy comprimida (LZMA, ~310 KB),
-- y se descomprime en segundo plano la primera vez que abres Animaciones (~1-2 s, sin tirones).
-- Descompresor LZMA (formato "raw") en Lua puro, sin operadores de bits: sirve en cualquier Lua.
local unpack_ = table.unpack or unpack
local function LzmaDescomprimir(datos, tamSalida, lc, tamVentana, ceder, avance)
    local byte, char, floor = string.byte, string.char, math.floor
    local total = #datos
    local pos = 2                                  -- el primer byte del rango siempre es 0
    local rango, codigo = 4294967295, 0
    for _ = 1, 4 do codigo = codigo * 256 + byte(datos, pos); pos = pos + 1 end
    local TOP = 16777216

    local function bit(p, i)
        local pr = p[i]
        local bound = floor(rango / 2048) * pr
        local b
        if codigo < bound then
            rango = bound; p[i] = pr + floor((2048 - pr) / 32); b = 0
        else
            rango = rango - bound; codigo = codigo - bound; p[i] = pr - floor(pr / 32); b = 1
        end
        if rango < TOP then rango = rango * 256; codigo = codigo * 256 + (byte(datos, pos) or 0); pos = pos + 1 end
        return b
    end
    local function directos(n)
        local r = 0
        for _ = 1, n do
            rango = floor(rango / 2)
            if codigo >= rango then codigo = codigo - rango; r = r * 2 + 1 else r = r * 2 end
            if rango < TOP then rango = rango * 256; codigo = codigo * 256 + (byte(datos, pos) or 0); pos = pos + 1 end
        end
        return r
    end
    local pot = {}
    do local v = 1; for i = 0, 31 do pot[i] = v; v = v * 2 end end
    local function arbol(p, base, n)
        local m = 1
        for _ = 1, n do m = m * 2 + bit(p, base + m) end
        return m - pot[n]
    end
    local function arbolInv(p, base, n)
        local m, r = 1, 0
        for i = 0, n - 1 do
            local b = bit(p, base + m)
            m = m * 2 + b
            r = r + b * pot[i]
        end
        return r
    end
    local function probs(n) local t = {}; for i = 0, n do t[i] = 1024 end; return t end

    local lit = probs(768 * pot[lc] + 1)
    local isMatch, isRep, isRepG0, isRepG1, isRepG2, isRep0Long = probs(12), probs(12), probs(12), probs(12), probs(12), probs(12)
    local posSlot = { [0] = probs(64), probs(64), probs(64), probs(64) }
    local posDec = probs(115 + 2)
    local align = probs(16)
    local function nuevoLen() return { choice = probs(1), low = probs(8), mid = probs(8), high = probs(256) } end
    local lenDec, repLenDec = nuevoLen(), nuevoLen()
    local function decLen(L)
        if bit(L.choice, 0) == 0 then return arbol(L.low, 0, 3) end
        if bit(L.choice, 1) == 0 then return 8 + arbol(L.mid, 0, 3) end
        return 16 + arbol(L.high, 0, 8)
    end

    local N = tamVentana
    local ventana = {}
    local sal = 0                                  -- bytes escritos
    local trozos, tn = {}, 0
    local pend, pn = {}, 0
    local function volcar()
        if pn == 0 then return end
        local partes = {}
        for i = 1, pn, 4000 do partes[#partes + 1] = char(unpack_(pend, i, math.min(i + 3999, pn))) end
        tn = tn + 1; trozos[tn] = table.concat(partes)
        pend, pn = {}, 0
    end
    local estado, rep0, rep1, rep2, rep3 = 0, 0, 0, 0, 0
    local desplLc = pot[8 - lc]

    while sal < tamSalida do
        if bit(isMatch, estado) == 0 then
            -- literal
            local previo = sal > 0 and ventana[(sal - 1) % N] or 0
            local base = 768 * floor(previo / desplLc)
            local s = 1
            if estado >= 7 then
                local mb = ventana[(sal - rep0 - 1) % N]
                repeat
                    local matchBit = floor(mb / 128) % 2
                    mb = (mb * 2) % 256
                    local b = bit(lit, base + (1 + matchBit) * 256 + s)
                    s = s * 2 + b
                    if matchBit ~= b then break end
                until s >= 256
            end
            while s < 256 do s = s * 2 + bit(lit, base + s) end
            local v = s - 256
            ventana[sal % N] = v; sal = sal + 1
            pn = pn + 1; pend[pn] = v
            if estado < 4 then estado = 0 elseif estado < 10 then estado = estado - 3 else estado = estado - 6 end
        else
            local len
            if bit(isRep, estado) == 1 then
                if bit(isRepG0, estado) == 0 then
                    if bit(isRep0Long, estado) == 0 then
                        -- "short rep": un solo byte
                        estado = estado < 7 and 9 or 11
                        len = -1
                    end
                else
                    local dist
                    if bit(isRepG1, estado) == 0 then dist = rep1
                    else
                        if bit(isRepG2, estado) == 0 then dist = rep2 else dist = rep3; rep3 = rep2 end
                        rep2 = rep1
                    end
                    rep1 = rep0; rep0 = dist
                end
                if len ~= -1 then
                    len = decLen(repLenDec)
                    estado = estado < 7 and 8 or 11
                end
            else
                rep3 = rep2; rep2 = rep1; rep1 = rep0
                len = decLen(lenDec)
                estado = estado < 7 and 7 or 10
                -- distancia
                local ls = len < 3 and len or 3
                local ps = arbol(posSlot[ls], 0, 6)
                local dist
                if ps < 4 then dist = ps
                else
                    local nd = floor(ps / 2) - 1
                    dist = (2 + ps % 2) * pot[nd]
                    if ps < 14 then dist = dist + arbolInv(posDec, dist - ps, nd)
                    else dist = dist + directos(nd - 4) * 16 + arbolInv(align, 0, 4) end
                end
                if dist == 4294967295 then break end   -- marca de fin
                rep0 = dist
            end
            len = len + 2                              -- short rep: -1 + 2 = 1 byte
            local desde = sal - rep0 - 1
            for i = 0, len - 1 do
                local v = ventana[(desde + i) % N]
                ventana[sal % N] = v; sal = sal + 1
                pn = pn + 1; pend[pn] = v
            end
        end
        if pn > 32768 then
            volcar()
            if avance then avance(sal / tamSalida) end
            if ceder then ceder() end
        end
    end
    volcar()
    return table.concat(trozos)
end


-- Devuelve el texto completo "dicc<TAB>clip,clip,...\n" (en minúsculas) y el total de animaciones
local function CargarListaGta(ceder, avance)
    local b64, tam = Animac.datosGta, Animac.tamGta
    if type(b64) ~= "string" or not tam then return nil end
    local raw = Base64Bin(b64, ceder)
    local fc = LzmaDescomprimir(raw, tam, 3, 65536, ceder, function(p) if avance then avance(p * 0.8) end end)
    raw = nil
    -- Cada nombre empieza con un carácter que dice cuántas letras comparte con el anterior
    local lineas, nl, total = {}, 0, 0
    local prevD = ""
    for linea in fc:gmatch("[^\n]+") do
        local tab = linea:find("\t", 1, true)
        if tab then
            local de = linea:sub(1, tab - 1)
            local d = prevD:sub(1, de:byte(1) - 48) .. de:sub(2); prevD = d
            local clips, prevC, cn = {}, "", 0
            for e in linea:sub(tab + 1):gmatch("[^,]+") do
                local c = prevC:sub(1, e:byte(1) - 48) .. e:sub(2); cn = cn + 1; clips[cn] = c; prevC = c
            end
            total = total + cn
            nl = nl + 1; lineas[nl] = d .. "\t" .. table.concat(clips, ",")
            if nl % 1500 == 0 then
                if avance then avance(0.8 + 0.2 * nl / 19720) end
                if ceder then ceder() end
            end
        end
    end
    return table.concat(lineas, "\n") .. "\n", total
end

local function Escanear()
    if Todas.estado == "cargando" then return end
    Todas.estado, Todas.progreso = "cargando", "empezando"
    Citizen.CreateThread(function()
        local ok, err = pcall(function()
            local candidatos, orden = {}, {}
            local function anadir(d, c, etq, recurso)
                if not DiccValido(d) then return end
                local e = candidatos[d]
                if not e then e = { clips = {}, vistos = {}, origen = recurso }; candidatos[d] = e; orden[#orden + 1] = d end
                if ClipValido(c) and not e.vistos[c] then
                    e.vistos[c] = true
                    e.clips[#e.clips + 1] = { c, (etq and etq ~= c and #etq < 60) and etq or nil }
                end
            end
            local n = GetNumResources() or 0
            local leidos = 0
            for i = 0, n - 1 do
                local recurso = GetResourceByFindIndex(i)
                if recurso and GetResourceState(recurso) == "started" then
                    for _, ruta in ipairs(RutasDe(recurso)) do
                        local txt = LoadResourceFile(recurso, ruta)
                        -- saltar archivos cifrados (escrow) o enormes
                        if type(txt) == "string" and #txt > 0 and #txt < 4000000 and txt:sub(1, 4) ~= "FXAP"
                            and not txt:find("\0", 1, true) then
                            leidos = leidos + 1
                            pcall(Extraer, txt, recurso, anadir)
                            Citizen.Wait(0)
                        end
                    end
                end
                Todas.progreso = "scripts " .. (i + 1) .. "/" .. n
            end
            -- Quedarse con los diccionarios que existen de verdad (base o addon del servidor).
            -- Si en este entorno DoesAnimDictExist no responde bien (falla con uno que seguro existe),
            -- no se filtra con él: se usan todos los que tengan pinta de diccionario.
            local okN, vN = pcall(DoesAnimDictExist, "mp_ped_interaction")
            local comprobar = okN and vN == true
            Todas.candidatos = #orden
            local function existe(d)
                if comprobar then local ok, v = pcall(DoesAnimDictExist, d); return ok and v == true end
                return d:find("@", 1, true) ~= nil or d:find("_", 1, true) ~= nil
            end
            local nombres, lista, origen = {}, {}, {}
            for k, d in ipairs(orden) do
                if existe(d) then
                    local e = candidatos[d]
                    table.sort(e.clips, function(a, b) return a[1] < b[1] end)
                    nombres[#nombres + 1] = d; lista[#nombres] = e.clips; origen[#nombres] = e.origen
                end
                if k % 150 == 0 then
                    Todas.progreso = "comprobando " .. k .. "/" .. #orden
                    Citizen.Wait(0)
                end
            end
            -- Orden alfabético
            local idx = {}
            for i = 1, #nombres do idx[i] = i end
            table.sort(idx, function(a, b) return nombres[a] < nombres[b] end)
            Todas.nombres, Todas.lista, Todas.origen = {}, {}, {}
            for k, i in ipairs(idx) do Todas.nombres[k], Todas.lista[k], Todas.origen[k] = nombres[i], lista[i], origen[i] end
            Todas.leidos = leidos

            -- Lista de todas las del GTA (va comprimida en el menú; solo se descomprime una vez)
            if not Todas.base then
                Todas.progreso = "lista del GTA"
                local txt, total = CargarListaGta(function() Citizen.Wait(0) end, function(p)
                    Todas.progreso = string.format("lista del GTA %d%%", math.floor(p * 100))
                end)
                if txt then
                    local inicios, k, p = {}, 0, 1
                    local largo = #txt
                    while p <= largo do
                        k = k + 1; inicios[k] = p
                        local nl = txt:find("\n", p, true)
                        if not nl then break end
                        p = nl + 1
                        if k % 4000 == 0 then Citizen.Wait(0) end
                    end
                    Todas.base = { txt = txt, inicios = inicios, total = total }
                    Animac.datosGta = nil   -- ya descomprimida: el texto comprimido ya no hace falta
                    pcall(collectgarbage, "step", 0)
                end
            end
        end)
        if ok then Todas.estado = "lista"
            local total = 0
            for _, l in ipairs(Todas.lista) do total = total + #l end
            Avisar(#Todas.nombres .. " diccionarios · " .. total .. " animaciones encontradas")
        else Todas.estado = "error"; Todas.error = tostring(err); print("[cargar coches] escanear animaciones: " .. tostring(err)) end
        Animac.sucio, Animac.arriba = true, true
    end)
end

local function Libre(dicc, clip)
    Hacer({ clip, dicc, clip })
end

-- ═══ Interfaz: izquierda = buscar en todas las del servidor · derecha = a quién + parar ═══
local itemBuscar = { tipo = "campo", label = "Buscar", placeholder = "Buscar animación...", max = 40,
    desc = "Haz clic y escribe: busca por nombre, animación, diccionario o recurso.",
    get = function() return Animac.busqueda or "" end,
    set = function(t) Animac.busqueda, Animac.pagina = t, 1; Animac.sucio, Animac.arriba = true, true end }

panelAnimCat = { titulo = "Todas las animaciones", items = { itemBuscar } }
panelAnimOpc = { titulo = "A quién", items = {} }

-- Todas las animaciones en una sola lista (se rehace después de cada escaneo)
local function Plano()
    if Todas.plano and Todas.planoDe == Todas.nombres then return Todas.plano end
    local r, claves = {}, {}
    Todas.claves = claves
    for i, d in ipairs(Todas.nombres) do
        local o = Todas.origen[i] or ""
        for _, c in ipairs(Todas.lista[i]) do
            r[#r + 1] = { d = d, c = c[1], e = c[2], o = o,
                          b = ((c[2] or "") .. " " .. c[1] .. " " .. d .. " " .. o):lower() }
            claves[d:lower() .. "/" .. c[1]:lower()] = true
        end
    end
    table.sort(r, function(x, y) return (x.e or x.c):lower() < (y.e or y.c):lower() end)
    Todas.plano, Todas.planoDe = r, Todas.nombres
    return r
end

-- Busca en la lista del GTA directamente sobre el texto (rápido: lo hace el motor de Lua en C)
local function LineaDe(inicios, pos)
    local lo, hi = 1, #inicios
    while lo < hi do
        local mid = math.floor((lo + hi + 1) / 2)
        if inicios[mid] <= pos then lo = mid else hi = mid - 1 end
    end
    return lo
end

local function Palabras(q)
    local r, larga = {}, ""
    for w in q:gmatch("%S+") do r[#r + 1] = w; if #w > #larga then larga = w end end
    return r, larga
end

local function BuscarBase(q, max, saltar)
    local B = Todas.base
    local res = {}
    if not B or q == "" then return res end
    local palabras, clave = Palabras(q)
    local txt, inicios = B.txt, B.inicios
    local pos = 1
    while #res < max do
        local s = txt:find(clave, pos, true)
        if not s then break end
        local li = LineaDe(inicios, s)
        local ini = inicios[li]
        local fin = (inicios[li + 1] or (#txt + 2)) - 2
        local linea = txt:sub(ini, fin)
        local tab = linea:find("\t", 1, true)
        if tab then
            local d = linea:sub(1, tab - 1)
            for c in linea:sub(tab + 1):gmatch("[^,]+") do
                local todo = d .. " " .. c
                local vale = true
                for _, w in ipairs(palabras) do if not todo:find(w, 1, true) then vale = false; break end end
                if vale and not saltar[d .. "/" .. c] then
                    res[#res + 1] = { d = d, c = c, o = "GTA" }
                    if #res >= max then break end
                end
            end
        end
        pos = fin + 2
    end
    return res
end

local POR_PAGINA = 30

local function ListaIzquierda()
    local items = { itemBuscar }
    if Todas.estado == "sin cargar" then Escanear() end
    if Todas.estado == "cargando" then
        items[#items + 1] = { tipo = "texto", label = function() return "Cargando " .. Todas.progreso end }
        return items
    elseif Todas.estado == "error" then
        items[#items + 1] = { tipo = "texto", label = "Error: " .. tostring(Todas.error) }
        items[#items + 1] = { tipo = "accion", label = "Volver a intentar", derecha = "",
            fn = function() Todas.estado = "sin cargar"; Animac.sucio = true end }
        return items
    end
    local todas = Plano()
    local q = (Animac.busqueda or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
    local res = todas
    local deGta, topeGta = 0, 3000
    if q ~= "" then
        res = {}
        local palabras = Palabras(q)
        for _, a in ipairs(todas) do
            local vale = true
            for _, w in ipairs(palabras) do if not a.b:find(w, 1, true) then vale = false; break end end
            if vale then res[#res + 1] = a end
        end
        -- y las del GTA normal (sin repetir las que ya salen del servidor)
        local base = BuscarBase(q, topeGta, Todas.claves or {})
        deGta = #base
        for _, a in ipairs(base) do res[#res + 1] = a end
    end
    local paginas = math.max(1, math.ceil(#res / POR_PAGINA))
    Animac.pagina = Clamp(Animac.pagina or 1, 1, paginas)
    local pagina = Animac.pagina
    items[#items + 1] = { tipo = "texto", label = (q ~= "" and ((#res - deGta) .. " del servidor · " .. deGta .. (deGta >= topeGta and "+" or "") .. " del GTA")
        or (#res .. " de scripts del servidor")) .. (paginas > 1 and ("  ·  pág. " .. pagina .. "/" .. paginas) or "") }
    if q == "" then
        if Todas.base then
            local total = tostring(Todas.base.total):reverse():gsub("(%d%d%d)", "%1."):reverse():gsub("^%.", "")
            items[#items + 1] = { tipo = "texto", label = "Escribe para buscar entre " .. total .. " del GTA" }
        else
            items[#items + 1] = { tipo = "texto", label = "No se pudo cargar la lista del GTA" }
        end
    end
    local desde = (pagina - 1) * POR_PAGINA + 1
    for k = desde, math.min(#res, desde + POR_PAGINA - 1) do
        local a = res[k]
        items[#items + 1] = { tipo = "accion", label = a.e or a.c, derecha = a.o,
            desc = function() return a.d .. " / " .. a.c .. "  ·  a: " .. NombreObjetivo() end,
            fn = function() Libre(a.d, a.c) end }
    end
    if pagina < paginas then
        items[#items + 1] = { tipo = "accion", label = "Página siguiente ›", derecha = "",
            desc = "Shift + Enter salta 10 páginas.",
            fn = function() Animac.pagina = pagina + (Tecla(0x10) and 10 or 1); Animac.sucio, Animac.arriba = true, true end }
    end
    if pagina > 1 then
        items[#items + 1] = { tipo = "accion", label = "‹ Página anterior", derecha = "",
            desc = "Shift + Enter salta 10 páginas.",
            fn = function() Animac.pagina = pagina - (Tecla(0x10) and 10 or 1); Animac.sucio, Animac.arriba = true, true end }
    end
    if #res == 0 then
        items[#items + 1] = { tipo = "texto", label = q ~= "" and "Nada con esa búsqueda" or
            ((Todas.leidos or 0) .. " scripts · " .. (Todas.candidatos or 0) .. " posibles · 0 válidos") }
    end
    items[#items + 1] = { tipo = "accion", label = "Volver a leer el servidor", derecha = "",
        desc = "Vuelve a buscar animaciones en los recursos (si el servidor ha cargado algo nuevo).",
        fn = function() Todas.estado = "sin cargar"; Animac.sucio, Animac.arriba = true, true end }
    panelAnimCat.titulo = "Todas las animaciones"
    return items
end

local function ListaGente()
    local me = PlayerPedId()
    local pos = GetEntityCoords(me)
    local items = {
        { tipo = "accion", label = "Tú", derecha = Animac.obj == nil and "elegido" or "",
          desc = "Las animaciones te las haces a ti.",
          fn = function() Animac.obj = nil; Animac.genteSucia = true; Avisar("Objetivo: tú") end },
    }
    local jugadores = {}
    for _, pid in ipairs(GetActivePlayers()) do
        if pid ~= PlayerId() then
            local ped = GetPlayerPed(pid)
            if ped ~= 0 and DoesEntityExist(ped) then
                jugadores[#jugadores + 1] = { pid, ped, #(GetEntityCoords(ped) - pos) }
            end
        end
    end
    table.sort(jugadores, function(a, b) return a[3] < b[3] end)
    for _, j in ipairs(jugadores) do
        local sid, ped, d = GetPlayerServerId(j[1]), j[2], j[3]
        local nombre = (GetPlayerName(j[1]) or "Jugador") .. " [" .. sid .. "]"
        local elegido = Animac.obj and Animac.obj.jugador == sid
        items[#items + 1] = { tipo = "accion", label = nombre, npc = ped,
            derecha = (elegido and "elegido · " or "jugador · ") .. string.format("%.0f m", d),
            desc = "Jugador: las animaciones las hace tu personaje mirándole. Las de pareja, se acerca.",
            fn = function()
                Animac.obj = { jugador = sid, ped = ped, nombre = nombre }
                Animac.genteSucia = true; Avisar("Objetivo: " .. nombre)
            end }
    end
    local npcs = {}
    for _, n in ipairs(GetGamePool("CPed")) do
        if n ~= me then
            local d = #(GetEntityCoords(n) - pos)
            if d <= Config.radioLista and not IsPedAPlayer(n) and not IsPedDeadOrDying(n, true) then
                npcs[#npcs + 1] = { n, d }
            end
        end
    end
    table.sort(npcs, function(a, b) return a[2] < b[2] end)
    for i = 1, math.min(#npcs, 50) do
        local n, d = npcs[i][1], npcs[i][2]
        local tipo = (GetPedType(n) == 28) and "Animal" or (IsPedMale(n) and "Hombre" or "Mujer")
        if IsPedInAnyVehicle(n, false) then tipo = tipo .. " en vehículo" end
        local nombre = tipo .. " " .. i
        local elegido = Animac.obj and Animac.obj.ped == n
        items[#items + 1] = { tipo = "accion", label = nombre, npc = n,
            derecha = (elegido and "elegido · " or "") .. string.format("%.0f m", d),
            desc = "NPC: hace él las animaciones. Si es compartido, los demás también lo ven.",
            fn = function()
                if DoesEntityExist(n) then
                    Animac.obj = { ped = n, nombre = nombre }
                    Animac.genteSucia = true; Avisar("Objetivo: " .. nombre)
                else Avisar("Ese NPC ya no está") end
            end }
    end
    panelAnimOpc.titulo = "Gente alrededor (" .. #jugadores .. " jugadores · " .. math.min(#npcs, 50) .. " NPCs)"
    return items
end

local function ListaDerecha()
    local items = {
        { tipo = "accion", label = "Parar animación", derecha = K("pararAnim"),
          desc = function() return "Para lo que esté haciendo " .. NombreObjetivo() .. " y a tu personaje." end,
          fn = function() Parar(); Avisar("Animación parada") end },
        { tipo = "accion", label = "Parar todas", derecha = "",
          desc = "Para tu animación y la de todos los NPCs que has animado.", fn = PararTodo },
        { tipo = "toggle", label = "Repetir en bucle", key = "animBucle",
          desc = "La animación se repite sin parar hasta que la pares." },
        { tipo = "toggle", label = "Solo de cintura para arriba", key = "animSoloArriba",
          desc = "Para ti: puedes seguir andando mientras haces la animación." },
    }
    for _, it in ipairs(ListaGente()) do items[#items + 1] = it end
    panelAnimOpc.titulo = "A quién: " .. NombreObjetivo()
    return items
end

-- Cada frame con la sección abierta
function ActualizarAnimaciones(itFoco)
    local ahora = GetGameTimer()
    -- Izquierda: solo cuando cambia algo (búsqueda, página, escaneo)
    if Animac.sucio or not Animac.izqHecha then
        if Animac.arriba then
            panelAnimCat._scroll, panelAnimCat._scrollObj = 0, 0
            if Menu.col == 1 and Menu.escribiendo ~= itemBuscar then Menu.pos[1] = 1 end
        end
        Animac.sucio, Animac.arriba, Animac.izqHecha = false, false, true
        local ok, items = pcall(ListaIzquierda)
        panelAnimCat.items = ok and items or { itemBuscar, { tipo = "texto", label = "Error: " .. tostring(items) } }
    end
    -- Derecha: gente alrededor, cada segundo (salvo mientras la recorres)
    if Animac.genteSucia or (Menu.col ~= 2 and ahora - (Animac.ultimaLista or 0) > 1000) then
        Animac.genteSucia, Animac.ultimaLista = false, ahora
        local ok, items = pcall(ListaDerecha)
        if ok then panelAnimOpc.items = items end
    end
    if Menu.col == 2 and itFoco and itFoco.npc then Flecha(itFoco.npc, 255, 255, 255) end
    local ped = Objetivo()
    if Animac.obj and ped then Flecha(ped) end
end

end

-- ═════════════════════════════════════════════════════════
-- EXTRAS (todo con las mecánicas reales del juego: lo ven y lo sufren todos)
--   · Patadas en moto: se quitan los bloqueos de la patada del juego (X + clic, como siempre).
--   · Manguera de bombero sin camión:
--       - Marcas a una o varias personas (NPCs o jugadores) con la que tengas en el centro de la
--         pantalla. Se mira en la imagen que ves (Susano.WorldToScreen), así que funciona igual
--         con la cámara normal que con la freecam de Susano. El agua va a por ellas aunque se muevan.
--       - Cañón real: camión de bomberos invisible y sin colisión, colocado en la línea entre
--         tú y el objetivo (como mucho a 7 m de él); su conductor invisible persigue al objetivo
--         con el cañón de agua de verdad. Solo existe mientras echas agua.
--       - Boca de incendios: agua a presión del propio juego a los pies de cada marcado
--         (se sincroniza con todos: tira a jugadores y NPCs).
-- ═════════════════════════════════════════════════════════
local Extras = { agua = {}, patada = {}, camion = {}, marcados = {}, candidato = nil, pendientes = {},
                 hayMarcas = false }
local panelAgua = { titulo = "A quién echas agua", items = {} }
local panelSuper = { titulo = "A quién tiras los coches", items = {} }
do
local VEH_MELEE_HOLD, VEH_MELEE_IZQ, VEH_MELEE_DER = 345, 346, 347   -- X, clic izquierdo, clic derecho
local FLAG_SIN_MELEE = 122          -- CPED_CONFIG_FLAG_DisableMelee
local FLAG_SIN_ARMAS_VEH = 48       -- con este flag el cañón de agua no dispara
local rad, deg, sin, cos, atan, asin = math.rad, math.deg, math.sin, math.cos, math.atan, math.asin

local function MotoDe(ped)
    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 then return nil end
    if IsPedOnAnyBike(ped) or IsThisModelAQuadbike(GetEntityModel(veh)) then return veh end
    return nil
end

-- ── Patadas en moto: solo se quitan los bloqueos; la patada es la normal del juego ──
local function FramePatadas(ped, ahora)
    if not MotoDe(ped) then return end
    EnableControlAction(0, VEH_MELEE_HOLD, true)
    EnableControlAction(0, VEH_MELEE_IZQ, true)
    EnableControlAction(0, VEH_MELEE_DER, true)
    local P = Extras.patada
    if ahora >= (P.proxFlag or 0) then
        P.proxFlag = ahora + 500
        SetPedConfigFlag(ped, FLAG_SIN_MELEE, false)
    end
end

-- ── Cámara que se está viendo (la normal o la freecam de Susano) ──
local function DirDe(rot)
    local p, y = rad(rot.x), rad(rot.z)
    local c = math.abs(cos(p))
    return vector3(-sin(y) * c, cos(y) * c, sin(p))
end
local function Camara()
    local rot = GetFinalRenderedCamRot(2)
    return GetFinalRenderedCamCoord(), DirDe(rot), rot
end

local APantalla = Proyectar

-- ── Personas marcadas ─────────────────────────────────────
local function NombrePed(p)
    if IsPedAPlayer(p) then
        local pid = NetworkGetPlayerIndexFromPed(p)
        return (GetPlayerName(pid) or "Jugador") .. " [" .. GetPlayerServerId(pid) .. "]", GetPlayerServerId(pid)
    end
    local tipo = (GetPedType(p) == 28) and "Animal" or (IsPedMale(p) and "Hombre" or "Mujer")
    return tipo, nil
end

local function PedDe(m)
    if m.jugador then
        local pid = GetPlayerFromServerId(m.jugador)
        local p = (pid and pid ~= -1) and GetPlayerPed(pid) or 0
        if p ~= 0 and DoesEntityExist(p) then m.ped = p; return p end
        return nil
    end
    if m.ped and DoesEntityExist(m.ped) then return m.ped end
    return nil
end

local function IndiceMarcado(p)
    local M = Extras.marcados
    for i = 1, #M do
        local m = M[i]
        if m.ped == p then return i end
        if m.jugador and IsPedAPlayer(p) and NetworkGetPlayerIndexFromPed(p) == GetPlayerFromServerId(m.jugador) then return i end
    end
    return nil
end

local function Alternar(p)
    local M = Extras.marcados
    local i = IndiceMarcado(p)
    if i then
        Avisar("Desmarcado: " .. M[i].nombre)
        table.remove(M, i)
    else
        local nombre, sid = NombrePed(p)
        M[#M + 1] = { ped = p, jugador = sid, nombre = nombre }
        Avisar("Marcado: " .. nombre .. "  (" .. #M .. " en total)")
    end
    Extras.listaSucia = true
end
Extras.Alternar = Alternar

function Extras.DesmarcarTodos()
    if #Extras.marcados > 0 then Avisar("Nadie marcado: el agua va donde apuntes") end
    Extras.marcados = {}
    Extras.listaSucia = true
end

-- Peds de los marcados que siguen existiendo (los que ya no están se quitan)
local vivos = {}
local function Marcados()
    local M = Extras.marcados
    for k in pairs(vivos) do vivos[k] = nil end
    local i = 1
    while i <= #M do
        local p = PedDe(M[i])
        if p then vivos[#vivos + 1] = p; i = i + 1
        else
            Avisar(M[i].nombre .. " ya no está")
            table.remove(M, i); Extras.listaSucia = true
        end
    end
    return vivos
end

-- A quién apuntas: la persona (NPC o jugador) que se ve más cerca del centro de la pantalla.
-- Se mira en la imagen que ves, así que vale igual con la freecam de Susano, esté donde esté.
local RADIO_MIRA = 0.06                      -- fracción del alto de pantalla alrededor del centro
local function Vivo(p) return not IsPedDeadOrDying(p, true) end
local function VivoNpc(p) return not IsPedAPlayer(p) and not IsPedDeadOrDying(p, true) end
-- soloNpc: si no hay manguera ni Superman, marcar solo busca NPCs
local function BuscarApuntado(ped, soloNpc)
    return MasCentrado(GetGamePool("CPed"), ped, RADIO_MIRA, 0.3, soloNpc and VivoNpc or Vivo)
end

-- Marcas en el mundo: blanca = a quién apuntas · color del menú + aro = marcado
local function Marca(p, marcado)
    local c = GetEntityCoords(p)
    if marcado then
        local A = (COLORES[Config.colorMenu] or COLORES[1])[2]
        R.Flecha(c.x, c.y, c.z + 1.4, A[1], A[2], A[3], vector3(c.x, c.y, c.z - 0.97))   -- flecha + aro en el suelo
    else
        R.Flecha(c.x, c.y, c.z + 1.4, 1.0, 1.0, 1.0)
    end
end

-- Marcas en el overlay (tamaño fijo en pantalla: se ven aunque estés lejos con la freecam)
local function MarcaOverlay(p, marcado, nombre, A)
    local c = GetEntityCoords(p)
    local en, sx, sy = APantalla(c.x, c.y, c.z + 1.05)
    if not en then return end
    if marcado then
        R.Rect(sx - 8, sy - 22, 16, 16, 0, 0, 0, 0.55, 8)
        R.Rect(sx - 6, sy - 20, 12, 12, A[1], A[2], A[3], 1, 6)
        if nombre then R.TextC(sx, sy - 44, nombre, 13, 1, 1, 1, 0.95) end
    else
        R.Rect(sx - 6, sy - 20, 12, 12, 0, 0, 0, 0.55, 6)
        R.Rect(sx - 4, sy - 18, 8, 8, 1, 1, 1, 0.95, 4)
    end
end

function Extras.DibujarMarcas()
    if not Extras.hayMarcas then return end
    local A = (COLORES[Config.colorMenu] or COLORES[1])[2]
    -- Coche apuntado para coger (con la freecam): punto + tecla
    local coche = Extras.cocheMira
    if coche and DoesEntityExist(coche) then
        local c = GetEntityCoords(coche)
        local en, sx, sy = APantalla(c.x, c.y, c.z + 1.2)
        if en then
            R.Rect(sx - 8, sy - 8, 16, 16, 0, 0, 0, 0.55, 8)
            R.Rect(sx - 6, sy - 6, 12, 12, A[1], A[2], A[3], 1, 6)
            R.TextC(sx, sy - 30, K("agarrar") .. " Coger", 13, 1, 1, 1, 0.95)
        end
    end
    -- Personas: solo la flecha del mundo (Marca); sin punto ni nombre en el overlay
end

-- ── Manguera ──────────────────────────────────────────────
-- Config.tipoAgua: 1 = los dos, 2 = solo cañón real, 3 = solo boca de incendios
local TIPOS_AGUA = { "Los dos", "Cañón real", "Boca de incendios" }
Extras.TIPOS_AGUA = TIPOS_AGUA
local MODELO_CAMION = GetHashKey("firetruk")
local MODELO_BOMBERO = GetHashKey("s_m_y_fireman_01")
local CANON_AGUA = GetHashKey("VEHICLE_WEAPON_WATER_CANNON")
local EXP_AGUA = 13                          -- EXP_TAG_DIR_WATER_HYDRANT: agua a presión, sin daño
local MANOS = { 0.20, 0.85, 0.45 }           -- de dónde sale el chorro visible, respecto a tu personaje
local ALTURA_CANON = 1.9                     -- el cañón real queda sobre tu cabeza...
local ATRAS_CANON = 0.6                      -- ...un poco por detrás
local MAX_DIST_CANON = 7.0                   -- el cañón nunca queda a más de esto del objetivo (acierta siempre)
local ROTAR_MS = 1500                        -- con varios marcados, el cañón cambia de uno a otro
local PTFX = "core"

local function CargarModelo(m)
    if HasModelLoaded(m) then return true end
    RequestModel(m)
    local t = 0
    while not HasModelLoaded(m) and t < 200 do Citizen.Wait(10); t = t + 1 end
    return HasModelLoaded(m)
end

-- Borrado seguro: si el juego no lo borra a la primera, se reintenta hasta que desaparezca
local function IntentarBorrar(e)
    if not e or not DoesEntityExist(e) then return true end
    if IsEntityAttached(e) then DetachEntity(e, true, false) end
    NetworkRequestControlOfEntity(e)
    SetEntityAsMissionEntity(e, true, true)
    if IsEntityAVehicle(e) then DeleteVehicle(e) end
    if DoesEntityExist(e) then DeleteEntity(e) end
    return not DoesEntityExist(e)
end
local function Borrar(e)
    if not IntentarBorrar(e) then Extras.pendientes[e] = 0 end
end
local function BorrarPendientes(ahora)
    if ahora < (Extras.proxPend or 0) or next(Extras.pendientes) == nil then return end
    Extras.proxPend = ahora + 200
    for e, n in pairs(Extras.pendientes) do
        if IntentarBorrar(e) then
            Extras.pendientes[e] = nil
        elseif n > 25 then
            SetEntityCoords(e, 0.0, 0.0, -200.0, false, false, false, false)
            FreezeEntityPosition(e, true)
            Extras.pendientes[e] = nil
        else
            Extras.pendientes[e] = n + 1
        end
    end
end

function Extras.QuitarCamion()
    local C = Extras.camion
    local drv, veh = C.drv, C.veh
    C.veh, C.drv, C.listo, C.boquilla, C.pegado, C.tareaDe = nil, nil, false, nil, nil, nil
    if drv then Borrar(drv) end
    if veh then Borrar(veh) end
end

-- Dónde está la boquilla del cañón respecto al camión (se mide con los huesos del modelo)
local function MedirBoquilla(veh)
    for _, hueso in ipairs({ "weapon_1a", "turret_1barrel", "turret_1", "turret_1base", "weapon_1barrel" }) do
        local i = GetEntityBoneIndexByName(veh, hueso)
        if i and i ~= -1 then
            local p = GetWorldPositionOfEntityBone(veh, i)
            return GetOffsetFromEntityGivenWorldCoords(veh, p.x, p.y, p.z)
        end
    end
    return vector3(0.0, 1.6, 2.0)   -- aproximado, por si el modelo no tiene esos huesos
end

-- Coloca el camión (pegado a ti) para que la boquilla quede en la línea tú → objetivo,
-- sobre tu cabeza si está cerca y como mucho a 7 m del objetivo si está lejos.
-- rel: rumbo del objetivo respecto a tu personaje (grados) · dist: distancia · dz: desnivel
local function ColocarCamion(ped, rel, dist, dz)
    local C = Extras.camion
    local s = math.max(0.0, dist - MAX_DIST_CANON) - ATRAS_CANON
    local r = rad(rel)
    local fx, fy = -sin(r), cos(r)                        -- hacia el objetivo, en coordenadas de tu personaje
    local nx, ny = fx * s, fy * s
    local nz = ALTURA_CANON + ((dist > 0.1) and dz * math.max(0.0, s) / dist or 0.0)
    local b = C.boquilla
    local bx, by = b.x * cos(r) - b.y * sin(r), b.x * sin(r) + b.y * cos(r)   -- boquilla girada con el camión
    local ox, oy, oz = nx - bx, ny - by, nz - b.z
    local u = C.pegado
    if u and math.abs(u[1] - ox) < 0.25 and math.abs(u[2] - oy) < 0.25 and math.abs(u[3] - oz) < 0.25
        and math.abs(u[4] - rel) < 3.0 and IsEntityAttachedToEntity(C.veh, ped) then return end
    AttachEntityToEntity(C.veh, ped, 0, ox, oy, oz, 0.0, 0.0, rel, false, false, false, false, 2, true)
    C.pegado = { ox, oy, oz, rel }
end

local function CrearCamion(ped)
    local C = Extras.camion
    if C.creando or C.listo then return end
    C.creando = true
    Citizen.CreateThread(function()
        local ok, err = pcall(function()
            if not CargarModelo(MODELO_CAMION) or not CargarModelo(MODELO_BOMBERO) then
                C.fallo = "no se pudo cargar el camión de bomberos"; return
            end
            local p = GetOffsetFromEntityInWorldCoords(ped, 0.0, -2.0, 0.0)
            local veh = CreateVehicle(MODELO_CAMION, p.x, p.y, p.z, GetEntityHeading(ped), true, false)
            if not veh or veh == 0 then C.fallo = "el servidor no deja crear el camión"; return end
            C.veh = veh
            SetEntityAsMissionEntity(veh, true, true)
            SetEntityVisible(veh, false, false)
            SetEntityCollision(veh, false, false)
            SetEntityInvincible(veh, true)
            SetVehicleDoorsLocked(veh, 2)
            SetVehicleRadioEnabled(veh, false)
            SetVehicleSiren(veh, false)
            local drv = CreatePedInsideVehicle(veh, 4, MODELO_BOMBERO, -1, true, false)
            if not drv or drv == 0 then C.fallo = "el servidor no deja crear el conductor"; return end
            C.drv = drv
            SetEntityAsMissionEntity(drv, true, true)
            SetEntityVisible(drv, false, false)
            SetEntityInvincible(drv, true)
            SetBlockingOfNonTemporaryEvents(drv, true)
            SetPedKeepTask(drv, true)
            SetPedConfigFlag(drv, FLAG_SIN_ARMAS_VEH, false)
            SetPedCanBeDraggedOut(drv, false)
            SetPedAccuracy(drv, 100)
            SetPedFiringPattern(drv, GetHashKey("FIRING_PATTERN_FULL_AUTO"))
            SetCurrentPedVehicleWeapon(drv, CANON_AGUA)
            local t = 0
            while not NetworkGetEntityIsNetworked(veh) and t < 20 do
                if NetworkIsSessionStarted() then NetworkRegisterEntityAsNetworked(veh) end
                Citizen.Wait(25); t = t + 1
            end
            C.boquilla = MedirBoquilla(veh)
            C.listo, C.fallo = true, nil
        end)
        if not ok then C.fallo = tostring(err); print("[cargar coches] camión de agua: " .. tostring(err)) end
        C.creando = false
        if not C.listo then
            if C.fallo then Avisar("Cañón real: " .. C.fallo .. ". Se usa la boca de incendios.") end
            Extras.QuitarCamion()
            C.fallido = GetGameTimer() + 10000     -- no reintentar en 10 s
        elseif not Extras.agua.echando then
            Extras.QuitarCamion()                  -- soltaste la tecla mientras se creaba
        end
    end)
end

-- Chorro visible desde las manos (solo cuando no está el cañón real)
local function PtfxListo()
    if HasNamedPtfxAssetLoaded(PTFX) then return true end
    RequestNamedPtfxAsset(PTFX)
    return false
end
local function QuitarPtfx(h) if h then StopParticleFxLooped(h, false); RemoveParticleFx(h, false) end end

-- Parar de echar agua: se quita el chorro y el camión desaparece
function Extras.PararAgua()
    local A = Extras.agua
    QuitarPtfx(A.chorro)
    A.chorro, A.echando, A.ultimoObjetivo = nil, false, nil
    Extras.QuitarCamion()
end

local function FrameAgua(ped, ahora)
    local A, C = Extras.agua, Extras.camion
    A.echando = true
    local tipo = Config.tipoAgua
    local usaCanon = (tipo == 1 or tipo == 2) and ahora >= (C.fallido or 0)
    local usaBoca = tipo == 1 or tipo == 3 or not usaCanon

    local desde = GetOffsetFromEntityInWorldCoords(ped, MANOS[1], MANOS[2], MANOS[3])
    local objetivos = Marcados()
    local actual, obj                                   -- ped al que va el cañón · punto al que va el agua
    if #objetivos > 0 then
        -- Varios marcados: el cañón va rotando entre ellos
        if ahora >= (A.proxRotar or 0) then
            A.proxRotar = ahora + ROTAR_MS
            A.indice = ((A.indice or 0) % #objetivos) + 1
        end
        if (A.indice or 1) > #objetivos then A.indice = 1 end
        actual = objetivos[A.indice or 1]
        local c = GetEntityCoords(actual)
        obj = vector3(c.x, c.y, c.z + 0.2)
    else
        -- Nadie marcado: el agua va a donde mira la cámara que se ve
        if ahora >= (A.proxRayo or 0) then
            A.proxRayo = ahora + 50
            local cam, dir = Camara()
            local lejos = #(cam - desde) + Config.alcanceAgua
            local hit, fin = Raycast(cam, cam + dir * lejos, -1, ped)
            A.hit, A.fin = hit, hit and fin or (cam + dir * lejos)
        end
        obj = A.fin or (desde + GetEntityForwardVector(ped) * Config.alcanceAgua)
    end

    -- Dirección del agua (te giras hacia ahí y se orienta el chorro)
    local v = obj - desde
    local dist = math.max(#v, 0.01)
    local rumbo = deg(atan(-v.x, v.y))
    local inclinacion = deg(asin(math.max(-1.0, math.min(1.0, v.z / dist))))
    if not IsPedInAnyVehicle(ped, false) and not IsPedRagdoll(ped) then SetEntityHeading(ped, rumbo) end
    local rel = (rumbo - GetEntityHeading(ped) + 540.0) % 360.0 - 180.0

    -- 1) Cañón real del camión de bomberos
    local canonActivo = false
    if usaCanon and (actual or dist <= Config.alcanceAgua + 2.0) then
        if not C.listo then
            CrearCamion(ped)
        elseif not DoesEntityExist(C.veh) or not DoesEntityExist(C.drv) then
            Extras.QuitarCamion()
        else
            canonActivo = true
            ColocarCamion(ped, rel, dist, v.z)
            SetCurrentPedVehicleWeapon(C.drv, CANON_AGUA)
            if actual then
                -- Persigue a la persona (el juego mueve el cañón siguiéndola, sin reiniciar la orden)
                SetVehicleShootAtTarget(C.drv, actual, 0.0, 0.0, 0.0)
                if C.tareaDe ~= actual or ahora >= (A.proxTarea or 0) then
                    TaskVehicleShootAtPed(C.drv, actual, 1.0)
                    C.tareaDe, A.proxTarea = actual, ahora + 5000
                end
            else
                SetVehicleShootAtTarget(C.drv, 0, obj.x, obj.y, obj.z)
                local u = A.ultimoObjetivo
                if C.tareaDe ~= "punto" or not u or #(u - obj) > 3.0 or ahora >= (A.proxTarea or 0) then
                    TaskVehicleShootAtCoord(C.drv, obj.x, obj.y, obj.z, 1.0)
                    C.tareaDe, A.ultimoObjetivo, A.proxTarea = "punto", obj, ahora + 3000
                end
            end
        end
    end

    -- Chorro visible desde las manos cuando no está el cañón real
    if not canonActivo and PtfxListo() then
        if not A.chorro then
            UseParticleFxAssetNextCall(PTFX)
            A.chorro = StartNetworkedParticleFxLoopedOnEntity("water_cannon_jet", ped, MANOS[1], MANOS[2] - 0.3, MANOS[3],
                inclinacion, 0.0, rel, 1.0, false, false, false)
        else
            SetParticleFxLoopedOffsets(A.chorro, MANOS[1], MANOS[2] - 0.3, MANOS[3], inclinacion, 0.0, rel)
        end
    elseif canonActivo and A.chorro then
        QuitarPtfx(A.chorro); A.chorro = nil
    end

    -- 2) Agua a presión del juego (se sincroniza con todos: tira a jugadores y NPCs)
    if usaBoca and ahora >= (A.proxBoca or 0) then
        A.proxBoca = ahora + 350
        if #objetivos > 0 then
            -- A los pies de cada marcado, estén donde estén
            for i = 1, math.min(#objetivos, 8) do
                local c = GetEntityCoords(objetivos[i])
                AddOwnedExplosion(ped, c.x, c.y, c.z - 0.95, EXP_AGUA, 1.0, true, false, 0.0)
            end
            StopFireInRange(obj.x, obj.y, obj.z, 3.0)
        elseif A.hit then
            if dist <= Config.alcanceAgua + 2.0 then
                local p = obj - v * (0.4 / dist)
                AddOwnedExplosion(ped, p.x, p.y, p.z, EXP_AGUA, 1.0, true, false, 0.0)
                StopFireInRange(obj.x, obj.y, obj.z, 3.0)
            elseif ahora >= (A.avisoLejos or 0) then
                A.avisoLejos = ahora + 2500
                Avisar("Demasiado lejos para el agua (" .. math.floor(dist) .. " m). Márcalo para llegar.")
            end
        end
    end
end

-- Cada frame (menú cerrado). pFijar: tecla de marcar · aguaAbajo: tecla de agua mantenida
function Extras.Frame(ped, pFijar, aguaAbajo)
    local ahora = GetGameTimer()
    BorrarPendientes(ahora)
    if Config.patadasMoto then FramePatadas(ped, ahora) end
    -- Coche que vas a coger, marcado en pantalla cuando estás en la freecam
    Extras.cocheMira = (Config.activado and not vehiculo and apuntado and CamaraLejos(ped)) and apuntado or nil

    -- Marcar sirve para la manguera y para el modo Superman
    if not Config.manguera and not Config.superman then
        Extras.hayMarcas, Extras.candidato = Extras.cocheMira ~= nil, nil
        if Extras.agua.echando or Extras.camion.veh then Extras.PararAgua() end
        return
    end

    -- A quién apuntas (10 veces por segundo) y marcas en el mundo
    if ahora >= (Extras.proxApunte or 0) then
        Extras.proxApunte = ahora + 100
        Extras.candidato = BuscarApuntado(ped, not Config.manguera and not Config.superman)
    end
    local marcados = Marcados()
    for i = 1, #marcados do Marca(marcados[i], true) end
    local cand = Extras.candidato
    if cand and not DoesEntityExist(cand) then cand, Extras.candidato = nil, nil end
    if cand and not IndiceMarcado(cand) then Marca(cand, false) end
    Extras.hayMarcas = (cand ~= nil) or #marcados > 0 or Extras.cocheMira ~= nil
    if pFijar then
        if cand then Alternar(cand) else Avisar("Apunta a alguien (flecha blanca) para marcarlo") end
    end

    if Config.manguera and aguaAbajo and not IsPedDeadOrDying(ped, true) then
        FrameAgua(ped, ahora)
    elseif Extras.agua.echando or Extras.camion.veh then
        Extras.PararAgua()
    end
end

-- Con el menú abierto no se echa agua (y el camión se quita)
function Extras.MenuAbierto()
    BorrarPendientes(GetGameTimer())
    if not Config.manguera and not Config.superman then Extras.hayMarcas = false end
    if Extras.agua.echando or Extras.camion.veh then Extras.PararAgua() end
end

-- ── Lista "A quién echas agua" (menú) ─────────────────────
local function ListaAgua()
    local me = PlayerPedId()
    local pos = GetEntityCoords(me)
    local n = #Extras.marcados
    local items = {
        { tipo = "accion", label = "Desmarcar a todos", derecha = (n == 0) and "nadie marcado" or (n .. " marcados"),
          desc = "Sin nadie marcado, el agua va a donde apuntes con la cámara.", fn = function() Extras.DesmarcarTodos() end },
    }
    local jugadores = {}
    for _, pid in ipairs(GetActivePlayers()) do
        if pid ~= PlayerId() then
            local p = GetPlayerPed(pid)
            if p ~= 0 and DoesEntityExist(p) then jugadores[#jugadores + 1] = { p, #(GetEntityCoords(p) - pos) } end
        end
    end
    table.sort(jugadores, function(a, b) return a[2] < b[2] end)
    for _, j in ipairs(jugadores) do
        local p, d = j[1], j[2]
        local nombre = NombrePed(p)
        local marcado = IndiceMarcado(p) ~= nil
        items[#items + 1] = { tipo = "accion", label = nombre, npc = p,
            derecha = (marcado and "marcado · " or "jugador · ") .. string.format("%.0f m", d),
            desc = "Marca / desmarca. A los marcados el agua les sigue aunque se muevan.", fn = function() Alternar(p) end }
    end
    local npcs = {}
    for _, p in ipairs(GetGamePool("CPed")) do
        if p ~= me then
            local d = #(GetEntityCoords(p) - pos)
            if d <= Config.radioLista and not IsPedAPlayer(p) and not IsPedDeadOrDying(p, true) then npcs[#npcs + 1] = { p, d } end
        end
    end
    table.sort(npcs, function(a, b) return a[2] < b[2] end)
    for i = 1, math.min(#npcs, 40) do
        local p, d = npcs[i][1], npcs[i][2]
        local marcado = IndiceMarcado(p) ~= nil
        items[#items + 1] = { tipo = "accion", label = NombrePed(p) .. " " .. i, npc = p,
            derecha = (marcado and "marcado · " or "") .. string.format("%.0f m", d),
            desc = "Marca / desmarca. A los marcados el agua les sigue aunque se muevan.", fn = function() Alternar(p) end }
    end
    panelAgua.titulo = "A quién echas agua (" .. (#items - 1) .. ")"
    return items
end

-- Cada frame con la sección Extras abierta
function Extras.ActualizarLista(itFoco)
    local ahora = GetGameTimer()
    if Extras.listaSucia or (Menu.col ~= 2 and ahora - (Extras.ultimaLista or 0) > 1000) then
        Extras.listaSucia, Extras.ultimaLista = false, ahora
        local ok, items = pcall(ListaAgua)
        if ok then panelAgua.items = items end
    end
    if Menu.col == 2 and itFoco and itFoco.npc and DoesEntityExist(itFoco.npc) then Marca(itFoco.npc, false) end
    local m = Marcados()
    for i = 1, #m do Marca(m[i], true) end
end

-- ═════════════════════════════════════════════════════════
-- MODO SUPERMAN
--   · [L] levantas los brazos y los coches de la zona suben volando hacia ti, uno detrás de otro
--     (tan rápido como elijas en el menú), y se quedan girando en anillos sobre tu cabeza.
--   · [G] los lanzas: cada uno va en arco hasta encima del objetivo, frena un instante y cae en
--     picado sobre su cabeza (le sigue aunque se mueva). Con varios NPCs marcados se reparten;
--     sin marcados, al NPC de la flechita blanca; si no hay ninguno, a donde apuntas.
--   · [L] otra vez: los bajas despacio y quedan en el suelo alrededor de ti.
--   Solo coge los coches que el juego deja controlar: vacíos, de NPC (también los del servidor) o tuyos.
--   Salta los que lleva un jugador o los que otro jugador usó por última vez (son suyos y no se dejan).
--   Se vuelve a mirar el conductor justo antes de levantarlo.
--   Para forzar el control se monta al jugador un instante y se le devuelve a su sitio. Objetivo: NPCs y jugadores.
-- ═════════════════════════════════════════════════════════
local SUPER_ANILLOS   = { 6, 8, 10, 12 }   -- coches por anillo, de abajo arriba (36 en total)
local SUPER_ALTURA    = 4.6                -- altura del primer anillo sobre tu cadera (m)
local SUPER_SEP_ALT   = 2.8                -- separación en altura entre anillos (m)
local SUPER_RADIO0    = 4.2                -- radio mínimo del primer anillo (m)
local SUPER_GIRO      = 0.45               -- velocidad de giro de los anillos (rad/s)
local SUPER_MAX_LARGO = 22.0               -- más largos que esto no se cogen (aviones grandes)
local SUPER_CTRL_MS   = 2500               -- tiempo máximo para conseguir el control de un coche
local SUPER_VUELO_MS  = 6000               -- tiempo máximo de vuelo guiado
local SUPER_ENTRE_MS  = 90                 -- entre coche y coche al lanzarlos todos
local SUPER_BAJAR_MS  = 900                -- lo que tarda cada coche en bajar al suelo
local HUESO_CABEZA    = 31086              -- SKEL_Head
-- pegar, apuntar, disparar y subirse a vehículos (con los brazos arriba no se usan)
local CTRL_SUPER = { 24, 25, 37, 44, 45, 140, 141, 142, 257, 263, 264, 23, 75, 49, 145 }
local TAU, PI = math.pi * 2, math.pi
local sqrt, exp, floor, random = math.sqrt, math.exp, math.floor, math.random

-- ── Qué coches se pueden coger ────────────────────────────
local function MedidasCoche(v)
    local minD, maxD = GetModelDimensions(GetEntityModel(v))
    return math.max(maxD.y - minD.y, maxD.x - minD.x), maxD.z - minD.z, minD.z
end

-- ¿Es de otro jugador? Si lo lleva un jugador (conductor o pasajero) o fue un jugador quien lo usó por
-- última vez, el juego no deja controlarlo (sigue siendo suyo): no se intenta. Los coches de NPC, los
-- vacíos que nadie usó y los que usaste tú sí se pueden coger.
function Super.UsadoPorOtroJugador(v, me)
    local n = GetVehicleModelNumberOfSeats(GetEntityModel(v)) or 0
    for s = -1, math.max(n - 2, 0) do
        local p = GetPedInVehicleSeat(v, s)
        if p and p ~= 0 and p ~= me and IsPedAPlayer(p) then return true end
    end
    local ok, ult = pcall(GetLastPedInVehicleSeat, v, -1)   -- quién lo condujo por última vez
    if ok and ult and ult ~= 0 and ult ~= me and DoesEntityExist(ult) and IsPedAPlayer(ult) then return true end
    return false
end

-- Se puede coger si no es de otro jugador (ver arriba): vacíos, de NPC (del mundo o del servidor) o
-- tuyos. Aparte: ni el tuyo ahora, ni trenes, ni remolques enganchados.
local function Cogible(v, me, miVeh)
    if v == miVeh or v == vehiculo or v == Extras.camion.veh or Super.usados[v] then return false end
    if not DoesEntityExist(v) or IsEntityAttached(v) then return false end
    if IsThisModelATrain(GetEntityModel(v)) then return false end
    if Super.UsadoPorOtroJugador(v, me) then return false end
    local ok, remolque = pcall(IsVehicleAttachedToTrailer, v)
    if ok and remolque then return false end
    return true
end

-- Candidatos ordenados por distancia (la búsqueda se repite unas pocas veces por segundo)
local function BuscarCandidatos(me, ahora)
    local L = Super.lista
    for i = #L, 1, -1 do L[i] = nil end
    local pos = GetEntityCoords(me)
    local miVeh = GetVehiclePedIsIn(me, false)
    local radio = Config.supermanRadio
    for _, v in ipairs(GetGamePool("CVehicle")) do
        if (Super.vetados[v] or 0) <= ahora then
            local d = #(GetEntityCoords(v) - pos)
            if d <= radio and Cogible(v, me, miVeh) and MedidasCoche(v) <= SUPER_MAX_LARGO then
                L[#L + 1] = { v, d }
            end
        end
    end
    table.sort(L, function(a, b) return a[2] < b[2] end)
    Super.listaPos, Super.proxLista = 1, ahora + 800
end

local function SiguienteCandidato(me, ahora)
    local L = Super.lista
    local miVeh = GetVehiclePedIsIn(me, false)
    while Super.listaPos <= #L do
        local v = L[Super.listaPos][1]
        Super.listaPos = Super.listaPos + 1
        if (Super.vetados[v] or 0) <= ahora and Cogible(v, me, miVeh) then return v end
    end
    return nil
end

-- ── Soltar un coche: vuelve al juego tal y como estaba ───
local function Migrar(v, si)
    if NetworkGetEntityIsNetworked(v) then
        local ok, id = pcall(NetworkGetNetworkIdFromEntity, v)
        if ok and id and id ~= 0 then pcall(SetNetworkIdCanMigrate, id, si) end
    end
end

-- Deja de contar con un coche (sin tocarlo); "veto": cuánto tarda en poder cogerse otra vez
local function Olvidar(v, ahora, veto)
    Super.usados[v] = nil
    Super.vetados[v] = ahora + (veto or 2500)
end

local function Liberar(v, ahora, puertas)
    Olvidar(v, ahora)
    if not DoesEntityExist(v) then return end
    FreezeEntityPosition(v, false)
    SetEntityCollision(v, true, true)
    SetEntityInvincible(v, false)
    pcall(SetEntityHasGravity, v, true)
    pcall(SetVehicleGravity, v, true)
    Migrar(v, true)
    -- Los seguros de las puertas vuelven a como estaban a los 2 s (que no te subas sin querer)
    if type(puertas) == "number" then Super.abrir[v] = { t = ahora + 2000, estado = puertas } end
end

-- ── Montarse para forzar el control ──────────────────────
-- Con la tecla M (Superman activo): te mete al volante de cada coche de la zona que aún no controlas,
-- espera los frames justos hasta que el control es tuyo y te devuelve a tu sitio. Mientras dura
-- eres invisible (la cámara no se toca: con Susano crashea).
-- Solo se monta si el asiento del conductor está libre (meterte encima de un NPC de otro jugador
-- puede crashear); esos se piden de la forma normal.
--   Cómo va, para tardar lo mínimo:
--   1. Se pide el control de todos a la vez de la forma normal (los que lo den ya no hace falta montarlos).
--   2. Pasada rápida: saltas de coche en coche SIN volver a tu sitio entre medias, 2 frames en cada uno.
--   3. Vuelves a tu sitio y se espera el control de todos a la vez (no uno detrás de otro).
--   4. Solo los que no lo hayan dado: segunda pasada, esta vez más rato dentro de cada uno.
local MONTAR_ESTANCIA_FR = 2    -- pasada rápida: frames dentro de cada coche
local MONTAR_ESPERA_FR   = 20   -- espera conjunta del control (acaba antes si llegan todos)
local MONTAR_LENTO_FR    = 12   -- segunda pasada: frames máximos dentro de cada coche

local function Montable(v)
    return DoesEntityExist(v) and not IsEntityDead(v) and not IsEntityAttached(v)
        and not NetworkHasControlOfEntity(v)
end

-- Te sienta al volante de v, desde donde estés (también desde otro coche). true si lo consigue.
local function Sentar(me, v)
    if not IsVehicleSeatFree(v, -1, false) then return false end
    SetPedIntoVehicle(me, v, -1)
    local f = 0
    while GetVehiclePedIsIn(me, false) ~= v and f < 3 do Citizen.Wait(0); f = f + 1 end
    return GetVehiclePedIsIn(me, false) == v
end

local function MontarTodos(me)
    if Super.montando then return end
    Super.montando = true
    Citizen.CreateThread(function()
        local t0 = GetGameTimer()
        local pos, hdg = GetEntityCoords(me), GetEntityHeading(me)
        local function Volver()
            SetEntityCoordsNoOffset(me, pos.x, pos.y, pos.z, false, false, false)
            SetEntityHeading(me, hdg)
        end
        -- Sin cámara: mover la cámara crashea con Susano; se hace invisible en su lugar
        SetEntityVisible(me, false, false)
        local L, ocupados, montados = {}, 0, 0
        local ok, err = pcall(function()
            BuscarCandidatos(me, t0)
            local max = floor(Config.supermanMax + 0.5)
            for i = 1, math.min(#Super.lista, max) do
                local v = Super.lista[i][1]
                if Montable(v) and not Super.usados[v] then L[#L + 1] = v; PedirControlCoche(v) end   -- 1. todos a la vez (salta los que ya son nuestros)
            end
            -- 2. Pasada rápida
            local pendientes = {}
            for i = 1, #L do
                if not Super.activo or IsPedDeadOrDying(me, true) then break end
                local v = L[i]
                if Montable(v) then                          -- quizá ya dio el control pedido en el paso 1
                    if Sentar(me, v) then
                        montados = montados + 1
                        pendientes[#pendientes + 1] = v
                        for _ = 1, MONTAR_ESTANCIA_FR do NetworkRequestControlOfEntity(v); Citizen.Wait(0) end
                    elseif DoesEntityExist(v) and not IsVehicleSeatFree(v, -1, false) then
                        ocupados = ocupados + 1
                    end
                end
            end
            -- 3. De vuelta a tu sitio; espera conjunta
            Volver()
            for _ = 1, MONTAR_ESPERA_FR do
                local faltan = 0
                for i = 1, #pendientes do
                    local v = pendientes[i]
                    if Montable(v) then faltan = faltan + 1; NetworkRequestControlOfEntity(v) end
                end
                if faltan == 0 then break end
                Citizen.Wait(0)
            end
            -- 4. Segunda pasada, solo los que faltan
            for i = 1, #pendientes do
                if not Super.activo or IsPedDeadOrDying(me, true) then break end
                local v = pendientes[i]
                if Montable(v) and Sentar(me, v) then
                    local f = 0
                    while f < MONTAR_LENTO_FR and not NetworkHasControlOfEntity(v) do
                        NetworkRequestControlOfEntity(v); Citizen.Wait(0); f = f + 1
                    end
                end
            end
        end)
        -- Pase lo que pase: fuera de cualquier coche, en tu sitio y visible otra vez
        if IsPedInAnyVehicle(me, false) or #(GetEntityCoords(me) - pos) > 1.0 then Volver() end
        SetEntityVisible(me, true, false)
        Super.proxLista, Super.listaPos, Super.acum = 0, 1, 1.0
        Super.montando = false
        if Super.activo then PonerAnimCargar(me) end
        if not ok then
            print("[cargar_coches] MontarTodos: " .. tostring(err))
            Avisar("Superman: fallo al montarse (mira la consola F8)")
            return
        end
        local conControl = 0
        for i = 1, #L do
            if DoesEntityExist(L[i]) and NetworkHasControlOfEntity(L[i]) then conControl = conControl + 1 end
        end
        Avisar(("Superman: control en %d de %d coches · montado en %d · %d con NPC · %d ms")
            :format(conControl, #L, montados, ocupados, GetGameTimer() - t0))
    end)
end

-- ── Recoger ───────────────────────────────────────────────
local function EmpezarCoche(v, ahora)
    local largo, alto, bajo = MedidasCoche(v)
    Super.usados[v] = true
    Super.coches[#Super.coches + 1] = { veh = v, fase = "control", t0 = ahora, largo = largo, alto = alto,
        bajo = bajo, fase0 = random() * TAU }
    Super.layoutSucio = true
    -- Control con la mecánica normal del juego (también el de los NPCs que van dentro)
    PedirControlCoche(v)
end

-- Reparte los coches en anillos: 6 abajo, 8 encima, luego 10 y 12, cada anillo más ancho y más alto
local anillos = {}
local function Recolocar()
    local C = Super.coches
    for k in pairs(anillos) do anillos[k] = nil end
    local k, cap, n = 1, SUPER_ANILLOS[1], 0
    for i = 1, #C do
        if n >= cap then k, n = k + 1, 0; cap = SUPER_ANILLOS[k] or 12 end
        n = n + 1
        local a = anillos[k]
        if not a then a = { n = 0, largo = 0.0 }; anillos[k] = a end
        a.n, a.largo = a.n + 1, a.largo + C[i].largo + 1.3
        C[i].anillo, C[i].puesto = k, a.n
    end
    for i = 1, #C do
        local e = C[i]
        local a = anillos[e.anillo]
        e.radio = math.max(SUPER_RADIO0 + (e.anillo - 1) * 2.4, a.largo / TAU)
        e.alt = SUPER_ALTURA + (e.anillo - 1) * SUPER_SEP_ALT
        e.angBase = (e.puesto - 1) / a.n * TAU + (e.anillo - 1) * 0.55
        e.dir = (e.anillo % 2 == 1) and 1 or -1            -- cada anillo gira al revés que el de abajo
    end
    Super.layoutSucio = false
end

-- Sitio del coche en su anillo (respecto a ti, flotando un poco) y su giro: morro hacia donde gira
local function Hueco(e, t)
    local a = e.angBase + e.dir * Super.girar
    return cos(a) * e.radio, sin(a) * e.radio, e.alt + 0.22 * sin(t * 1.7 + e.fase0)
end
local function Giro(e, x, y, t)
    return 5.0 * sin(t * 1.3 + e.fase0), -9.0 * e.dir, deg(atan(y, x)) + (e.dir > 0 and 0.0 or 180.0)
end

-- Ya es nuestro: se prepara para subir volando
local function EmpezarSubida(e, me, ahora)
    local v = e.veh
    e.fase, e.t0 = "sube", ahora
    e.desde, e.rot0 = GetEntityCoords(v), GetEntityRotation(v, 2)
    e.ox, e.oy, e.oz = Hueco(e, ahora / 1000.0)     -- su sitio (se mueve suave si cambia el reparto)
    local d = #(e.desde - GetEntityCoords(me))
    -- con más velocidad de recogida también suben más deprisa
    e.dur = Clamp((d + 6.0) / (10.0 + Config.supermanVelocidad * 3.0), 0.45, math.max(3.0, d / 120.0)) * 1000.0   -- el tope crece con la distancia (≤120 m/s)
    e.arco = math.min(7.0, 1.5 + d * 0.15)
    e.puertas = GetVehicleDoorLockStatus(v)
    SetEntityInvincible(v, true)
    SetVehicleDoorsLocked(v, 2)
    SetEntityCollision(v, false, false)        -- atraviesa farolas, coches y gente al subir
    FreezeEntityPosition(v, true)
    Migrar(v, false)                           -- que no pase a otro jugador mientras lo tienes
end

-- ── Lanzar ────────────────────────────────────────────────
-- A quién van los coches: los marcados (NPCs y jugadores) o el de la flechita
local function ObjetivosNpc()
    local lista = {}
    local M = Marcados()
    for i = 1, #M do lista[#lista + 1] = M[i] end
    local flecha = false
    if #lista == 0 then
        local c = Extras.candidato
        if c and DoesEntityExist(c) then lista[1], flecha = c, true end
    end
    return lista, 0, flecha
end

-- "a donde apuntas" / "al objetivo marcado" / "al objetivo de la flecha" / "a 3 objetivos marcados"
local function Destino(n, flecha)
    if n == 0 then return "a donde apuntas" end
    if n > 1 then return "a " .. n .. " objetivos marcados" end
    return flecha and "al objetivo de la flecha" or "al objetivo marcado"
end

-- Punto del mundo en el centro de la imagen que ves (cámara normal o freecam de Susano)
local function PuntoApuntado(me)
    local cam, dir = Camara()
    local hit, fin = Raycast(cam + dir * 0.5, cam + dir * 500.0, -1, me)
    if hit then return fin end
    return cam + dir * 150.0
end

local function PosObjetivo(f)
    local o = f.obj
    if o and DoesEntityExist(o) then f.ultimo = GetPedBoneCoords(o, HUESO_CABEZA, 0.0, 0.0, 0.0) end
    return f.ultimo or f.punto or GetEntityCoords(f.veh)
end

-- El morro hacia donde va
local function Orientar(v, x, y, z)
    local n = sqrt(x * x + y * y + z * z)
    if n < 0.5 then return end
    SetEntityRotation(v, deg(asin(Clamp(z / n, -1.0, 1.0))), 0.0, deg(atan(-x, y)), 2, true)
end

local function Despegar(e, me, ahora)
    local v = e.veh
    DetachEntity(v, true, false)
    FreezeEntityPosition(v, false)
    PrepararFisica(v)
    SetEntityCollision(v, false, false)        -- en el arco atraviesa lo que haya: no se atasca
    pcall(SetEntityHasGravity, v, false)
    pcall(SetVehicleGravity, v, false)
    NetworkRequestControlOfEntity(v)
    local f = { veh = v, t0 = ahora, obj = e.obj, punto = e.punto, fase = "arco", puertas = e.puertas,
        dx = (random() - 0.5) * 1.4, dy = (random() - 0.5) * 1.4, extra = e.extra or 0.0 }
    -- Impulso inicial hacia arriba y hacia el objetivo
    local pos, obj = GetEntityCoords(v), PosObjetivo(f)
    local dx, dy = obj.x - pos.x, obj.y - pos.y
    local n = math.max(sqrt(dx * dx + dy * dy), 0.01)
    local fz = Config.supermanFuerza
    SetEntityVelocity(v, dx / n * fz * 0.5, dy / n * fz * 0.5, 9.0)
    Super.vuelo[#Super.vuelo + 1] = f
end

-- Vuelo guiado: 1) en arco hasta encima del objetivo, frenando al llegar (no se pasa)
--               2) en picado sobre su cabeza, siguiéndole aunque se mueva
-- Devuelve true cuando ha terminado (ha chocado, ha llegado o se acabó el tiempo)
local function Guiar(f, me, ahora, dt)
    local v = f.veh
    if not DoesEntityExist(v) then return true end
    SetEntityNoCollisionEntity(v, me, true)
    if ahora >= (f.proxCtrl or 0) then
        f.proxCtrl = ahora + 250
        if not NetworkHasControlOfEntity(v) then NetworkRequestControlOfEntity(v) end
    end
    local obj = PosObjetivo(f)
    local pos = GetEntityCoords(v)
    local fz = Config.supermanFuerza
    local vivo = ahora - f.t0
    local tx, ty, tz = obj.x + f.dx, obj.y + f.dy, obj.z
    if f.fase == "arco" then
        local hx, hy = tx - pos.x, ty - pos.y
        local horiz = sqrt(hx * hx + hy * hy)
        local az = tz + Clamp(horiz * 0.3, 7.0, 22.0) + f.extra - pos.z
        local dist = sqrt(hx * hx + hy * hy + az * az)
        if dist < 2.0 or (vivo > 400 and dist < 4.0 and GetEntitySpeed(v) < 8.0) or (vivo > 2500 and horiz < 12.0) then
            f.fase, f.tPicado = "picado", ahora
            SetEntityCollision(v, true, true)
            SetEntityInvincible(v, false)      -- ahora sí: se abolla al caer
            pcall(SetEntityRecordsCollisions, v, true)
        else
            local rapidez = math.min(fz, dist * 3.5)
            local k = 1.0 - exp(-dt * 6.0)
            local cv = GetEntityVelocity(v)
            local nx = cv.x + (hx / dist * rapidez - cv.x) * k
            local ny = cv.y + (hy / dist * rapidez - cv.y) * k
            local nz = cv.z + (az / dist * rapidez - cv.z) * k
            SetEntityVelocity(v, nx, ny, nz)
            Orientar(v, nx, ny, nz)
        end
    end
    if f.fase == "picado" then
        local dx, dy, dz = tx - pos.x, ty - pos.y, tz - pos.z
        local dist = sqrt(dx * dx + dy * dy + dz * dz)
        if dist < 1.2 or pos.z < tz - 1.5 then return true end
        if ahora - f.tPicado > 120 and HasEntityCollidedWithAnything(v) then return true end
        -- Velocidad limitada: máx 25 m/s para que el motor de físicas detecte el impacto
        local vel = math.min(fz, math.max(dist * 2.5, 12.0), 25.0)
        local w = vel / math.max(dist, 0.01)
        SetEntityVelocity(v, dx * w, dy * w, dz * w)
        Orientar(v, dx, dy, dz)
    end
    return vivo > SUPER_VUELO_MS
end

-- Al terminar el vuelo: gravedad y física normales (sigue con su velocidad y se estrella)
local function Aterrizar(f, ahora)
    if DoesEntityExist(f.veh) then SetEntityInvincible(f.veh, false) end
    Liberar(f.veh, ahora, f.puertas)
end

local function FrameVuelos(me, ahora, dt)
    local V = Super.vuelo
    for i = #V, 1, -1 do
        local f = V[i]
        local ok, fin = pcall(Guiar, f, me, ahora, dt)
        if not ok then print("[cargar coches] Superman (vuelo): " .. tostring(fin)) end
        if not ok or fin then
            table.remove(V, i)
            Aterrizar(f, ahora)
        end
    end
end

local function Lanzar(me, ahora)
    if Super.parar then return end                        -- ya se están lanzando todos
    local listos = {}
    for i = 1, #Super.coches do
        local e = Super.coches[i]
        if e.fase ~= "control" and not e.lanzarEn then listos[#listos + 1] = e end
    end
    if #listos == 0 then Avisar("Todavía no tienes ningún coche arriba"); return end
    local objetivos, jugadores, flecha = ObjetivosNpc()
    -- jugadores y NPCs valen como objetivo
    local punto = (#objetivos == 0) and PuntoApuntado(me) or nil
    local todos = Config.supermanModo ~= 2
    local n = todos and #listos or 1
    local nObj = math.max(#objetivos, 1)
    for i = 1, n do
        local e = listos[i]
        e.obj = (#objetivos > 0) and objetivos[(Super.turno + i - 1) % #objetivos + 1] or nil
        e.punto = punto
        e.extra = floor((i - 1) / nObj) * 1.6              -- se apilan encima: caen uno detrás de otro
        e.lanzarEn = ahora + (i - 1) * SUPER_ENTRE_MS
    end
    Super.turno = (Super.turno + n) % 1000
    if todos then
        Super.parar = true                                  -- ya no se recogen más; al vaciarse bajas los brazos
        for i = #Super.coches, 1, -1 do                     -- los que aún no eran tuyos se quedan donde están
            local e = Super.coches[i]
            if e.fase == "control" then table.remove(Super.coches, i); Olvidar(e.veh, ahora) end
        end
        Super.layoutSucio = true
    end
    if CargarAnim(ANIM_LANZAR.dict) then
        TaskPlayAnim(me, ANIM_LANZAR.dict, ANIM_LANZAR.name, 8.0, -8.0, 900, 48, 0, false, false, false)
    end
    Avisar((n == 1 and "¡Coche lanzado " or ("¡" .. n .. " coches lanzados ")) .. Destino(#objetivos, flecha) .. "!")
end

-- ── Bajar los coches al suelo ─────────────────────────────
local function EmpezarBajada(e, me, ahora, orden)
    local v = e.veh
    DetachEntity(v, true, false)
    FreezeEntityPosition(v, true)
    SetEntityCollision(v, false, false)
    local pos = GetEntityCoords(v)
    local rel = GetOffsetFromEntityGivenWorldCoords(me, pos.x, pos.y, pos.z)
    local ang = atan(rel.y, rel.x)
    -- un poco más lejos que el anillo, para que no te caigan encima
    local fuera = math.max(e.radio or SUPER_RADIO0, sqrt(rel.x * rel.x + rel.y * rel.y)) + 2.0 + e.largo * 0.35
    local w = GetOffsetFromEntityInWorldCoords(me, cos(ang) * fuera, sin(ang) * fuera, 0.0)
    local hay, suelo = GetGroundZFor_3dCoord(w.x, w.y, w.z + 25.0, false)
    local z = ((hay and type(suelo) == "number") and suelo or (w.z - 1.0)) - (e.bajo or -0.5) + 0.15
    Super.bajando[#Super.bajando + 1] = { veh = v, t0 = ahora + orden * 60, desde = pos,
        hasta = vector3(w.x, w.y, z), rot0 = GetEntityRotation(v, 2), puertas = e.puertas }
end

local function FrameBajadas(ahora)
    local B = Super.bajando
    for i = #B, 1, -1 do
        local b = B[i]
        local v = b.veh
        if not DoesEntityExist(v) then
            table.remove(B, i); Olvidar(v, ahora)
        elseif ahora >= b.t0 then
            local tt = (ahora - b.t0) / SUPER_BAJAR_MS
            local d, h, r0 = b.desde, b.hasta, b.rot0
            if tt >= 1.0 then
                table.remove(B, i)
                SetEntityCoordsNoOffset(v, h.x, h.y, h.z, false, false, false)
                SetEntityRotation(v, 0.0, 0.0, r0.z, 2, true)
                FreezeEntityPosition(v, false)
                SetEntityCollision(v, true, true)
                SetVehicleOnGroundProperly(v)
                PrepararFisica(v)
                SetEntityVelocity(v, 0.0, 0.0, 0.0)
                Liberar(v, ahora, b.puertas)
            else
                local s = tt * tt * (3.0 - 2.0 * tt)
                SetEntityCoordsNoOffset(v, d.x + (h.x - d.x) * s, d.y + (h.y - d.y) * s, d.z + (h.z - d.z) * s,
                    false, false, false)
                SetEntityRotation(v, r0.x * (1.0 - s), r0.y * (1.0 - s), r0.z, 2, true)
            end
        end
    end
end

-- Deja todos los coches: bajándolos despacio o, si te mueres, que caigan sin más
local function SoltarTodos(me, ahora, caer)
    local C = Super.coches
    for i = 1, #C do
        local e = C[i]
        local v = e.veh
        if not DoesEntityExist(v) then
            Olvidar(v, ahora)
        elseif e.fase == "control" then
            Olvidar(v, ahora)                                -- aún no se había movido
        elseif caer then
            DetachEntity(v, true, true)
            FreezeEntityPosition(v, false)
            SetEntityCollision(v, true, true)
            PrepararFisica(v)
            Liberar(v, ahora, e.puertas)
        else
            EmpezarBajada(e, Super.orbitObj or me, ahora, i - 1)   -- caen alrededor de quien orbitaban
        end
    end
    Super.coches = {}
    Super.activo, Super.parar, Super.nArriba, Super.linea = false, false, 0, ""
    Super.orbitObj = nil
    StopAnimTask(me, ANIM_CARGAR.dict, ANIM_CARGAR.name, 2.0)
end

Super.SoltarTodos = SoltarTodos   -- para poder soltarlo al descargar el script

local function Empezar(me, ahora)
    if vehiculo then Avisar("Suelta primero el coche que llevas en las manos"); return end
    if IsPedInAnyVehicle(me, false) then Avisar("Bájate del vehículo para usar Superman"); return end
    if IsPedDeadOrDying(me, true) then return end
    Super.activo, Super.parar, Super.coches = true, false, {}
    Super.proxAdd, Super.proxLista, Super.avisoVacio, Super.proxTexto, Super.acum = ahora, 0, false, 0, 1.0
    SetCurrentPedWeapon(me, H_DESARMADO, true)
    ClearPedTasks(me)
    PonerAnimCargar(me)
    Avisar("Superman: recogiendo coches  ·  " .. K("superLanzar") .. " lanzar  ·  " .. K("superMontar") .. " forzar control  ·  " .. K("superOrbitar") .. " orbitar  ·  " .. K("superRecoger") .. " bajarlos")
end

-- Brazos arriba: recoger coches nuevos, subirlos y mantenerlos girando
local function FrameArriba(me, ahora, t, dt)
    for i = 1, #CTRL_SUPER do DisableControlAction(0, CTRL_SUPER[i], true) end
    if ahora >= (Super.proxAnim or 0) then
        Super.proxAnim = ahora + 500
        if not IsEntityPlayingAnim(me, ANIM_CARGAR.dict, ANIM_CARGAR.name, 3)
            and not IsEntityPlayingAnim(me, ANIM_LANZAR.dict, ANIM_LANZAR.name, 3) then
            PonerAnimCargar(me)
        end
    end

    -- Coches nuevos, a la velocidad elegida (primero los más cercanos). Se acumula "cuántos toca coger"
    -- con el tiempo real, así la velocidad es exacta vaya el juego a los FPS que vaya.
    local max = floor(Config.supermanMax + 0.5)
    if Super.montando then
        -- montándose en los coches de la zona: aún no se coge ninguno
    elseif Super.parar or #Super.coches >= max then
        Super.acum = 1.0                                     -- en cuanto haya hueco, sale el siguiente
    elseif ahora >= Super.proxAdd then                       -- (proxAdd: pausa tras no encontrar coches)
        Super.acum = math.min(Super.acum + dt * math.max(Config.supermanVelocidad, 0.5), 2.0)
        while Super.acum >= 1.0 and #Super.coches < max do
            if ahora >= Super.proxLista or Super.listaPos > #Super.lista then BuscarCandidatos(me, ahora) end
            local v = SiguienteCandidato(me, ahora)
            if not v then
                Super.proxAdd, Super.acum = ahora + 300, 1.0
                if #Super.coches == 0 and not Super.avisoVacio then
                    Super.avisoVacio = true
                    Avisar("No hay coches libres (vacíos o de NPC) a menos de " .. floor(Config.supermanRadio) .. " m")
                end
                break
            end
            EmpezarCoche(v, ahora)
            Super.acum = Super.acum - 1.0
            Super.avisoVacio = false
        end
    end

    if Super.layoutSucio then Recolocar() end
    Super.girar = (Super.girar + SUPER_GIRO * dt) % TAU
    -- Centro de la órbita: el objetivo si hay, si no tú
    local centro = Super.orbitObj or me
    local hueso = GetPedBoneIndex(centro, 0)
    local k = 1.0 - exp(-dt * 6.0)
    local C = Super.coches
    local arriba = 0
    for i = #C, 1, -1 do
        local e = C[i]
        local v = e.veh
        if not DoesEntityExist(v) then
            table.remove(C, i); Olvidar(v, ahora); Super.layoutSucio = true
        elseif e.lanzarEn and ahora >= e.lanzarEn then
            table.remove(C, i); Super.layoutSucio = true
            Despegar(e, me, ahora)
        elseif e.fase == "control" then
            if NetworkHasControlOfEntity(v) then
                if Super.UsadoPorOtroJugador(v, me) then
                    -- Se ha subido un jugador mientras se pedía el control: no se toca
                    table.remove(C, i); Super.layoutSucio = true
                    Olvidar(v, ahora, 5000)
                else
                    EmpezarSubida(e, me, ahora)
                end
            elseif ahora - e.t0 > SUPER_CTRL_MS then
                table.remove(C, i); Super.layoutSucio = true
                Olvidar(v, ahora, 15000)                     -- no se pudo: no se reintenta en un rato
            elseif ahora >= (e.proxCtrl or 0) then
                e.proxCtrl = ahora + 100
                PedirControlCoche(v)                         -- se insiste hasta que el juego lo da
            end
        else
            arriba = arriba + 1
            if ahora >= (e.proxCtrl or 0) then
                e.proxCtrl = ahora + 500
                if not NetworkHasControlOfEntity(v) then PedirControlCoche(v) end
            end
            -- Su sitio en el anillo; si cambia el reparto (entra o sale un coche) va hacia el nuevo suave
            local x, y, z = Hueco(e, t)
            e.ox, e.oy, e.oz = e.ox + (x - e.ox) * k, e.oy + (y - e.oy) * k, e.oz + (z - e.oz) * k
            local p, r, yw = Giro(e, e.ox, e.oy, t)
            if e.fase == "sube" then
                local tt = (ahora - e.t0) / e.dur
                if tt >= 1.0 then
                    -- Ha llegado: se engancha a su sitio del anillo
                    e.fase = "orbita"
                    FreezeEntityPosition(v, false)
                    AttachEntityToEntity(v, centro, hueso, e.ox, e.oy, e.oz, p, r, yw, false, false, false, false, 2, true)
                else
                    -- Subiendo: sale suave, hace un pequeño arco y llega suave a su sitio
                    local s = tt * tt * (3.0 - 2.0 * tt)
                    local dst = GetOffsetFromEntityInWorldCoords(centro, e.ox, e.oy, e.oz)
                    local d0, r0 = e.desde, e.rot0
                    SetEntityCoordsNoOffset(v, d0.x + (dst.x - d0.x) * s, d0.y + (dst.y - d0.y) * s,
                        d0.z + (dst.z - d0.z) * s + e.arco * sin(PI * tt), false, false, false)
                    local dyaw = (GetEntityHeading(centro) + yw - r0.z + 540.0) % 360.0 - 180.0
                    SetEntityRotation(v, r0.x + (p - r0.x) * s, r0.y + (r - r0.y) * s, r0.z + dyaw * s, 2, true)
                end
            else
                -- Girando sobre la cabeza del centro (tú o el objetivo)
                AttachEntityToEntity(v, centro, hueso, e.ox, e.oy, e.oz, p, r, yw, false, false, false, false, 2, true)
            end
        end
    end
    Super.nArriba = arriba

    -- Texto de la barra de abajo (4 veces por segundo)
    if ahora >= (Super.proxTexto or 0) then
        Super.proxTexto = ahora + 250
        if Super.parar then
            Super.linea = "SUPERMAN   ·   ¡lanzando!"
        else
            local obj, _, flecha = ObjetivosNpc()
            local orb = Super.orbitObj and "  ★ orbitando objetivo" or ""
            Super.linea = "SUPERMAN   " .. arriba .. "/" .. max .. " coches" .. orb
                .. "   ·   " .. K("superLanzar") .. " lanzar "
                .. Destino(#obj, flecha) .. "   ·   " .. K("superOrbitar") .. " orbitar"
                .. "   ·   " .. K("superMontar") .. " montar"
                .. "   ·   " .. K("superRecoger") .. " bajarlos"
        end
    end

    -- Lanzados todos: bajas los brazos
    if Super.parar and #C == 0 then
        Super.activo, Super.parar, Super.linea = false, false, ""
        StopAnimTask(me, ANIM_CARGAR.dict, ANIM_CARGAR.name, 2.0)
    end
end

-- Cada frame (también con el menú abierto; entonces sin teclas)
-- Cambia el centro de la órbita (nil = tú): los coches ya girando vuelan suaves al nuevo sitio
local function CambiarCentro(nuevo, me, ahora)
    Super.orbitObj = nuevo
    local centro = nuevo or me
    local c0 = GetEntityCoords(centro)
    for i = 1, #Super.coches do
        local e = Super.coches[i]
        local v = e.veh
        if e.fase == "orbita" and DoesEntityExist(v) then
            e.desde, e.rot0 = GetEntityCoords(v), GetEntityRotation(v, 2)
            DetachEntity(v, true, true)
            SetEntityCollision(v, false, false)
            FreezeEntityPosition(v, true)
            SetEntityCoordsNoOffset(v, e.desde.x, e.desde.y, e.desde.z, false, false, false)
            local d = #(e.desde - c0)
            e.fase, e.t0 = "sube", ahora
            e.dur = Clamp((d + 6.0) / (10.0 + Config.supermanVelocidad * 3.0), 0.45, math.max(3.0, d / 120.0)) * 1000.0   -- el tope crece con la distancia (≤120 m/s)
            e.arco = math.min(7.0, 1.5 + d * 0.15)
        end
    end
end

function Super.Frame(me, pRecoger, pLanzar, pOrbitar, pMontar)
    local ahora = GetGameTimer()
    local dt = math.min(GetFrameTime(), 0.1)
    if #Super.vuelo > 0 then FrameVuelos(me, ahora, dt) end
    if #Super.bajando > 0 then FrameBajadas(ahora) end
    if ahora >= (Super.proxLimpieza or 0) then
        Super.proxLimpieza = ahora + 1000
        for v, hasta in pairs(Super.vetados) do if hasta <= ahora then Super.vetados[v] = nil end end
        for v, a in pairs(Super.abrir) do
            if a.t <= ahora then
                Super.abrir[v] = nil
                if DoesEntityExist(v) and not Super.usados[v] then SetVehicleDoorsLocked(v, a.estado) end
            end
        end
    end

    if not Super.activo then
        if pRecoger and Config.superman then Empezar(me, ahora) end
        return
    end
    local muerto = IsPedDeadOrDying(me, true)
    -- Mientras te montas (M) estás dentro de coches a propósito: eso no cuenta como subirte a uno
    if not Config.superman or muerto or (IsPedInAnyVehicle(me, false) and not Super.montando) then
        SoltarTodos(me, ahora, muerto); return
    end
    if Super.montando then
        -- mientras dura el montaje no se baja, lanza ni cambia la órbita (dura milisegundos)
        pRecoger, pLanzar, pOrbitar = false, false, false
    end
    if pRecoger then SoltarTodos(me, ahora, false); Avisar("Coches bajados"); return end
    if pLanzar then Lanzar(me, ahora) end
    -- Montar: forzar control montándose (M); solo si Superman está activo y no lanzando
    if pMontar and not Super.parar and not Super.montando then MontarTodos(me) end
    -- Orbitar en objetivo: pulsa O para que los coches orbiten al ped apuntado; otra vez para volver a ti
    if pOrbitar and not Super.parar then
        if Super.orbitObj then
            -- Volver a orbitar al jugador
            CambiarCentro(nil, me, ahora)
            Avisar("Coches orbitando a ti")
        else
            -- Buscar al ped apuntado
            local objetivos = ObjetivosNpc()
            local obj = objetivos[1]
            if not obj then
                obj = BuscarApuntado(me, false)
            end
            if obj and DoesEntityExist(obj) then
                CambiarCentro(obj, me, ahora)
                Avisar("Coches orbitando al objetivo")
            else
                Avisar("Apunta a alguien primero")
            end
        end
    end
    -- Si el objetivo de órbita ha muerto o no existe, volver al jugador
    if Super.orbitObj and (not DoesEntityExist(Super.orbitObj) or IsPedDeadOrDying(Super.orbitObj, true)) then
        CambiarCentro(nil, me, ahora)
        Avisar("Objetivo perdido: coches vuelven a ti")
    end
    FrameArriba(me, ahora, ahora / 1000.0, dt)
end

-- ── Lista "A quién tiras los coches" (menú): solo NPCs ────
local function ListaSuper()
    local me = PlayerPedId()
    local pos = GetEntityCoords(me)
    local nNpc, nJug = 0, 0
    for _, m in ipairs(Extras.marcados) do if m.jugador then nJug = nJug + 1 else nNpc = nNpc + 1 end end
    local items = {
        { tipo = "accion", label = "Desmarcar a todos",
          derecha = (nNpc + nJug == 0) and "nadie marcado" or ((nNpc + nJug) .. (nNpc + nJug == 1 and " marcado" or " marcados")),
          desc = "Sin nadie marcado, los coches van al NPC de la flechita blanca o a donde apuntes.",
          fn = function() Extras.DesmarcarTodos(); Super.listaSucia = true end },
    }
    if nJug > 0 then
        items[#items + 1] = { tipo = "texto", label = nJug .. (nJug == 1 and " jugador marcado (también le caen)" or " jugadores marcados (también les caen)") }
    end
    local npcs = {}
    for _, p in ipairs(GetGamePool("CPed")) do
        if p ~= me and not IsPedAPlayer(p) and not IsPedDeadOrDying(p, true) then
            local d = #(GetEntityCoords(p) - pos)
            if d <= Config.radioLista then npcs[#npcs + 1] = { p, d } end
        end
    end
    table.sort(npcs, function(a, b) return a[2] < b[2] end)
    for i = 1, math.min(#npcs, 40) do
        local p, d = npcs[i][1], npcs[i][2]
        local marcado = IndiceMarcado(p) ~= nil
        items[#items + 1] = { tipo = "accion", label = NombrePed(p) .. " " .. i, npc = p,
            derecha = (marcado and "marcado · " or "") .. string.format("%.0f m", d),
            desc = "Marca / desmarca. Los coches le caen en la cabeza aunque se mueva.",
            fn = function() Alternar(p); Super.listaSucia = true end }
    end
    panelSuper.titulo = "A quién tiras los coches (" .. math.min(#npcs, 40) .. ")"
    return items
end

-- Cada frame con la sección Superman abierta
function Super.ActualizarLista(itFoco)
    local ahora = GetGameTimer()
    if Super.listaSucia or (Menu.col ~= 2 and ahora - (Super.ultimaLista or 0) > 1000) then
        Super.listaSucia, Super.ultimaLista = false, ahora
        local ok, items = pcall(ListaSuper)
        if ok then panelSuper.items = items end
    end
    if Menu.col == 2 and itFoco and itFoco.npc and DoesEntityExist(itFoco.npc) then Marca(itFoco.npc, false) end
    local m = Marcados()
    for i = 1, #m do Marca(m[i], true) end
end
end

local Secciones = {
    { nombre = "Cargar coches", sub = "General", icono = "coche", paneles = {
        { titulo = "General", items = {
            Toggle("Activado", "activado", "Enciende o apaga el mod entero."),
            Toggle("Contorno al apuntar", "contorno", "Ilumina el vehículo que vas a coger."),
            Toggle("Ayuda en pantalla", "ayudaHud", "Muestra abajo qué tecla usar en cada momento."),
            Accion("Soltar ahora",
                function() if vehiculo then Soltar(); Avisar("Vehículo soltado") else Avisar("No llevas ningún vehículo") end end,
                "Deja en el suelo, delante de ti, el vehículo que llevas."),
        } },
        { titulo = "Ajustes", items = {
            Slider("Alcance", "alcance", 4, 40, 1, "%.0f m", "Distancia máxima para coger un vehículo apuntándolo."),
            Slider("Coger cercano", "alcanceCercano", 0, 10, 0.5, "%.1f m",
                "Si no apuntas a nada, coge el más cercano en este radio. 0 = desactivado."),
            Slider("Fuerza de lanzamiento", "fuerzaLanzar", 5, 100, 5, "%.0f", "Velocidad con la que sale al lanzarlo."),
            Slider("Ajuste de altura", "ajusteAltura", -0.6, 0.6, 0.05, "%+.2f m",
                "Sube o baja el vehículo sobre tus manos. Se aplica al momento."),
        } },
    } },
    { nombre = "Tuneo", icono = "llave", paneles = { panelCategorias, panelOpciones },
      sub = function()
          -- El nombre del vehículo se lee del juego solo cuando cambia el vehículo o la categoría
          if Tuneo.subVeh ~= Tuneo.veh or Tuneo.subCat ~= Tuneo.cat or not Tuneo.sub then
              Tuneo.subVeh, Tuneo.subCat = Tuneo.veh, Tuneo.cat
              local nombre = Tuneo.veh and NombreVehiculo(Tuneo.veh) or "sin vehículo"
              Tuneo.sub = CATEGORIAS[Tuneo.cat][1] .. "  ·  " .. nombre
          end
          return Tuneo.sub
      end },
    { nombre = "Personaje", icono = "ropa", paneles = { panelCatRopa, panelRopa },
      sub = function() return CATEGORIAS_ROPA[Ropa.cat][1] end },
    { nombre = "Control de NPCs", icono = "fantasma", paneles = { panelPosesion, panelCercanos },
      sub = function() return Pos.activo and "Controlando un NPC" or "Ninguno" end },
    { nombre = "Animaciones", icono = "baile", paneles = { panelAnimCat, panelAnimOpc },
      sub = function()
          local o = Animac.obj
          local b = Animac.busqueda or ""
          local n = o and o.nombre or "tú"
          if b ~= Animac.subB or n ~= Animac.subN then
              Animac.subB, Animac.subN = b, n
              Animac.sub = (b ~= "" and ("Buscar: " .. b) or "Todas") .. "  ·  a: " .. n
          end
          return Animac.sub
      end },
    { nombre = "Extras", sub = function()
          local n = #Extras.marcados
          local a = (n == 0) and "donde apuntes" or (n == 1 and Extras.marcados[1].nombre or (n .. " marcados"))
          return "Moto y manguera  ·  agua: " .. a
      end, icono = "rayo", paneles = {
        { titulo = "Moto y manguera", items = {
            Toggle("Patadas en moto siempre", "patadasMoto",
                "Quita los bloqueos de la patada del juego: X + clic izquierdo / derecho, como siempre."),
            Toggle("Manguera sin camión", "manguera",
                "Agua de verdad del juego: la ven todos y tira a jugadores y NPCs. Mantén la tecla para echarla."),
            Lista("Tipo de agua", "tipoAgua", Extras.TIPOS_AGUA,
                "Cañón real: camión de bomberos invisible con el cañón sobre tu cabeza. Boca de incendios: agua a presión donde cae. Los dos: ambos."),
            Slider("Alcance del agua", "alcanceAgua", 5, 60, 1, "%.0f m", "Hasta dónde llega el agua."),
            T(function() return "Mantén " .. K("agua") .. " para echar agua" end),
            T(function() return K("fijarAgua") .. " marcar / desmarcar" end),
            T("También con la freecam de Susano"),
        } },
        panelAgua,
    } },
    { nombre = "Superman", icono = "superman", sub = function()
          if Super.activo then return Super.nArriba .. " coches arriba" end
          if not Config.superman then return "Apagado" end
          return "Listo  ·  " .. K("superRecoger") .. " para empezar"
      end, paneles = {
        { titulo = "Modo Superman", items = {
            Toggle("Modo Superman", "superman",
                function() return "Pulsa " .. K("superRecoger") .. ": los coches de alrededor suben volando a tu cabeza. Apagarlo los baja." end),
            Slider("Velocidad de recogida", "supermanVelocidad", 1, 30, 1, "%.0f coches/s",
                "Cuántos coches suben por segundo: 1 = de uno en uno, despacio · 30 = casi todos de golpe (y suben más rápido)."),
            Slider("Coches a la vez", "supermanMax", 1, 36, 1, "%.0f",
                "Cuántos coches levitas a la vez (hasta 36, en 4 anillos)."),
            Slider("Radio de búsqueda", "supermanRadio", 10, 1000, 10, "%.0f m",
                "Hasta qué distancia se buscan coches (solo vacíos, de NPC o tuyos). Solo existen los que el juego tiene cargados a tu alrededor: normalmente unos 400 m, más con OneSync Infinity."),
            Slider("Fuerza", "supermanFuerza", 20, 120, 5, "%.0f m/s", "Velocidad a la que salen los coches al lanzarlos."),
            Lista("Al lanzar", "supermanModo", { "Todos a la vez", "De uno en uno" },
                "Todos: lluvia de coches sobre el objetivo. De uno en uno: cada pulsación lanza uno y el anillo se vuelve a llenar."),
            T(function() return K("superRecoger") .. " recoger  ·  otra vez: bajarlos" end),
            T(function() return K("superLanzar") .. " lanzar  ·  " .. K("fijarAgua") .. " marcar objetivo" end),
            T(function() return K("superMontar") .. " forzar control (montarse)  ·  " .. K("superOrbitar") .. " orbitar en objetivo" end),
        } },
        panelSuper,
    } },
    { nombre = "Controles", sub = "Teclas", icono = "teclado", paneles = {
        { titulo = "Teclas", items = itemsTeclas },
        { titulo = "Teclas fijas", items = {
            T("F10   Abrir / cerrar el menú"),
            T("Esc   Volver / cerrar"),
        } },
    } },
    { nombre = "Ayuda", sub = "Cómo se usa", icono = "ayuda", paneles = {
        { titulo = "Cómo se usa", items = {
            T(function() return "1. Apunta a un vehículo (máx. " .. math.floor(Config.alcance) .. " m)" end),
            T(function() return "2. " .. K("agarrar") .. " para cogerlo" end),
            T("3. Llévalo encima mientras andas"),
            T(function() return "4. " .. K("lanzar") .. " lo lanza donde miras" end),
            T(function() return "5. " .. K("agarrar") .. " otra vez lo suelta" end),
        } },
        { titulo = "En el menú", items = {
            T("Ratón: clic y arrastrar las barras"),
            T("Arrastra la parte de arriba para mover"),
            T("Rueda del ratón: bajar en listas largas"),
            T("Shift + flechas: de 10 en 10"),
            T("Flechas: moverse y cambiar valores"),
            T("Enter: elegir   ·   Esc: volver"),
        } },
    } },
    { nombre = "Menú", sub = "Ajustes", icono = "engranaje", engranaje = true, paneles = {
        { titulo = "Apariencia", items = {
            Lista("Color", "colorMenu", nombresColores, "Color de acento del menú."),
            Toggle("Descripciones", "descripciones", "Muestra abajo la descripción de cada opción."),
        } },
        { titulo = "General", items = {
            Accion("Guardar ajustes", function() Guardado.Guardar(false) end,
                "Los ajustes se guardan solos al cambiarlos; esto los guarda ya mismo."),
            Accion("Restablecer ajustes", function() Guardado.Restablecer() end,
                "Vuelve a poner todos los ajustes y teclas como venían."),
            Accion("Exportar ajustes", function() Guardado.Exportar() end,
                "Copia ajustes, teclas, atuendos y apariencia al portapapeles. Pégalo en un .txt para guardarlo."),
            Accion("Importar ajustes", function() Guardado.Importar() end,
                "Copia el texto exportado (Ctrl+C) y pulsa aquí para recuperarlo todo."),
            Accion("Centrar ventana", function() Config.ventanaX, Config.ventanaY = 0, 0; Guardado.pendiente = true; Avisar("Ventana centrada") end,
                "Vuelve a colocar la ventana en el centro de la pantalla."),
        } },
    } },
}

-- ── Lógica ────────────────────────────────────────────────
local function SeccionActual() return Secciones[Menu.seccion] end

-- Valor de una opción: de Config o de sus funciones get/set (tuneo)
local function Leer(it)
    if it.get then
        local ok, v = pcall(it.get)
        if ok then return v end
        if it.tipo == "toggle" then return false end
        return nil -- quien lo usa pone su propio valor por defecto
    end
    return Config[it.key]
end
local function Escribir(it, v)
    if it.set then pcall(it.set, v) else Config[it.key] = v; Guardado.pendiente = true end
end
local function Minimo(it) return type(it.min) == "function" and it.min() or it.min end
local function Maximo(it) return type(it.max) == "function" and it.max() or it.max end

-- Índices de las opciones que se pueden elegir (se guarda mientras la lista no cambie; no modificar el resultado)
local function Seleccionables(panel)
    local items = panel.items
    if panel._selDe ~= items or panel._selN ~= #items then
        local r = {}
        for i, it in ipairs(items) do if it.tipo ~= "texto" then r[#r + 1] = i end end
        panel._sel, panel._selDe, panel._selN = r, items, #items
    end
    return panel._sel
end

-- Opción con el foco: item, índice en el panel, nº de seleccionables
local function ItemFoco()
    if Menu.col == 0 then return nil end
    local panel = SeccionActual().paneles[Menu.col]
    if not panel then return nil end
    local sel = Seleccionables(panel)
    if #sel == 0 then return nil end
    Menu.pos[Menu.col] = Clamp(Menu.pos[Menu.col] or 1, 1, #sel)
    return panel.items[sel[Menu.pos[Menu.col]]], sel[Menu.pos[Menu.col]], #sel
end

local function CambiarSeccion(i)
    if i == Menu.seccion then return end
    Menu.dirSec  = (i > Menu.seccion) and 1 or -1
    Menu.seccion = i
    Menu.pos     = { 1, 1 }
end

-- Siguiente panel (en la dirección dada) que tenga opciones seleccionables
local function PanelSiguiente(desde, dir)
    local paneles = SeccionActual().paneles
    local c = desde + dir
    while c >= 1 and c <= #paneles do
        if #Seleccionables(paneles[c]) > 0 then return c end
        c = c + dir
    end
    return nil
end

local function CambiarValor(it, dir)
    if it.tipo == "toggle" then
        Escribir(it, not Leer(it))
        if it.key == "activado" and not Config.activado and vehiculo then Soltar() end
    elseif it.tipo == "slider" then
        local mn, mx = Minimo(it), Maximo(it)
        local shift = Tecla(0x10)                            -- Shift: de 10 en 10
        local paso = it.paso * (shift and 10 or 1)
        local v = Clamp((Leer(it) or mn) + dir * paso, mn, math.max(mx, mn))
        Escribir(it, math.floor(v / it.paso + 0.5) * it.paso) -- evita 1.2000000001
        if it.key == "ajusteAltura" then Reenganchar() end
    elseif it.tipo == "lista" then
        local n = #it.opciones
        local actual = Clamp(math.floor(Leer(it) or 1), 1, n)
        Escribir(it, (actual - 1 + dir) % n + 1)
    end
end

local function SliderDesdeRaton(it, x0, ancho, mx)
    local pct = Clamp((mx - x0) / ancho, 0, 1)
    local mn, mxv = Minimo(it), Maximo(it)
    if mxv <= mn then return end
    local v = mn + pct * (mxv - mn)
    local nuevo = Clamp(math.floor(v / it.paso + 0.5) * it.paso, mn, mxv)
    if nuevo ~= Leer(it) then Escribir(it, nuevo) end
    if it.key == "ajusteAltura" then Reenganchar() end
end

local function Activar(it)
    if it.tipo == "cat" then it.fn()
    elseif it.tipo == "toggle" or it.tipo == "lista" then CambiarValor(it, 1)
    elseif it.tipo == "bind" then Menu.esperandoTecla = true; Teclas.Instantanea()
    elseif it.tipo == "campo" then Menu.escribiendo = it; Teclas.Instantanea()
    elseif it.tipo == "accion" then it.fn() end
end

-- ── Escribir en un campo de texto del menú ───────────────
-- Mientras escribes, el teclado del juego queda bloqueado (en Frame).
local TECLAS_TEXTO = {}
for i = 0, 25 do TECLAS_TEXTO[0x41 + i] = { string.char(97 + i), string.char(65 + i) } end
for i = 0, 9 do
    TECLAS_TEXTO[0x30 + i] = { tostring(i), tostring(i) }
    TECLAS_TEXTO[0x60 + i] = { tostring(i), tostring(i) }
end
TECLAS_TEXTO[0x20] = { " ", " " }
TECLAS_TEXTO[0xBD] = { "-", "_" }   -- tecla - (con Shift: _)
TECLAS_TEXTO[0x6D] = { "-", "-" }
TECLAS_TEXTO[0xBE] = { ".", ":" }
TECLAS_TEXTO[0x6E] = { ".", "." }
TECLAS_TEXTO[0x6F] = { "/", "/" }

-- Devuelve el texto después de las pulsaciones de este frame (letras, números, Ctrl+V, Retroceso, Supr)
function Teclas.Teclear(txt, maximo)
    local nuevo = txt
    local shift, ctrl, alt = Tecla(0x10), Tecla(0x11), Tecla(0x12)
    if ctrl and alt and Pulsada(0x32) then
        nuevo = nuevo .. "@"                                 -- AltGr + 2
    elseif ctrl and Pulsada(0x56) then
        -- Ctrl + V: pegar
        local ok, pegado = pcall(function() return Susano.GetClipboardText() end)
        if ok and type(pegado) == "string" then nuevo = nuevo .. pegado:gsub("[\r\n\t]", "") end
    elseif not ctrl and not alt then
        for vk, c in pairs(TECLAS_TEXTO) do
            if Pulsada(vk) then nuevo = nuevo .. (shift and c[2] or c[1]) end
        end
    end
    if Repetir(0x08) and #nuevo > 0 then
        -- borrar la última letra (con tildes, que ocupan más de un byte)
        local corte = #nuevo
        while corte > 1 and nuevo:byte(corte) >= 128 and nuevo:byte(corte) < 192 do corte = corte - 1 end
        nuevo = nuevo:sub(1, corte - 1)
    end
    if Pulsada(0x2E) then nuevo = "" end                     -- Supr: borrar todo
    if #nuevo > maximo then nuevo = nuevo:sub(1, maximo) end
    return nuevo
end

local function ProcesarEscritura()
    local it = Menu.escribiendo
    if Pulsada(0x0D) or Pulsada(0x1B) or Pulsada(TECLA_MENU) then
        Menu.escribiendo = nil
        Teclas.Instantanea()
        return
    end
    local txt = it.get() or ""
    local nuevo = Teclas.Teclear(txt, it.max or 40)
    if nuevo ~= txt then it.set(nuevo) end
end

-- Cuadro de texto (PedirTexto): Enter acepta, Esc cancela
function Menu.ProcesarPrompt()
    local p = Menu.prompt
    if not p then return end
    local fin = Pulsada(0x0D) and 1 or (Pulsada(0x1B) and 2 or nil)
    if fin then
        Menu.prompt = nil
        Tuneo.escribiendo = false
        Teclas.Instantanea()
        if fin == 1 and p.texto ~= "" then p.cb(p.texto) end
        return
    end
    p.texto = Teclas.Teclear(p.texto, p.max)
end

-- ── Ratón ─────────────────────────────────────────────────
local Hits  = {}   -- zonas clicables del último frame dibujado
local Raton = { x = 0, y = 0, px = -1, py = -1, arrastre = nil }

local function LeerRaton()
    SetMouseCursorActiveThisFrame()
    Raton.x, Raton.y = R.PosCursor()
    local down, pressed = Tecla(0x01)
    local _, pressedDer = Tecla(0x02)
    Raton.down, Raton.click, Raton.clickDer = down, pressed, pressedDer
    Raton.movido = math.abs(Raton.x - Raton.px) + math.abs(Raton.y - Raton.py) > 0.5
    Raton.rueda = 0
    if IsDisabledControlJustPressed(0, 241) or IsDisabledControlJustPressed(0, 15) then Raton.rueda = -1 end
    if IsDisabledControlJustPressed(0, 242) or IsDisabledControlJustPressed(0, 14) then Raton.rueda = 1 end
    Raton.px, Raton.py = Raton.x, Raton.y
end

local function HitEn(x, y)
    for i = #Hits, 1, -1 do
        local h = Hits[i]
        if x >= h.x and x <= h.x + h.w and y >= h.y and y <= h.y + h.h then return h end
    end
end

local function ProcesarRaton()
    LeerRaton()
    if Raton.moviendo then
        if Raton.down then
            local m = Raton.moviendo
            Config.ventanaX = m.ox + (Raton.x - m.mx)
            Config.ventanaY = m.oy + (Raton.y - m.my)
        else
            Raton.moviendo = nil
            Guardado.pendiente = true
        end
        return
    end
    if Raton.arrastre then
        if Raton.down then
            local a = Raton.arrastre
            SliderDesdeRaton(a.item, a.x + 12, a.w - 24, Raton.x)
        else
            Raton.arrastre = nil
        end
        return
    end

    local h = HitEn(Raton.x, Raton.y)
    if h and h.tipo == "item" and Raton.movido and not Menu.esperandoTecla then
        Menu.col, Menu.pos[h.panel] = h.panel, h.posSel
    end

    if Raton.click and h and not Menu.esperandoTecla then
        if h.tipo == "mover" then
            Raton.moviendo = { mx = Raton.x, my = Raton.y, ox = Config.ventanaX, oy = Config.ventanaY }
        elseif h.tipo == "seccion" then
            CambiarSeccion(h.i); Menu.col = 0
        elseif h.tipo == "item" then
            Menu.col, Menu.pos[h.panel] = h.panel, h.posSel
            if h.item.tipo == "slider" then
                Raton.arrastre = { item = h.item, x = h.x, w = h.w }
                SliderDesdeRaton(h.item, h.x + 12, h.w - 24, Raton.x)
            else
                Activar(h.item)
            end
        end
    end
    if Raton.clickDer and h and h.tipo == "item" and h.item.tipo == "lista" then CambiarValor(h.item, -1) end
end

-- ── Teclado ───────────────────────────────────────────────
local function ProcesarMenu()
    if Menu.esperandoTecla then
        if Pulsada(0x1B) then Menu.esperandoTecla = false; Avisar("Cancelado"); return end
        local vk = EscanearTecla()
        if vk then
            local it, msg = ItemFoco(), nil
            if it and it.bind then
                for _, b in ipairs(binds) do
                    if b ~= it.bind and b.tecla == vk then
                        b.tecla = it.bind.tecla
                        msg = b.nombre .. " pasa a " .. NombreTecla(b.tecla)
                    end
                end
                it.bind.tecla = vk
                Guardado.pendiente = true
                Avisar(msg or (it.bind.nombre .. ": " .. NombreTecla(vk)))
            end
            Menu.esperandoTecla = false
        end
        return
    end

    if Menu.escribiendo then
        local campo = Menu.escribiendo
        ProcesarRaton()
        -- Clic fuera del campo: dejar de escribir
        if Raton.click and Menu.escribiendo == campo then
            local h = HitEn(Raton.x, Raton.y)
            if not (h and h.tipo == "item" and h.item == campo) then Menu.escribiendo = nil end
        end
        if Menu.escribiendo then ProcesarEscritura() end
        return
    end

    ProcesarRaton()

    local arriba, abajo = Repetir(0x26), Repetir(0x28)
    local izq, der      = Repetir(0x25), Repetir(0x27)

    if Menu.col == 0 then
        -- Barra lateral: ↑↓ cambia de sección, → o Enter entra en los paneles
        if arriba then CambiarSeccion((Menu.seccion - 2) % #Secciones + 1) end
        if abajo  then CambiarSeccion(Menu.seccion % #Secciones + 1) end
        if der or Pulsada(0x0D) then Menu.col = PanelSiguiente(0, 1) or 0 end
    else
        local it, _, nSel = ItemFoco()
        if not it then Menu.col = 0; return end
        if arriba then Menu.pos[Menu.col] = (Menu.pos[Menu.col] - 2) % nSel + 1 end
        if abajo  then Menu.pos[Menu.col] = Menu.pos[Menu.col] % nSel + 1 end
        it = ItemFoco()
        -- En la lista de categorías, moverse ya abre la categoría
        if (arriba or abajo) and it.tipo == "cat" then it.fn() end
        local ajustable = it.tipo == "slider" or it.tipo == "lista"
        if izq then
            if ajustable then CambiarValor(it, -1) else Menu.col = PanelSiguiente(Menu.col, -1) or 0 end
        end
        if der then
            if ajustable then CambiarValor(it, 1) else Menu.col = PanelSiguiente(Menu.col, 1) or Menu.col end
        end
        if Pulsada(0x09) then Menu.col = PanelSiguiente(Menu.col, 1) or PanelSiguiente(0, 1) or 0 end
        if Pulsada(0x0D) then Activar(it) end
    end

    if Pulsada(0x08) or Pulsada(0x1B) then
        if Menu.col > 0 then Menu.col = 0 else Menu.abierto = false end
    end
    if Pulsada(TECLA_MENU) then Menu.abierto = false end
    if not Menu.abierto then
        Raton.moviendo, Raton.arrastre = nil, nil
        Menu.cierreHasta = GetGameTimer() + 400
    end
end

-- ═════════════════════════════════════════════════════════
-- RECURSOS INCRUSTADOS (imágenes PNG y fuente Poppins, en base64)
--   Todo va dentro del script: no hace falta copiar archivos.
--   Poppins: licencia SIL Open Font License. Iconos y logo: propios.
-- ═════════════════════════════════════════════════════════
local RECURSOS = {
    superman = [[
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
]],
    rayo = [[
iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAEiElEQVR42u2bTYgcVRSFz63pGaIhEhIhGsxClICKMCQoo6AgoysXoiLiCCIKupHgTiKYlcSd
IKJ7FUQ0/mAQBBEVUTFEUfwBUdGNQUZjNDATnamuz8198Kh0T6q6u6qn38yF4dFNd9c795173nm3aqQNHrYeJwWcNS8zY0OsSC/wG4YBQGZmBbC9NLdM0mkz
W0155Ts+3gOcBP4A/gT+An4ALhgHQ9oCP+XjVcASZ8fr8eeSq3kgA7YB3zvgHCiAVX+9ELMkNfCB+kccbABd+Pg3cGGS9I/AP+ZgVyLa5z6+EwQy1bq/OaJ7
ESUgMOGhmCmpgM983AMsOvBuBD4kYhnYnRQDfDWngA7wWYnuZfp/1DT4cWR1ysy6kp6RNCcpl1Te3oLtfdOFL5nVD6J3f6nO6UH/VeCyZOgfid4+4Ey019OH
/sfb2PqyFkUP9/hHJG1xr98LXKD/G6FkUjI7R9egfrkErk6C/hH4QxXAh63wO98pbKLdX1T3t0bgizUSEJLz5MR7/8jsXAqc6mF21mLAdRN9+ovMzgzwRR+z
0w/8z8BMW4efpgQmmJ3nJe3rY3bKUfgO8LaZrQCdiewDRqL3cAXR68WAW9qkv41a9MysC8xJ+th/P6twncI/d0LSXknL/p3aDKjLms6IRa8Adkp61X+7qJjk
kICjZrZUMkSNRmdUoicpM7MceFnSHkndGi4uJOkTYId/L687DUnnSVp0/WmvBFywcuCwpIM++UGSe2rAKeQO/l1JC558WhHRSPTurGh2mopfgF117bMNW/d+
I2OvpOOStq5xyKlK4zpR+PivpDkz+zYIceMaEEwKsEXSa5K2OfWG8RZWM1k4hnsdfMfM8jbEM6b+SzX3+1FF6CAfbP3cEIF/dEzgw/VeGBa8DQA+mJ0bJX3g
NMzU3o3WsL0ek3SDvy4GVXwbUPR2SfpS0sVRAmhBeGPHeI2ZnQhzatwIRaKXSXpF0u6S2WmaAUH0ViTd7uBrKf7QPt+PuU/3uI1VJYro0FMMUff3jVL0apeA
pCt8Fepud5lT+BJ3bB1f0SpzCM7yKTN7HJie2IclgPmKDZLyyr8VVn6UjZLOAACyIa6VS7qphuvr+ve+kbQQTpyj9Pi1EzCo4gJd30FmK5ZfUPyTku4ws+VW
RW/UPUIfZ4BfSx2gfoIZ7hzNT3SDtNQhvjLaAaq0xx9p3eY2bJ3vriCAAfyzbYBv+7bT/nMIYBC99yUdcNp3NekRlcCHazAgvPcjsDM8PZYC+CCAW4Hf+9R/
1/+WopuiaTwTGK3+bAS+KCl+qPvbkhC9PgL4YJ/ewfgaGy0n4LkeCRhZY2MSNODTktiF8XM3SFMpPgkawO8A/olqPrjA35J7DrDcQ/Dx+pIA5sB/wLXjVvym
ay5QejY615tf9wEzO9ZqK3uMAviiM+CMj4f9/WmlGvEDTsBX0d7fSGNjPQvgRcBpB/81cL7/g0SmlCMSwHlf/UXg8vVmc5tcBYtOgCbpLjP7aWK7OkMw4D3g
iWSd3jnqfztwIKnTXc1ETMcJ2YzN2Ix1F/8DWdDUVpglr38AAAAASUVORK5CYII=
]],
    logo = [[
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
]],
    coche = [[
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
]],
    teclado = [[
iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAFPUlEQVR4nO2az4tcRRDHP2/e7OaHq2ETf4AS9aAo8Reii+gtRBH/AQ/Gg5CDv8WTiiCupxyNIih7EBS8CB70IBhE9CKLvwmKcbNePIR4cE2MuJud
H+Whunw9PW/evMm82R7J+0LTb6a6+1XXq66qru5ERLiQ0YjNQGzUAojNQGzUAojNQGzUAojNQGzUAojNQGzUAojNQGw0R2yfTISLyaDUJqeMABIgBTplB50SpCi/3aJGyZDdoE3cMO8GnVZNsMmcJeM7nEMPijSg
4TpeDjwBPABcx/RO3iDAKeBL4DXgR5Tn3C89SAMaqOrcD7wNXDkJTrcALeA5VBD2QXuQJwBTmfuAo+6/tkcf1XBuNXxeG668AiySsxxCAZh67wZ+QtW/6wYx2j/ApnueFqOYePUu92y8tdGPth/4gkAI4dc0NXka
uMJ1Tt3AJ1EpfgL8zfRM3kcTuBt4EbiL3o+3CBwg5FtE/JKISFNEfhCRroi0XH1SRK4O2k5zmRGRT0XRdnNY9+bQsLZ+JGiW8hLgGu93ArwE/AZsD9qbdBPvt480oKdbQE9R4/c4ulQTpwnbges93oF8gyZkatJE
ferHrtMGGgsAnKY/yBCPvgGsB/QOKuB0DPouMi91Joe+A9gJ/A58jy6FlhuzLygathdIUDuw4dq+BfwKrKIG5TIyyTeBNx39BGpEF9w4M64+5OgrY9BXgV9cfSigL7h+K46HG4bOM1j/iMi8iKxJhtMiMudKS3px
r9d/t4icc/93XX3Y0ba5etlbl+PQO65eDuiHJR/Wfr9rl+bZgDI4Q6YRLXp9quTQN4L+Zyukt91vH36/FkP2AVA+qDFDMuf6WD//BZJDDzFbMX02p80M2ZIYijIC6LoXrQFPAQfRyX4HLJNZ4DNo/PCw67MGLLkx
LDp7AY3KUuCPMejmoV4O6EvATaht2nDPeymKWUrYgDX3X2zffj7lqJvD5iAbMMoSMOxxta33EEY/h0aMIeZRqzwuvQv8mUOfQ11hixIaXsYI2uRT1A2uoi7mM/LdoLmpY+S7sRXg+Jj0n12d5waPuf7HgTuGzrPE
EqjdoIfaDVK7QR6i2A0epNgNLlLs5srQzQ0uBvQlYB+ZG7yZKXCDTa9Mgr4lbtDQJFP7hIJsq4c8Vzku3VLe0LsM/S26UGIpjCqAQWcD9sI9wGPeuFVmkC278yG6zbVYwIc4Ho02NGtVVYIzAbYBHwH3VDTmIDyD
7vFXyRfCSKhCAOYhdgK3oio7qcOTDhoJXosGY2OfbVaZ4hY3XoPJnx6V/epDl8AgCfod/ZzboLYNNCh51z2nZDn5KksT+AoNd8uof5hD7BNIngb4ycc2moNbQNPhs2RnAuHAbeBR4L2cF1eFBPgG+IvBx1327kuB
2+jVxv75BnFAIiI7ROSEZGlxEZGvJUslNwaU1PevEy5pAR/W5g3Hu6X2N0VknzeHvr2AqfI68LknNQHuRDPDt6Bql1c6lIsLqkCngI+rgNeBJ91vm4ftYs1oA/1HY7aubkRPVYUs6DDat+Tv06cBKXA7cDGZ6m+i
S/cR4B2Co7Giw9FngVfp/aqTWttVo41+sDY6+Q+AB8mJXvOMoEVSR1ADuBjQxgo8tgDmLUAn/z4anfoHPv+h6IaIWdkDwPNohHdRxcxOCm00a3QEvd8AA7zGKFdk9qI3RP4POIWm5XwjONINER92pjaNx+HDUHg/
CMoJwOBfkph2CAPWfIhR9gLTbvzOCxf8TdFaALEZiI1aALEZiI1aALEZiI1aALEZiI1aALEZiI1/AfoIbmAkj2aLAAAAAElFTkSuQmCC
]],
    ayuda = [[
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
FuwK6QgAAAAASUVORK5CYII=
]],
    llave = [[
iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAEnklEQVR4nO2bv6scVRTHP7v71qgx5gf6wNfYKUZRLF7QzsqIhZ2InRaJtkKIlX+BjY0/iIWI2FgkCCpqo6jYxBQRIxixTCdoHjZhd+dYnHuYu7N3
fu3OzH0zeV8YZnbvnbn3e+75eWd3JCLczhjHnkBsHAgg9gRiYyv2BCpilPncmOPazwKYoMQFWGTaxu4ItdXCaB9GgQmQsLzKdwGHUIEkwM2mBttPGmBqbiv6NHDanR8B7vHarwFXgMvARWDGumYhIvvhGHvXL4vI
z1INn4rINHN/rSM2cURk4s47IvKVRy4RkZmIzEVk4T4nInLLtb/n7hu5Y63xY/uACarSu8DnwAOkJjAJ9J+jZvshcJawv6iFmD5gjJI9BXwNHCclGELj5CFeFLAEbBu46s4LwqsOLZH3JxIDCfAxSn5OO+RHrCZR
S4ghACPwEvAs7aq9lPWNIQBBV+W8+5y3Qk2t/OGicboWgJF4CnjCXYdUP2Ez8pYmfwac88ZeQddRwFbheXRCc1YXIXHfXQFec9d1yS+A94EXgfu8Z6ygaw2wSey6c0gtjeg77npMffIXgNfdeI+haXQSGq9LAVgh
cwQ4mTO+oJrxH/Cdu6dKtZclfwatD0Dzi4dzxoviBKfAvSV9bgF7rLfyZ1DTmrr2raLxYkWBoD2S1v+H0bS4LI7nkc/6trzxoglgXtC+AO4EXiA1iRDqkM83o44rv7Gr3H50Fd1cVmFV3w0R2Xb3Tb17RyKy5VWA
F9x9s8BzRET+FZH7vcpxaU5da4B59Ksm/0AfM4Md4AvUFGakodA0aELxytuz/wL+8Z67MqEuYVngl6TxPgSL27vAL2gycxI4ATwIvAL8RD55SO3+ewpqja6rQav/d4DrwN02j5z+vpASNDIcQvcIs+2hewXNOK+R
kwx1mQmawzoBXEI9fREBu8d2freAY+77BakTDMFK628pIA/daYBN4DjwDaraZeSz8CdaFBr9MPso8AeRU+EQ+VANUIYRFep7Uns/h5K3Qir80JY1II98G6Zn0WHKchVZmEq3qQGbkK+7KkbSJ5+r9tlJtoFNyFvV
NkeJhYRhdm4Z5QTNFd4gJV+6GwTtmMCm5MesOsgsGb9tgXr788Bv1CBPxUnVwSbkrd9l4FXgOXTj5HF0U8N3fjdRB/cD8Anwq/u+1OazaFIDmiJ/Gk1dDUeBh1h+N/g78LfXx6JDqc1n0ZQAmiZvr8YTikvnSUmf
UjQhgKbJZ713KONr5KUIbC6Atsm3jk3CYO/Jw/oCGAR5WE8AgyEP9QUwKPJQTwCDIw/VBWAxeVDkoZoALA5vMzDyUE0AtpX1Nkp+xkDIQ3kiZMXFM+jqjxkQeahuAm8Cd1C+HQU9Ig/FArA3s0dJX2eXCaxX5KG6
DxiU2vsoEoD9OGEP+JPisrOX5KFcA2xv7l3SaOCTEtKo0DvyUK0cNiF9gL6Lg5SctfWSPFTzAbbBeBZ4C7hB+oeFPeAjdP+ud+Sh3oaIvV4+AjyJ5gjXUYH47b1C3R2h0K5rY7/bjYF1tsT8Pbqi3/v0ArH/LxAd
t/3/Bg8EEHsCsXEggNgTiI3/Ad4KE1yI9pdLAAAAAElFTkSuQmCC
]],
    ropa = [[
iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAEaElEQVR4nO2bTagcRRSFv54ZE00UEjU+EdFlxAiBYBYuBFHjVsStCIIIIi4UV7qImJ0iItlIFqLuhaxcJOAf4k4MKEJQcaNiIKgg0bxkeo6Luteu
6enp6Znu98rH9IGCnuqaqnNP3a66t3omk8Q6Y5CaQGr0AqQmkBq9AKkJpMbaCzDagj4HQAb4/jrpoD+sT4C8ZX9T6FIAN7xTgswKmNlYnYzTxSMwAIYEojlwCDgFfAycBm6wdlnVl2vg7d+0vj4EjhE8K4/GbQdJ
q5aBpGH0+R5J70raVIErkvbb/WyF/pH0paZxRtKxGh5Lla0y/KqVy5IOm/HLkMysXCvpJ0ljEzPvWoiuDR9LmkTXknTc2o+WGMvHecCMjg0fdynEMjPS1HDHxMpFSRslwxaN5e0+K4kZY5EQjR65ZYw/1NDwMklJ
OqvCA0YKsxQTdJf3e0h6rcb4pkJ4XysL4EQPSrq0hOFlgpL0haTbKvovk9wl6Z3Sd5uOEwvxhBp4XdNn8X3r9LKaGx7DiV1QWBPulrQ3Gmck6Q5JT0v6xtquMo4UFsuJpPMKYrp3VdqYSXMPRAa2594FfA1cY3vz
svu5Y0IRd+TAr8AP9vlW4E5gT0XbVZATYoSngPfsujJwqhNgBIwJgciLdt02chTBuHkBTE4R6bWBB0pfAUftujIknyeAz/KNwHfAgVJ9Wygq3m8b76qCG/wQ8ClzvGCe0u7+zwO3WGddkvNZHlrxPKJLyPo9TmHP
LJEKD3Aie4AfCQLE9TsJvpYcJTwOM0lUlQe4Wo8DG3Q/+9sJn93naOgBbuhu4BxwkPYrckq4cVeBw8B5go3/LYhlw4b2pccIxucVbaoGSIk6Dn4+sQt4ydpOeXPZOFfmmQUdxwOkxiIOPqmPAjdReqQHpYYT4H4r
dfu1b2GbVlJhAlxa0Ma94GbgWYrdAZgWQIRo720K1XKqPcFd6RTwS1S33RCB77imTbzqvwrcThFwzQiQASeBs4Sob2h1YwoDvd0F4C2KI6/thnvoaeAjq3Nj48kbEmz5FniZ4LHFYzMvSVBIKT/Q7EnPFbt+xdr9
1TJ5WRWeYN0r6Yhd+0lUjDOSnpS0Ww2zwaFmD0DekPRb1OlFSfskXS/pT6tLJcDDCjw/j+5tKkxefEDiWedUZrgoFY5z6Q1JL0j6XtIJqzsg6XcbNKUAmaRHJP0s6XWFSSufMFWmxHXZoGNgxRea6+zz38A+Qri8
n4o9dovhAdqDwCeEvX4v8Ifd9x2s9v1Bk/R2QrF3DoF/ViC7HcgJxo8o3lEsxDL5vQhe4Glr21deWwHfsRpjlQOO/0P4Ow9Lc9upSU5n6AVITSA1egFSE0iNXoDUBFKjFyA1gdToBUhNIDV6AVITSI1egNQEUqMX
IDWB1Fh7Abr4tbgfmqY4FYaWR3RtBcgIr8ZSeJKP2cqGJu8F6jAC7mtLoiXOEY7D4z9pNEZbAXY8upi59n9aaAdff1bC2nvA2m+DvQCpCaTG2gvwLxvkSB95diujAAAAAElFTkSuQmCC
]],
    fantasma = [[
iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAFBElEQVR4nO2by+scRRDHP/vwJwkoeaEgKuaHiYiBJGIO6kUl4kEED2JEhYhoDopnye8g/geeVVTwgYIInkSiR4nBFz5OIuSiB5WYnxoUdHe2PFRX
ZjI7u9vd07MtZL/QzM7j211VU13dPV3bExEuZvRzC5Abw4xt9xquLd0dl2WAHuptPVTJCc3KDjyeSStYxzGg78q44d622vk5oKhdG7hj/XoydOUB9rYL9E1uBQ4AdwEHgWuA62ucn4Efgc+Bz4BPgLPunnlQckN0
4QEDSkH3AUeBB4FrA+v5DfgAeAP4yF3ro90indAikqr0XEFE9onIqyLyj5SYiMhIRMauTGqlcNdH7ncVJ0Tk7kpb/VRyp1J+UPn9fE3xkVMwFBNnkKox3haRna6dYQrZU3QBc/mdwFvAPe76mDKqt0VBGQd+AB5F
48SQ5gDrjbYTIVP+EPApqvwY7aND0ihv7dhosgf4GHjcnbcK5G08oI9G+FuAE8D2FAJ5oKAcHo8BL3Nh4A1CrAHsze5Ah63dLEd5w6Qix+2o90UZIbYLGO8dlq98tX2A94ErUeWD9YkxgFn6OeAwy1feYF3wCuBN
yslXEEK7gE1E9gLfUUb5VMEuBvYCjgKvE9gVQj3AFiobwCXoG/BRPmb25suxl7IBrAXIdJ4c8mwB3AgccQ0N5jJKJcxLJvMfj+JYV7gBeNhxvfUKNQDAk8ClLLZ0VYlN97wJm5JT5T6NvhRvb/M1QA/ta1vQhc0i
rimyCdyLTl4OokPmLIViOAbzxJuB/fh5p2s1bK5/W8P8vGkOX4jIWRE5VKtnh4h8VXmmDaeOkTs+G7JWCPEA0PX8YMHbsPH4FfTtrTn+Grq+36AMpm04s2Q87I4+3cbbANbwgVpjs+ocA+9SBk4BRu78JPATF/bV
GE4dJtNe9AOM12jga4AJOtburjVWh0Xgc8D3jjep3AP4092zemM4TTAP2eXKPDnPw8cAVvHlwLpnxYuicNP9GE4VJudWNIDatbkIGQZ9JiYmxBZ0fl6fJQo6hF5VeT6Gswhe/R+62RgpUGXuQ4W34Wjozm9CJ1M2
xsdykqALA9jU9Bi6XB6hitj8/DjTET2Gk0zYLuq0BdOHqOuO0bXDS8ADTE9UYjhJ0OW+wAT9VPYN8C1wNargLDeO4bRGl+t4U2gXOoGCxYrEcFqh6w8Z5to2KfFRJIYTjWV8yekR3ndjOFG46PMDVgbILUBurAyQ
W4DcWBkgtwC5sTJAbgFyY2WA3ALkxsoAuQXIjWUYIDavL20+4Ax0bYDQneG2vGB0aYAxqsBrwFPMzhlOxYuDxwaiZX9ud5uXtpk5D7aJeVpEtjn+e7VNzJS8Ov9OmU7gbLU5GmRTV/5Ct9J/R788PYGm1VQ/d6fg
tUJXGyMD4BngC8rNjU3gEeBvmr/xx/LaYZGLSFgXMDd9Uab36O33Yw0uHctr3QVSGmDsjqdEs7kHFW5dmRcqysTyshjgjJRp7UWlWEb4GRFZd5ymlPaeU2YgIicrhovh/VuTweQoROQOXwOExIAecBkaNyx52Yol
Rj8EnGZ+HpDt/98P/OrqOhLI+wXdNuszLYcd/ZQS/0TJIXDrjMp7wB/Al/hlddkze9A0+1OBvHXgOmZngXyNBs+FQTP1X2ZConT12Vhea4TuDM3brTE39YWlxtifq2J4s+D9l7uu/zb3v8dqOZxbgNxYGSC3ALnx
H4bONv6a3nDPAAAAAElFTkSuQmCC
]],
    baile = [[
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
8WmGkcNLsu8AAAAASUVORK5CYII=
]],
    animaciones_gta = [[
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
]],
    engranaje = [[
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
]],
    cursor = [[
iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAEdElEQVR4nL2Wz28bRRTHP7PjXXv9M7EhVhMwUaUopKWqIlU5FJ9A5cIJJCKKOCAOhktuPUBP/ReqkoJ6i8q99FCUA6gHCo1EKqpGkSqljUIRPxpT
cEBO4uzOPA67btMmaWIU90kjeT2zep/39jvfGQAF9B46dKiolCIOh2cVhUKhN5PJzAPLnud9XqvV3Hgq8awYigcPHvz73Llzks1mRSn13cjIyEvxnPvUN/cLoL+//76I2OvXr28MDAwI8HOlUnk1nve6DjAwMLBc
r9dFROzS0lI4NjYmQLOvr+/9eI1LpJXuATQaDTHGWBGRZrNpxsfHBZBcLncmFqcD6K4CiIgNgkDisKdPnzaA+L7/5YkTJzLx+n0X52MA1lqx1ooxRkREpqamglQqJY7jfD88PDwYv7Ov4twC0I52N65duxZsI859
g9gRYDNEN8X5VAARkTAMpZvi3BVARB5qohvi3BNAPNkVce4ZoFvi7BhARGRjY0NEHhdnqVRqi7MjTfwvAJFH4lxdXQ3b4vR9/wzg04EmdgRom9J2lbf/b0NIJE7xfV+y2Ww17sKuEDsuEBE2XVAwxqC15vz580xO
TpLP540xRgNYa1FKqUwmI67r2vX19RKQA9aB8GkAKu7A7fn5+ecLhYKIiLLWorVmbW0NEcH3fUQEx3FYWlqyhw8fdlZXV68C3wJJwAAWCB3HaVprbwGLwJ/AGiA7AWy5eoVhiNaaer0ux48flwsXLqCUQkQwxjA4
OKgmJiYARnK53D3P8256nnfD87wbWuuf4uT/xkA7Jt4cW47jO3fu2NHRUQFkeHhYms2mWGslDEOx1sri4qLJZrPied5nwFg8jgCvAC8DFaCHPW7Jxy4kc3NzplKpCHC/p6fnC2D94sWLIhLt/1h0plarCfBLqVQ6
BrwAFIEC0bdP08E5UTxw4MCyiMjMzExQLBbFcZxf0+n0J1rrt5VSPxw9elRarZbZ3IWFhYV2F07FSTNEynf2mvghwNDQ0PLU1JT09vaK4zgLvu9PAO8Bb2az2Y+B4NKlS7a97dpdOHnypAVul8vlwRii8+t8Pp8v
5vP5P1zXFa31j8lk8iNgHHgDOJbL5YaUUler1aqISGiMediF2dlZk0gkJJVKnYo7kOoYgMgLXk8mkx9ord8B3gJeIxJTP9CTz+ffBcz09LS11kqr1Wp3IazVaiHwdblc7gPynXbBITKKuVarNWuMuQ/8DtwDloG/
AJPJZL4BZs6ePauUUsbzPLTW9sqVK9y9e1e7rptuNBo5Ik/o+IKigF7gRWAwrrrAIxUngVQ6nf5Qay3T09Pm8uXLUq1WhWif3/Q871NgFCjT4WnYpnWJPoUicrWQR0aigEw6nc4ZY75KpVJjKysrLeCW7/tXwzC8
FQTBg7hj94AGu9jvdgBP/n7SwVwgm0gkRsIwPOJ5XkpE6kEQbAABkeX+BjwAmnERHQPsti5NJLLniEwnSeTzjXj8Ez8H2xSwY+z1zBagRVSdjhNBdNqtxWODqPI9Jwf4D2BH5bCDcAwdAAAAAElFTkSuQmCC
]],
    fuente_normal = [[
AAEAAAAMAIAAAwBAR1BPU0R2THUAADfoAAAAIEdTVUIfSCdrAAA4CAAAADBPUy8yWXR9JQAAAUgAAABgY21hcCKnIaYAAATIAAAATGdseWYxPrWMAAAGqAAAL4RoZWFkIqJrigAAAMwAAAA2aGhlYQiFA6UAAAEE
AAAAJGhtdHiysiZcAAABqAAAAyBsb2NhGTcODAAABRQAAAGSbWF4cAFBAKUAAAEoAAAAIG5hbWUjJDkzAAA2LAAAAZpwb3N0/7gAMgAAN8gAAAAgAAEAAAAEAQa+ZJEQXw889QADA+gAAAAA2KSpvgAAAADm330u
/+X+8gQfA8IAAAAHAAIAAAAAAAAAAQAABBr+ogBkBEn/5f/xBB8AAQAAAAAAAAAAAAAAAAAAAMgAAQAAAMgARwAFAD0ABAABAAIAHgAGAAAAZAAAAAMAAgAEA1MBkAAFAAACigJYAAAASwKKAlgAAAFeADIBSAAA
AAAFAAAAAAAAAAAAAAMAAAAAAAAAAAAAAABJVEZPAMAAICA6BBr+ogBkBG8CcwAAAAEAAAAAAiQCugAAACAABAH0AAABCwAAASoAWAEkACMDSAAhAm4APAL3ACoC4wAlAJ8AIwHGAGwBxgAhAeYAPQKrAFcAxv/+
AicAOgDSACwB3AA1AnQAPgFAACYCPwAzAk0AMQJ1ACgCdABJAnsASQIiACECdwA8AnYASQDVACwBCAAXAisAVALTAGUCGwBeAgwAJQP1AEgCogAhAmUATQMEACsCwwBNAgEATQH4AE0DCgArArQATQD2AE0CEgAp
AlcATQGwAE0DXQBNAr8ATQMSACsCQwBNAxQAKwJgAE0CSwA5Ah0AIgKjAEsCpAAWA9AAFwJtAC0CSAATAh0ALgGnAIUCkgCDAacAbgJ1ACUC3QBpAQEAEQKkACsCpABNAl8AKwKkACsCbAArAUkAFwKkACsCgABN
APYAPgD4/+UCAwBNAPYATQQGAE0CgABNAoAAKwKkAE0CpAArAXUATQIKAC8BbAAaAoAASAIxAAwDNAAMAd8ADQIzAAwBxwApAc4AaQEjAGQBzgBEAgcAJQELAAABKgBYApkAQQJsACwCGQA/AlMAGQEjAGQCPwAu
AToAFwMYADEBwgAhAc0ALQKKACkCJwA6Af0ANAGDABEBmgAcAq4AWAFKAB4BTAAXAPcAEQKFAE0CVAAfANQALwEQABEAxAAZAbQAIQHNADICgAAmAqMAJALFACMCBwAuAqIAIQKiACECogAhAqIAIQKiACECogAh
A4QADAMEACsCAQBNAgEATQIBAE0CAQBNAPYABwD2AAcA9v/wAPb/9QLVAAkCvwBNAxIAKwMSACsDEgArAxIAKwMSACsCgwBnAxIAIwKjAEsCowBLAqMASwKjAEsCSAATAkMATQKpADwCpAArAqQAKwKkACsCpAAr
AqQAKwKkACsESQArAl8AKwJsACsCbAArAmwAKwJsACsA9gAHAPYABwD2//AA9v/1An4AKwKAAE0CgAArAoAAKwKAACsCgAArAoAAKwKRAE4CgAAmAoAASAKAAEgCgABIAoAASAIzAAwCpABNAjMADAD2AE0BNwAR
APMADwFZABECRQAsARgALQEYADICJwBMAAAAAgAAAAMAAAAUAAMAAQAAABQABAA4AAAACgAIAAIAAgB+AP8gJiA6//8AAAAgAKAgJiA5////4f/A4J7gjAABAAAAAAAAAAAAAAAAAAAAAAAeADEAYACuAP0BSAFV
AXIBkAGyAccB1QHdAfMCAwIvAj4CZQKjAr8C8QMqAz4DiQPCA84D2gPqA/4EDgRDBKcEwQT5BScFSgVgBXQFqAXBBc4F6gYEBhMGMAZGBncGlwbPBvcHOAdKB2sHgAeeB7oH0QfmB/gIBwgYCCoINwhECHoIsAjb
CREJRQliCagJywnoCg4KJgozCmkKigq7CvELJws9C30Lmwu+C9AL7gwIDB4MMwx1DIEMwwzqDOoNBw03DW8NrQ3UDecORA5pDr0O7A8FDxQPHA9nD3QPnA+1D90QGBAlEEkQYhBrEIgQlxDDENwRBxFBEZcRzBHY
EeQR8BH8EggSFBI4EnsShxKTEp8SqxK3EsMSzxLbEwYTEhMeEyoTNhNCE04TaBOwE7wTyBPUE+AT7BQPFFkUZRRxFH0UiRSVFKEVARVBFU0VWRVlFXEVfBWHFZIVnRXhFe0V+RYFFhEWHRYpFlYWmxanFrMWvxbL
FtcXDRcYFyUXNRdbF4UXlRelF7UXwgAAAAIAWP/6ANICuQADAA8AABMDIwMSJjU0NjMyFhUUBiPDC0wLGyQkGhkjIxkCuf4MAfT9QSQaGiQkGhokAAIAIwJVAQADHAADAAcAABMHIyczByMneQs/DN0LPwwDHMfH
x8cAAgAhAAADEQLkABsAHwAAAQczFSMHIzcjByM3IzUzNyM1MzczBzM3MwczFSMjBzMCdSaKmytXK9IrVyudriabrCtXK9IrVyuL89Im0gHMtFDIyMjIULRQyMjIyFC0AAMAPP+pAg8DFAAkACsAMgAAJAYGBxUj
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
FRQWFjMyNjY1wmtISXdERHdJSGobW1sBdDJVMzJVMzNVMjNVMgHoRUZ/VFOCSEc6/oQD6P7MXlwwMV09Pl0xMV0///8ADP7+AiUC1wAiAFoAAAACAGh9AAABAE0AAACoAiQAAwAAExEjEahbAiT93AIkAAEAEQJV
ASYC8AAFAAATBzU3FxWci4uKAqpVSFNTSAAAAgAPAl8A5QMxAAsAFwAAEgYjIiY1NDYzMhYVJiYjIgYVFBYzMjY15T0uLT4+LS49NR8XFx8fFxcfApg5Oi8vOjkwGh8fGRkgIBkAAAEAEQJdAUcCyAAZAAASNjMy
FhcWFjMyNjczBgYjIiYnJiYjIgYHIxg1KBMbEw4WDREYAzQGNigTHRIQEw0RFwM1ApI2DQwKCxYVMjYNDQoKFhYA//8ALP/6Ah0AdgAjAA8AuwAAACMADwF3AAAAAgAPAAAAAQAtAHgA5gHWAAUAADcnNzMHF41g
YFljY3ivr6+vAAABADIAeADrAdYABQAAEyczFwcjlWNZYGBZASevr68AAAEATAFIAdsBlQADAAABFSE1Adv+cQGVTU0AAAAHAFoAAwABBAkAAACiAAAAAwABBAkAAQAOAKIAAwABBAkAAgAOALAAAwABBAkAAwA8
AL4AAwABBAkABAAeAPoAAwABBAkABQAKARgAAwABBAkABgAeASIAQwBvAHAAeQByAGkAZwBoAHQAIAAyADAAMgAwACAAVABoAGUAIABQAG8AcABwAGkAbgBzACAAUAByAG8AagBlAGMAdAAgAEEAdQB0AGgAbwBy
AHMAIAAoAGgAdAB0AHAAcwA6AC8ALwBnAGkAdABoAHUAYgAuAGMAbwBtAC8AaQB0AGYAbwB1AG4AZAByAHkALwBQAG8AcABwAGkAbgBzACkAUABvAHAAcABpAG4AcwBSAGUAZwB1AGwAYQByAEkAVABGAE8AOwAg
AFAAbwBwAHAAaQBuAHMAIABSAGUAZwB1AGwAYQByADsAIAA0AC4AMAAwADQAYgA4AFAAbwBwAHAAaQBuAHMAIABSAGUAZwB1AGwAYQByADQALgAwADAANABQAG8AcABwAGkAbgBzAC0AUgBlAGcAdQBsAGEAcgAA
AAMAAAAAAAD/tQAyAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAoAHAAeAAFERkxUAAgABAAAAAD//wAAAAAAAAABAAAACgAsAC4AA0RGTFQAFGRldjIAHmRldmEAHgAEAAAAAP//AAAAAAAAAAAAAA==
]],
    fuente_negrita = [[
AAEAAAAMAIAAAwBAR1BPU0R2THUAADfEAAAAIEdTVUIfSCdrAAA35AAAADBPUy8yWdl+MAAAAUgAAABgY21hcCKnIaYAAATIAAAATGdseWZZB22fAAAGqAAAL3RoZWFkIpprkwAAAMwAAAA2aGhlYQh9A5oAAAEE
AAAAJGhtdHi++iZoAAABqAAAAyBsb2NhFVMKJQAABRQAAAGSbWF4cAFBAKYAAAEoAAAAIG5hbWUgPTeGAAA2HAAAAYZwb3N0/7gAMgAAN6QAAAAgAAEAAAAEAQZjLyqGXw889QADA+gAAAAA2KSpwgAAAADm330u
/+T+8AQYA8kAAAAHAAIAAAAAAAAAAQAABBr+ogBkBD3/5P/yBBgAAQAAAAAAAAAAAAAAAAAAAMgAAQAAAMgASAAFAD0ABAABAAIAHgAGAAAAZAAAAAMAAgAEA1sB9AAFAAACigJYAAAASwKKAlgAAAFeADIBSgAA
AAAGAAAAAAAAAAAAAAMAAAAAAAAAAAAAAABJVEZPAMAAICA6BBr+ogBkBG8CcwAAAAEAAAAAAicCuQAAACAABAH0AAABBAAAAUEAWAFDACIDaAAfAooAPAMaACoC+QAjAKwAIgHsAHwB7AAbAfgAPwLKAGYA4QAF
AkkAVwDxADACAgA9AoEAPAFeAC0CQQAyAlIAMAKHAC4CfwBKAoIASgIwACgCfgA9AnsATQD1ADABMAAgAmQAYgMGAHkCTgBwAhoAKAQBAEYCuQAiAnYASwMFACUCxQBLAgwASwIDAEsDBQAlAsEASwEIAEsCNAAs
AnkASwG8AEsDcgBLAtEASwMQACUCUwBLAxMAJQJ4AEsCXAA6AjQAJwKyAEoCtgATA+cAEwKUADICXQAPAi4AMgHlAJQCzQCkAeQAgAKOACQDHgB+AP4ACgKmACUCpgBLAlgAJQKmACUCaQAlAUwAGAKmACUCiQBL
AQgAPAEI/+QCKgBLAQgASwQPAEsCiQBLAn4AJgKmAEsCpgAlAYAASwIWAC0BdAAcAokARgJAAAoDOQAKAfMACgJGAAoB1wAsAgQAfgFEAGkCBABaAikAJAEEAAABQQBYArIAQgKGACoCJAA8Al0ADwFEAGkCQgAp
ATgACgMVAC4ByAAfAekALQKJACUCSQBXAgUAMgGCAAoBqwAcAs0AaAFUABsBVgASAPEACgKOAEsCdgAjAPQANAEXAAoA0QAUAbwAHwHpADICqgAiAr0AIgLmACECGgAzArkAIgK5ACICuQAiArkAIgK5ACICuQAi
A5kADAMFACUCDABLAgwASwIMAEsCDABLAQgADgEIAA4BCP/1AQj/8gLQAAkC0QBLAxAAJQMQACUDEAAlAxAAJQMQACUCuwB7AxAAGgKyAEoCsgBKArIASgKyAEoCXQAPAlMASwK7ADYCpgAlAqYAJQKmACUCpgAl
AqYAJQKmACUEPQAlAlgAJQJpACUCaQAlAmkAJQJpACUBCAAOAQgADgEI//UBCP/yAnwAJQKJAEsCfgAmAn4AJgJ+ACYCfgAmAn4AJgKnAFoCfgAcAokARgKJAEYCiQBGAokARgJGAAoCpgBLAkYACgEIAEsBMgAK
AO4ABwFkAAoCfgAwASkALQEpADICSQBXAAAAAgAAAAMAAAAUAAMAAQAAABQABAA4AAAACgAIAAIAAgB+AP8gJiA6//8AAAAgAKAgJiA5////4f/A4J7gjAABAAAAAAAAAAAAAAAAAAAAAAAeADEAYQCuAPIBOQFG
AWMBgQGjAbgBxgHOAeQB9AIgAi8CWQKXArIC5AMfAzMDfQO1A8EDzQPdA/EEAQQ2BJsEtQTsBRoFPQVTBWcFmwW0BcEF3QX3BgYGIgY4BmkGjAbEBuwHLQc/B2AHdQeTB60HwwfYB+oH+QgKCBwIKQg2CGwIogjM
CQIJNAlRCZcJugnXCf0KFAohClcKegqpCt8LFQssC2wLigutC78L3Qv3DA0MIQxmDHIMtwzhDOEM/g0uDWQNog3JDdwOOQ5eDrQO4w78DwsPEw9dD2oPkw+sD9YQERAeEEEQWxBkEIEQkBC8ENURABE7EZERxhHS
Ed4R6hH2EgISDhIyEnUSgRKNEpkSpRKxEr0SyRLVEwATDBMYEyQTMBM8E0gTYhOqE7YTwhPOE9oT5hQMFFYUYhRuFHoUhhSSFJ4U/BU6FUYVUhVeFWoVdRWAFYsVlhXcFegV9BYAFgwWGBYkFlEWkhaeFqoWthbC
Fs4XBBcQFx0XLRdTF30XjRedF60XugAAAAIAWP/5AOkCtwADAA8AABMDIwMSJjU0NjMyFhUUBiPaDV8NISoqHx4qKh4Ct/4bAeX9QiofHyoqHx8qAAIAIgJQASADHQADAAcAABMHIyczByMniQxODf4MTg0DHc3N
zc0AAgAfAAADLALkABsAHwAAAQczFSMHIzcjByM3IzUzNyM1MzczBzM3MwczFSEjBzMCkiWEmShtKMQobSibsCWarydtJ8QnbSeF/vnEJcQByq1kubm5uWStZLa2trZkrQAAAwA8/6kCIAMQACQAKwAyAAAkBgYH
FSM1JiY1MxYWFzUuAjU0Njc1MxUWFhcjJiYnFR4CFQAWFzUGBhUSNjU0JicVAiAxX0FBXnR6AywpQ1Q7dF5BWGsHegMqI0NUOv6QMS0rM8syMS2UWDwGUVEJZFInMwfcESNMQlNtCVFRCF9THzEJ2BAjS0IBDS4O
ygU0LP5jOSgoLQ7LAAUAKv/zAvACxQALAA8AGAAkACwAABI2MzIWFRQGIyImNSUBIwEEFRQzMjY1NCMSNjMyFhUUBiMiJjU2FRQzMjU0IypVQ0NVVUNDVQJi/nFwAY/+Zz8eIT//VUNCVVVCQ1VYPz8/AnJTU0lJ
VFRJj/1IArg4V1grLVf+WVNTSUlUVElXV1dXVwACACP/8wL5AscAJgAuAAAhJwYGIyImJjU0NjcmJjU0NjYzMhYWByM2JiMiBhUUFhcXNzMHBxckNycGFRQWMwJkVjJ2SUpyPlJRHRgvWDo7UykEcgEmISEpHye4
R3taGan+gki4dkw8VjIxNGFASHEhIz0lLkgqLU4wJSknHBs1Krd1mimoVE25L18zRQAAAQAiAlAAiQMdAAMAABMHIyeJDE4NAx3NzQABAHz/RgHRA6YADwAAFgI1NBI3MxUGAhUUEhcVI+VpcW52c3RsZ3ZcASKm
qgEuYgtq/tidl/7magsAAQAb/0YBcAOmAA8AABc1NhI1NAInNTMWEhUUAgcvZ2x0c3ZucWliugtqARqXnQEoagti/tKqpv7eXgAAAQA/AWgBtQLgABEAAAEXBxcHJxcjNwcnNyc3FyczBwGILYmJLnIVXBNyMIiI
LnUUXRYCp1AzM1JakZFcVTMxUlqSkgABAGYAagJkAmgACwAAASMVIzUjNTM1MxUzAmTKasrKasoBOc/PYM/PAAABAAX/dQDIAIkAAwAANwMjE8h5SkeJ/uwBFAD//wBXAToB8gGaAAIAxwAAAAEAMP/5AMEAiwAL
AAAWJjU0NjMyFhUUBiNaKiofHioqHgcqHx8qKh8fKgAAAQA9/1EBvQOwAAMAAAEBIwEBvf7wcAEPA7D7oQRfAAACADwAAgJEAuYACwAbAAASNjMyFhUUBiMiJjUkJiYjIgYGFRQWFjMyNjY1PHWPj3V1j491AZgV
QD8/QBUUQT8/QRQCI8PDra/Fxa9RcEdHcFFUckZGclQAAQAtAAAA/QLZAAUAABM1MxEjES3QcwJxaP0nAnEAAQAyAAoCGQLoABoAADc+AjU0JiMiBgcjNjYzMhYVFAYGBwchFSE1e2BvSjk9O0ECbgODZW17SWVO
LQE9/hqbU2t0OjxESz9yeXhkSIVpRShfUwAAAQAw//wCFgLqACsAABI2MzIWFhUUBgcVFhYVFAYGIyImJzMWFjMyNjU0JiMjNTM2NjU0JiMiBgcjQINmRmY0Qi47QjZqSmyLBW4ESj89QllcGhtRVT45OD4GbwKC
aDJWNj5YDwQSX0o7XDVvaDVDQzVGO14BNDgwOTkqAAIALgAAAmUC0AAKAA0AADc1ATMRMxUjFSM1EwMzLgFQil1dcAXs7JhWAeL+K2OYmAHE/p8AAAEASgAAAkQC2wAgAAABIRU2NjMyFhYVFAYGIyImJzMWFjMy
NjU0JiMiBgcjESECEv6xFVMvVGktOXFSbYQNbwtMOUdHSEYxQw9sAbgCd8ccJkhuPUpzQmxZLzdWR0hNMSoBpQACAEoAAAJEAusAGgAmAAAAJiMiBgc2NjMyFhYVFAYGIyImJjUQITIWFyMGBhUUFjMyNjU0JiMB
uTo0T04CGmQ6QmU5N2xMZ3UvAQJkcwpptlVPRz9JR0UCXi55jCwwOWxLRm4/W6Z8AW5sT61JRUVRTkFEUQAAAQAoAAACCgLWAAYAAAEBIwEhNSECCv7qcwEZ/o4B4gKB/X8CdWEAAAMAPf/uAkIC5gAaACYAMgAA
EjU0NjYzMhYWFRQGBxYWFRQGBiMiJiY1NDY3JCYjIgYVFBYzMjY1BgYVFBYzMjY1NCYjTzZsTk1tNjkvOUJCdktLdUJCOAELRj08Rkk5OUrFU1BFRE9RQgGxcDZaNTVaNjhVFxVfQEFkNjZkQUFeFc48PDkyP0Ay
yEE9OUdIODxCAAACAE0AAQI6AuoAGgAmAAA2FjMyNjUGBiMiJiY1NDYzMhYVFAYGIyImJzM2NjU0JiMiBhUUFjPUQjhHQhhXM0FqPYFxiHMral5rdAdpu0VJPz9JR0iUNHCHIiU1aUtug7W7gaRUcFWqSz5FTU9A
PU///wAw//kAwQIvACIADwAAAAcADwAAAaT//wAg/3UA4wIvACcADwAWAaQAAgANGwAAAQBiAIYB2AJMAAUAACUnNzMHFwFI5uaQ5+eG4+Pj4wACAHkAyAKNAgsAAwAHAAABFSE1BRUhNQKN/ewCFP3sAgtgYONg
YAAAAQBwAIYB5gJMAAUAABMzFwcjN3CQ5uaQ5wJM4+PjAAACACj/+QHnAsEAFwAjAAAAFhUUBiMHIyczMjY1NCYjIgYVIzQ2NjMCJjU0NjMyFhUUBiMBbHuAagRjBSFhZz02Nj5rNmVDXyoqHx4qKh4CwXBhZWZP
nTRJNTw6NDxeNP04Kh8fKiofHyoAAgBG/zUDuwKGADkARwAAABYWFRQGBiMiJicGBiMiJjU0NjYzMhc3MwMGFRQWMzI2NjU0JiMiBgYVFBYzMjcXBiMiJiY1NDY2MwI2NjU0JiMiBgYVFBYzAr6mVzdnRjM6Bx9e
M01XP3JHVyMJYzIDFRsmNhuUjXa7apiNX0cPW3FtpFqF7JVMRSg1MCtBIy4vAoZUl2RQklwtKSguXVBMhE87Mv7iFRAaGktuNH+GcMR4gIYjTCdSl2SP7In9yzFRLjA9NVQuLzcAAAIAIgAAApgCuAAHAAoAACUh
ByMTMxMjJwMDAe7+3TJ3+YT5eFJxco6OArj9SOsBQ/69AAADAEsAAAJFArcAEAAZACIAAAAWFRQGBiMhESEyFhYVFAYHJTMyNjU0JiMjEjY1NCYjIxUzAfdON2hF/uoBCUdmNEA2/v6NOD8/OI3UQkY6lpoBW2I+
NVUxArcwUTI8UBMuMzAvNf4DODIzPNkAAAEAJf/6AssCwAAdAAASNjYzMhYXIyYmIyIGBhUUFhYzMjY3MwYGIyImJjUlX6Nhb60niRtgP0VsPT1sRT9gG4knrW9iol8Bw6JbbWQ3Nj50TU10PzY3ZGxbomYAAgBL
AAACnwK3AAoAEwAAABYWFRQGBiMjETMSNjU0JiMjETMBnadbW6dv4+N6goJ6cXECt1WfamqcUwK3/aaEeHmI/gMAAAEASwAAAcsCuAALAAATFTMVIxUhFSERIRW98PABDv6AAYACW8xd1V0CuF0AAQBLAAAB5AK3
AAkAAAEVIRUzFSMRIxEB5P7Z5uZyArddzV3+0AK3AAEAJf/6AuACwAAhAAABJiYjIgYGFRQWFjMyNjchNSEVDgIjIiYmNTQ2NjMyFhcCQhtgP0VsPT1sRV10Df77AX8LXZVbYqJfX6Nhb60nAe80NT5yS0tzPmhZ
W1lRiFFbomZmolttZAAAAQBLAAACdgK3AAsAAAERIxEhESMRMxEhEQJ2cv65cnIBRwK3/UkBMP7QArf+1gEqAAABAEsAAAC9ArcAAwAAExEjEb1yArf9SQK3AAEALP/5AcYCtwAPAAABERQGIyImNTMWFjMyNjUR
AcZxXFxxcwEtLCwuArf+C11sbF0uNjctAfUAAQBLAAACXwK3AAoAACEBESMRMxEBMwEBAcr+83JyAQ6P/tIBMwE3/skCt/7DAT3+pP6lAAEASwAAAagCtwAFAAA3MxUhETO96/6jclxcArcAAAEASwAAAycCtwAM
AAABESMRAyMDESMRMxMTAydy1E/Vcnv08wK3/UkB3P4kAdz+JAK3/d8CIQAAAQBLAAAChgK4AAkAACEjAREjETMBETMChnL+qXJyAVdyAgf9+QK4/foCBgACACX/+QLrAsAADwAfAAAEJiY1NDY2MzIWFhUUBgYj
PgI1NCYmIyIGBhUUFhYzASejX1+jYWKjXl6jYkVsPT1sRUVsPT1sRQdbo2ZmoltbomZmo1tjP3VNTXQ+PnRNTXU/AAIASwAAAjECtwAMABQAAAAGBiMjESMRMzIWFhUGNjU0IyMVMwIxMm5WfnLwUG83tUCBfn4B
s147/uYCtzdeOnE7NnLjAAACACX/ggL2AsAAEwAjAAAFJwYjIiYmNTQ2NjMyFhYVFAYHFwAWFjMyNjY1NCYmIyIGBhUCZXotNmGjX1+jYWKjXlNJp/2kPWxFRWw9PWxFRWw9foQNW6NmZqJbW6JmYJsvsQGOdT8/
dU1NdD4+dE0AAgBLAAACPAK3AA4AFwAAIQMjESMRMzIWFhUUBgcTATMyNjU0JiMjAbSgV3LwUG83T1Ks/oF+QEFAQX4BFv7qArc4XjpEbxT+4AFxQDY2PQABADr/+QIgAsAALAAAFiYmNTMWFjMyNjU0JiYnLgI1
NDY2MzIWFyMmJiMiBhUUFhYXHgIVFAYGI+pwQHoEPzk7Qik9NkRVPDxsR2WBB34DQjYxPic8NEVXPTltSgcxWjwtOjktIywYDhIlTkE8WjBlWCY2Mi8gKRgOEyZPQjVeOQAAAQAnAAACDAK3AAcAAAEVIxEjESM1
Agy5croCt139pgJaXQAAAQBK//kCaQK3ABMAABMRFBYzMjY1ETMRFAYGIyImJjURvFNKS1NySnxLS3tIArf+RU9QUE8Bu/5HVXY6OnZVAbkAAQATAAACogK3AAYAAAEBIwEzExMCov77hP76es7PArf9SQK3/b4C
QgAAAQAT//8D1AK3AAwAAAEDIwMDBwMzExMzExMD1M6BkpuAxXmQnICRkQK3/UkCDv3yAQK4/coCNv3NAjMAAQAyAAACYwK3AAsAAAETIycHIxMDMxc3MwGK2ICdk3/Y2YCelH8BW/6l/PwBWwFc/v4AAAEADwAA
Ak4CtwAIAAABAxUjNQMzExMCTuZy53+hoQK3/kX8/AG7/qsBVQAAAQAyAAAB/AK3AAkAADchFSE1ASE1IRW5AUP+NgFC/r4BymNjWQH7Y1kAAQCU/0YBZAOmAAcAAAEVIxEzFSMRAWRlZdADpl78XV8EYAAAAQCk
/1ECQAOwAAMAAAUBMwEB0P7UcAEsrwRf+6EAAQCA/0YBUAOmAAcAAAUjNTMRIzUzAVDQZWXQul8Do14AAAEAJACoAmsCuAAGAAA3IxMzEyMDmnbtbO53rKgCEP3wAYYAAAEAfv9uAqz/2AADAAAFFSE1Aqz90ihq
agAAAQAKAk4A5wMcAAMAABMVJzXn3QKiVG1hAAACACX/9wJbAjAAEgAiAAASNjYzMhYXNTMRIzUGBiMiJiY1JCYmIyIGBhUUFhYzMjY2NSVFd0hBYR1zcx1kQEd2RQHDL0wsLEwvL00rLEwvAWmARzMmUP3ZUic0
SYNTN1QsK1M5OVYtLFU5AAACAEv/9wKAAuQAEgAiAAASNjMyFhYVFAYGIyImJxUjETMRBCYmIyIGBhUUFhYzMjY2NdplPkl2RER3SEBjHXJyAU8vTSwrTS8vTSssTS8B/TNGgVNTg0kyJ1AC5P7xhlMrLFQ5OVUs
LVY5AAABACX/9wIxAjAAGgAAEjY2MzIWFyMmJiMiBhUUFjMyNzMGBiMiJiY1JUV6T2SDF3sPQjJGU1NGYyB7GIRiT3pFAWmBRl9YKS5jWVlkV1RjR4FVAAACACX/9wJbAuQAEgAiAAASNjYzMhYXETMRIzUGBiMi
JiY1JCYmIyIGBhUUFhYzMjY2NSVFd0k2aR9zcxxjQEh3RQHDL0wsLEwvL00rLEwvAWmARy8nAQr9HFMoNEmDUzdULCtTOTlWLSxVOQACACX/9wJEAjAAFwAeAAAAByEWFjMyNzMGBiMiJiY1NDY2MzIWFhUnJiYj
IgYHAkQE/lsFWEBcJnsZg2FPfUdFfVFOekR3AVhBO1QIAQIZQlBNTGFHgVVVgUZEe1AkP0xLQAAAAQAYAAABMgMEABEAAAEjESMRIzUzNTQ2MxUiBhUVMwEyZnNBQWVsNCpmAcr+NgHKXSdfV18nMCcAAAIAJf7w
AlsCMAAfAC8AAAAWFzUzERQGBiMiJiczFhYzMjY1NQYGIyImJjU0NjYzFiYmIyIGBhUUFhYzMjY2NQFpYxxzQHlUcJQKcQ1VO0VVHWM/SHdFRXdIvy9MLCxMLy9NKyxMLwIwMyZQ/dBMd0RpWis1VFBcJzVJg1NT
gEfjVCwrUzk5Vi0sVTkAAQBLAAACQwLkABQAAAAWFhURIxE0JiMiBhURIxEzFTY2MwGnYzlxSkBAS3JyHVk1AjA2akv+uwE0Sk9PSv7MAuT9IyYAAAIAPAAAAM0DAgALAA8AABImNTQ2MzIWFRQGIxcRIxFmKiof
HioqHjhyAnAqHx8qKh8fKkn92QInAAAC/+T++gDNAwIACwAXAAASJjU0NjMyFhUUBiMTFAYjIzUzMjY1ETNmKiofHioqHjhRTTsnIx1yAnAqHx8qKh8fKv0kUUlgGx8CkwAAAQBLAAACIwLkAAoAAAETIycVIxEz
ETczASX+msxycsieARP+7e3tAuT+UvEAAAEASwAAAL0C5AADAAATESMRvXIC5P0cAuQAAQBLAAADyQIwACMAAAAWFhURIxE0JiMiBhURIxE0JiMiBhURIxEzFTY2MzIWFzY2MwMnZztxSkBAS3FKQEBLcnIcVjFC
aBwZaj0CMDZqS/67ATRKT09K/swBNEpPT0r+zAInPyImODUyOwAAAQBLAAACQwIwABQAAAAWFhURIxE0JiMiBhURIxEzFTY2MwGiZzpxSkBAS3JyHFcxAjA2akv+uwE0Sk9PSv7MAic/IiYAAAIAJv/3AlgCMAAP
AB4AABYmJjU0NjYzMhYWFRQGBiM+AjU0JiYjIgYGFRQWM+x+SEqAT0+ASkyDTyxNMC5MLCxLLFtFCUeBVVSCRkaCVFSCR2MqVDw8UyoqUzxZYQACAEv++gKAAjAAEgAiAAASNjMyFhYVFAYGIyImJxEjETMVBCYm
IyIGBhUUFhYzMjY2NdpkP0h3RER3SD9iH3JyAU8vTSwrTS8vTSssTS8B/DRHgFNTg0kzJv6qAy1Rh1MrLFQ5OVUsLVY5AAACACX++gJbAjAAEgAiAAASNjYzMhYXNTMRIxEGBiMiJiY1JCYmIyIGBhUUFhYzMjY2
NSVFd0lAYxtzcxtmQUd1RQHDL0wsLEwvL00rLEwvAWmARzQlUPzTAVYlNEmDUzdULCtTOTlWLSxVOQABAEsAAAFiAjAADAAAEjYzFSMiBhURIxEzFdZTOR1DRXJyAgEvdkRU/t4CJ1AAAQAt//cB5gIwACsAABYm
JiczFhYzMjY1NCYnLgI1NDY2MzIWFyMmJiMiBhUUFhYXHgIXFAYGI9JnPAJ2Az0uMDU7QD5OOTRhP15zBHIDNi4tMCAuLTxNOAE0X0AJL1EyIy8lHR8eEhEgQjYsSSpfUiUsIhwWHhENECFANS9KKgABABwAAAFW
ArAAEwAAExEUFjMzFSMiJjURIzUzNTMVMxXQHSNGWk1SQUFzhgHK/s8fG19IUQExXYmJXQABAEb/+AI+AicAFAAAAREjNQYGIyImJjURMxEUFjMyNjURAj5yG1cxQWc7cUpAQEsCJ/3ZQSInNmpLAUT+zUpPT0oB
MwAAAQAKAAACNQInAAYAACUTMwMjAzMBIJx50ojRemYBwf3ZAicAAQAKAAADLwInAAwAAAEDIwMDIwMzExMzExMDL6t4b294rHRzdXdwcgIn/dkBl/5pAif+RQG7/kcBuQAAAQAKAAAB6QInAAsAAAETIycHIxMD
Mxc3MwE3soF3cHeysoF3cHcBF/7pu7sBDwEYu7sAAAEACv79AjsCJwAHAAABASMTAzMTEwI7/q52cNl/m6ECJ/zWAQwCHv5cAaQAAQAsAAABqgInAAkAADczFSE1EyM1IRWw+v6C+/sBfl1dXQFtXV0AAAEAfv9E
AaoDqAAxAAATNjY1NCcmNTQ2MzMVIyIGFRQWFxYVFAYHFRYWFRQHBgYVFBYzMxUjIiY1NDc2NTQmJ34wMwgJU0RDLCAfBgEJMzU1MwkBBh8gLENEUwkIMzABoQUwJyRgWjZHUGMdIBhQEVw6M0QLAgtEMzpcEVAY
IB1jUEc2WmAkJzAFAAEAaf+PANsDIQADAAAXIxEz23JycQOSAAEAWv9EAYYDqAAxAAAABhUUFxYVFAYjIzUzMjY1NCYnJjU0Njc1JiY1NDc2NjU0JiMjNTMyFhUUBwYVFBYXFQFWMwgJU0RDLCAfBgEJMzU1MwkB
Bh8gLENEUwkIMzABRjAnJGBaNkdQYx0gGFARXDozRAsCC0QzOlwRUBggHWNQRzZaYCQnMAVWAAEAJADsAgUBkwAZAAASNjMyFhcWFjMyNjczBgYjIiYnJiYjIgYHIzNSPhwrHBkdEhknBFMPUz4cKhwWIBIaJwRS
AUJREhIPDiEeVFESEg8OIR4AAAIAWP95AOkCNwALAA8AABIWFRQGIyImNTQ2MwczEyO/KioeHyoqHzNfDXkCNyofHyoqHx8q2f4bAAABAEL/qAI1Al8AHwAAJDY3MwYGBxUjNSYmNTQ2NzUzFRYWFyMmJiMiBhUU
FjMBf0AMaghuVkFvd3dvQVZuCGoMQDZHVFRHXCsnRmAJV1cKkGpqkQpXVwlgRicrWk5OWQABACr//gIuAtEAJQAAJRUhJzY2NTQnIzUzJjU0NjYzMhYXIzQmIyIGFRQWFzMVIxYVFAcCLv4xFCooBW5VFTpmQ2tu
Amg4OzZBDAvCqwVDW10+LVlCFBZPPztDYjV4XTY/PkIdNiFPFxRhRwACADwApAHoAlAAGwAnAAAABxcHJwYjIicHJzcmNTQ3JzcXNjMyFzcXBxYVBjY1NCYjIgYVFBYzAcwfOzI+LDw5LDwzOh0fPDM+LTg5LT4y
Ox+WNzYmJjQzJgE9KzszPRoZPDM7Kzw+KzszPhkZPjM7LTxrOTIzOTkzMzgAAQAPAAACTgK3ABgAAAEzFQcHFTMVIxUjNSM1MzUnJzUzAzMTEzMBsn6pH8jIcsjIH6l9nH+goIABi1ICOx5SjIxSHjsCUgEs/q0B
UwAAAgBp/48A2wMhAAMABwAAEzMRIxMjETNpcnJycnIDIf58/fIBhAACACn/LAIZArwANQBBAAAkFhUUBgYjIiY1MxYWMzI2NTQmJicmJjU0NjcmJjU0NjYzMhYVIyYmIyIGFRQWFhcWFhUUBgckFjMyNjU0JiMi
BhUByi40YUFddXIDMC0wNBtBQWJePzwrLzRhQV11cgMwLTA0G0FBYl49Pf7/STw7Rkk7O0c7PSwtTC1XTiguJyYXISEXI1ZDNlQWGT0sLUwtV04oLicmFyEhFyNWQzVSGXU9PCwsPDwsAAACAAoCbAEuAuQACwAX
AAASJjU0NjMyFhUUBiMyJjU0NjMyFhUUBiMtIyMZGSMjGZMjIxkZIyMZAmwjGRkjIxkZIyMZGSMjGRkjAAMALv/3AucCwAAPAB8AOwAAABYWFRQGBiMiJiY1NDY2Mw4CFRQWFjMyNjY1NCYmIw4CFRQWFjMyNjcj
BgYjIiY1NDYzMhYXMyYmIwHxnlhYnmZmn1hYn2Zbh0lJh1tah0lJhltAZDk6Yz1MbhNoDTAoNUBANSY1CmgTbE4CwFuiZ2ejW1ujZ2eiWy5MjV1djE5OjF1djUxQOWhERGk5UUIgIk1ISEwiIEZNAAACAB8BWwGe
AsUAEgAeAAASNjYzMhYXNTMRIzUGBiMiJiY1FhYzMjY1NCYjIgYVHy1NLitAE1lZEUAqME4tXDwpKjs7Kik8AkZRLh4YMP6iLhcdL1Q0NT08NDQ8OzQAAgAtAHgBtwHWAAUACwAANyc3MwcXMyc3MwcXiVxcbmBg
UlxcbmBgeK+vr6+vr6+vAAABACUA0AJdAbMABQAAARUjNSE1Al1y/joBs+OKWf//AFcBOgHyAZoAAgAOAAAABAAyAR8B0wLBAA8AGwApADIAAAAWFhUUBgYjIiYmNTQ2NjMSNjU0JiMiBhUUFjM2BgcXIycjFSM1
MzIWFQczMjY1NCYjIwE/XzU1Xzw8XzY2XzxIV1dISVZWSVwWEzVMLAc/ZSMqcyIICwsIIgLBNl88PF82Nl88PF82/oxaSUlaWklJWrUhCFJLS9cnHxMJCAgIAAEACgJ7AXgC0AADAAABFSE1AXj+kgLQVVUAAgAc
AVsBjwK+AA0AGQAAEjYzMhYWFRQGBiMiJjUkJiMiBhUUFjMyNjUcaFI1VDAxVjVSZQEYOCgnNzUoKDkCXWErUTU1USxiUDU7OzU2OTo1AAEAaAB/AmUCbQAPAAABFTMVITUzNSM1MzUzFTMVAZzJ/gPKyspqyQF0
lWBglWCZmWAAAQAbAWABKgLHABkAAAEVITU3NjY1NCYjIgYHIzY2MzIWFhUUBgcHASr+82whIRkTEhYCWgJHPik9ISszSQGoSEJPGiwaFxsUEjA6IDQeJDgiLwAAAQASAVsBNQLHACkAABI2MzIWFhUUBgcVFhYV
FAYjIiYnMxYWMzI2NTQmIyM1MzI2NTQmIyIHIxpOPiZBJSIbHCRTQEBOAlgEHBcXHR4YJSIZHRsYKgpVAo45HDAdHicIAgopHio5OzMWFhgVFBc6FhQUFyMAAAEACgJOAOcDHAADAAATBzU3593dArttVHoAAQBL
/voCQwInABQAAAERIzUGBiMiJxEjETMRFBYzMjY1EQJDchtbOjwpcXFKQEBLAif92VcvMB/+4wMt/sxKT09KATQAAAEAIwAAAisCtwAOAAAhIxEjESMRIyImNTQ2MyECK2VDZQ52d3h1ARsCXv2iARpzW1t0AP//
ADQBBgDFAZgABwAPAAQBDQABAAr++gENAAcAEgAAFhYVFAYjIzUzMjY1NCYjIzUzFcVISDeEbRwcHBw3SzA3MjI7SBAVFRB7NwAAAQAUAWAAowLAAAUAABM1MxEjERSPWQJ8RP6gARwAAgAfAVsBnQLFAA8AGwAA
EjY2MzIWFhUUBgYjIiYmNSQmIyIGFRQWMzI2NR8yVzY2VzIzWDY2VjEBIjspKTk4KSk8AkZSLSxTNjVTLS1SNjQ8OzY0OjszAAIAMgB4AbwB1gAFAAsAABMnMxcHIyUnMxcHI5FfbV1dbQEfX21dXW0BJ6+vr6+v
r68ABAAiAAACgwLAAAUACQAUABcAABM1MxEjESUBIwETIxUjNSM1NzMVMycHMyKPWQHR/oJsAX/FLVm6l3wthGNjAnxE/qABHDz9SAK4/YtDQzLs5qKiAAADACL//wKRAsAABQAJACMAABMjNTMRIwEBIwETFSE1
NzY2NTQmIyIGByM2NjMyFhYVFAYHB1g2j1kBxv6NbAFz3/7zbCEhGRMSFgJaAkc+KT0hKzNJAnxE/qABWP1IArj9j0hCTxosGhcbFBIwOiA0HiQ4Ii8ABAAhAAACzALHACkALQA4ADsAABI2MzIWFhUUBgcVFhYV
FAYjIiYnMxYWMzI2NTQmIyM1MzI2NTQmIyIHIyUBIwETIxUjNSM1NzMVMycHMylOPiZBJSIbHCRTQEBOAlgEHBcXHR4YJSIZHRsYKgpVAmP+bmsBkq8tWbqXfC2EY2MCjjkcMB0eJwgCCikeKjk7MxYWGBUUFzoW
FBQXI1f9SAK4/YtDQzLs5qKiAAIAM/9pAfICMQALACMAAAAWFRQGIyImNTQ2MwImNTQ2MzczFyMiBhUUFjMyNjUzFAYGIwFzKiofHioqHqZ7gGoEYwUhYWc9NjY+azZlQwIxKh8fKiofHyr9OHBhZWZPnTRJNTw6
NDxeNP//ACIAAAKYA60AIgAiAAAABwBBAN0Akf//ACIAAAKYA60AIgAiAAAABwB0AN0Akf//ACIAAAKYA4sAIgAiAAAABwDBAMQAkf//ACIAAAKYA2YAIgAiAAAABwDDALAAkf//ACIAAAKYA3UAIgAiAAAABwBo
AMEAkf//ACIAAAKYA8kAIgAiAAAABwDCAOYAkQACAAwAAANXArgADwASAAABFTMVIxUhFSE1IQcjASEVAREDAkrv7wEN/oH+/U18AX8BzP6B0gJf01jbWY6OArhZ/ogBgv5+AAABACX++gLLAsAALwAAJDY3MwYG
BxUyFhUUBiMjNTMyNjU0JiMjNS4CNTQ2NjMyFhcjJiYjIgYGFRQWFjMBx2AbiSSYZDpISDeEbRwcHBw3WJBTX6Nhb60niRtgP0VsPT1sRV02N1xrCCs3MjI7SBAVFRBwCV6bX2aiW21kNzY+dE1NdD8A//8ASwAA
AcsDrQAiACYAAAAHAEEAhgCR//8ASwAAAcsDrQAiACYAAAAHAHQAhgCR//8ASwAAAcsDiwAiACYAAAAHAMEAbQCR//8ASwAAAcsDdQAiACYAAAAHAGgAagCR//8ADgAAAOsDrQAiACoAAAAHAEEABACR//8ADgAA
AOsDrQAiACoAAAAHAHQABACR////9QAAARMDiwAiACoAAAAHAMH/6wCR////8gAAARYDdQAiACoAAAAHAGj/6ACRAAIACQAAAqoCtwAOABsAAAAWFhUUBgYjIxEjNTMRMxI2NTQmIyMVMxUjFTMBqaZbW6Zv5E1N
5HmCgnlxsrJxArdVn2pqnFMBJWkBKf2ginh5ic1pzgD//wBLAAAChgNmACIALwAAAAcAwwC8AJH//wAl//kC6wOtACIAMAAAAAcAQQEIAJH//wAl//kC6wOtACIAMAAAAAcAdAEIAJH//wAl//kC6wOLACIAMAAA
AAcAwQDvAJH//wAl//kC6wNmACIAMAAAAAcAwwDbAJH//wAl//kC6wN1ACIAMAAAAAcAaADsAJEAAQB7AIoCPwJLAAsAACUnByc3JzcXNxcHFwH2mJhLmZVJlZVLlZeKmJhLmJVJlZVLlZgAAAMAGv/5AvYCwAAZ
ACIAKwAAARYWFRQGBiMiJicHIzcmJjU0NjYzMhYXNzMAFwEmIyIGBhUkJwEWMzI2NjUCkyouXqNiPW8tOltkKi9fo2E9cC05W/2kLgFTP1RFbD0B3C3+rTxWRWw9Ak0ve0Zmo1skIj9sMHtGZqJbJCI+/khEAXEv
PnRNXkH+kDA/dU0A//8ASv/5AmkDrQAiADYAAAAHAEEA2QCR//8ASv/5AmkDrQAiADYAAAAHAHQA2QCR//8ASv/5AmkDiwAiADYAAAAHAMEAwACR//8ASv/5AmkDdQAiADYAAAAHAGgAvQCR//8ADwAAAk4DrQAi
ADoAAAAHAHQArwCRAAIASwAAAjECuAAOABcAAAAGBiMjFSMRMxUzMhYWFQY2NTQmIyMVMwIxMm5WfnJxf1BvN7VAQEF+fgEnXjuOAriNN146dT43Nz/rAAABADb/9gKFAwUAMwAAEjYzMhYWFRQGBwYGFRQWFxYW
FRQGIyImJzMWFjMyNTQmJyYmNTQ2NzY2NTQmIyIGFREjETZ8fEloNTEqFxUrPktEbF5bcQd0AjAtVSc0UkklJSAePzdHPXICjncxTi00QyMVFw0SHRUZUT1KW2BXKzFBIScRGz8xIzQjHikZKS1CQf3dAjL//wAl
//cCWwMcACIAQgAAAAMAQQDTAAD//wAl//cCWwMcACIAQgAAAAMAdADTAAD//wAl//cCWwL6ACIAQgAAAAMAwQC6AAD//wAl//cCWwLVACIAQgAAAAMAwwCmAAD//wAl//cCWwLkACIAQgAAAAMAaAC3AAD//wAl
//cCWwM4ACIAQgAAAAMAwgDcAAAAAwAl//cEGAIwACoAMQBBAAAAByEeAjMyNjczBgYjIiYnFSM1BgYjIiYmNTQ2NjMyFzUzFTY2MzIWFhUnJiYjIgYHBjY2NTQmJiMiBgYVFBYWMwQYBP5JBjJHJTdHDnwZf1w8
aiFiImU8SHdFRXpLeEhfKmA9S3ZCdgFbRD5dCvBMLy9MLCxMLy9NKwEGGS9EIyojTGEzKVNTKTNJg1NTgUZXTk4uKUV7TRxBUFBB5SxVOTlULCtTOTlWLQABACX++gIxAjAALAAAJDczBgYHFTIWFRQGIyM1MzI2
NTQmIyM1LgI1NDY2MzIWFyMmJiMiBhUUFjMBliB7FnFVOkhIN4RtHBwcHDdEaDlFek9kgxd7D0IyRlNTRldXTGEIKTcyMjtIEBUVEG4IS3lOVYFGX1gpLmNZWWT//wAl//cCRAMcACIARgAAAAMAQQC1AAD//wAl
//cCRAMcACIARgAAAAMAdAC1AAD//wAl//cCRAL6ACIARgAAAAMAwQCcAAD//wAl//cCRALkACIARgAAAAMAaACZAAD//wAOAAAA6wMcACIAwAAAAAIAQQQA//8ADgAAAOsDHAAiAMAAAAACAHQEAP////UAAAET
AvoAIgDAAAAAAgDB6wD////yAAABFgLkACIAwAAAAAIAaOgAAAIAJf/3AlcC5wAdAC0AAAAVFAYGIyImJjU0NjYzMhYXJicHNTcmJzMWFzcVBwI2NjU0JiYjIgYGFRQWFjMCV0qBUk9+SEh7SzFMIhwze08iKHQV
FH1RcE0vLkwsLEosK0ksAfe6aZNKR4FVVIJGHB1BPCg9GiAhEhQpPRv9yCxVPDxVKytVPDxWKwD//wBLAAACQwLVACIATwAAAAMAwwCiAAD//wAm//cCWAMlACIAUAAAAAcAQQC/AAn//wAm//cCWAMlACIAUAAA
AAcAdAC/AAn//wAm//cCWAMDACIAUAAAAAcAwQCmAAn//wAm//cCWALeACIAUAAAAAcAwwCSAAn//wAm//cCWALtACIAUAAAAAcAaACjAAkAAwBaAEsCWAKLAAsADwAbAAAAJjU0NjMyFhUUBiMXFSE1EiY1NDYz
MhYVFAYjATwqKh8eKioe/f4C4ioqHx4qKh4B+SofHyoqHx8qX2Bg/rEqHx8qKh8fKgAAAwAc//cCYgIwABUAHgAnAAABFhUUBgYjIicHIzcmNTQ2NjMyFzczABcTJiMiBgYVJCcDFjMyNjY1AhVDTINPYEcoT0xC
SoBPYkkpT/44Gu4rOixLLAFJGu8oOCxNMAHTTXJUgkc0K1NNdFSCRjUs/q4vAQUiKlM8Pi3++h8qVDwA//8ARv/4Aj4DHAAiAFYAAAADAEEAxQAA//8ARv/4Aj4DHAAiAFYAAAADAHQAxQAA//8ARv/4Aj4C+gAi
AFYAAAADAMEArAAA//8ARv/4Aj4C5AAiAFYAAAADAGgAqQAA//8ACv79AjsDHAAiAFoAAAADAHQAowAAAAIAS/76AoAC5AASACIAABI2MzIWFhUUBgYjIiYnESMRMxEEJiYjIgYGFRQWFjMyNjY12WNBSHdERHdI
QWIdcnIBTy9NLCtNLy9NKyxNLwH1O0eAU1ODST0z/pMD6v7hdlMrLFQ5OVUsLVY5//8ACv79AjsC5AAiAFoAAAADAGgAhwAAAAEASwAAAL0CJwADAAATESMRvXICJ/3ZAicAAQAKAk4BKAL6AAUAABMHNTcXFZmP
j48CpFZZU1NZAAACAAcCXQDoAzgACwAXAAASBiMiJjU0NjMyFhUmJiMiBhUUFjMyNjXoQTAvQUEvMEFAHBUUHBwUFRwCmTw8MTI8PDIYHBwXFh0dFgAAAQAKAl4BWgLVABkAABI2MzIWFxYWMzI2NzMGBiMiJicm
JiMiBgcjEjwtExwUDxUNERcDQAg8LRMeEhITDBEXA0ACmjsMDAoKFRU6Ow0MCwkWFQD//wAw//kCVACLACMADwDJAAAAIwAPAZMAAAACAA8AAAABAC0AeAD3AdYABQAANyc3MwcXiVxcbmBgeK+vr68AAAEAMgB4
APwB1gAFAAATJzMXByORX21dXW0BJ6+vrwAAAQBXAToB8gGaAAMAAAEVITUB8v5lAZpgYAAAAAcAWgADAAEECQAAAKIAAAADAAEECQABABwAogADAAEECQACAA4AvgADAAEECQADADoAzAADAAEECQAEABwAogAD
AAEECQAFAAoBBgADAAEECQAGABwBEABDAG8AcAB5AHIAaQBnAGgAdAAgADIAMAAyADAAIABUAGgAZQAgAFAAbwBwAHAAaQBuAHMAIABQAHIAbwBqAGUAYwB0ACAAQQB1AHQAaABvAHIAcwAgACgAaAB0AHQAcABz
ADoALwAvAGcAaQB0AGgAdQBiAC4AYwBvAG0ALwBpAHQAZgBvAHUAbgBkAHIAeQAvAFAAbwBwAHAAaQBuAHMAKQBQAG8AcABwAGkAbgBzACAATQBlAGQAaQB1AG0AUgBlAGcAdQBsAGEAcgBJAFQARgBPADsAIABQ
AG8AcABwAGkAbgBzACAATQBlAGQAaQB1AG0AOwAgADQALgAwADAANABiADgANAAuADAAMAA0AFAAbwBwAHAAaQBuAHMALQBNAGUAZABpAHUAbQAAAAMAAAAAAAD/tQAyAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAA
AAoAHAAeAAFERkxUAAgABAAAAAD//wAAAAAAAAABAAAACgAsAC4AA0RGTFQAFGRldjIAHmRldmEAHgAEAAAAAP//AAAAAAAAAAAAAA==
]],
    fuente_titulo = [[
AAEAAAAMAIAAAwBAR1BPU0R2THUAADasAAAAIEdTVUIfSCdrAAA2zAAAADBPUy8yWq2AJQAAAUgAAABgY21hcCKnIaYAAATIAAAATGdseWZUYZ6JAAAGqAAALmBoZWFkIpFrqAAAAMwAAAA2aGhlYQhzA4kAAAEE
AAAAJGhtdHjPxR7EAAABqAAAAyBsb2Nh++Dw8QAABRQAAAGSbWF4cAFBAJ4AAAEoAAAAIG5hbWUf9zbOAAA1CAAAAYJwb3N0/7gAMgAANowAAAAgAAEAAAAEAQZ80w1kXw889QADA+gAAAAA2KSpyAAAAADm330u
/+H+7QQRA9sAAQAHAAIAAAAAAAAAAQAABBr+ogBkBDj/4f/mBBEAAQAAAAAAAAAAAAAAAAAAAMgAAQAAAMgARQAFADgABAABAAIAHgAGAAAAZAAAAAMAAgAEA2kCvAAFAAACigJYAAAASwKKAlgAAAFeADIBTgAA
AAAIAAAAAAAAAAAAAAMAAAAAAAAAAAAAAABJVEZPAKAAICA6BBr+ogBkBG8CcwAAAAEAAAAAAi4CwQAAACAABAH0AAAA1AAAAYgAXwGbACgDiAAUApIALANmAB8DHgAkAN0AKAHdAFcB3QAHAhYASgJ0ADsBHwAa
AkQANAEaACgBxQAKAowALQF4ABsCOwAlAl0AKgKlADECigBUAn0APgIXABwCiAA2AmcANAEcACgBWwAyAicAOQK4AEQCHQA/AhoAGgQ4AEkC4QAQApMAPgL6ACEC1wA+Ah0APgIjAD4C+gAhAtsAPgEnAD4CQgAa
ArkAPgHdAD4DlgA+AvAAPgMSACECcAA+AxQAIQKMAD4CZwAqAk8AGALBADsC2gAJBBwAGQLLABgCnwAHAlQAMgH+AHgDIgC3Af4AWgLFAB4DDABVASMACgKnABwCpwA+Al0AHAKnABwCaAAcAWgAEQKnABwCogA+
AScALgEm/+ECagA+AScAPgQjAD4CogA+An0AHAKnAD4CpwAcAawAPgIuACABlgAVAqIAOQJyAAkDYgAEAkwABQJ4//8B8AAfAfMAWwEjADwB8wBHAnwAHADUAAABiABfAncAKgKXACQCQQA8Ap8ABwF9AGkCSwAe
AW8ACgMLACYB1QAZAi0ALQLNAC8CRAA0AgIAJwGkAAoBzwAZAnUAPAF/ACIBdgAPAQUACgLBAEsCxAAcASsAMgE5AAoA+QAUAcoAGQItADIDEgAoAzUAKAN7ADICGgAiAuEAEALhABAC4QAQAuEAEALhABAC4QAQ
A7sABgL6ACECHQA+Ah0APgIdAD4CHQA+AScAFwEnABcBJ//5ASf/5gLcAAQC8AA+AxIAIQMSACEDEgAhAxIAIQMSACECfQBFAxIAFgLBADsCwQA7AsEAOwLBADsCnwAHAnAAPgL4ADECpwAcAqcAHAKnABwCpwAc
AqcAHAKnABwELQAcAl0AHAJoABwCaAAcAmgAHAJoABwBQQAkAUEAJAFBAAYBQf/zAoAAHAKiAD4CfQAcAn0AHAJ9ABwCfQAcAn0AHAJjADUCdQANAqIAOQKiADkCogA5AqIAOQJ4//8CpwA+Anj//wFBAEsBSgAK
AQYACQGaAAUC+AAoAVEALQFRADICHwA0AAAAAgAAAAMAAAAUAAMAAQAAABQABAA4AAAACgAIAAIAAgB+AP8gJiA6//8AAAAgAKAgJiA5////4f/A4J7gjAABAAAAAAAAAAAAAAAAAAAAAAAfADMAYwCuAPcBQgFP
AWwBigGsAcEBzwHXAe0B/QImAjYCXwKdArcC6QMjAzYDfwO5A8UD0QPhA/UEBQQ7BJsEtQToBRMFNwVNBWEFkQWqBbcF0wXsBfsGFwYtBlkGfQavBtgHFgcoB0kHXQd7B5UHqwfAB9IH4QfzCAUIEggfCE8Ifwin
CNcJCQkpCWkJiwmoCc4J5QnyCiYKRwpyCqIK2ArwCy8LTAtvC4ELnwu5C88L4wwoDDQMeQygDKAMvQzsDSENXw2EDZcN6w4QDmQOkA6pDrkOwQ8IDxUPPQ9WD3oPrw+8D98P/BAFECIQMRBdEHYQoRDXESgRXxFr
EXcRgxGPEZsRpxHKEgoSFhIiEi4SOhJGElISXhJqEpYSohKuEroSxhLSEt4S+BM7E0cTUxNfE2sTdxOdE+0T+RQFFBEUHRQpFDUUjBTIFNQU4BTsFPcVAhUNFRgVIxVhFW0VeRWFFZEVnBWoFdUWERYdFikWNRZB
Fk0WgBaMFpkWqRbPFvMXAxcTFyMXMAAAAAIAX//4ASoC1wADAA8AAAEDIwMSJjU0NjMyFhUUBiMBHxSRFDI5OS0sOTksAtf+IQHf/SE1Jyg2NignNQAAAgAoAkMBcwMgAAMABwAAEwcjJyEHIye1DXMNAUsNcw0D
IN3d3d0AAAIAFAAAA2cC5AAbAB8AAAEHMxUjByM3IwcjNyM1MzcjNTM3MwczNzMHMxUhIwczAssceJkhoCGmIaAhlLUckbEgoCCmIKAgfP7EphymAbaDmpmZmZmag5qUlJSUmoMAAAMALP+pAlEDGAAiACkAMAAA
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
AvENDQoJLZQNDQoJLQD//wAo//gC1ACyACMADwDwAAAAIwAPAeEAAAACAA8AAAABAC0AeAEfAdYABQAANyc3MwcXgVRUnldXeK+vr68AAAEAMgB4ASQB1gAFAAATJzMXByOJV55UVJ4BJ6+vrwAAAQA0ARgB7AGm
AAMAAAEVITUB7P5IAaaOjgAAAAcAWgADAAEECQAAAKIAAAADAAEECQABAA4AogADAAEECQACAAgAsAADAAEECQADADYAuAADAAEECQAEABgA7gADAAEECQAFAAoBBgADAAEECQAGABgBEABDAG8AcAB5AHIAaQBn
AGgAdAAgADIAMAAyADAAIABUAGgAZQAgAFAAbwBwAHAAaQBuAHMAIABQAHIAbwBqAGUAYwB0ACAAQQB1AHQAaABvAHIAcwAgACgAaAB0AHQAcABzADoALwAvAGcAaQB0AGgAdQBiAC4AYwBvAG0ALwBpAHQAZgBv
AHUAbgBkAHIAeQAvAFAAbwBwAHAAaQBuAHMAKQBQAG8AcABwAGkAbgBzAEIAbwBsAGQASQBUAEYATwA7ACAAUABvAHAAcABpAG4AcwAgAEIAbwBsAGQAOwAgADQALgAwADAANABiADgAUABvAHAAcABpAG4AcwAg
AEIAbwBsAGQANAAuADAAMAA0AFAAbwBwAHAAaQBuAHMALQBCAG8AbABkAAAAAwAAAAAAAP+1ADIAAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAACgAcAB4AAURGTFQACAAEAAAAAP//AAAAAAAAAAEAAAAKACwALgAD
REZMVAAUZGV2MgAeZGV2YQAeAAQAAAAA//8AAAAAAAAAAAAA
]],
}

-- Lista comprimida de todas las animaciones del GTA (se descomprime al abrir Animaciones)
Animac.datosGta, Animac.tamGta = RECURSOS.animaciones_gta, 3587784
RECURSOS.animaciones_gta = nil

-- Anchura de cada letra de Poppins (fracción del tamaño), para alinear y centrar texto
local ANCHOS = {
    normal = { [32]=0.267, [33]=0.298, [34]=0.292, [35]=0.84, [36]=0.622, [37]=0.759, [38]=0.739, [39]=0.159, [40]=0.454, [41]=0.454, [42]=0.486, [43]=0.683, [44]=0.198, [45]=0.551, [46]=0.21, [47]=0.476, [48]=0.628, [49]=0.32, [50]=0.575, [51]=0.589, [52]=0.629, [53]=0.628, [54]=0.635, [55]=0.546, [56]=0.631, [57]=0.63, [58]=0.213, [59]=0.264, [60]=0.555, [61]=0.723, [62]=0.539, [63]=0.524, [64]=1.013, [65]=0.674, [66]=0.613, [67]=0.772, [68]=0.707, [69]=0.513, [70]=0.504, [71]=0.778, [72]=0.692, [73]=0.246, [74]=0.53, [75]=0.599, [76]=0.432, [77]=0.861, [78]=0.703, [79]=0.786, [80]=0.579, [81]=0.788, [82]=0.608, [83]=0.587, [84]=0.541, [85]=0.675, [86]=0.676, [87]=0.976, [88]=0.621, [89]=0.584, [90]=0.541, [91]=0.423, [92]=0.658, [93]=0.423, [94]=0.629, [95]=0.733, [96]=0.257, [97]=0.676, [98]=0.676, [99]=0.607, [100]=0.676, [101]=0.62, [102]=0.329, [103]=0.676, [104]=0.64, [105]=0.246, [106]=0.248, [107]=0.515, [108]=0.246, [109]=1.03, [110]=0.64, [111]=0.64, [112]=0.676, [113]=0.676, [114]=0.373, [115]=0.522, [116]=0.364, [117]=0.64, [118]=0.561, [119]=0.82, [120]=0.479, [121]=0.563, [122]=0.455, [123]=0.462, [124]=0.291, [125]=0.462, [126]=0.519, [160]=0.267, [161]=0.298, [162]=0.665, [163]=0.62, [164]=0.537, [165]=0.595, [166]=0.291, [167]=0.575, [168]=0.314, [169]=0.792, [170]=0.45, [171]=0.461, [172]=0.65, [173]=0.551, [174]=0.509, [175]=0.387, [176]=0.41, [177]=0.686, [178]=0.33, [179]=0.332, [180]=0.247, [181]=0.645, [182]=0.596, [183]=0.212, [184]=0.272, [185]=0.196, [186]=0.436, [187]=0.461, [188]=0.64, [189]=0.675, [190]=0.709, [191]=0.519, [192]=0.674, [193]=0.674, [194]=0.674, [195]=0.674, [196]=0.674, [197]=0.674, [198]=0.9, [199]=0.772, [200]=0.513, [201]=0.513, [202]=0.513, [203]=0.513, [204]=0.246, [205]=0.246, [206]=0.246, [207]=0.246, [208]=0.725, [209]=0.703, [210]=0.786, [211]=0.786, [212]=0.786, [213]=0.786, [214]=0.786, [215]=0.643, [216]=0.786, [217]=0.675, [218]=0.675, [219]=0.675, [220]=0.675, [221]=0.584, [222]=0.579, [223]=0.681, [224]=0.676, [225]=0.676, [226]=0.676, [227]=0.676, [228]=0.676, [229]=0.676, [230]=1.097, [231]=0.607, [232]=0.62, [233]=0.62, [234]=0.62, [235]=0.62, [236]=0.246, [237]=0.246, [238]=0.246, [239]=0.246, [240]=0.638, [241]=0.64, [242]=0.64, [243]=0.64, [244]=0.64, [245]=0.64, [246]=0.64, [247]=0.657, [248]=0.64, [249]=0.64, [250]=0.64, [251]=0.64, [252]=0.64, [253]=0.563, [254]=0.676, [255]=0.563, [8230]=0.581, [8249]=0.28, [8250]=0.28 },
    negrita = { [32]=0.26, [33]=0.321, [34]=0.323, [35]=0.872, [36]=0.65, [37]=0.794, [38]=0.761, [39]=0.172, [40]=0.492, [41]=0.492, [42]=0.504, [43]=0.714, [44]=0.225, [45]=0.585, [46]=0.241, [47]=0.514, [48]=0.641, [49]=0.35, [50]=0.577, [51]=0.594, [52]=0.647, [53]=0.639, [54]=0.642, [55]=0.56, [56]=0.638, [57]=0.635, [58]=0.245, [59]=0.304, [60]=0.612, [61]=0.774, [62]=0.59, [63]=0.538, [64]=1.025, [65]=0.697, [66]=0.63, [67]=0.773, [68]=0.709, [69]=0.524, [70]=0.515, [71]=0.773, [72]=0.705, [73]=0.264, [74]=0.564, [75]=0.633, [76]=0.444, [77]=0.882, [78]=0.721, [79]=0.784, [80]=0.595, [81]=0.787, [82]=0.632, [83]=0.604, [84]=0.564, [85]=0.69, [86]=0.694, [87]=0.999, [88]=0.66, [89]=0.605, [90]=0.558, [91]=0.485, [92]=0.717, [93]=0.484, [94]=0.654, [95]=0.798, [96]=0.254, [97]=0.678, [98]=0.678, [99]=0.6, [100]=0.678, [101]=0.617, [102]=0.332, [103]=0.678, [104]=0.649, [105]=0.264, [106]=0.264, [107]=0.554, [108]=0.264, [109]=1.039, [110]=0.649, [111]=0.638, [112]=0.678, [113]=0.678, [114]=0.384, [115]=0.534, [116]=0.372, [117]=0.649, [118]=0.576, [119]=0.825, [120]=0.499, [121]=0.582, [122]=0.471, [123]=0.516, [124]=0.324, [125]=0.516, [126]=0.553, [160]=0.26, [161]=0.321, [162]=0.69, [163]=0.646, [164]=0.548, [165]=0.605, [166]=0.324, [167]=0.578, [168]=0.312, [169]=0.789, [170]=0.456, [171]=0.489, [172]=0.649, [173]=0.585, [174]=0.517, [175]=0.386, [176]=0.427, [177]=0.717, [178]=0.34, [179]=0.342, [180]=0.241, [181]=0.654, [182]=0.63, [183]=0.244, [184]=0.279, [185]=0.209, [186]=0.444, [187]=0.489, [188]=0.682, [189]=0.701, [190]=0.742, [191]=0.538, [192]=0.697, [193]=0.697, [194]=0.697, [195]=0.697, [196]=0.697, [197]=0.697, [198]=0.921, [199]=0.773, [200]=0.524, [201]=0.524, [202]=0.524, [203]=0.524, [204]=0.264, [205]=0.264, [206]=0.264, [207]=0.264, [208]=0.72, [209]=0.721, [210]=0.784, [211]=0.784, [212]=0.784, [213]=0.784, [214]=0.784, [215]=0.699, [216]=0.784, [217]=0.69, [218]=0.69, [219]=0.69, [220]=0.69, [221]=0.605, [222]=0.595, [223]=0.699, [224]=0.678, [225]=0.678, [226]=0.678, [227]=0.678, [228]=0.678, [229]=0.678, [230]=1.085, [231]=0.6, [232]=0.617, [233]=0.617, [234]=0.617, [235]=0.617, [236]=0.264, [237]=0.264, [238]=0.264, [239]=0.264, [240]=0.636, [241]=0.649, [242]=0.638, [243]=0.638, [244]=0.638, [245]=0.638, [246]=0.638, [247]=0.679, [248]=0.638, [249]=0.649, [250]=0.649, [251]=0.649, [252]=0.649, [253]=0.582, [254]=0.678, [255]=0.582, [8230]=0.638, [8249]=0.297, [8250]=0.297 },
    titulo = { [32]=0.212, [33]=0.392, [34]=0.411, [35]=0.904, [36]=0.658, [37]=0.87, [38]=0.798, [39]=0.221, [40]=0.477, [41]=0.477, [42]=0.534, [43]=0.628, [44]=0.287, [45]=0.58, [46]=0.282, [47]=0.453, [48]=0.652, [49]=0.376, [50]=0.571, [51]=0.605, [52]=0.677, [53]=0.65, [54]=0.637, [55]=0.535, [56]=0.648, [57]=0.615, [58]=0.284, [59]=0.347, [60]=0.551, [61]=0.696, [62]=0.541, [63]=0.538, [64]=1.08, [65]=0.737, [66]=0.659, [67]=0.762, [68]=0.727, [69]=0.541, [70]=0.547, [71]=0.762, [72]=0.731, [73]=0.295, [74]=0.578, [75]=0.697, [76]=0.477, [77]=0.918, [78]=0.752, [79]=0.786, [80]=0.624, [81]=0.788, [82]=0.652, [83]=0.615, [84]=0.591, [85]=0.705, [86]=0.73, [87]=1.052, [88]=0.715, [89]=0.671, [90]=0.596, [91]=0.51, [92]=0.802, [93]=0.51, [94]=0.709, [95]=0.78, [96]=0.291, [97]=0.679, [98]=0.679, [99]=0.605, [100]=0.679, [101]=0.616, [102]=0.36, [103]=0.679, [104]=0.674, [105]=0.295, [106]=0.294, [107]=0.618, [108]=0.295, [109]=1.059, [110]=0.674, [111]=0.637, [112]=0.679, [113]=0.679, [114]=0.428, [115]=0.558, [116]=0.406, [117]=0.674, [118]=0.626, [119]=0.866, [120]=0.588, [121]=0.632, [122]=0.496, [123]=0.499, [124]=0.291, [125]=0.499, [126]=0.636, [160]=0.212, [161]=0.392, [162]=0.631, [163]=0.663, [164]=0.577, [165]=0.671, [166]=0.381, [167]=0.587, [168]=0.367, [169]=0.779, [170]=0.469, [171]=0.557, [172]=0.717, [173]=0.58, [174]=0.514, [175]=0.42, [176]=0.463, [177]=0.629, [178]=0.383, [179]=0.374, [180]=0.261, [181]=0.705, [182]=0.708, [183]=0.299, [184]=0.313, [185]=0.249, [186]=0.458, [187]=0.557, [188]=0.786, [189]=0.821, [190]=0.891, [191]=0.538, [192]=0.737, [193]=0.737, [194]=0.737, [195]=0.737, [196]=0.737, [197]=0.737, [198]=0.955, [199]=0.762, [200]=0.541, [201]=0.541, [202]=0.541, [203]=0.541, [204]=0.295, [205]=0.295, [206]=0.295, [207]=0.295, [208]=0.732, [209]=0.752, [210]=0.786, [211]=0.786, [212]=0.786, [213]=0.786, [214]=0.786, [215]=0.637, [216]=0.786, [217]=0.705, [218]=0.705, [219]=0.705, [220]=0.705, [221]=0.671, [222]=0.624, [223]=0.76, [224]=0.679, [225]=0.679, [226]=0.679, [227]=0.679, [228]=0.679, [229]=0.679, [230]=1.069, [231]=0.605, [232]=0.616, [233]=0.616, [234]=0.616, [235]=0.616, [236]=0.321, [237]=0.321, [238]=0.321, [239]=0.321, [240]=0.64, [241]=0.674, [242]=0.637, [243]=0.637, [244]=0.637, [245]=0.637, [246]=0.637, [247]=0.611, [248]=0.629, [249]=0.674, [250]=0.674, [251]=0.674, [252]=0.674, [253]=0.632, [254]=0.679, [255]=0.632, [8230]=0.76, [8249]=0.337, [8250]=0.337 },
}


-- ═════════════════════════════════════════════════════════
-- RENDER: dos modos de dibujo
--   · Susano  -> overlay de Susano (BeginFrame / DrawRectFilled / DrawText / DrawImage / SubmitFrame)
--   · Nativo  -> DrawRect / texto de GTA (funciona siempre, y es lo que usarás en el recurso)
--   F9 cambia de modo en cualquier momento.
--   Todas las llamadas usan colores 0..1; el render los convierte a 0..255,
--   que es lo que Susano interpreta sin ambigüedad.
-- ═════════════════════════════════════════════════════════
local function SusanoDisponible()
    return type(Susano) == "table"
       and type(Susano.BeginFrame) == "function"
       and type(Susano.SubmitFrame) == "function"
       and type(Susano.DrawRectFilled) == "function"
       and type(Susano.DrawText) == "function"
end

-- Poppins: alto de línea = 1,4 × tamaño de letra (ascendente 1050 + descendente 350, sobre 1000).
-- ImGui usa el alto de línea como "tamaño", así que hay que multiplicar para que se vea al tamaño pedido.
local ESCALA_POPPINS = 1.4

R = { modo = "susano", ok = SusanoDisponible(), sw = 1920, sh = 1080, alpha = 1, ox = 0,
      fuentes = {}, poppins = false, tex = {},
      clips = 0,         -- recortes (PushClipRect) abiertos: se cierran solos al acabar el frame
      toasts = {},       -- avisos en pantalla
      mundo = {},        -- flechas y aros del mundo (se dibujan en el overlay, no con DrawMarker)
      errorTxt = nil, errorHasta = 0,
      vacio = false,     -- el último frame enviado a Susano ya estaba vacío (no hace falta repetirlo)
      proxRes = 0,       -- cuándo volver a mirar la resolución
      buffers = {} } -- los datos decodificados se guardan para que Lua no los libere

local floor, min, max = math.floor, math.min, math.max

-- Color 0..1 -> 0..255 (igual que antes: lo que no es un número válido cuenta como 1)
local function C(v)
    if v >= 1 or v ~= v then return 255 end
    if v <= 0 then return 0 end
    return floor(v * 255 + 0.5)
end

-- Cachés de texto: los mismos textos se dibujan cada frame, así que el trabajo se hace una sola vez.
-- Se vacían solas si crecen demasiado (textos que cambian, como distancias o lo que escribes).
local anchoCache, anchoN = {}, 0      -- [tabla de anchos][texto] = ancho a tamaño 1
local recorteCache, recorteN = {}, 0  -- [clave] = texto recortado con "…"
local fuenteCache = {}                -- [estilo][tamaño] = { fuente, tamaño para DrawText }
local function LimpiarCachesTexto()
    anchoCache, anchoN, recorteCache, recorteN, fuenteCache = {}, 0, {}, 0, {}
end

-- Ancho del texto en píxeles. Con Poppins cargada es exacto (tabla de anchos);
-- si no, una estimación.
local function Ancho(t, s, estilo)
    if R.poppins and utf8 then
        local tabla = ANCHOS[estilo or "normal"] or ANCHOS.normal
        local c = anchoCache[tabla]
        if not c then c = {}; anchoCache[tabla] = c end
        local w = c[t]
        if not w then
            w = 0
            for _, cp in utf8.codes(t) do w = w + (tabla[cp] or 0.55) end
            anchoN = anchoN + 1
            if anchoN > 4000 then c = {}; anchoCache, anchoN = { [tabla] = c }, 1 end
            c[t] = w
        end
        return w * s
    end
    local n = (utf8 and utf8.len(t)) or #t
    return n * s * 0.50
end

-- Tamaño de la pantalla de juego
function R.Pantalla() return R.sw, R.sh end

R.gt = { {}, {}, {}, {} }   -- tablas reutilizadas por los degradados
function R.GradV(x, y, w, h, r1, g1, b1, a1, r2, g2, b2, a2, radio)       -- arriba (1) → abajo (2)
    local t = R.gt
    local c1, c2, c3, c4 = t[1], t[2], t[3], t[4]
    c1[1], c1[2], c1[3], c1[4] = r1, g1, b1, a1
    c2[1], c2[2], c2[3], c2[4] = r1, g1, b1, a1
    c3[1], c3[2], c3[3], c3[4] = r2, g2, b2, a2
    c4[1], c4[2], c4[3], c4[4] = r2, g2, b2, a2
    R.Grad(x, y, w, h, c1, c2, c3, c4, radio)
end
function R.GradH(x, y, w, h, r1, g1, b1, a1, r2, g2, b2, a2, radio)       -- izquierda (1) → derecha (2)
    local t = R.gt
    local c1, c2, c3, c4 = t[1], t[2], t[3], t[4]
    c1[1], c1[2], c1[3], c1[4] = r1, g1, b1, a1
    c4[1], c4[2], c4[3], c4[4] = r1, g1, b1, a1
    c2[1], c2[2], c2[3], c2[4] = r2, g2, b2, a2
    c3[1], c3[2], c3[3], c3[4] = r2, g2, b2, a2
    R.Grad(x, y, w, h, c1, c2, c3, c4, radio)
end

function R.Rect(x, y, w, h, r, g, b, a, radio)
    if w <= 0 or h <= 0 or not R.ok then return end
    a = a * R.alpha
    if a <= 0.003 then return end
    x = x + R.ox
    if radio then radio = min(radio, w / 2, h / 2) end
    Susano.DrawRectFilled(x, y, w, h, C(r), C(g), C(b), C(a), radio or 0)
end

-- Dibuja una imagen incrustada. Devuelve false si no puede.
function R.Imagen(nombre, x, y, w, h, r, g, b, a)
    if not R.ok then return false end
    local tex = R.tex[nombre]
    if not tex or type(Susano.DrawImage) ~= "function" then return false end
    a = a * R.alpha
    if a <= 0.003 then return true end
    local ok = pcall(Susano.DrawImage, tex, x + R.ox, y, w, h, C(r), C(g), C(b), C(a), 0)
    return ok
end

function R.Text(x, y, txt, size, r, g, b, a, centrado, estilo)
    if not txt or txt == "" or not R.ok then return end
    a = a * R.alpha
    if a <= 0.003 then return end
    x = x + R.ox
    if centrado then x = x - Ancho(txt, size, estilo) / 2 end
    local fuente, tam = R.Fuente(estilo, size)
    if fuente then
        Susano.DrawText(x, y, txt, tam, C(r), C(g), C(b), C(a), fuente)
    else
        Susano.DrawText(x, y, txt, size, C(r), C(g), C(b), C(a))
    end
end

-- Texto con sombra suave (se lee sobre cualquier fondo)
function R.TextS(x, y, txt, size, r, g, b, a, centrado, estilo)
    R.Text(x + 1, y + 1, txt, size, 0, 0, 0, a * 0.55, centrado, estilo)
    R.Text(x, y, txt, size, r, g, b, a, centrado, estilo)
end

-- Cristal esmerilado: desenfoca lo que hay debajo y le pone un tinte (colores 0..1).
-- Si esta versión de Susano no lo tiene, queda un rectángulo translúcido.
function R.Blur(x, y, w, h, fuerza, radio, r, g, b, a)
    if w <= 0 or h <= 0 or not R.ok then return end
    a = a * R.alpha
    if a <= 0.003 then return end
    if type(Susano.DrawBlurRect) ~= "function" then R.Rect(x, y, w, h, r, g, b, a * 0.6, radio); return end
    radio = radio and min(radio, w / 2, h / 2) or 0
    Susano.DrawBlurRect(x + R.ox, y, w, h, fuerza or 3, radio, min(max(r, 0), 1), min(max(g, 0), 1), min(max(b, 0), 1), min(a, 1))
end

-- Degradado en las 4 esquinas: c1 arriba-izq, c2 arriba-der, c3 abajo-der, c4 abajo-izq, cada una { r, g, b, a } (0..1)
function R.Grad(x, y, w, h, c1, c2, c3, c4, radio)
    if w <= 0 or h <= 0 or not R.ok then return end
    local al = R.alpha
    if type(Susano.DrawRectGradient) ~= "function" then
        R.Rect(x, y, w, h, (c1[1] + c3[1]) / 2, (c1[2] + c3[2]) / 2, (c1[3] + c3[3]) / 2, (c1[4] + c3[4]) / 2, radio)
        return
    end
    if radio then radio = min(radio, w / 2, h / 2) end
    Susano.DrawRectGradient(x + R.ox, y, w, h,
        c1[1], c1[2], c1[3], min(c1[4] * al, 1), c2[1], c2[2], c2[3], min(c2[4] * al, 1),
        c3[1], c3[2], c3[3], min(c3[4] * al, 1), c4[1], c4[2], c4[3], min(c4[4] * al, 1), radio or 0)
end

-- Contorno de un rectángulo (sin relleno)
function R.Borde(x, y, w, h, r, g, b, a, grosor, radio)
    if w <= 0 or h <= 0 or not R.ok then return end
    a = a * R.alpha
    if a <= 0.003 then return end
    if radio then radio = min(radio, w / 2, h / 2) end
    Susano.DrawRect(x + R.ox, y, w, h, C(r), C(g), C(b), C(a), grosor or 1, radio or 0)
end

-- Círculo (relleno o solo contorno), colores 0..1
function R.Circulo(x, y, radio, lleno, r, g, b, a, grosor)
    if not R.ok then return end
    a = a * R.alpha
    if a <= 0.003 then return end
    Susano.DrawCircle(x + R.ox, y, radio, lleno and true or false, min(max(r, 0), 1), min(max(g, 0), 1), min(max(b, 0), 1),
        min(a, 1), grosor or 1, radio > 30 and 64 or 32)
end

function R.Linea(x1, y1, x2, y2, r, g, b, a, grosor)
    if not R.ok then return end
    a = a * R.alpha
    if a <= 0.003 then return end
    Susano.DrawLine(x1 + R.ox, y1, x2 + R.ox, y2, min(max(r, 0), 1), min(max(g, 0), 1), min(max(b, 0), 1), min(a, 1), grosor or 1)
end

-- Recorte: lo que se dibuje hasta R.FinClip() no se sale de este rectángulo
function R.Clip(x, y, w, h)
    if not R.ok or type(Susano.PushClipRect) ~= "function" then return false end
    Susano.PushClipRect(x + R.ox, y, w, h, true)
    R.clips = R.clips + 1
    return true
end
function R.FinClip()
    if R.clips > 0 and type(Susano.PopClipRect) == "function" then
        Susano.PopClipRect()
        R.clips = R.clips - 1
    end
end

-- Sombra suave debajo de un rectángulo (capas translúcidas)
-- Brillo de color difuminado: círculos concéntricos cada vez más tenues
function R.Brillo(cx, cy, radio, r, g, b, a)
    for i = 0, 11 do
        R.Circulo(cx, cy, radio * (1 - i / 12), true, r, g, b, a / 12)
    end
end

function R.Sombra(x, y, w, h, radio, fuerza)
    fuerza = fuerza or 1
    for i = 1, 6 do
        R.Rect(x - i * 3, y - i * 3 + 8, w + i * 6, h + i * 6, 0, 0, 0, 0.055 * fuerza, (radio or 0) + i * 3)
    end
end

-- Avisos: aparecen arriba a la derecha unos segundos
function R.Aviso(txt)
    if not txt or txt == "" then return end
    local L, ahora = R.toasts, GetGameTimer()
    local u = L[#L]
    if u and u.txt == txt then u.hasta = ahora + 2600; return end
    L[#L + 1] = { txt = txt, t0 = ahora, hasta = ahora + 2600 }
    while #L > 5 do table.remove(L, 1) end
end

-- Flechas del mundo (sobre NPCs y jugadores) y aro en el suelo: se guardan y se dibujan en el overlay
function R.Flecha(x, y, z, r, g, b, aro)
    local L = R.mundo
    if #L > 60 then return end
    L[#L + 1] = { x = x, y = y, z = z, r = r, g = g, b = b, aro = aro }
end

function R.TextC(cx, y, txt, size, r, g, b, a, estilo) R.Text(cx, y, txt, size, r, g, b, a, true, estilo) end

-- Elige la fuente horneada más cercana al tamaño pedido y devuelve el tamaño a pasar a DrawText
-- (se calcula una vez por estilo y tamaño)
local function ElegirFuente(estilo, size)
    local grupo = R.fuentes[estilo or "normal"] or R.fuentes.normal
    if not grupo then return nil, size end
    if type(grupo) ~= "table" then return grupo, size end
    local tam = R.poppins and size * ESCALA_POPPINS or size
    local mejor, dif = nil, math.huge
    for px, id in pairs(grupo) do
        local d = math.abs(px - tam)
        if d < dif then mejor, dif = id, d end
    end
    return mejor, tam
end
function R.Fuente(estilo, size)
    local clave = estilo or "normal"
    local porEstilo = fuenteCache[clave]
    if not porEstilo then porEstilo = {}; fuenteCache[clave] = porEstilo end
    local e = porEstilo[size]
    if not e then e = { ElegirFuente(estilo, size) }; porEstilo[size] = e end
    return e[1], e[2]
end

-- Carga las fuentes y las imágenes incrustadas en el overlay de Susano.
-- Si algo no está disponible en tu versión, se usa lo de por defecto sin romper nada.
function R.CargarRecursos()
    if type(Susano) ~= "table" then return end
    local log = {}

    -- Fuentes: primero Poppins incrustada; si no se puede, Segoe UI de Windows
    -- (cada fuente se decodifica una sola vez aunque se hornee a varios tamaños)
    local decodificado = {}
    local function FuenteBuffer(clave, tam)
        if type(Susano.LoadFontFromBuffer) ~= "function" then return nil end
        local datos = decodificado[clave]
        if not datos then datos = Base64Bin(RECURSOS[clave]); decodificado[clave] = datos; R.buffers[#R.buffers + 1] = datos end
        local ok, f = pcall(Susano.LoadFontFromBuffer, datos, tam)
        if ok and type(f) == "number" then return f end
    end
    local function FuenteArchivo(rutas, tam)
        if type(Susano.LoadFont) ~= "function" then return nil end
        for _, ruta in ipairs(rutas) do
            local ok, f = pcall(Susano.LoadFont, ruta, tam)
            if ok and f then return f end
        end
    end
    -- Se hornea cada estilo a los tamaños que usa el menú (en píxeles de ImGui)
    local function Grupo(clave, tamanos)
        local g, alguno = {}, false
        for _, px in ipairs(tamanos) do
            local id = FuenteBuffer(clave, px)
            if id then g[px] = id; alguno = true end
        end
        return alguno and g or nil
    end
    R.fuentes.normal  = Grupo("fuente_normal",  { 17, 18, 20, 21 })
    R.fuentes.negrita = Grupo("fuente_negrita", { 20, 21 })
    R.fuentes.titulo  = Grupo("fuente_titulo",  { 25 })
    R.poppins = R.fuentes.normal ~= nil
    if not R.poppins then
        R.fuentes.normal  = FuenteArchivo({ "C:/Windows/Fonts/segoeui.ttf", "C:/Windows/Fonts/arial.ttf" }, 15)
        R.fuentes.negrita = FuenteArchivo({ "C:/Windows/Fonts/segoeuisb.ttf", "C:/Windows/Fonts/segoeuib.ttf" }, 15)
        R.fuentes.titulo  = FuenteArchivo({ "C:/Windows/Fonts/segoeuib.ttf", "C:/Windows/Fonts/arialbd.ttf" }, 18)
    end
    log[#log + 1] = "fuente=" .. (R.poppins and "Poppins" or (R.fuentes.normal and "Segoe UI" or "por defecto"))

    -- Imágenes
    local n = 0
    if type(Susano.LoadTextureFromBuffer) == "function" then
        for _, nombre in ipairs({ "logo", "coche", "llave", "ropa", "fantasma", "baile", "teclado", "ayuda", "engranaje", "cursor", "rayo", "superman" }) do
            local datos = Base64Bin(RECURSOS[nombre])
            R.buffers[#R.buffers + 1] = datos
            local ok, tex = pcall(Susano.LoadTextureFromBuffer, datos)
            if ok and tex then R.tex[nombre] = tex; n = n + 1 end
        end
    end
    log[#log + 1] = "imagenes=" .. n .. "/12"
    print("[cargar coches] Recursos: " .. table.concat(log, ", "))
    LimpiarCachesTexto()
end

-- Posición del cursor en píxeles: la del propio overlay de Susano (si no la tiene, la del juego)
function R.PosCursor()
    if type(Susano) == "table" and type(Susano.GetCursorPos) == "function" then
        local ok, x, y = pcall(function()
            local p = Susano.GetCursorPos()
            return p.x or p[1], p.y or p[2]
        end)
        if ok and type(x) == "number" and type(y) == "number" then return x, y end
    end
    return GetDisabledControlNormal(0, 239) * R.sw, GetDisabledControlNormal(0, 240) * R.sh
end

function R.Begin()
    -- La resolución casi nunca cambia: se mira una vez por segundo
    local t = GetGameTimer()
    if t >= R.proxRes then
        R.proxRes = t + 1000
        local sw, sh = GetActiveScreenResolution()
        if sw and sw > 0 then R.sw, R.sh = sw, sh end
    end
    if R.ok then Susano.BeginFrame() end
end

function R.End()
    while R.clips > 0 do R.FinClip() end   -- ningún recorte se queda abierto
    if R.ok then Susano.SubmitFrame() end
end

local Anim = {
    t = 0, dt = 0.016,
    open = 0,            -- 0 cerrado → 1 abierto
    contenido = 1,       -- fundido del contenido al cambiar de pestaña
    dirTab = 1, ultimaTab = 1,
    descA = 1, descIdx = nil,
    hud = 1,
}

local factorSuave, factorDt = {}, -1
local function Suave(actual, objetivo, vel)
    local dt = Anim.dt
    if dt ~= factorDt then factorDt = dt; factorSuave = {} end
    local f = factorSuave[vel]
    if not f then f = 1 - math.exp(-vel * dt); factorSuave[vel] = f end
    return actual + (objetivo - actual) * f
end
local function EaseOut(t) t = Clamp(t, 0, 1); return 1 - (1 - t) ^ 3 end
local function Mix(a, b, t) return a + (b - a) * t end

-- ═════════════════════════════════════════════════════════
-- DIBUJO DEL MENÚ (ventana)
-- ═════════════════════════════════════════════════════════
local VERSION = "v11.0"

local UI = {
    w = 850, h = 597, lateral = 72,
    fondo   = { 0.060, 0.060, 0.090 },
    lateralC = { 0.040, 0.040, 0.065 },
    panel   = { 0.118, 0.118, 0.150 },
    caja    = { 0.165, 0.165, 0.200 },
    cajaFoco = { 0.205, 0.205, 0.250 },
    texto   = { 0.94, 0.94, 0.97 },
    gris    = { 0.56, 0.57, 0.62 },
    icono   = { 0.62, 0.63, 0.68 },
}

local function Acento() return (COLORES[Config.colorMenu] or COLORES[1])[2] end

local function Envolver(txt, max)
    local lineas, actual = {}, ""
    for pal in txt:gmatch("%S+") do
        if #actual > 0 and #actual + #pal + 1 > max then
            lineas[#lineas + 1] = actual; actual = pal
        else
            actual = (#actual > 0) and (actual .. " " .. pal) or pal
        end
    end
    if #actual > 0 then lineas[#lineas + 1] = actual end
    return lineas
end

-- Icono: imagen PNG incrustada, teñida del color pedido
local function Icono(tipo, cx, cy, c, a, tam)
    tam = tam or 26
    if R.Imagen(tipo, cx - tam / 2, cy - tam / 2, tam, tam, c[1], c[2], c[3], a) then return end
    R.Circulo(cx, cy, tam / 3, true, c[1], c[2], c[3], a)            -- si la imagen no se cargó: un punto
end

-- Distintivo propio (arriba a la izquierda)
local function Logo(cx, cy)
    if R.Imagen("logo", cx - 24, cy - 24, 48, 48, 1, 1, 1, 1) then return end
    R.TextC(cx, cy - 11, "SG", 15, 1, 1, 1, 1, "titulo")
end

-- ── Opciones ──────────────────────────────────────────────
local ALTO = { toggle = 34, slider = 50, lista = 50, bind = 50, accion = 46, texto = 26, cat = 38, campo = 46 }

-- Recorta un texto con "…" para que quepa en el ancho dado.
-- Lo normal es que quepa (se comprueba al momento); si no, el recorte se calcula una vez y se guarda.
local function Recortar(txt, size, max, estilo)
    if Ancho(txt, size, estilo) <= max then return txt end
    local c1 = recorteCache[max];        if not c1 then c1 = {}; recorteCache[max] = c1 end
    local c2 = c1[size];                 if not c2 then c2 = {}; c1[size] = c2 end
    local c3 = c2[estilo or "normal"];   if not c3 then c3 = {}; c2[estilo or "normal"] = c3 end
    local r = c3[txt]
    if r then return r end
    local out = ""
    for _, cp in utf8.codes(txt) do
        local sig = out .. utf8.char(cp)
        if Ancho(sig .. "…", size, estilo) > max then break end
        out = sig
    end
    r = out .. "…"
    recorteN = recorteN + 1
    if recorteN > 1000 then
        recorteCache, recorteN, c3 = {}, 1, {}
        recorteCache[max] = { [size] = { [estilo or "normal"] = c3 } }
    end
    c3[txt] = r
    return r
end

-- Primera línea de la descripción de abajo (se repite cada frame: se guarda la última)
local ultimaDesc, ultimaLinea = nil, ""
local function PrimeraLinea(txt)
    if txt ~= ultimaDesc then ultimaDesc, ultimaLinea = txt, (Envolver(txt, 110)[1] or "") end
    return ultimaLinea
end

local GRIS_CAMPO = { UI.gris[1] + 0.15, UI.gris[2] + 0.15, UI.gris[3] + 0.15 }
local AMARILLO_AVISO = { 1.0, 0.82, 0.35 }

-- Dibuja una opción y devuelve su rectángulo (x, y, ancho, alto): es a la vez el "de foco" y el clicable
local function DibujarItem(it, px, pw, iy, foco, A)
    local T1 = UI.texto
    local tipo = it.tipo
    if tipo == "cat" then
        local activo = it.activo and it.activo()
        it._a = it._a and Suave(it._a, activo and 1 or 0, 16) or (activo and 1 or 0)
        local a = it._a
        local rx, rw = px + 12, pw - 24
        R.Rect(rx, iy, rw, 32, 1, 1, 1, (foco and 0.10 or 0.045) + 0.04 * a, 9)
        if a > 0.02 then
            R.GradH(rx, iy, rw, 32, A[1], A[2], A[3], 0.24 * a, A[1], A[2], A[3], 0.02 * a, 9)
            R.Rect(rx, iy + 8, 3, 16, A[1], A[2], A[3], a, 1.5)
        end
        R.Text(rx + 16 + 4 * a, iy + 6, it.label, 15, Mix(T1[1], A[1], a), Mix(T1[2], A[2], a), Mix(T1[3], A[3], a), 1,
            false, activo and "negrita" or nil)
        R.Text(rx + rw - 16, iy + 5, "›", 16, T1[1], T1[2], T1[3], 0.35 + 0.4 * a)
        return rx, iy, rw, 32

    elseif tipo == "toggle" then
        local on = Leer(it) and 1 or 0
        it._a = it._a and Suave(it._a, on, 18) or on
        local a = it._a
        local rx, rw = px + 12, pw - 24
        if foco then R.Rect(rx, iy, rw, 30, 1, 1, 1, 0.07, 9) end
        R.Text(rx + 12, iy + 5, it.label, 15, T1[1], T1[2], T1[3], 1)
        -- interruptor: pista con bola que se desliza
        local sx, sy = rx + rw - 12 - 40, iy + 5
        if a > 0.02 then R.Rect(sx - 3, sy - 3, 46, 26, A[1], A[2], A[3], 0.13 * a, 13) end
        R.Rect(sx, sy, 40, 20, Mix(0.24, A[1], a), Mix(0.25, A[2], a), Mix(0.30, A[3], a), 0.60 + 0.40 * a, 10)
        R.Circulo(sx + 10 + 20 * a, sy + 10, 7.5, true, 1, 1, 1, 1)
        return rx, iy, rw, 30

    elseif tipo == "slider" or tipo == "lista" or tipo == "bind" then
        local rx, rw = px + 14, pw - 28
        R.Rect(rx, iy, rw, 38, 1, 1, 1, foco and 0.10 or 0.050, 10)
        if foco then R.Borde(rx, iy, rw, 38, A[1], A[2], A[3], 0.55, 1, 10) end
        R.Text(rx + 12, iy + 6, it.label, 15, T1[1], T1[2], T1[3], 1, false, "negrita")

        local valor
        if tipo == "slider" then
            local mn, mx = Minimo(it), Maximo(it)
            local v = Leer(it) or mn
            it._v = it._v and Suave(it._v, v, 16) or v
            if type(it.fmt) == "function" then
                valor = it.fmt(v)
            else
                -- el texto del valor solo se rehace cuando cambia el valor
                if it._fv ~= v then it._fv, it._fs = v, string.format(it.fmt, v) end
                valor = it._fs
            end
            local pct = (mx > mn) and Clamp((it._v - mn) / (mx - mn), 0, 1) or 1
            local tx, tw = rx + 12, rw - 24
            local lw = max(tw * pct, 0)
            R.Rect(tx, iy + 29, tw, 4, 1, 1, 1, 0.10, 2)                                   -- pista
            if lw > 1 then R.GradH(tx, iy + 29, lw, 4, A[1], A[2], A[3], 0.70, A[1], A[2], A[3], 1, 2) end   -- relleno
            R.Circulo(tx + lw, iy + 31, 9, true, A[1], A[2], A[3], foco and 0.30 or 0.16)  -- brillo
            R.Circulo(tx + lw, iy + 31, 5.5, true, 1, 1, 1, 1)                             -- tirador
        elseif tipo == "lista" then
            local i = floor(Leer(it) or 1)
            valor = it.opciones[i] or it.opciones[1] or "?"
            if foco then valor = "‹  " .. valor .. "  ›" end
            R.Rect(rx + 12, iy + 30, rw - 24, 2, A[1], A[2], A[3], foco and 0.9 or 0.45, 1)
        else
            if foco and Menu.esperandoTecla then
                valor = "Pulsa una tecla"
                R.Rect(rx + 12, iy + 30, rw - 24, 2, A[1], A[2], A[3], 0.5 + 0.5 * math.sin(Anim.t * 8), 1)
            else
                valor = NombreTecla(it.bind.tecla)
            end
        end
        local maxValor = rw - 24 - Ancho(it.label, 15, "negrita") - 14
        valor = Recortar(valor, 15, max(maxValor, 40))
        local wv = Ancho(valor, 15)
        if tipo == "bind" then
            R.Rect(rx + rw - 12 - wv - 10, iy + 4, wv + 20, 22, 1, 1, 1, 0.10, 7)      -- la tecla, dentro de una "ficha"
            R.Text(rx + rw - 12 - wv, iy + 6, valor, 15, A[1], A[2], A[3], 1)
        else
            R.Text(rx + rw - 12 - wv, iy + 6, valor, 15, T1[1], T1[2], T1[3], 1)
        end
        return rx, iy, rw, 38

    elseif tipo == "campo" then
        local rx, rw = px + 14, pw - 28
        local escribiendo = Menu.escribiendo == it
        R.Rect(rx, iy, rw, 38, 1, 1, 1, (foco or escribiendo) and 0.10 or 0.050, 10)
        if foco or escribiendo then R.Borde(rx, iy, rw, 38, A[1], A[2], A[3], escribiendo and 0.9 or 0.55, 1, 10) end
        local txt = it.get() or ""
        local vacio = txt == ""
        local mostrar = vacio and (escribiendo and "" or (it.placeholder or it.label)) or txt
        local cursor = (escribiendo and floor(GetGameTimer() / 500) % 2 == 0) and "|" or ""
        local maxw = rw - 28
        -- se ve el final del texto (el recorte se guarda mientras no cambie)
        if it._mEn ~= mostrar or it._mMax ~= maxw then
            local m = mostrar
            while #m > 0 and Ancho(m .. "|", 15) > maxw do m = m:sub(2) end
            it._mEn, it._mMax, it._mSal = mostrar, maxw, m
        end
        mostrar = it._mSal
        local tc = vacio and not escribiendo and GRIS_CAMPO or T1
        R.Text(rx + 12, iy + 9, mostrar .. cursor, 15, tc[1], tc[2], tc[3], 1)
        return rx, iy, rw, 38

    elseif tipo == "accion" then
        local rx, rw = px + 14, pw - 28
        if foco then
            R.GradH(rx, iy, rw, 36, A[1], A[2], A[3], 0.32, A[1], A[2], A[3], 0.10, 10)
            R.Borde(rx, iy, rw, 36, A[1], A[2], A[3], 0.65, 1, 10)
        else
            R.Rect(rx, iy, rw, 36, 1, 1, 1, 0.060, 10)
        end
        local tc = foco and A or T1
        local der = it.derecha
        if der then
            local anchoDer = (der ~= "") and (Ancho(der, 14) + 16) or 0
            R.Text(rx + 12, iy + 8, Recortar(it.label, 15, rw - 24 - anchoDer, "negrita"), 15, tc[1], tc[2], tc[3], 1, false, "negrita")
            R.Text(rx + rw - 12 - Ancho(der, 14), iy + 9, der, 14, UI.gris[1] + 0.25, UI.gris[2] + 0.25, UI.gris[3] + 0.25, 1)
        else
            R.TextC(rx + rw / 2, iy + 8, it.label, 15, tc[1], tc[2], tc[3], 1, "negrita")
        end
        return rx, iy, rw, 36

    else -- texto
        R.Text(px + 20, iy + 4, Recortar(Texto(it.label), 14, pw - 40), 14, UI.gris[1] + 0.2, UI.gris[2] + 0.2, UI.gris[3] + 0.2, 1)
    end
end

-- Zonas clicables: se reutilizan las mismas tablas cada frame en vez de crear unas nuevas
local hitPool, nHits = {}, 0
local function EmpezarHits()
    for i = nHits, 1, -1 do Hits[i] = nil end
    nHits = 0
end
local function NuevoHit(tipo, x, y, w, h)
    nHits = nHits + 1
    local t = hitPool[nHits]
    if not t then t = {}; hitPool[nHits] = t end
    t.tipo, t.x, t.y, t.w, t.h = tipo, x, y, w, h
    t.i, t.panel, t.posSel, t.item = nil, nil, nil, nil
    Hits[nHits] = t
    return t
end

local ALTO_MAX_PANEL = 444  -- lo que cabe en la ventana; si hay más, el panel hace scroll

-- Devuelve el rectángulo de la opción con el foco (x, y, ancho, alto) o nada
local function DibujarPanel(panel, nPanel, px, py, pw, A, posFoco)
    local items = panel.items
    local nItems = #items
    -- Posición de cada opción dentro del contenido (solo se recalcula si cambia la lista)
    if panel._posDe ~= items or panel._posN ~= nItems then
        local posY, cont = {}, 0
        for i = 1, nItems do posY[i] = cont; cont = cont + ALTO[items[i].tipo] end
        panel._posY, panel._contenido, panel._posDe, panel._posN = posY, cont, items, nItems
    end
    local posY, contenido = panel._posY, panel._contenido
    local alto = min(40 + contenido + 12, ALTO_MAX_PANEL)
    local visible = alto - 50                       -- zona de opciones (sin título ni margen)
    local maxScroll = max(0, contenido - visible)

    -- Tarjeta de cristal con título
    R.GradV(px, py, pw, alto, 1, 1, 1, 0.070, 1, 1, 1, 0.030, 14)
    R.Borde(px, py, pw, alto, 1, 1, 1, 0.075, 1, 14)
    R.Circulo(px + 20, py + 20, 3.2, true, A[1], A[2], A[3], 1)
    R.Text(px + 32, py + 11, panel.titulo, 14, UI.texto[1], UI.texto[2], UI.texto[3], 0.85, false, "negrita")

    -- Rueda del ratón encima del panel
    panel._scrollObj = panel._scrollObj or 0
    if Raton.rueda and Raton.rueda ~= 0 and Raton.x >= px and Raton.x <= px + pw and Raton.y >= py and Raton.y <= py + alto then
        panel._scrollObj = panel._scrollObj + Raton.rueda * 70
        Raton.rueda = 0
    end

    -- Que la opción con el foco del teclado siempre se vea
    local tieneFoco = Menu.col == nPanel
    if tieneFoco then
        local i = Seleccionables(panel)[posFoco]
        if i then
            if posY[i] < panel._scrollObj then panel._scrollObj = posY[i] end
            local fin = posY[i] + ALTO[items[i].tipo]
            if fin > panel._scrollObj + visible then panel._scrollObj = fin - visible end
        end
    end
    panel._scrollObj = Clamp(panel._scrollObj, 0, maxScroll)
    panel._scroll = panel._scroll and Suave(panel._scroll, panel._scrollObj, 16) or panel._scrollObj

    local scroll = panel._scroll
    local arriba, abajo = py + 38, py + 38 + visible
    local fx, fy, fw, fh
    local nSel = 0
    -- Con recorte, las opciones a medio salir se ven cortadas; sin él, solo se dibujan las que caben enteras
    local recorte = R.Clip(px, arriba, pw, visible)
    for i = 1, nItems do
        local it = items[i]
        local tipo = it.tipo
        local seleccionable = tipo ~= "texto"
        if seleccionable then nSel = nSel + 1 end
        local iy = arriba + posY[i] - scroll
        local entra
        if recorte then entra = iy + ALTO[tipo] > arriba and iy < abajo
        else entra = iy >= arriba - 2 and iy + ALTO[tipo] - 12 <= abajo + 2 end
        if entra then
            local foco = seleccionable and tieneFoco and posFoco == nSel
            local zx, zy, zw, zh = DibujarItem(it, px, pw, iy, foco, A)
            if seleccionable and zx then
                -- la zona clicable solo cubre la parte que se ve
                local y0, y1 = max(zy, arriba), min(zy + zh, abajo)
                if y1 - y0 > 4 then
                    local h = NuevoHit("item", zx, y0, zw, y1 - y0)
                    h.panel, h.posSel, h.item = nPanel, nSel, it
                end
                if foco then fx, fy, fw, fh = zx, zy, zw, zh end
            end
        end
    end
    if recorte then R.FinClip() end

    -- Barra de scroll
    if maxScroll > 0 then
        local th = max(visible * visible / contenido, 24)
        local ty = arriba + (visible - th) * (scroll / maxScroll)
        R.Rect(px + pw - 7, arriba, 3, visible, 1, 1, 1, 0.07, 1.5)
        R.Rect(px + pw - 7, ty, 3, th, A[1], A[2], A[3], 0.9, 1.5)
    end
    return fx, fy, fw, fh
end

local function DibujarCursor(mx, my)
    if R.Imagen("cursor", mx - 2, my - 2, 26, 26, 1, 1, 1, 1) then return end
    -- Respaldo: flecha sencilla hecha con líneas de Susano
    R.Linea(mx, my, mx, my + 18, 0, 0, 0, 0.9, 5)
    R.Linea(mx, my, mx + 12, my + 13, 0, 0, 0, 0.9, 5)
    R.Linea(mx, my, mx, my + 16, 1, 1, 1, 1, 2)
    R.Linea(mx, my, mx + 10, my + 11, 1, 1, 1, 1, 2)
end

-- Posición de cada icono de sección respecto a la ventana (las secciones no cambian: se calcula una vez)
local iconosRel
local function IconosRel()
    if iconosRel then return iconosRel end
    iconosRel = {}
    local yi = 116
    for i, s in ipairs(Secciones) do
        if not s.engranaje then
            iconosRel[#iconosRel + 1] = { i = i, dx = 36, dy = yi }
            yi = yi + 54
        else
            iconosRel[#iconosRel + 1] = { i = i, dx = UI.w - 32, dy = 38 }
        end
    end
    return iconosRel
end
local colIcono = { 0, 0, 0 }

-- ── Píldora de cristal (barras del HUD) ──
function R.Pildora(x, y, w, h, A, progreso)
    R.Sombra(x, y, w, h, 12, 0.7)
    R.Blur(x, y, w, h, 3, 12, 0.05, 0.05, 0.09, 0.40)
    R.GradV(x, y, w, h, 0.115, 0.115, 0.170, 0.93, 0.050, 0.050, 0.080, 0.95, 12)
    R.Borde(x, y, w, h, 1, 1, 1, 0.10, 1, 12)
    if progreso and progreso > 0 then
        R.Rect(x + 12, y + h - 4, (w - 24) * Clamp(progreso, 0, 1), 2, A[1], A[2], A[3], 1, 1)
    end
end

-- ── Avisos arriba a la derecha ──
function R.DibujarAvisos(sw, sh)
    local L = R.toasts
    if #L == 0 then return end
    local ahora, A = GetGameTimer(), Acento()
    local y = 24
    for i = #L, 1, -1 do
        local t = L[i]
        if ahora >= t.hasta + 250 then
            table.remove(L, i)
        else
            local entra = Clamp((ahora - t.t0) / 200, 0, 1)
            local sale = Clamp((t.hasta + 250 - ahora) / 250, 0, 1)
            local a = min(entra, sale)
            local w = Ancho(t.txt, 14) + 46
            R.alpha, R.ox = a, (1 - EaseOut(entra)) * 40
            R.Pildora(sw - 24 - w, y, w, 34, A, nil)
            R.Rect(sw - 24 - w + 12, y + 9, 3, 16, A[1], A[2], A[3], 1, 1.5)
            R.Text(sw - 24 - w + 26, y + 8, t.txt, 14, UI.texto[1], UI.texto[2], UI.texto[3], 1)
            y = y + 42
        end
    end
    R.alpha, R.ox = 1, 0
end

-- ── Error en pantalla (8 segundos) ──
function R.DibujarError(sw, sh)
    if not R.errorTxt then return end
    if GetGameTimer() > R.errorHasta then R.errorTxt = nil; return end
    local txt = Recortar(R.errorTxt, 13, sw - 60)
    local w = Ancho(txt, 13) + 28
    R.Rect(16, 16, w, 28, 0.35, 0.05, 0.07, 0.88, 9)
    R.Borde(16, 16, w, 28, 1, 0.31, 0.35, 0.8, 1, 9)
    R.Text(30, 22, txt, 13, 1, 0.78, 0.80, 1)
end

-- ── Cuadro de texto (matrícula...) ──
function R.DibujarPrompt(sw, sh)
    local p = Menu.prompt
    if not p then return end
    local A = Acento()
    local k = EaseOut((GetGameTimer() - p.t0) / 160)
    R.alpha = k
    R.Rect(0, 0, sw, sh, 0, 0, 0, 0.45)
    local W, H = 460, 168
    local x, y = floor((sw - W) / 2), floor((sh - H) / 2 + 12 * (1 - k))
    R.Sombra(x, y, W, H, 16, 1.2)
    R.Blur(x, y, W, H, 4, 16, 0.05, 0.05, 0.09, 0.50)
    R.GradV(x, y, W, H, 0.12, 0.12, 0.175, 0.96, 0.05, 0.05, 0.08, 0.98, 16)
    R.Borde(x, y, W, H, 1, 1, 1, 0.12, 1, 16)
    R.Circulo(x + 30, y + 32, 3.5, true, A[1], A[2], A[3], 1)
    R.Text(x + 42, y + 21, p.titulo or "Escribe", 16, UI.texto[1], UI.texto[2], UI.texto[3], 1, false, "negrita")
    R.Rect(x + 24, y + 60, W - 48, 42, 1, 1, 1, 0.08, 11)
    R.Borde(x + 24, y + 60, W - 48, 42, A[1], A[2], A[3], 0.85, 1, 11)
    local cursor = (floor(GetGameTimer() / 500) % 2 == 0) and "|" or ""
    R.Text(x + 38, y + 71, p.texto .. cursor, 17, UI.texto[1], UI.texto[2], UI.texto[3], 1)
    R.Text(x + 24, y + 120, "Enter aceptar   ·   Esc cancelar   ·   Supr borra todo", 13, UI.gris[1], UI.gris[2], UI.gris[3], 1)
    R.Text(x + W - 24 - Ancho(#p.texto .. "/" .. p.max, 13), y + 120, #p.texto .. "/" .. p.max, 13, A[1], A[2], A[3], 1)
    R.alpha = 1
end

-- ── Flechas y aros del mundo (antes DrawMarker) ──
function R.DibujarMundo()
    local L = R.mundo
    for i = 1, #L do
        local m = L[i]
        local en, sx, sy = Proyectar(m.x, m.y, m.z)
        if en then
            -- flecha hacia abajo: contorno oscuro + relleno de color, hecha con filas de 1 px
            for j = 0, 15 do
                local w = 22 * (1 - j / 16)
                R.Rect(sx - w / 2 - 1.5, sy - 30 + j * 1.2 - 1, w + 3, 2.4, 0, 0, 0, 0.55)
            end
            for j = 0, 14 do
                local w = 18 * (1 - j / 15)
                R.Rect(sx - w / 2, sy - 29 + j * 1.2, w, 1.4, m.r, m.g, m.b, 1)
            end
            if m.aro then
                local ea, ax, ay = Proyectar(m.aro.x, m.aro.y, m.aro.z)
                if ea then
                    R.Circulo(ax, ay, 26, false, 0, 0, 0, 0.5, 4)
                    R.Circulo(ax, ay, 26, false, m.r, m.g, m.b, 0.95, 2)
                end
            end
        end
        L[i] = nil
    end
end

-- ── Contorno del coche apuntado: caja 3D en el overlay ──
function R.CajaEntidad(e, A)
    local mn, mx = GetModelDimensions(GetEntityModel(e))
    local P = R.caja or {}
    R.caja = P
    local n = 0
    for xi = 0, 1 do for yi = 0, 1 do for zi = 0, 1 do
        local w = GetOffsetFromEntityInWorldCoords(e, xi == 0 and mn.x or mx.x, yi == 0 and mn.y or mx.y, zi == 0 and mn.z or mx.z)
        local en, sx, sy = Proyectar(w.x, w.y, w.z)
        n = n + 1
        P[n] = en and { sx, sy } or false
    end end end
    for a = 0, 7 do
        for _, bit in ipairs({ 1, 2, 4 }) do
            if a & bit == 0 then
                local p1, p2 = P[a + 1], P[a + bit + 1]
                if p1 and p2 then
                    R.Linea(p1[1], p1[2], p2[1], p2[2], A[1], A[2], A[3], 0.25, 5)
                    R.Linea(p1[1], p1[2], p2[1], p2[2], A[1], A[2], A[3], 0.95, 2)
                end
            end
        end
    end
end

local function DibujarMenu(sw, sh)
    local e = EaseOut(Anim.open)
    local A = Acento()
    EmpezarHits()

    -- Cambio de sección: el contenido entra deslizando
    if Menu.seccion ~= Anim.ultimaTab then
        Anim.dirTab, Anim.contenido, Anim.ultimaTab = Menu.dirSec, 0, Menu.seccion
    end
    Anim.contenido = Suave(Anim.contenido, 1, 12)

    local W, H = UI.w, UI.h
    -- Que la ventana no pueda salirse de la pantalla al arrastrarla
    Config.ventanaX = Clamp(Config.ventanaX, -(sw - W) / 2 - W + 140, (sw - W) / 2 + W - 140)
    Config.ventanaY = Clamp(Config.ventanaY, -(sh - H) / 2, (sh - H) / 2 + H - 60)
    local x = floor((sw - W) / 2 + Config.ventanaX)
    local y = floor((sh - H) / 2 + Config.ventanaY + 24 * (1 - e))  -- entra deslizando desde abajo
    -- Zona para arrastrar la ventana (la franja superior, fuera de los botones)
    NuevoHit("mover", x + UI.lateral, y, W - UI.lateral - 70, 90)
    R.alpha, R.ox = e, 0

    -- ── Ventana: cristal oscuro con sombra, brillo de color y borde fino ──
    local RADIO = 16
    R.Sombra(x, y, W, H, RADIO, 1)
    R.Blur(x, y, W, H, 4, RADIO, 0.05, 0.05, 0.09, 0.45)
    R.GradV(x, y, W, H, 0.115, 0.115, 0.170, 0.94, 0.045, 0.045, 0.075, 0.97, RADIO)
    if R.Clip(x, y, W, H) then
        R.Brillo(x + W - 130, y + 20, 260, A[1], A[2], A[3], 0.22)
        R.Brillo(x + 280, y + H + 60, 280, A[1], A[2], A[3], 0.14)
        R.FinClip()
    end
    R.Borde(x, y, W, H, 1, 1, 1, 0.11, 1, RADIO)

    -- Barra lateral (opaca, con las esquinas del lado izquierdo redondas)
    local F = UI.lateralC
    R.Rect(x, y, UI.lateral, H, F[1], F[2], F[3], 1, RADIO)
    R.Rect(x + UI.lateral - RADIO, y, RADIO, H, F[1], F[2], F[3], 1)
    R.Rect(x + UI.lateral, y + 16, 1, H - 32, 1, 1, 1, 0.07)

    Logo(x + 36, y + 38)

    -- Iconos de sección (barra lateral)
    local sec = SeccionActual()
    local iconos = IconosRel()
    for k = 1, #iconos do
        local ic = iconos[k]
        if ic.i == Menu.seccion then
            -- Posición relativa a la ventana: si la arrastras, el resalte va con ella
            local rx, ry = ic.dx, ic.dy
            Anim.lateralY = Anim.lateralY and Suave(Anim.lateralY, ry, 18) or ry
            Anim.lateralX = Anim.lateralX and Suave(Anim.lateralX, rx, 18) or rx
        end
    end
    if Anim.lateralY then
        local lx, ly = x + Anim.lateralX, y + Anim.lateralY
        if Anim.lateralX < UI.lateral then
            R.Rect(x, ly - 16, 3, 32, A[1], A[2], A[3], 1, 1.5)                          -- barra de color pegada al borde
        end
        R.Rect(lx - 22, ly - 22, 44, 44, A[1], A[2], A[3], Menu.col == 0 and 0.22 or 0.13, 13)  -- fondo del icono activo
    end
    local IC = UI.icono
    for k = 1, #iconos do
        local ic = iconos[k]
        local cx, cy = x + ic.dx, y + ic.dy
        local activo = (ic.i == Menu.seccion)
        local s2 = Secciones[ic.i]
        s2._a = s2._a and Suave(s2._a, activo and 1 or 0, 14) or (activo and 1 or 0)
        colIcono[1], colIcono[2], colIcono[3] = Mix(IC[1], A[1], s2._a), Mix(IC[2], A[2], s2._a), Mix(IC[3], A[3], s2._a)
        Icono(s2.icono, cx, cy, colIcono, 1, s2.engranaje and 22 or 24)
        NuevoHit("seccion", cx - 22, cy - 22, 44, 44).i = ic.i
    end

    -- Contenido de la sección (entra deslizando al cambiar)
    R.ox = (1 - Anim.contenido) * 26 * Anim.dirTab
    R.alpha = e * Anim.contenido

    -- Cabecera: ruta pequeña, título grande y línea de color
    R.Text(x + 98, y + 22, sec.nombre, 13, UI.gris[1], UI.gris[2], UI.gris[3], 1)
    R.Text(x + 98, y + 40, Texto(sec.sub), 22, UI.texto[1], UI.texto[2], UI.texto[3], 1, false, "negrita")
    R.GradH(x + 98, y + 82, W - 98 - 34, 2, A[1], A[2], A[3], 0.75, A[1], A[2], A[3], 0.0, 1)

    -- Paneles (dos columnas)
    local ffx, ffy, ffw, ffh
    local paneles = sec.paneles
    local p1, p2 = paneles[1], paneles[2]
    if p1 then
        local fx, fy, fw, fh = DibujarPanel(p1, 1, x + 96, y + 104, 354, A, Menu.pos[1])
        if Menu.col == 1 then ffx, ffy, ffw, ffh = fx, fy, fw, fh end
        if p2 then
            fx, fy, fw, fh = DibujarPanel(p2, 2, x + 462, y + 104, 354, A, Menu.pos[2])
            if Menu.col == 2 then ffx, ffy, ffw, ffh = fx, fy, fw, fh end
        end
    end

    -- Marca de foco del teclado (se desliza entre opciones y paneles)
    if ffx then
        local fx, fy = ffx - x, ffy - y
        local Fo = Anim.foco
        if not Fo then Fo = { x = fx, y = fy, w = ffw, h = ffh }; Anim.foco = Fo end
        Fo.x, Fo.y = Suave(Fo.x, fx, 20), Suave(Fo.y, fy, 20)
        Fo.w, Fo.h = Suave(Fo.w, ffw, 20), Suave(Fo.h, ffh, 20)
        R.Rect(x + Fo.x - 8, y + Fo.y + 6, 3, Fo.h - 12, A[1], A[2], A[3], 1, 1.5)
        R.Rect(x + Fo.x - 10, y + Fo.y + 4, 7, Fo.h - 8, A[1], A[2], A[3], 0.18, 3.5)
    else
        Anim.foco = nil
    end

    -- Barra de estado: descripción de la opción con el foco
    local it = ItemFoco()
    local texto
    if Menu.esperandoTecla then
        texto = "Pulsa la tecla nueva. Esc para cancelar."
    elseif Menu.escribiendo then
        texto = "Escribiendo (el juego no recibe el teclado)  ·  Enter o Esc para terminar  ·  Supr borra todo"
    elseif Config.descripciones and it and it.desc then
        texto = it.desc
        if type(texto) == "function" then texto = texto() end
    end
    texto = texto or "Flechas: moverte   ·   Enter: elegir   ·   Esc: atrás   ·   " .. NombreTecla(TECLA_MENU) .. ": cerrar"
    local clave = texto or ""
    if clave ~= Anim.descIdx then Anim.descIdx, Anim.descA = clave, 0 end
    Anim.descA = Suave(Anim.descA, 1, 14)
    R.alpha, R.ox = e, 0
    R.Rect(x + 96, y + H - 46, W - 96 - 34, 30, 1, 1, 1, 0.045, 11)
    if texto then
        R.alpha = e * Anim.descA
        R.ox = (1 - Anim.descA) * 8
        R.Circulo(x + 112, y + H - 31, 3, true, A[1], A[2], A[3], 1)
        R.Text(x + 124, y + H - 40, PrimeraLinea(texto), 13, UI.gris[1] + 0.2, UI.gris[2] + 0.2, UI.gris[3] + 0.2, 1)
    end
    R.alpha, R.ox = e, 0
    R.Text(x + W - 30 - Ancho(VERSION, 12), y + H - 38, VERSION, 12, UI.gris[1], UI.gris[2], UI.gris[3], 0.8)

    -- Cursor propio en el overlay (el de GTA quedaría tapado por la ventana)
    if Menu.abierto then DibujarCursor(Raton.x, Raton.y) end

    R.alpha, R.ox = 1, 0
end

-- ═════════════════════════════════════════════════════════
-- HUD EN JUEGO
-- ═════════════════════════════════════════════════════════
-- (Anim.hud se actualiza en DibujarTodo, que decide si hay que dibujarlo)
local function DibujarHUDJuego(sw, sh)
    local linea
    if not Config.activado then
        linea = "Cargar coches desactivado   ·   F10 menú"
    elseif vehiculo then
        linea = K("lanzar") .. " Lanzar      " .. K("agarrar") .. " Soltar"
    elseif apuntado then
        linea = K("agarrar") .. " Coger vehículo"
    else
        linea = "Apunta a un vehículo   ·   F10 menú"
    end
    local activo = Config.activado and (vehiculo or apuntado)
    local lp = LineaPosesion()
    if lp and (Pos.activo or not vehiculo) then linea, activo = lp, true end
    local A = Acento()

    R.alpha = Anim.hud
    local w = Ancho(linea, 14) + 40
    local x, y = sw / 2 - w / 2, sh - 76
    R.Pildora(x, y, w, 34, A, activo and 1 or 0.25)
    R.TextC(sw / 2, y + 8, linea, 14, UI.texto[1], UI.texto[2], UI.texto[3], activo and 1 or 0.65)
    R.alpha = 1
end

local dibujarHud = false

-- Barra del modo Superman (encima de la ayuda de teclas): coches arriba, objetivo y teclas.
-- La línea de texto se prepara 4 veces por segundo en Super (no crea texto nuevo cada frame).
function Super.Dibujar(sw, sh)
    local linea = Super.linea
    if not linea or linea == "" then return end
    local A = Acento()
    local max = math.max(math.floor(Config.supermanMax + 0.5), 1)
    local w = Ancho(linea, 14) + 40
    local x, y = sw / 2 - w / 2, sh - (dibujarHud and 120 or 76)
    R.Pildora(x, y, w, 34, A, Super.nArriba / max)
    R.TextC(sw / 2, y + 8, linea, 14, UI.texto[1], UI.texto[2], UI.texto[3], 1)
end

local function DibujarDentro()
    R.Begin()
    R.alpha, R.ox = 1, 0
    local w, h = R.Pantalla()
    Extras.DibujarMarcas()
    R.DibujarMundo()
    if Config.contorno and apuntado and DoesEntityExist(apuntado) then R.CajaEntidad(apuntado, Acento()) end
    if Super.activo then Super.Dibujar(w, h) end
    if dibujarHud then DibujarHUDJuego(w, h) end
    if Anim.open > 0 then DibujarMenu(w, h) end
    if Menu.prompt then R.DibujarPrompt(w, h) end
    R.DibujarAvisos(w, h)
    R.DibujarError(w, h)
end

local function DibujarTodo()
    Anim.dt = min(GetFrameTime(), 0.1)
    Anim.t  = GetGameTimer() / 1000.0
    Anim.open = Suave(Anim.open, Menu.abierto and 1 or 0, Menu.abierto and 11 or 16)
    if Anim.open < 0.002 then Anim.open = 0 end
    Anim.hud = Suave(Anim.hud, Menu.abierto and 0.0 or 1.0, 10)
    dibujarHud = (Config.ayudaHud or Pos.activo) and Anim.hud >= 0.01
    local hay = dibujarHud or Anim.open > 0 or Extras.hayMarcas or Super.activo or #R.mundo > 0 or #R.toasts > 0
        or Menu.prompt ~= nil or R.errorTxt ~= nil or (Config.contorno and apuntado ~= nil)

    -- Menú cerrado y sin ayuda en pantalla: una vez enviado un frame vacío, no se toca el overlay
    if not hay and R.vacio then return end

    local ok, err = pcall(DibujarDentro)
    R.alpha, R.ox = 1, 0
    pcall(R.End) -- cerrar el frame siempre, aunque algo falle
    R.vacio = not hay
    if not ok then
        R.vacio = false
        if err ~= R.ultimoErrorDibujo then
            R.ultimoErrorDibujo = err
            print("[cargar coches] Error dibujando con Susano: " .. tostring(err))
        end
    end
end

-- ═════════════════════════════════════════════════════════
-- BUCLE PRINCIPAL
-- ═════════════════════════════════════════════════════════
local controlesBloqueados = { 24, 25, 37, 44, 45, 140, 141, 142, 257, 263, 264 } -- atacar, apuntar, armas
local controlesEntrar     = { 23, 75, 49, 145 } -- entrar / salir de vehículo

-- Evita subirse al coche que llevas (o al que acabas de soltar/lanzar)
local function BloquearEntrar(ped)
    for i = 1, #controlesEntrar do DisableControlAction(0, controlesEntrar[i], true) end
    local veh = vehiculo or ultimoVeh
    if veh and DoesEntityExist(veh) and GetVehiclePedIsTryingToEnter(ped) == veh then
        ClearPedTasksImmediately(ped)
    end
end
local ultimoCheckAnim = 0
local proxObjetivo = 0

local function LogicaCargar(ped, pAgarrar, pLanzar)
    if vehiculo or GetGameTimer() < bloqueoEntrarHasta then BloquearEntrar(ped) end

    if not Config.activado then
        if vehiculo then Soltar() end
        if apuntado then Contorno(apuntado, false); apuntado = nil end
        return
    end

    if vehiculo then
        -- Soltar si el coche desaparece, mueres o te subes a algo
        if not DoesEntityExist(vehiculo) or IsPedDeadOrDying(ped, true) or IsPedInAnyVehicle(ped, false) then
            Soltar(true); return
        end

        for i = 1, #controlesBloqueados do DisableControlAction(0, controlesBloqueados[i], true) end

        -- Mantener la animación de brazos arriba
        if GetGameTimer() - ultimoCheckAnim > 500 then
            ultimoCheckAnim = GetGameTimer()
            if not IsEntityPlayingAnim(ped, ANIM_CARGAR.dict, ANIM_CARGAR.name, 3) then
                PonerAnimCargar(ped)
            end
        end

        if not Menu.abierto then
            if pLanzar then Lanzar()
            elseif pAgarrar then Soltar() end
        end
    else
        if Menu.abierto then return end
        -- Con el modo Superman en marcha no se coge nada con las manos
        if Super.activo then
            if apuntado then Contorno(apuntado, false); apuntado = nil end
            return
        end
        -- Buscar el coche apuntado recorre todos los vehículos: ~16 veces por segundo basta
        -- (y siempre justo al pulsar la tecla de coger)
        local ahora = GetGameTimer()
        if pAgarrar or ahora >= proxObjetivo then
            proxObjetivo = ahora + 60
            local objetivo = (not IsPedInAnyVehicle(ped, false)) and BuscarObjetivo(pAgarrar) or nil
            if objetivo ~= apuntado then
                Contorno(apuntado, false)
                if Config.contorno then Contorno(objetivo, true) end
                apuntado = objetivo
            end
        end
        if pAgarrar then Agarrar() end
    end
end

-- Con el menú abierto (sin escribir): solo se bloquea lo que usa el menú
-- (ratón, disparar/pegar, flechas, Enter, Esc, Tab, rueda); WASD, saltar, correr, coche... siguen.
local CONTROLES_MENU = { 1, 2, 3, 4, 5, 6, 12, 13, 14, 15, 16, 17, 18, 24, 25, 27, 37, 68, 69, 70, 91, 92, 99, 100,
    106, 114, 115, 116, 140, 141, 142, 143, 172, 173, 174, 175, 176, 177, 187, 188, 189, 190, 191, 194, 199, 200,
    201, 202, 241, 242, 257, 261, 262, 263, 264, 322, 330, 331 }
local function BloquearControlesMenu()
    for i = 1, #CONTROLES_MENU do DisableControlAction(0, CONTROLES_MENU[i], true) end
end

local function Frame()
    local ped = PlayerPedId()
    Teclas.NuevoFrame()

    -- Escribiendo con el teclado de GTA (p. ej. la matrícula): no procesar teclas
    if Tuneo.escribiendo then Menu.ProcesarPrompt(); Super.Frame(ped, false, false); DibujarTodo(); return end

    local p2 = Menu.abierto and SeccionActual().paneles[2] or nil
    if p2 == panelOpciones then ActualizarTuneo()
    elseif p2 == panelRopa then ActualizarRopa()
    elseif p2 == panelAnimOpc then ActualizarAnimaciones(Menu.col == 2 and ItemFoco() or nil)
    elseif p2 == panelAgua then Extras.ActualizarLista(Menu.col == 2 and ItemFoco() or nil)
    elseif p2 == panelSuper then Super.ActualizarLista(Menu.col == 2 and ItemFoco() or nil) end
    if p2 == panelCercanos then
        ActualizarCercanos(false)
        ResaltarLista(Menu.col == 2 and ItemFoco() or nil)
    elseif Pos.resaltado then
        ResaltarLista(nil)
    end

    if Menu.abierto then
        ProcesarMenu()
        if Menu.escribiendo or Menu.esperandoTecla then
            DisableAllControlActions(0)       -- escribiendo: todo el teclado es para el menú
        else
            BloquearControlesMenu()           -- si no: puedes andar/conducir con el menú abierto
        end
        if not Menu.abierto then Menu.escribiendo = nil end
        if Pos.activo then PosesionFrame(ped, false, false, true) end
        LogicaCargar(ped, false, false)
        Extras.MenuAbierto()
        Super.Frame(ped, false, false)        -- los coches siguen girando / volando con el menú abierto
    else
        local _, pAgarrar = Tecla(TeclaDe("agarrar"))
        local _, pLanzar  = Tecla(TeclaDe("lanzar"))
        local _, pPoseer  = Tecla(TeclaDe("poseer"))
        local _, pVolver  = Tecla(TeclaDe("volver"))
        local _, pParar   = Tecla(TeclaDe("pararAnim"))
        local _, pFijar   = Tecla(TeclaDe("fijarAgua"))
        local _, pSuperR  = Tecla(TeclaDe("superRecoger"))
        local _, pSuperL  = Tecla(TeclaDe("superLanzar"))
        local _, pSuperO  = Tecla(TeclaDe("superOrbitar"))
        local _, pSuperM  = Tecla(TeclaDe("superMontar"))
        local aguaAbajo   = Tecla(TeclaDe("agua"))
        if not Pos.activo then Extras.Frame(ped, pFijar, aguaAbajo) else Extras.MenuAbierto() end
        if pParar and not Pos.activo and not vehiculo and not Super.activo then Animac.Parar() end
        -- Justo después de cerrar el menú con Esc, bloquear la pausa de GTA
        if Menu.cierreHasta and GetGameTimer() < Menu.cierreHasta then
            DisableControlAction(0, 199, true); DisableControlAction(0, 200, true); DisableControlAction(0, 322, true)
        end
        if Pulsada(TECLA_MENU) then
            Menu.abierto, Menu.esperandoTecla = true, false
            Menu.col = 0
            Raton.moviendo, Raton.arrastre = nil, nil
            Teclas.Instantanea()
            Super.Frame(ped, false, false, false, false)
        else
            if not Pos.activo then LogicaCargar(ped, pAgarrar, pLanzar) end
            PosesionFrame(ped, pPoseer, pVolver, false)
            -- Superman (L / G / O / M); mientras controlas a un NPC, sin teclas
            Super.Frame(ped, not Pos.activo and pSuperR, not Pos.activo and pSuperL, not Pos.activo and pSuperO, not Pos.activo and pSuperM)
        end
    end

    DibujarTodo()
end

-- Muestra el último error con texto nativo (se ve aunque falle el overlay)
local ultimoError = nil
-- Lo que hace esta copia al ser sustituida por otra: dejar todo como estaba
Citizen.Limpieza = function()
    print("[cargar coches] Copia anterior descargada")
    local me = PlayerPedId()
    pcall(function() if vehiculo then Soltar() end end)
    pcall(function() if Pos and Pos.activo then Soltar_("script recargado") end end)
    pcall(function() if Super.activo and Super.SoltarTodos then Super.SoltarTodos(me, GetGameTimer(), true) end end)
    pcall(function() Extras.PararAgua() end)
    pcall(function() if apuntado then Contorno(apuntado, false); apuntado = nil end end)
    pcall(function() ClearFocus() end)
    pcall(function() FreezeEntityPosition(me, false) end)
    pcall(function() StopAnimTask(me, ANIM_CARGAR.dict, ANIM_CARGAR.name, 2.0) end)
end

Citizen.CreateThread(function()
    -- Si había otra copia, se le da un momento para que se descargue antes de empezar a dibujar
    if Citizen.HABIA_OTRA then Citizen.Real.Wait(500) end
    local okRec, errRec = pcall(R.CargarRecursos)
    if not okRec then print("[cargar coches] No se pudieron cargar los recursos: " .. tostring(errRec)) end
    -- Las imágenes y fuentes ya están cargadas: el texto base64 ya no hace falta (libera memoria)
    for k in pairs(RECURSOS) do RECURSOS[k] = nil end
    -- Recolector generacional (Lua 5.4): pausas mucho más cortas, sin tirones.
    pcall(collectgarbage, "generational")
    pcall(collectgarbage, "collect")

    local fn = {}
    for _, n in ipairs({ "BeginFrame", "SubmitFrame", "DrawRectFilled", "DrawText", "GetAsyncKeyState", "DrawImage", "LoadTextureFromBuffer", "LoadFontFromBuffer" }) do
        fn[#fn + 1] = n .. "=" .. ((type(Susano) == "table" and type(Susano[n]) == "function") and "ok" or "FALTA")
    end
    print("[cargar coches] API de Susano: " .. table.concat(fn, ", "))
    -- Cargar lo guardado (ajustes, teclas, atuendos y, si se pidió, la apariencia)
    local okA, hay = pcall(Guardado.Cargar)
    print("[cargar coches] Ajustes: " .. ((okA and hay) and "cargados" or "por defecto")
        .. " | guardado en archivo: " .. (Guardado.Disponible() and "sí" or "no (usa Exportar/Importar)"))
    if Config.aparienciaAlIniciar then pcall(Guardado.CargarApariencia, true) end

    -- Guardado automático (cada vez que algo cambia, a los 2 s)
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(2000)
            if Guardado.pendiente and not (Raton.moviendo or Raton.arrastre) then
                if Guardado.Disponible() then pcall(Guardado.Guardar, true) else Guardado.pendiente = false end
            end
        end
    end)

    while true do
        Citizen.Wait(0)
        local ok, err = pcall(Frame)
        if not ok and err ~= ultimoError then
            ultimoError = err
            R.errorTxt, R.errorHasta = "[cargar coches] " .. tostring(err), GetGameTimer() + 8000
            print("[cargar coches] ERROR: " .. tostring(err))
        end
    end
end)
