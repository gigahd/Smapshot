local AssetService = game:GetService("AssetService")

local ConvertPartToRegion3int16 = require(script.Helper.ConvertPartToRegion3int16)
local LoadInstances = require(script.Instances.LoadInstances)
local LoadLighting = require(script.Lighting.LoadLighting)
local LoadTerrain = require(script.Terrain.LoadTerrain)
local LoadWorkspace = require(script.Workspace.LoadWorkspace)
local SaveInstances = require(script.Instances.SaveInstances)
local SaveLighting = require(script.Lighting.SaveLighting)
local LoadMaterial = require(script.Material.LoadMaterial)
local SaveMaterial = require(script.Material.SaveMaterial)
local LoadMusic = require(script.Music.LoadMusic)
local SaveMusic = require(script.Music.SaveMusic)
local SaveTerrain = require(script.Terrain.SaveTerrain)
local SaveWorkspace = require(script.Workspace.SaveWorkspace)

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
    .effectsWhitelist { string }? -- ClassNames of `Lighting` effects to include.
    .effectsBlacklist { string }? -- ClassNames of `Lighting` effects to exclude.
]=]
export type LightingConfig = {
    whitelist: { string }?,
    blacklist: { string }?,
}

--[=[
    @interface InstanceConfig
    @within Smapshot
    .ignoreParents boolean? -- When `true`, instances are saved without recording their original parent path.
]=]
export type InstanceConfig = {
    instances: { Instance },
    ignoreParents: boolean?,
}

export type WorkspaceConfig = {
    whitelist: { string }?,
    blacklist: { string }?,
    saveCameraCFrame: boolean?,
}

export type MusicConfig = {
    whitelist: { string }?,
    blacklist: { string }?,
}

export type MaterialConfig = {
    whitelist: { string }?,
    blacklist: { string }?,
    materialFilter: { Enum.Material }?,
}

--[=[
    @interface SnapshotConfig
    @within Smapshot
    .name string? -- Name applied to the returned snapshot `Folder`.
    .saveLocation Instance? -- If provided, the snapshot is parented here with a unique name.
    .saveDefaults boolean? -- When `true`, properties that match Roblox defaults are still serialized.
    .terrain TerrainConfig? -- Terrain to capture. Omit to skip terrain.
    .lighting LightingConfig? -- Lighting settings to capture. Omit to skip lighting.
    .instanceConfig InstanceConfig? -- Additional options for instance saving.
]=]
export type SnapshotConfig = {
    name: string?,
    saveLocation: Instance?,
    saveDefaults: boolean?,
    terrainConfig: TerrainConfig?,
    lightingConfig: LightingConfig?,
    workspaceConfig: WorkspaceConfig?,
    musicConfig: MusicConfig?,
    materialConfig: MaterialConfig?,
    instanceConfig: InstanceConfig?,
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
        lighting = { effectsBlacklist = { "Sky" } },
    })
    ```

    @param config -- Describes what to capture and where to store the result.
    @return Folder -- A snapshot containing the serialized map data.
]=]
function Smapshot.Snapshot(config: SnapshotConfig): Folder
    local snapshot = Instance.new("Folder")

    local terrainConfig = config.terrainConfig
    if terrainConfig then
        local slice = if typeof(terrainConfig.slice) == "Instance" and terrainConfig.slice:IsA("BasePart")
            then ConvertPartToRegion3int16(terrainConfig.slice)
            else terrainConfig.slice
        local result = SaveTerrain(slice, config.saveDefaults)
        result.Parent = snapshot
    end
    local instanceConfig = config.instanceConfig
    if instanceConfig then
        local result = SaveInstances(instanceConfig.instances or {}, instanceConfig.ignoreParents)
        result.Parent = snapshot
    end
    local lightingConfig = config.lightingConfig
    if lightingConfig then
        local result = SaveLighting(lightingConfig.whitelist, lightingConfig.blacklist, config.saveDefaults)
        result.Parent = snapshot
    end
    local workspaceConfig = config.workspaceConfig
    if workspaceConfig then
        local result = SaveWorkspace(
            workspaceConfig.whitelist,
            workspaceConfig.blacklist,
            workspaceConfig.saveCameraCFrame,
            config.saveDefaults
        )
        result.Parent = snapshot
    end
    local musicConfig = config.musicConfig
    if musicConfig then
        local result = SaveMusic(musicConfig.whitelist, musicConfig.blacklist)
        result.Parent = snapshot
    end
    local materialConfig = config.materialConfig
    if materialConfig then
        local result = SaveMaterial(materialConfig.materialFilter, materialConfig.whitelist, materialConfig.blacklist)
        result.Parent = snapshot
    end
    if config.name then
        snapshot.Name = config.name
    end
    local location = config.saveLocation
    if location then
        snapshot.Name = FindFittingName(snapshot, location)
        snapshot.Parent = location
    end

    snapshot:SetAttribute(SMAPSHOT_MARK, true)

    return snapshot
end

local function LoadFromInstance(snapshot: Instance, keepDirty: boolean?)
    assert(Smapshot.IsSnapshot(snapshot), `Trying to load an invalid save file. ({snapshot.Name})`)
    local terrainSnapshot = snapshot:FindFirstChild("MapTerrain")
    if terrainSnapshot and terrainSnapshot:IsA("TerrainRegion") then
        LoadTerrain(terrainSnapshot, keepDirty)
    end
    local instanceSnapshot = snapshot:FindFirstChild("Instances")
    if instanceSnapshot and instanceSnapshot:IsA("Folder") then
        LoadInstances(instanceSnapshot, keepDirty)
    end
    local lightingSnapshot = snapshot:FindFirstChild("Lighting")
    if lightingSnapshot and lightingSnapshot:IsA("Folder") then
        LoadLighting(lightingSnapshot, keepDirty)
    end
    local workspaceSnapshot = snapshot:FindFirstChild("Workspace")
    if workspaceSnapshot and workspaceSnapshot:IsA("Folder") then
        LoadWorkspace(workspaceSnapshot, keepDirty)
    end
    local musicSnapshot = snapshot:FindFirstChild("Music")
    if musicSnapshot and musicSnapshot:IsA("Folder") then
        LoadMusic(musicSnapshot, keepDirty)
    end
    local MaterialSnapshot = snapshot:FindFirstChild("Material")
    if MaterialSnapshot and MaterialSnapshot:IsA("Folder") then
        LoadMaterial(MaterialSnapshot, keepDirty)
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
