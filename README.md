[![License: AGPL v3](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](https://github.com/Hand-Lock/mode-13h/blob/main/LICENSE)

# Mode 13h: MS-DOSify!

*An **Iris** shader pack for Minecraft that recreates the look of late-90s **MS-DOS** 3D graphics with deliberate retro accuracy.*

![A screenshot of a Minecraft daytime scene with the shader pack.](https://cdn.modrinth.com/data/cached_images/7f88226fae022bc760918a14c467a6762b129cd6.png)

**Mode 13h: MS-DOSify!** is not just a generic “pixelation” shader. It aims to reproduce the actual visual limitations and quirks that gave old DOS-era 3D games their unmistakable look: low resolution, wobbly software texture mapping, a fixed 256-color palette, colormap lighting, billboarded sprites, and carefully tuned fog.

It supports **Minecraft `1.20.1` and `1.21.1`** with **Iris** or **Oculus**; every release is tested on both. Newer versions are **best-effort**.

> **Recommended render resolution: `1280 x 800`**  
> The shader pack is designed to **downscale by 4x** to an internal **`320 x 200`** image, matching classic **Mode 13h** output.  
> For the most authentic look, stretch the final image to **`4:3`** to reproduce the era’s **non-square pixels**.

## 🧾 Why This Exists

A lot of “retro” shaders stop at chunky pixels and call it a day.

**Mode 13h** goes further. It tries to recreate the specific rendering artifacts that defined old DOS-era 3D, including the quirks modern graphics usually try to hide or eliminate. The goal is not just to look old — it is to feel like an actual late-90s PC pushing textured 3D slightly beyond its comfort zone.

![A screenshot of a Minecraft night-time scene using the shader pack.](https://cdn.modrinth.com/data/cached_images/8b56f91dff28ec8312f6133e71f8c0ba1f3aa826.png)

## ✨ Features

### 📺 Authentic low-resolution output

- The image is downscaled to a **Mode 13h-style `320 x 200`** internal resolution.
- This gives the shader pack the crunchy image structure typical of classic DOS graphics.
- Textures pick their mipmaps for that `320 x 200` image, so distant surfaces don't shimmer.

### 🧱 Quake-style texture mapping

- Like **Quake**, textures are perspective-correct only every **16 pixels** and linear in between, giving the subtle **texture wobble** of software-rendered 3D.
- Want the full **PlayStation-style warping**? Switch to **affine** mapping. Prefer it clean? Perspective-correct is there too.

### 🎨 A real 256-color palette

- Every pixel is drawn from a **fixed 256-color palette**, like a DOS game's own.
- The default **ramp** palette has 16 Minecraft hues (stone, dirt, grass, water, lava, gold…) in 16 shades each.
- Prefer the classic? Pick the **stock VGA palette**, or the computed **RGB332** and **`6 x 6 x 6`** palettes.
- Or play in the colors of a classic: **Wolfenstein 3D**, **Doom**, **Heretic**, **Hexen**, **Quake**, **Duke Nukem 3D**, **Daggerfall**, or the **Mac OS** system palette.

### 💡 Colormap lighting

- Textures only use palette colors, and shadows **step down each color's ramp** instead of dimming smoothly — just like the colormaps of **Doom** and **Quake**.
- Light is **quantized** into configurable brightness steps; **16** matches vanilla Minecraft’s light levels.

### 🌫️ Tuned fog

- Fog keeps vanilla's shapes and curves but starts at **half the vanilla distance** by default, selling depth the way older games did.
- **Start**, **End** and **Density** scales in the menu let you push it thicker or back to vanilla.

### 🪧 Billboarded sprites

- Flowers and grass, torches, lanterns, chains, amethyst, bamboo and hanging propagules render as **2D billboards** that always face the player.
- This mimics the sprite-based tricks commonly used in older 3D games.
- Signs and more blocks can billboard too, with the add-ons below.

### ✋ Painted viewmodel

- First-person hands and held items are drawn **flat and unlit**, like the painted weapon sprites of old shooters.
- An **ordered dither** at `320 x 200` scale breaks up their gradients before the palette.

### 💧 Night water

- Water turns **darker and more opaque** in low light, so rivers and oceans read as black depths at night.

## ⚙️ Configuration

The shader includes a **configuration menu** with several options so you can fine-tune the effect to your taste.

You can adjust things such as:

- **Pixel scale** (resolution reduction)
- **Palette**: ramp, stock VGA, RGB332, `6 x 6 x 6`, Mac OS, seven classic game palettes, or off
- **Colormap lighting**, **light steps** and **ambient floor**
- **Texture mapping**: subdivided, affine or perspective-correct, and the span width
- **Fog** start, end and density
- **Hands**: flat sprite look and dithering strength
- **Add-on compatibility toggles**, which can be enabled or disabled individually

## 🔧 Technical Notes

- Requires **Iris** or **Oculus**. **OptiFine is not supported.**
- Supported: **Minecraft `1.20.1` and `1.21.1`**. Newer versions are best-effort.
- Targets **OpenGL `4.1`**, so it can also run on **macOS**.
- **Lightweight:** a handful of geometry passes and one final pass, no composites.
- **Upgrading from 1.x:** settings for removed or renamed options reset to their defaults.

## 🧩 Add-ons

**Mode 13h** also has optional companion add-ons that expand the billboarding system.

> **Important:** Add-ons are **not included** with the shader pack. They must be **downloaded separately**.

### 🪧 Flatter Signs

[**Flatter Signs**](https://modrinth.com/mod/flatter-signs) is a mod that changes signs into **cross/hatch models**, allowing Mode 13h to billboard them like flowers or grass.

Without the shader pack, those signs simply render as flat cross/hatch objects. With **Mode 13h** enabled, they become proper DOS-style billboarded signs.

### 🧱 Billy-Boarding *(WIP)*

**Billy-Boarding** is a resource pack that changes the **`.json` block models** of selected blocks so they become **cross/hatch-based** and therefore compatible with the shader’s billboarding system.

If you install these add-ons, you can enable or disable their dedicated support from the **shader configuration screen**.

## 🌌 Recommended with a Stylized Sky

For the best overall presentation, it is recommended to pair **Mode 13h** with a **stylized skybox**.

At the moment, the recommended choice is [**Anime Sky**](https://modrinth.com/resourcepack/anime-sky).

A bespoke skybox made specifically for **Mode 13h** may come in the future.

## ❌ What It Is Not

- Not just a simple “pixelation” filter
- Not a generic CRT-style retro effect: it emulates the **signal, not the monitor**. No CRT curvature, scanlines or bloom; stretch to `4:3` yourself.
- Not a clean or modernized take on retro visuals

**Mode 13h** intentionally embraces visual instability, harsh quantization, and awkward old rendering tricks — because that is the whole point.

## 🖇️ Credits

- **Shader pack & idea:** *HandLock_*

## 🛠️ Development

See [`AGENTS.md`](https://github.com/Hand-Lock/mode-13h/blob/main/AGENTS.md).

> *“If the textures don’t wobble, it’s not old enough.”*
