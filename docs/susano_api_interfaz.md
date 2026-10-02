# Susano: API de dibujo, texto, imágenes, teclas y cámara

Extracto de la documentación de Susano que pasó el usuario (solo la parte de interfaz y cámara).
Los colores aceptan 0..1 o 0..255 (se detecta solo). Origen: arriba a la izquierda, en píxeles.

---

GetCameraAngles
Get the gameplay cameras angles.

Syntax

Susano.GetCameraAngles() -> x, y, z
Parameters
None

Return(s)
x (number): Self explainatory

y (number): Self explainatory

z (number): Self explainatory

Behavior
Self explainatory

Example(s)

-- Change gameplay cam position
local x, y, z = Susano.GetCameraAngles()


LockCameraPos
Lock the gameplay camera position. Useful to make features such as Freecam, spectate, ...

Syntax

Susano.LockCameraPos(state) -> void
Parameters
state (boolean): Self explainatory

Return(s)
None

Behavior
Call with (true) to lock the gameplay camera position.

Call with (false) to unlock it.

Example(s)

-- Change gameplay cam position
Susano.LockCameraPos(true)

local currentPos = GetEntityCoords(PlayerPedId(), true)
Susano.SetCameraPos(currentPos.x + 15.0, currentPos.y, currentPos.z + 15.0)


SetCameraPos
Change the gameplay camera position when camera is locked (Susano.LockCameraPos)

Syntax

Susano.SetCameraPos(x, y, z) -> void
Parameters
x (number): Self explainatory

y (number): Self explainatory

z (number): Self explainatory

Return(s)
None

Behavior
Self explainatory

Example(s)

-- Change gameplay cam position
Susano.LockCameraPos(true)

local currentPos = GetEntityCoords(PlayerPedId(), true)
Susano.SetCameraPos(currentPos.x + 15.0, currentPos.y, currentPos.z + 15.0)



BeginFrame
Start a new Lua render frame. Clears the build buffer for this tick.

Syntax

Susano.BeginFrame() -> void
Parameters
None

Return(s)
None

Behavior
Clears the build buffer only.

Leaves the currently displayed frame untouched.

Subsequent Draw* calls append to the new build buffer.

Calling it again within the same tick re-clears the build buffer.

Does not trigger rendering or a swap by itself.

Example(s)

-- Example 1: one-time overlay (persists until you submit a new frame)
Susano.BeginFrame()
Susano.DrawLine(100,100, 300,200, 1,0,0,1, 2)
Susano.DrawRect(320,100, 120,80, 0,1,0,1, 1.5)
Susano.DrawRectFilled(460,100, 120,80, 0,0,1,0.6)
Susano.DrawCircle(620,140, 40, false, 1,1,0,1, 2, 48)
Susano.DrawText(100,260, "Overlay", 20, 1,1,1,1)
Susano.SubmitFrame()

-- Example 2: animated overlay (updates every frame)
Citizen.CreateThread(function()
  while true do
    local t = GetGameTimer() / 1000.0
    local x = 100 + math.floor(math.sin(t) * 50)

    Susano.BeginFrame()
    Susano.DrawLine(100,100, 300,200, 1,0,0,1, 2)
    Susano.DrawRectFilled(x, 80, 120, 30, 0,0,0,0.5)
    Susano.DrawText(x + 8, 88, ("x=%d"):format(x), 16, 1,1,1,1)
    Susano.SubmitFrame()

    Citizen.Wait(0)
  end
end)




DrawBlurRect
Draw a rectangular region that blurs the pixels underneath it, with an optional colored tint on top.

Syntax

Susano.DrawBlurRect(x, y, w, h[, strength][, rounding][, tintR, tintG, tintB[, tintA]]) -> void
Parameters
x, y (number): Top-left corner in pixels.

w, h (number): Width and height in pixels.

strength (integer, optional): Blur strength (higher = more blur). Default: 3.

rounding (number, optional): Corner rounding in pixels. Default: 0.0.

tintR, tintG, tintB (number, optional): Tint color components in [0..1]. Only applied when all three are provided.

tintA (number, optional): Tint alpha in [0..1]. Default: 1.0. Only used when the tint RGB is provided.

