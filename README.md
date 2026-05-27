# Smapshot

Smapshot is a small package for saving and loading Roblox maps as portable snapshots. Capture a map once, then load it into any place from a snapshot stored in your game, or dynamically from a Roblox asset id at runtime.

## Features

- **Modular capture** — pick any combination of terrain, lighting, workspace, sound, materials, and arbitrary instances. Omit a section and it's skipped.
- **Fine-grained filtering** — whitelist or blacklist children for each subsystem.
- **Region-based terrain** — slice terrain to a `BasePart` or `Region3int16` instead of saving the whole map.
- **Camera capture** — optionally save and restore `Camera.CFrame` with the workspace.
- **Material variant filtering** — restrict captured `MaterialVariant`s by base material.
- **Dynamic loading** — `LoadAssetAsync` pulls snapshots from a Roblox asset id and caches them for repeat loads.
- **Consume mode** — reparent directly into target services instead of cloning, for one-shot loads with zero clone cost.
- **Keep-dirty mode** — additively layer a snapshot onto existing state instead of clearing first.
- **Version-stamped** — snapshots carry a version string; check compatibility with `IsCompatible` and `ReadVersion`.

## Installation

Install via the [Roblox plugin](https://create.roblox.com/store/asset/109345457910746/Smapshot), or as a package via [Wally](https://wally.run/package/gigahd/smapshot) or [Pesde](https://pesde.dev/packages/gigahd/smapshot). The plugin can also drop the package straight into your place.

## Quick example

```lua
local Smapshot = require(path.to.Smapshot)

local snapshot = Smapshot.Snapshot({
    name = "Arena",
    saveLocation = game:GetService("ReplicatedStorage"),
    terrainConfig = { slice = workspace.ArenaBounds },
    lightingConfig = { blacklist = { "Sky" } },
    workspaceConfig = { saveCameraCFrame = true },
    instanceConfig = { instances = { game:GetService("ReplicatedStorage").Arena } },
})

-- later, in the same or a different place:
Smapshot.Load(snapshot)
-- or, from an uploaded asset:
Smapshot.LoadAssetAsync(1234567890)
```

## [Full API Reference →](https://gigahd.github.io/Smapshot/api/Smapshot)
