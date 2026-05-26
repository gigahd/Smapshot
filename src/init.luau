local AssetService = game:GetService("AssetService")

local ConvertPartToRegion3int16 = require(script.Helper.ConvertPartToRegion3int16)
local LoadInstances = require(script.Instances.LoadInstances)
local LoadLighting = require(script.Lighting.LoadLighting)
local LoadTerrain = require(script.Terrain.LoadTerrain)
local SaveInstances = require(script.Instances.SaveInstances)
local SaveLighting = require(script.Lighting.SaveLighting)
local SaveTerrain = require(script.Terrain.SaveTerrain)


--[=[
    @class Smapshot

    Smapshot allows for dynamic saving and loading of maps.
]=]
local Smapshot = {}

local idCache: { [number]: Instance } = {}

--[=[
    @interface TerrainConfig
    @within Smapshot
    .slice (BasePart | Region3int16)? -- Region of terrain to save. If a `BasePart` is provided it is converted to a `Region3int16`. When `nil`, all terrain is saved.
]=]
export type TerrainConfig = {
    slice: (BasePart | Region3int16)?,
}

--[=[
    @interface LightingConfig
    @within Smapshot
    .effectsWhiteList { string }? -- ClassNames of `Lighting` effects to include.
    .effectsBlackList { string }? -- ClassNames of `Lighting` effects to exclude.
]=]
export type LightingConfig = {
    effectsWhiteList: { string }?,
    effectsBlackList: { string }?,
}

--[=[
    @interface InstanceConfig
    @within Smapshot
    .ignoreParents boolean? -- When `true`, instances are saved without recording their original parent path.
]=]
export type InstanceConfig = {
    ignoreParents: boolean?,
}

--[=[
    @interface SnapshotConfig
    @within Smapshot
    .name string? -- Name applied to the returned snapshot `Folder`.
    .saveLocation Instance? -- If provided, the snapshot is parented here with a unique name.
    .saveDefaults boolean? -- When `true`, properties that match Roblox defaults are still serialized.
    .terrain TerrainConfig? -- Terrain to capture. Omit to skip terrain.
    .instances { Instance }? -- Instances to capture. Omit to skip instances.
    .instanceConfig InstanceConfig? -- Additional options for instance saving.
    .lighting LightingConfig? -- Lighting settings to capture. Omit to skip lighting.
]=]
export type SnapshotConfig = {
    name: string?,
    saveLocation: Instance?,
    saveDefaults: boolean?,
    terrain: TerrainConfig?,
    instances: { Instance }?,
    instanceConfig: InstanceConfig?,
    lighting: LightingConfig?,
}

local MAX_NAME_COUNT = 1000
local SMAPSHOT_MARK = "__Smapshot"

local function FindFittingName(snapshot: Folder, parent: Instance): string
    local name = snapshot.Name
    local originalName = name
    local number = 1
    while number <= MAX_NAME_COUNT do
        local exists = parent:FindFirstChild(name)
        if not exists then
            return name
        end
        name = `{originalName}_{number}`
        number += 1
    end
    error(`{originalName} is not available (exceeded max count of {MAX_NAME_COUNT})`)
end