Return(s)
None

Behavior
Enqueues a blur rectangle in the current build buffer. The rectangle blurs whatever is drawn beneath it in the same frame.

If a tint color is supplied, it is composited on top of the blurred region, producing a "frosted glass" effect similar to iOS/macOS UI panels.

Not rendered until Susano.SubmitFrame() is called.

Example(s)

Susano.BeginFrame()

-- Plain blur without tint
Susano.DrawBlurRect(100, 100, 300, 200, 5, 12)

-- Frosted-glass panel with a subtle orange tint
Susano.DrawBlurRect(500, 100, 300, 200, 6, 12, 1.0, 0.48, 0.33, 0.15)

Susano.SubmitFrame()


DrawBorderRect
Draw a filled rectangle with a colored border in a single call.

Syntax

Susano.DrawBorderRect(x, y, w, h, fillR, fillG, fillB, fillA, borderR, borderG, borderB[, borderA][, borderThickness][, rounding]) -> void
Parameters
x, y (number): Top-left corner in pixels.

w, h (number): Width and height in pixels.

fillR, fillG, fillB, fillA (number): Fill color. Accepts 0..1 floats or 0..255 integers.

borderR, borderG, borderB (number): Border color. Accepts 0..1 floats or 0..255 integers.

borderA (number, optional): Border alpha. Default: 1.0.

borderThickness (number, optional): Border thickness in pixels. Default: 1.0.

rounding (number, optional): Corner rounding in pixels. Default: 0.0.

Return(s)
None

Behavior
Draws a filled rectangle first, then overlays a rectangle outline on top with the border color. Combines DrawRectFilled + DrawRect in one call.

Example(s)

Susano.BeginFrame()
Susano.DrawBorderRect(100, 100, 250, 60, 30,30,50,255, 100,100,200,255, 2, 6)
Susano.SubmitFrame()



DrawCircle
Enqueue a circle (filled or outline) in the current build buffer.

Syntax

Susano.DrawCircle(x, y, radius, filled, r, g, b[, a], thickness[, segments]) -> void
Parameters
x, y (number): Center position in pixels.

radius (number): Radius in pixels.

filled (boolean): true for filled, false for outline.

r, g, b (number): Color in [0..1].

a (number, optional): Alpha in [0..1]. Default: 1.0.

thickness (number): Outline thickness in pixels. Used when filled=false. Default: 1.0.

segments (integer, optional): Approximation segments. Default: 32.

Return(s)
None

Behavior
Appends a circle to the build buffer.

Visible after Susano.SubmitFrame(). Persists until next submit.

Example(s)

Susano.BeginFrame()
Susano.DrawCircle(620,140, 40, false, 1,1,0, 1, 2, 48)
Susano.SubmitFrame()


DrawImage
Draw a texture on screen with optional tint, rounding, and UVs.

Syntax

Susano.DrawImage(texId, x, y, w, h [, r,g,b,a [, rounding [, u0,v0,u1,v1]]]) -> void
Parameters
texId (number): Texture handle.

x, y (number): Top-left in screen pixels.

w, h (number): Size in pixels.

r, g, b, a (number, optional): Tint color. Default 1,1,1,1.

rounding (number, optional): Corner radius in px. Default 0.

u0, v0, u1, v1 (number, optional): UV rectangle. Default 0,0,1,1.

Return(s)
None

Behavior
Draws via ImGui AddImage (or AddImageRounded when rounding>0).

Uses the exact pixels of w x h; no aspect correction.

UVs allow cropping or atlas regions.

Fails if texId is invalid or released.

Example(s)

-- basic
local id,w,h = Susano.LoadTexture("logo.png")
Susano.BeginFrame()
Susano.DrawImage(id, 40, 40, w, h)

-- tinted, rounded, scaled
Susano.DrawImage(id, 40, 40+h+12, 128, 128, 1,1,1,1, 10)

-- crop left half via UVs
Susano.DrawImage(id, 200, 40, 128, 128, 1,1,1,1, 0, 0,0,0.5,1)
Susano.SubmitFrame()


DrawLine
Enqueue a line in the current build buffer.

Syntax

