[![License: AGPL v3](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](https://github.com/Hand-Lock/mode-13h/blob/main/LICENSE)

# Mode 13h: MS-DOSify!

*An **Iris** shader pack for Minecraft that recreates the look of late-90s **MS-DOS** 3D graphics with deliberate retro accuracy.*

![A screenshot of a Minecraft daytime scene with the shader pack.](https://cdn.modrinth.com/data/cached_images/7f88226fae022bc760918a14c467a6762b129cd6.png)

**Mode 13h: MS-DOSify!** is not just a generic “pixelation” shader. It aims to reproduce the actual visual limitations and quirks that gave old DOS-era 3D games their unmistakable look: low resolution, affine texture warping, limited color depth, stepped lighting, billboarded sprites, and carefully tuned fog.

It has currently only been **tested on Minecraft `1.20.1`**, but it **should also work on other versions**.

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

### 🧱 Affine texture mapping

- Textures use **affine mapping** instead of perspective-correct mapping.
- This recreates the classic **texture wobble and warping** seen in older software-rendered 3D games.

### 🎨 Retro palette reduction

- Colors are quantized to a **256-color** style output.
- An optional **`6 x 6 x 6`** palette provides a more limited **216-color** look.

### 💡 Stepped lighting

- Lighting is **quantized** into configurable brightness steps.
- Setting it to **16** steps gives something closer to vanilla Minecraft’s light progression while keeping the retro feel.

### 🌫️ Tuned fog

- Fog is adjusted to better match the mood and readability of old-school 3D visuals.
- It helps sell distance the way older games often did.

### 🪧 Billboarded sprites

- Many blocks and decorations render as **2D billboards** that always face the player.
- This mimics the sprite-based tricks commonly used in older 3D games.

## ⚙️ Configuration

The shader includes a **configuration menu** with several options so you can fine-tune the effect to your taste.

You can adjust things such as:

- **Fog tuning parameters**
- **Affine mapping parameters**
- **Color reduction mode**, including switching between **256-color** and **216-color**
- **Add-on compatibility toggles**, which can be enabled or disabled individually
- **Resolution reduction**
- And other settings for dialing in the exact retro look you want

## 🔧 Technical Notes

- Built for **Iris** and compatible with **Oculus**
- Currently only **tested with Minecraft `1.20.1`**, though it should work on other versions as well
- Targets **OpenGL `4.1`**, so it can also run on **macOS**

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
- Not a generic CRT-style retro effect
- Not a clean or modernized take on retro visuals

**Mode 13h** intentionally embraces visual instability, harsh quantization, and awkward old rendering tricks — because that is the whole point.

## 🖇️ Credits

- **Shader pack & idea:** *HandLock_*

> *“If the textures don’t wobble, it’s not old enough.”*