--[=[
    Creates a snapshot of terrain, instances, and/or lighting based on the supplied [SnapshotConfig].

    The returned `Folder` can later be passed to [Smapshot.Load] to restore the captured state.
    If `config.saveLocation` is set, the folder is parented there with a unique name.

    ```lua
    local snapshot = Smapshot.Snapshot({
        name = "Arena",
        saveLocation = game:GetService("ReplicatedStorage"),
        terrain = { slice = workspace.ArenaBounds },
        instances = workspace.Arena:GetChildren(),
        lighting = { effectsBlackList = { "Sky" } },
    })
    ```

    @param config -- Describes what to capture and where to store the result.
    @return Folder -- A snapshot containing the serialized map data.
]=]
function Smapshot.Snapshot(config: SnapshotConfig): Folder
    local snapshot = Instance.new("Folder")

    local terrainConfig = config.terrain
    if terrainConfig then
        local slice = if typeof(terrainConfig.slice) == "Instance" and terrainConfig.slice:IsA("BasePart")
            then ConvertPartToRegion3int16(terrainConfig.slice)
            else terrainConfig.slice
        local result = SaveTerrain(slice, config.saveDefaults)
        result.Parent = snapshot
    end
    local instances = config.instances
    if instances then
        local ignoreParents = config.instanceConfig ~= nil and config.instanceConfig.ignoreParents
        local result = SaveInstances(instances, ignoreParents)
        result.Parent = snapshot
    end
    local lightingConfig = config.lighting
    if lightingConfig then
        local result =
            SaveLighting(lightingConfig.effectsWhiteList, lightingConfig.effectsBlackList, config.saveDefaults)
        result.Parent = snapshot
    end
    if config.name then
        snapshot.Name = config.name
    end
    local location = config.saveLocation
    if location then
        FindFittingName(snapshot, location)
        snapshot.Parent = location
    end

    snapshot:SetAttribute(SMAPSHOT_MARK, true)

    return snapshot
end

local function LoadFromInstance(snapshot: Instance, keepDirty: boolean?)
    assert(Smapshot.IsSnapshot(snapshot), `Trying to load an invalid save file. ({snapshot.Name})`)
    local terrain = snapshot:FindFirstChild("MapTerrain")
    if terrain and terrain:IsA("TerrainRegion") then
        LoadTerrain(terrain, keepDirty)
    end
    local instances = snapshot:FindFirstChild("Instances")
    if instances and instances:IsA("Folder") then
        LoadInstances(instances)
    end
    local lighting = snapshot:FindFirstChild("Lighting")
    if lighting and lighting:IsA("Folder") then
        LoadLighting(lighting, keepDirty)
    end
    return snapshot
end

local function LoadFromAssetId(snapshotId: number, keepDirty: boolean?)
    local cached = idCache[snapshotId]
    if cached then
        return LoadFromInstance(cached, keepDirty)
    end
    local asset = AssetService:LoadAssetAsync(snapshotId)
    local snapshot = asset:GetChildren()[1]
    idCache[snapshotId] = snapshot
    return LoadFromInstance(snapshot, keepDirty)
end

--[=[
    Checks if the input has been made by [Smapshot.Snapshot].

    ```lua
    Smapshot.IsSnapshot(Smapshot.Snapshot({})) -- true
    Smapshot.IsSnapshot(Instance.new("Folder")) -- false
    ```

    @param snapshot -- The snapshot you are trying to validate.
    @return boolean -- The result of the validation.
]=]
function Smapshot.IsSnapshot(snapshot: Instance): boolean
    return snapshot:GetAttribute(SMAPSHOT_MARK) ~= nil
end

--[=[
    Loads a snapshot folder previously produced by [Smapshot.Snapshot].

    Use [Smapshot.LoadAssetAsync] when loading from a Roblox asset id instead.

    ```lua
    Smapshot.Load(snapshot)
    ```

    @param snapshot -- The Snapshot to load.
    @param keepDirty -- When `true`, existing terrain and lighting state is preserved instead of being cleared first.
    @return Folder -- The loaded snapshot.
]=]
function Smapshot.Load(snapshot: Folder, keepDirty: boolean?): Folder
    return LoadFromInstance(snapshot, keepDirty) :: Folder
end

--[=[
    Loads a snapshot from a Roblox asset id.

    The asset is fetched via `AssetService:LoadAssetAsync` and cached for subsequent loads.
    Use [Smapshot.Load] when loading from an in-memory snapshot `Folder` instead.

    ```lua
    Smapshot.LoadAssetAsync(1234567890)
    ```

    @yields
    @param assetId -- Asset id of an uploaded snapshot.
    @param keepDirty -- When `true`, existing terrain and lighting state is preserved instead of being cleared first.
    @return Folder -- The loaded snapshot.
]=]
function Smapshot.LoadAssetAsync(assetId: number, keepDirty: boolean?): Folder
    return LoadFromAssetId(assetId, keepDirty) :: Folder
end

return Smapshot