Susano.DrawLine(x1, y1, x2, y2, r, g, b[, a], thickness) -> void
Parameters
x1, y1 (number): Start position in pixels.

x2, y2 (number): End position in pixels.

r, g, b (number): Color components in [0..1].

a (number, optional): Alpha in [0..1]. Default: 1.0.

thickness (number): Line thickness in pixels.

Return(s)
None

Behavior
Appends a line command to the build buffer.

Not rendered until Susano.SubmitFrame() is called.

The submitted frame persists on screen until the next Susano.SubmitFrame().

Example(s)

Susano.BeginFrame()
Susano.DrawLine(100,100, 300,200, 1,0,0, 1, 2)
Susano.SubmitFrame()



DrawRect
Draw a rectangle outline with optional rounding.

Syntax

Susano.DrawRect(x, y, w, h, r, g, b[, a], thickness[, rounding]) -> void
Parameters
x, y (number): Top-left corner in pixels.

w, h (number): Width and height in pixels.

r, g, b (number): Color. Accepts 0..1 floats or 0..255 integers (auto-detected).

a (number, optional): Alpha. Default: 1.0.

thickness (number, optional): Border thickness in pixels. Default: 1.0.

rounding (number, optional): Corner rounding in pixels. Default: 0.0.

Return(s)
None

Behavior
Appends a rectangle outline to the build buffer. Visible after Susano.SubmitFrame() or on next present if auto-frame is enabled. Persists until next submit.

Example(s)

Susano.BeginFrame()
Susano.DrawRect(320, 100, 120, 80, 0, 1, 0, 1, 1.5)
-- With rounding
Susano.DrawRect(320, 200, 120, 80, 255, 0, 0, 255, 1.5, 8)
Susano.SubmitFrame()



DrawRectFilled
Draw a filled rectangle with optional rounding.

Syntax

Susano.DrawRectFilled(x, y, w, h, r, g, b[, a][, rounding]) -> void
Parameters
x, y (number): Top-left corner in pixels.

w, h (number): Width and height in pixels.

r, g, b (number): Color. Accepts 0..1 floats or 0..255 integers (auto-detected).

a (number, optional): Alpha. Default: 1.0.

rounding (number, optional): Corner rounding in pixels. Default: 0.0.

Return(s)
None

Behavior
Appends a filled rectangle to the build buffer. Visible after Susano.SubmitFrame() or on next present if auto-frame is enabled.

Example(s)

Susano.BeginFrame()
Susano.DrawRectFilled(100, 100, 200, 50, 0.2, 0.2, 0.8, 0.9, 6)
Susano.SubmitFrame()


DrawRectGradient
Enqueue a filled rectangle with gradient in the current build buffer.

Syntax

Susano.DrawRectGradient(x, y, w, h, 
    r1, g1, b1[, a1], 
    r2, g2, b2[, a2],
    r3, g3, b3[, a3],
    r4, g4, b4[, a4],
    rounding
) -> void
Parameters
x, y (number): Top-left corner in pixels.

w, h (number): Width and height in pixels.

r1, g1, b1 (number): Color in [0..1].

r2, g2, b2 (number): Color in [0..1].

r3, g3, b3 (number): Color in [0..1].

r4, g4, b4 (number): Color in [0..1].

a1, a2, a3, a4 (number, optional): Alpha in [0..1]. Default: 1.0

rounding (number): Rounding, 0 for no rounding

Return(s)
None

Behavior
Appends a filled rectangle outline with gradient to the build buffer.

Visible after Susano.SubmitFrame(). Persists until next submit.

Example(s)

Citizen.CreateThread(function()
    while true do
        Wait(0)

        local t = GetGameTimer() / 2800.0  

        local tl_r = math.abs(math.sin(t * 1.0))
        local tl_g = math.abs(math.sin(t * 0.7))
        local tl_b = math.abs(math.sin(t * 1.3))

        local tr_r = math.abs(math.sin(t * 1.6))
        local tr_g = math.abs(math.sin(t * 0.9))
        local tr_b = math.abs(math.sin(t * 1.1))

        local br_r = math.abs(math.sin(t * 2.0))
        local br_g = math.abs(math.sin(t * 1.4))
        local br_b = math.abs(math.sin(t * 0.8))

        local bl_r = math.abs(math.sin(t * 0.5))
        local bl_g = math.abs(math.sin(t * 1.8))
        local bl_b = math.abs(math.sin(t * 1.2))

        Susano.BeginFrame()
        Susano.DrawRectGradient(300.0, 300.0, 240.0, 240.0, tl_r, tl_g, tl_b, 1.0, tr_r, tr_g, tr_b, 1.0, br_r, br_g, br_b, 1.0, bl_r, bl_g, bl_b, 1.0, 18.0)           
        Susano.SubmitFrame()
    end
end)



