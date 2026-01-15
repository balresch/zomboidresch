# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Project Zomboid addon/mod. Project Zomboid uses a dual Java/Lua architecture where the main engine is Java and moddable components are Lua (specifically Kahlua, a Lua 5.1 interpreter written in Java).

## Mod Structure

```
ModName/
├── mod.info              # Mod metadata (required)
├── poster.png            # Preview image for mod manager
└── media/
    ├── scripts/          # Item, vehicle, recipe definitions (text files)
    ├── models/           # 3D models (.X, .fbx)
    ├── textures/         # PNG textures (Item_ prefix for item icons)
    ├── sound/            # Audio files (.wav, .ogg)
    └── lua/
        ├── shared/       # Loaded first - shared client/server code
        ├── client/       # UI, context menus, timed actions (loaded second)
        └── server/       # Spawning, farming, weather (loaded on save start only)
```

## mod.info Format

```
name=Mod Display Name
id=UniqueModID
poster=poster.png
description=Mod description
author=Author Name
require=DependencyModID1,DependencyModID2
url=https://example.com
```

## Lua Development Patterns

### Event System
```lua
-- Register callback
local function onPlayerUpdate(player)
    -- logic here
end
Events.OnPlayerUpdate.Add(onPlayerUpdate)

-- Remove callback (must keep function reference)
Events.OnPlayerUpdate.Remove(onPlayerUpdate)

-- Custom events
LuaEventManager.AddEvent("MyCustomEvent")
Events.MyCustomEvent.Add(callback)
triggerEvent("MyCustomEvent", arg1, arg2)
```

### Overwriting Vanilla Functions
```lua
local original_render = ISToolTipInv.render
function ISToolTipInv:render()
    if not CONDITION then
        original_render(self)
    end
    -- custom code
end
```

### Delayed Execution (for mod compatibility)
```lua
Events.OnGameBoot.Add(function()
    -- Code here runs after all mods load
    originalFunction = someFunction
    someFunction = myPatchedVersion
end)
```

## Important Notes

- **Never overwrite existing game files** - hook into functions or use events instead
- **Java Lists are 0-indexed** - iterate with `:size()` and `:get()` methods
- **Cache method calls for performance** - `local inventory = player:getInventory()`
- **Use locals over globals** - faster access and cleaner namespace
- **Store all mod globals in a single namespace table** to avoid pollution
- **Lua files load alphabetically** - use OnGameBoot event to ensure proper load order when patching other mods

## Testing

1. Place mod folder in `Zomboid/mods/` for local testing
2. Use `Zomboid/workshop/` folder for Steam Workshop development
3. Enable debug mode in-game to reload Lua without restarting (main menu only)
4. Server lua files only load when entering a save

## Resources

- [PZwiki Modding Guide](https://pzwiki.net/wiki/Modding)
- [Lua API Documentation](https://pzwiki.net/wiki/Lua_(API))
- [Zomboid Modding Guide (GitHub)](https://github.com/FWolfe/Zomboid-Modding-Guide)
- [ZomboidDoc - Lua Library Compiler](https://github.com/cocolabs/pz-zdoc)