DrawRoundedRect
Draw a rounded rectangle outline with rounding as a required parameter.

Syntax

Susano.DrawRoundedRect(x, y, w, h, rounding, r, g, b[, a][, thickness]) -> void
Parameters
x, y (number): Top-left corner in pixels.

w, h (number): Width and height in pixels.

rounding (number): Corner rounding radius in pixels.

r, g, b (number): Color. Accepts 0..1 floats or 0..255 integers.

a (number, optional): Alpha. Default: 1.0.

thickness (number, optional): Border thickness in pixels. Default: 1.0.

Return(s)
None

Behavior
Convenience function that draws a rounded rectangle outline. Same as DrawRect with rounding, but with rounding as a dedicated required parameter for clarity.

Example(s)

Susano.BeginFrame()
Susano.DrawRoundedRect(100, 100, 200, 80, 12, 0, 255, 0, 255, 2)
Susano.SubmitFrame()



DrawRoundedRectFilled
Draw a filled rounded rectangle with rounding as a required parameter.

Syntax

Susano.DrawRoundedRectFilled(x, y, w, h, rounding, r, g, b[, a]) -> void
Parameters
x, y (number): Top-left corner in pixels.

w, h (number): Width and height in pixels.

rounding (number): Corner rounding radius in pixels.

r, g, b (number): Color. Accepts 0..1 floats or 0..255 integers.

a (number, optional): Alpha. Default: 1.0.

Return(s)
None

Behavior
Convenience function that draws a filled rounded rectangle. Same as DrawRectFilled with rounding, but with rounding as a dedicated required parameter.

Example(s)

Susano.BeginFrame()
Susano.DrawRoundedRectFilled(100, 100, 200, 80, 12, 50, 50, 200, 220)
Susano.SubmitFrame()



DrawShadowRect
Draw a filled rectangle with an automatic drop shadow.

Syntax

Susano.DrawShadowRect(x, y, w, h, r, g, b, a[, shadowOffset][, shadowAlpha][, rounding]) -> void
Parameters
x, y (number): Top-left corner in pixels.

w, h (number): Width and height in pixels.

r, g, b, a (number): Fill color. Accepts 0..1 floats or 0..255 integers.

shadowOffset (number, optional): Shadow offset in pixels. Default: 2.0.

shadowAlpha (number, optional): Shadow opacity (0..1). Default: 0.4.

rounding (number, optional): Corner rounding in pixels. Default: 0.0.

Return(s)
None

Behavior
Draws a black shadow rectangle offset by shadowOffset pixels, then draws the main filled rectangle on top. Creates a simple drop-shadow effect.

Example(s)

Susano.BeginFrame()
Susano.DrawShadowRect(200, 200, 300, 100, 40, 40, 60, 255, 3, 0.5, 8)
Susano.SubmitFrame()


DrawText
Draw text at a given position with optional font.

Syntax

Susano.DrawText(x, y, text, size_px, r, g, b[, a][, fontId]) -> void
Parameters
x, y (number): Position in pixels.

text (string): The text to render.

size_px (number): Font size in pixels. Pass 0 to use the font's default size.

r, g, b (number): Color. Accepts 0..1 floats or 0..255 integers (auto-detected).

a (number, optional): Alpha. Default: 1.0.

fontId (number, optional): Font handle from LoadFont/LoadFontFromBuffer. If omitted, uses the current PushFont stack or ImGui default.

Return(s)
None

Behavior
Enqueues a text draw command. The position is floor'd to integer pixels for sharpness. Visible after SubmitFrame() or on next present if auto-frame is enabled.

Example(s)

local font = Susano.LoadFont("C:/Windows/Fonts/arial.ttf", 18)
Susano.BeginFrame()
Susano.DrawText(100, 50, "Hello World", 18, 255, 255, 255, 255, font)
Susano.SubmitFrame()



DrawTextCentered
Draw text horizontally centered at a given X position.

Syntax

Susano.DrawTextCentered(x, y, text, size_px, r, g, b[, a][, fontId]) -> void
Parameters
x, y (number): Center X position and top Y position in pixels.

text (string): The text to render.

size_px (number): Font size in pixels. Pass 0 for the font's default.

r, g, b (number): Color. Accepts 0..1 floats or 0..255 integers (auto-detected).

a (number, optional): Alpha. Default: 1.0.

fontId (number, optional): Font handle from LoadFont/LoadFontFromBuffer.

Return(s)
None

Behavior
Measures the text width, then draws it offset so it is horizontally centered on the X coordinate. Useful for titles, labels, and UI headers.

Example(s)

Susano.BeginFrame()
Susano.DrawTextCentered(960, 50, "Centered Title", 24, 255, 255, 255)
Susano.SubmitFrame()



DrawTextOutlined
Draw text with a 1px outline for readability on any background.

Syntax

Susano.DrawTextOutlined(x, y, text, size_px, r, g, b, a, outR, outG, outB[, outA][, fontId]) -> void
Parameters
x, y (number): Position in pixels.

text (string): The text to render.

size_px (number): Font size in pixels. Pass 0 for the font's default.

r, g, b, a (number): Foreground color. Accepts 0..1 floats or 0..255 integers.

outR, outG, outB (number): Outline color. Accepts 0..1 floats or 0..255 integers.

outA (number, optional): Outline alpha. Default: 1.0.

fontId (number, optional): Font handle from LoadFont/LoadFontFromBuffer.

Return(s)
None

Behavior
Draws 4 offset copies of the text (up, down, left, right by 1px) in the outline color, then draws the foreground text on top. Creates a readable outline effect.

Example(s)

Susano.BeginFrame()
Susano.DrawTextOutlined(100, 100, "Outlined", 20, 255,255,255,255, 0,0,0,255)
Susano.SubmitFrame()



GetTextWidth
Measure the pixel width of a text string at a given font size.

Syntax

Susano.GetTextWidth(text, size_px) -> number
Parameters
text (string): UTF-8 text to measure.

size_px (number): Font size in pixels. If 0, uses default font size.

Return(s)
number: Width in pixels. 0 if no result was available within the internal timeout.

Behavior
Enqueues a measurement request and waits briefly for the Overlay thread to compute width.

Non-drawing operation; does not affect the build buffer.

Result depends on the active Overlay font.

Example(s)

local w = Susano.GetTextWidth("hello overlay", 18)
Susano.BeginFrame()
Susano.DrawRect(100, 240, w + 10, 24, 1,1,1, 1, 1)
Susano.DrawText(105, 260, "hello overlay", 18, 1,1,1, 1)
Susano.SubmitFrame()


LoadFont
Load a TTF/OTF font into ImGui and return its handle.

Syntax

Susano.LoadFont(path, size_px) -> number
Parameters
path (string): Absolute or relative path to a TTF/OTF file.

size_px (number): Native pixel size for this font.

Return(s)
fontId (number): Handle to use with Susano.PushFont.

On error: nil, err (string).

Behavior
Registers the font in the Susano renderer atlas. Must be called once for each font.

The returned fontId is valid for the current session.

Does not change the active font by itself.

Example(s)

local ok, sx, sy = Susano.WorldToScreen(250.0, -1040.0, 29.0)
local id, err = Susano.LoadFont("C:/Windows/Fonts/Consola.ttf", 18)
if not id then 
    print(err) 
end



LoadFontFromBuffer
Load a TTF/OTF font into ImGui and return its handle.

Syntax

Susano.LoadFontFromBuffer(data, size_px) -> number
Parameters
data (string): Raw font bytes (TTF/OTF).

size_px (number): Native pixel size to bake into the atlas.

Return(s)
fontId (number): Handle for Susano.PushFont.

On error: nil, err (string).

Behavior
Adds the font to the renderer atlas; the atlas owns the copied bytes.

Loading a font does not change the active font. Use Susano.PushFont(fontId) to use it.

In Susano.DrawText, pass 0 for size to render at this font’s native size_px; non-zero scales at draw time.

If loaded at runtime, it becomes usable after the atlas is uploaded by the renderer (typically next frame).

Example(s)

local bytes = "" -- font buffer

local id, err = Susano.LoadFontFromBuffer(bytes, 20)
assert(id, err)

Susano.PushFont(id)
Susano.BeginFrame()
Susano.DrawText(1200, 100, "Consolas @ native", 0, 1,1,1,1) -- 0 => native 20px
Susano.SubmitFrame()
Susano.PopFont()


LoadTexture
Load an image file into a DX11 texture.

Syntax

Susano.LoadTexture(path) -> number, number, number
Parameters
path (string): File path (PNG, JPG/JPEG, BMP, GIF*, TGA).

Return(s)
texId (number): Texture handle.

w (number): Width in pixels.

h (number): Height in pixels.

Behavior
Decodes via stb_image to RGBA8, uploads to a Shader Resource View.

GIF*: only the first frame is loaded (no animation).

Keep texId until you call Susano.ReleaseTexture.

Example(s)

local id, w, h = Susano.LoadTexture("logo.png")




LoadTextureFromBuffer
Load a texture from raw image bytes.

Syntax

Susano.LoadTextureFromBuffer(data) -> number, number, number
Parameters
data (string): Image bytes (PNG/JPG/BMP/GIF*/TGA).

Return(s)
texId (number): Texture handle.

w (number): Width in pixels.

h (number): Height in pixels.

Behavior
Same formats and rules as LoadTexture.

Useful for in-memory or downloaded assets.

Example(s)

local imageBytes = "" -- your image bytes
local id, w, h = Susano.LoadTextureFromBuffer(imageBytes)



PopClipRect
Pop the last clipping rectangle from the draw clip stack.

Syntax

Susano.PopClipRect() -> void
Parameters
None.

Return(s)
None

Behavior
Removes the most recently pushed clip rectangle. Must be called after a matching PushClipRect().

Example(s)

Susano.PushClipRect(100, 100, 200, 150)
-- draw commands here are clipped
Susano.PopClipRect()
-- draw commands here are no longer clipped



PopFont
Restore the previous font for this coroutine.

Syntax

Susano.PopFont() -> boolean
Parameters
None

Return(s)
popped (boolean): true if a font was popped, false if the stack was empty.

Behavior
Pops one entry from the per-coroutine font stack.

No effect if the stack is already empty.

Example(s)

Susano.PushFont(id)
-- draw...
local ok = Susano.PopFont()



PushClipRect
Push a clipping rectangle onto the draw clip stack.

Syntax

Susano.PushClipRect(x, y, w, h[, intersect]) -> void
Parameters
x, y (number): Top-left corner of the clip region in pixels.

w, h (number): Width and height of the clip region in pixels.

intersect (boolean, optional): If true, intersects with the current clip rect. Default: true.

Return(s)
None

Behavior
All subsequent draw commands will be clipped to this rectangle until PopClipRect() is called. Clip rects can be nested. Must be paired with a matching PopClipRect().

Example(s)

Susano.BeginFrame()
Susano.PushClipRect(100, 100, 200, 150)
Susano.DrawRectFilled(50, 50, 300, 300, 1, 0, 0)  -- only the part inside 100,100,200,150 is visible
Susano.PopClipRect()
Susano.SubmitFrame()




PushFont
Make a previously loaded font the current font for this coroutine.

Syntax

Susano.PushFont(fontId) -> void
Parameters
fontId (number): Result of Susano.LoadFont.

Return(s)
None

Behavior
Pushes fontId on a per-coroutine font stack.

Affects subsequent Susano.DrawText and Susano.GetTextWidth.

Use size_px = 0 in DrawText to render at this font’s native size.

Example(s)

local id = Susano.LoadFont("C:/Windows/Fonts/RAVIE.TTF", 30)
Susano.PushFont(id)
Susano.DrawText(100, 100, "RAVIE @ native", 0, 1,1,1,1)
Susano.PopFont()



ReleaseTexture
Free a previously loaded texture.

Syntax

Susano.ReleaseTexture(texId) -> boolean
Parameters
texId (number): Handle from a load call.

Return(s)
ok (boolean): true if released, false if id not found.

Behavior
Releases the underlying DX11 SRV. texId becomes invalid.

Example(s)

local imageBytes = ""
local id, w, h = Susano.LoadTextureFromBuffer("logo.png")
local ok = Susano.ReleaseTexture(id)




ResetAllFrames
Clear every coroutine’s build and render buffers. Removes all layers.

Syntax

Susano.ResetAllFrames() -> void
Parameters
None

Return(s)
None

Behavior
Drops all queued and displayed draws from all Lua threads.

Cancels all pending submits.

Next Present renders nothing until new frames are submitted.

Example(s)

-- global wipe
Susano.ResetAllFrames()



ResetFrame
Clear all queued and displayed draw commands for the current Lua coroutine. Empties both build and render buffers and cancels any pending swap.

Syntax

Susano.ResetFrame() -> void
Parameters
None

Return(s)
None

Behavior
Removes this coroutine’s current build buffer and the last submitted render buffer.

Cancels any pending SubmitFrame() for this coroutine.

Effect is immediate on next Overlay rendering (nothing from this coroutine will render).

Other coroutines’ drawings are unaffected.

Example(s)

-- emergency wipe of your overlay
Susano.ResetFrame()

-- rebuild a fresh frame after clearing
Susano.BeginFrame()
Susano.DrawText(40, 40, "reloaded", 18, 1,1,1,1)
Susano.SubmitFrame()


SetAutoFrame
Enable or disable auto-frame mode for the current coroutine.

Syntax

Susano.SetAutoFrame(enabled) -> void
Parameters
enabled (boolean): true to enable, false to disable auto-frame mode.

Return(s)
None

Behavior
When auto-frame is enabled, draw commands are automatically presented each game frame without needing BeginFrame()/SubmitFrame(). The build buffer is swapped to the render buffer and cleared every present. This is simpler for scripts that redraw every tick. BeginFrame()/SubmitFrame() still works normally even with auto-frame enabled.

Example(s)

Susano.SetAutoFrame(true)
-- No BeginFrame/SubmitFrame needed
Susano.DrawRectFilled(100, 100, 200, 50, 255, 0, 0)



SubmitFrame
Publish the current build buffer as the active frame to render on the Overlay.

Syntax

Susano.SubmitFrame() -> void
Parameters
None

Return(s)
None

Behavior
Flags the current build buffer as ready.

Next Overlay swaps to this buffer and starts displaying it.

Stays visible on the Overlay until the next Susano.SubmitFrame().

Does not clear the displayed frame; it replaces it on swap.

Non-blocking.

Example(s)

-- One-shot overlay: persists until another Submit
Susano.BeginFrame()
Susano.DrawLine(100,100, 300,200, 1,0,0,1, 2)
Susano.DrawText(110,90, "Overlay", 18, 1,1,1,1)
Susano.SubmitFrame()

-- Per-frame update
Citizen.CreateThread(function()
  while true do
    local t = GetGameTimer() / 1000.0
    Susano.BeginFrame()
    Susano.DrawText(20, 20, ("t=%.2f"):format(t), 18, 1,1,1,1)
    Susano.SubmitFrame()
    Citizen.Wait(0)
  end
end)




WithClipRect
Execute a callback with a temporary clipping rectangle.

Syntax

Susano.WithClipRect(x, y, w, h, callback) -> void
Parameters
x, y (number): Top-left corner of the clip region in pixels.

w, h (number): Width and height of the clip region in pixels.

callback (function): A function containing draw commands to execute within the clip region.

Return(s)
None

Behavior
Convenience wrapper that pushes a clip rect, executes your callback, then pops the clip rect. Always intersects with the current clip rect. PopClipRect() is called even if the callback errors.

Example(s)

Susano.WithClipRect(100, 100, 200, 150, function()
    Susano.DrawRectFilled(50, 50, 300, 300, 1, 0, 0)
end)




WithFrame
Execute a callback between BeginFrame and SubmitFrame automatically.

Syntax

Susano.WithFrame(callback) -> void
Parameters
callback (function): A function containing draw commands. BeginFrame() is called before it, SubmitFrame() after it.

Return(s)
None

Behavior
Convenience wrapper that calls BeginFrame(), executes your callback, then calls SubmitFrame(). If the callback errors, SubmitFrame() is still called and the error is re-raised.

Example(s)

Susano.WithFrame(function()
    Susano.DrawRectFilled(100, 100, 200, 50, 0, 1, 0)
    Susano.DrawText(110, 110, "Inside WithFrame", 16, 1, 1, 1)
end)




WorldToScreen
Project a 3D world position to 2D screen space.

Syntax

Susano.WorldToScreen(x, y, z) -> boolean, number, number
Parameters
x (number): World X.

y (number): World Y.

z (number): World Z.

Return(s)
ok (boolean): true if the point projects in front of the camera, else false.

sx (number): Screen X in pixels.

sy (number): Screen Y in pixels.

Behavior
Returns ok=false when the point is behind the camera or projection invalid.

Does not clamp; sx, sy can be outside the visible bounds when off-screen.

Coordinates are suitable for Susano.Draw* functions.

Example(s)

local ok, sx, sy = Susano.WorldToScreen(250.0, -1040.0, 29.0)
if ok then
  Susano.DrawCircle(sx, sy, 4, true, 1, 0, 0, 1)
end




GetAsyncKeyState
Gets the raw key state using the Windows GetAsyncKeyState function.

Syntax

Susano.GetAsyncKeyState(vk) -> down, pressed
Parameters
vk (integer): Windows virtual-key code (e.g. 0x41 = A, 0xA0 = VK_LSHIFT).

Return(s)
down (boolean): true if the key is currently held.

pressed (boolean): true if the key transitioned from up → down since the last OS query.

Example(s)

-- A key (0x41)
local down, pressed = Susano.GetAsyncKeyState(0x41)
if pressed then print("A pressed") end
if down then   print("A held")    end







CopyToClipboard
Copy a string to the Windows clipboard as CF_TEXT (ANSI).

Syntax

Susano.CopyToClipboard(string) -> boolean, string
Parameters
text (string): Bytes to copy. NUL-terminated internally.

Return(s)
ok (boolean): true on success.

On error: nil, err (string).

Behavior
Uses OpenClipboard → EmptyClipboard → SetClipboardData(CF_TEXT).

On success the OS owns the memory handle.

ANSI only. Non-ASCII may be mangled. Use a Unicode variant if you need UTF-8/UTF-16.

Fails if the clipboard is busy.

Example(s)

local ok, err = Susano.CopyToClipboard("Test 123")
if not ok then print("clipboard error:", err) end




EnableOverlay
Temporarily blocks in-game input while allowing Susano’s own overlay to handle mouse interactions.

Syntax

Susano.EnableOverlay(bool) -> void
Parameters
state (boolean): Whether or not you enable overlay

Return(s)
None

Behavior
Temporarily blocks in-game input while allowing Susano’s own overlay to handle mouse interactions and draw its cursor. Commonly used when rendering the main menu or other interactive UI elements.

Example(s)

Susano.EnableOverlay(true)





GetClipboardText
Get the windows clipboard content.

Syntax

Susano.GetClipboardText() -> string
Parameters
None

Return(s)
data (string): clipboard content

Behavior
Self explainatory.

Example(s)

local data = Susano.GetClipboardText()
print(data)



GetCursorPos
Returns the actual cursor position used internally by Susano’s overlay system

Syntax

Susano.GetCursorPos() -> Vector2
Parameters
None

Return(s)
cursorPos (Vector2):

x (float): Cursor X position relative to the monitor dimensions. y (float): Cursor Y position relative to the monitor dimensions.

Behavior
Returns the actual cursor position used internally by Susano’s overlay system, not the NUI cursor (which is spoofed by Susano safety measures), allowing precise interaction with ImGui-based elements and accurate mouse tracking within the overlay.

Example(s)

local cursorPos = Susano.GetCursorPos()

