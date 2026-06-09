local AssetService = game:GetService("AssetService")

local ConvertPartToRegion3int16 = require(script.Helper.ConvertPartToRegion3int16)
local LoadInstances = require(script.Instances.LoadInstances)
local LoadLighting = require(script.Lighting.LoadLighting)
local LoadMaterial = require(script.Material.LoadMaterial)
local LoadMusic = require(script.Music.LoadMusic)
local LoadTerrain = require(script.Terrain.LoadTerrain)
local LoadWorkspace = require(script.Workspace.LoadWorkspace)
local SaveInstances = require(script.Instances.SaveInstances)
local SaveLighting = require(script.Lighting.SaveLighting)
local SaveMaterial = require(script.Material.SaveMaterial)
local SaveMusic = require(script.Music.SaveMusic)
local SmapshotConfig = require(script.SmapshotConfig)
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
    .whitelist { string }? -- Names of `Lighting` children (effects, atmospheres, skies) to include. Mutually exclusive with `blacklist`.
    .blacklist { string }? -- Names of `Lighting` children to exclude.
]=]
export type LightingConfig = {
    whitelist: { string }?,
    blacklist: { string }?,
}

--[=[
    @interface InstanceConfig
    @within Smapshot
    .instances { Instance } -- Instances to capture.
    .saveParents boolean? -- When `true`, each instance's original parent path is recorded so it can be restored on load. Defaults to `false`.
]=]
export type InstanceConfig = {
    instances: { Instance },
    saveParents: boolean?,
}

--[=[
    @interface WorkspaceConfig
    @within Smapshot
    .whitelist { string }? -- Names of `Workspace` children to include. `Terrain` and `CurrentCamera` are always skipped here. Mutually exclusive with `blacklist`.
    .blacklist { string }? -- Names of `Workspace` children to exclude.
    .saveCameraCFrame boolean? -- When `true`, the current `Camera.CFrame` is captured and restored on load.
]=]
export type WorkspaceConfig = {
    whitelist: { string }?,
    blacklist: { string }?,
    saveCameraCFrame: boolean?,
}

--[=[
    @interface MusicConfig
    @within Smapshot
    .whitelist { string }? -- Names of `SoundService` children to include. Mutually exclusive with `blacklist`.
    .blacklist { string }? -- Names of `SoundService` children to exclude.
]=]
export type MusicConfig = {
    whitelist: { string }?,
    blacklist: { string }?,
}

--[=[
    @interface MaterialConfig
    @within Smapshot
    .whitelist { string }? -- Names of `MaterialService` children to include. Mutually exclusive with `blacklist`.
    .blacklist { string }? -- Names of `MaterialService` children to exclude.
    .materialFilter { Enum.Material }? -- If provided, only `MaterialVariant`s whose `BaseMaterial` is in this list are captured.
]=]
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
    .terrainConfig TerrainConfig? -- Terrain to capture. Omit to skip terrain.
    .lightingConfig LightingConfig? -- `Lighting` properties and children to capture. Omit to skip lighting.
    .workspaceConfig WorkspaceConfig? -- `Workspace` properties and children to capture. Omit to skip workspace.
    .musicConfig MusicConfig? -- `SoundService` properties and children to capture. Omit to skip music.
    .materialConfig MaterialConfig? -- `MaterialService` properties and material variants to capture. Omit to skip materials.
    .instanceConfig InstanceConfig? -- Arbitrary instances to capture. Omit to skip instance saving.
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


--[=[
    @interface SimpleLoadOverwrite
    @within Smapshot
    .keepDirty boolean? -- When `true`, existing state is preserved instead of being cleared before this section is applied. Overrides `globalKeepDirty` for this section.
    .consume boolean? -- When `true`, the section's children are reparented into the target service instead of cloned, and the section is tagged so it is skipped on subsequent loads. Overrides `globalConsume` for this section.
    .ignoreOnLoad boolean? -- When `true`, this section is skipped entirely on load.
]=]
export type SimpleLoadOverwrite = {
    keepDirty: boolean?,
    consume: boolean?,
    ignoreOnLoad: boolean?,
}

--[=[
    @interface LoadOverwrite
    @within Smapshot
    .keepDirty boolean? -- When `true`, existing state is preserved instead of being cleared before this section is applied. Overrides `globalKeepDirty` for this section.
    .consume boolean? -- When `true`, the section's children are reparented into the target service instead of cloned, and the section is tagged so it is skipped on subsequent loads. Overrides `globalConsume` for this section.
    .ignoreOnLoad boolean? -- When `true`, this section is skipped entirely on load.
    .ignoreOnClear { Instance }? -- Instances to leave in place when the target service is cleared (only applies when `keepDirty` is not set, since that is the only path that clears).
]=]
export type LoadOverwrite = SimpleLoadOverwrite & {
    ignoreOnClear: { Instance }?,
}

--[=[
    @interface LoadConfig
    @within Smapshot
    .globalConsume boolean? -- Default `consume` applied to every section that does not set its own. See [SimpleLoadOverwrite].
    .globalKeepDirty boolean? -- Default `keepDirty` applied to every section that does not set its own.
    .globalIgnoreOnClear { Instance }? -- Default `ignoreOnClear` applied to every clearing section (`Lighting`/`Workspace`/`SoundService`/`MaterialService`) that does not set its own. See [LoadOverwrite].
    .terrain SimpleLoadOverwrite? -- Overrides for the terrain section.
    .light LoadOverwrite? -- Overrides for the `Lighting` section.
    .workspace LoadOverwrite? -- Overrides for the `Workspace` section.
    .music LoadOverwrite? -- Overrides for the `SoundService` (music) section.
    .material LoadOverwrite? -- Overrides for the `MaterialService` section.
    .instance SimpleLoadOverwrite? -- Overrides for the saved-instances section.
]=]
export type LoadConfig = {
    globalConsume: boolean?,
    globalKeepDirty: boolean?,
    globalIgnoreOnClear: { Instance }?,
    terrain: SimpleLoadOverwrite?,
    light: LoadOverwrite?,
    workspace: LoadOverwrite?,
    music: LoadOverwrite?,
    material: LoadOverwrite?,
    instance: SimpleLoadOverwrite?,
}

local MAX_NAME_COUNT = 1000

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

local function GetIdentifier()
    return SmapshotConfig.MARK
end

--[=[
    Creates a snapshot of any combination of terrain, lighting, workspace, music, materials,
    and arbitrary instances based on the supplied [SnapshotConfig]. Any config field that is
    omitted is skipped.

    The returned `Folder` can later be passed to [Smapshot.Load] to restore the captured state.
    If `config.saveLocation` is set, the folder is parented there with a unique name.

    ```lua
    local snapshot = Smapshot.Snapshot({
        name = "Arena",
        saveLocation = game:GetService("ReplicatedStorage"),
        terrainConfig = { slice = workspace.ArenaBounds },
        lightingConfig = { blacklist = { "Sky" } },
        workspaceConfig = { saveCameraCFrame = true },
        instanceConfig = { instances = { game:GetService("ReplicatedStorage").Arena.Weapons } },
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
        local result = SaveInstances(instanceConfig.instances or {}, instanceConfig.saveParents)
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
    else
        snapshot.Name = "Snapshot"
    end
    local location = config.saveLocation
    if location then
        snapshot.Name = FindFittingName(snapshot, location)
        snapshot.Parent = location
    end

    snapshot:SetAttribute(`{GetIdentifier()}_Compatibility`, SmapshotConfig.COMPATIBILITY)
    snapshot:SetAttribute(`{GetIdentifier()}_Version`, SmapshotConfig.VERSION)

    return snapshot
end

local function NotCompatibleError(snapshot: Instance)
    if not Smapshot.IsCompatible(snapshot) then
        local loadedVersion = Smapshot.ReadVersion(snapshot)
        if not loadedVersion then
            error(`{snapshot} is not a valid Smapshot`)
        else
            error(`Tried loading missmatching Versions Snapshot: {loadedVersion}, Smapshot Module: {SmapshotConfig.VERSION}`)
        end
    end
end

-- Resolves the effective `keepDirty`/`consume`/`ignoreOnClear` for a section, falling back
-- to the global config values when the section has no overwrite. Returns `shouldLoad = false`
-- when the section is explicitly skipped via `ignoreOnLoad`.
local function ResolveLoadSettings(
    config: LoadConfig,
    overwrite: SimpleLoadOverwrite?
): (boolean, boolean?, boolean?, { Instance }?)
    if not overwrite then
        return true, config.globalKeepDirty, config.globalConsume, config.globalIgnoreOnClear
    end
    if overwrite.ignoreOnLoad then
        return false, nil, nil, nil
    end
    local keepDirty = if overwrite.keepDirty ~= nil then overwrite.keepDirty else config.globalKeepDirty
    local consume = if overwrite.consume ~= nil then overwrite.consume else config.globalConsume
    -- `ignoreOnClear` only exists on `LoadOverwrite` sections; fall back to the global list otherwise.
    local sectionIgnoreOnClear = (overwrite :: LoadOverwrite).ignoreOnClear
    local ignoreOnClear = if sectionIgnoreOnClear ~= nil then sectionIgnoreOnClear else config.globalIgnoreOnClear
    return true, keepDirty, consume, ignoreOnClear
end

-- Finds a section's snapshot child, resolves its load settings and applies it via `load`.
-- Returns `true` when the section was consumed so the caller can invalidate the snapshot.
local function LoadSection<T>(
    snapshot: Instance,
    childName: string,
    className: string,
    config: LoadConfig,
    overwrite: SimpleLoadOverwrite?,
    load: (Instance &  T, boolean?, boolean?, { Instance }?) -> ()
): boolean
    local sectionSnapshot = snapshot:FindFirstChild(childName)
    if not (sectionSnapshot and sectionSnapshot:IsA(className)) then
        return false
    end
    local shouldLoad, keepDirty, consume, ignoreOnClear = ResolveLoadSettings(config, overwrite)
    if not shouldLoad then
        return false
    end
    if sectionSnapshot:GetAttribute("__consumed") == true then
        warn(`Subsection {childName} is already consumed`)
        return false
    end
    load(sectionSnapshot, keepDirty, consume, ignoreOnClear)
    if consume then
        sectionSnapshot:SetAttribute("__consumed", true)
    end
    return consume == true
end

local function LoadFromInstance(snapshot: Instance, config: LoadConfig)
    NotCompatibleError(snapshot)

    -- Each section guards itself via its `__consumed` attribute, so the snapshot folder
    -- as a whole stays a valid Smapshot even after some sections have been consumed.
    LoadSection(snapshot, "MapTerrain", "TerrainRegion", config, config.terrain, LoadTerrain)
    LoadSection(snapshot, "Instances", "Folder", config, config.instance, LoadInstances)
    LoadSection(snapshot, "Lighting", "Folder", config, config.light, LoadLighting)
    LoadSection(snapshot, "Workspace", "Folder", config, config.workspace, LoadWorkspace)
    LoadSection(snapshot, "Music", "Folder", config, config.music, LoadMusic)
    LoadSection(snapshot, "Material", "Folder", config, config.material, LoadMaterial)

    return snapshot
end
--[=[
    Checks if the input has been made by [Smapshot.Snapshot].

    ```lua
    Smapshot.IsCompatible(Smapshot.Snapshot({})) -- true
    Smapshot.IsCompatible(Instance.new("Folder")) -- false
    ```

    @param snapshot -- The snapshot you are trying to validate.
    @return boolean -- The result of the validation.
]=]
function Smapshot.IsCompatible(snapshot: Instance): boolean
    local Version = snapshot:GetAttribute(`{GetIdentifier()}_Compatibility`)
    return Version ~= nil and Version == SmapshotConfig.COMPATIBILITY
end

--[=[
    Reads the Smapshot version string that was stamped onto a snapshot at creation time.
    Returns `nil` if the value is missing (e.g. the instance was not produced by [Smapshot.Snapshot]).

    ```lua
    Smapshot.ReadVersion(Smapshot.Snapshot({})) -- "0.2.0"
    Smapshot.ReadVersion(Instance.new("Folder")) -- nil
    ```

    @param snapshot -- The snapshot to read the version from.
    @return string? -- The stored version string, or `nil` if there is none.
]=]
function Smapshot.ReadVersion(snapshot: Instance): string?
    return snapshot:GetAttribute(`{GetIdentifier()}_Version`) :: string?
end

--[=[
    Loads a snapshot folder previously produced by [Smapshot.Snapshot].

    Use [Smapshot.LoadAssetAsync] when loading from a Roblox asset id instead.

    ```lua
    Smapshot.Load(snapshot)

    -- Reset the workspace but consume everything else (cheaper, one-shot):
    Smapshot.Load(snapshot, {
        globalConsume = true,
        workspace = { consume = false },
    })
    ```

    @param snapshot -- The Snapshot to load.
    @param config -- Optional [LoadConfig] describing how each section is applied: clear vs keep (`keepDirty`), clone vs consume (`consume`), or skip (`ignoreOnLoad`). Per-section values fall back to `globalKeepDirty` / `globalConsume`. Omit to clear and clone every section.
    @return Folder -- The loaded snapshot.
]=]
function Smapshot.Load(snapshot: Folder, config: LoadConfig?): Folder
    return LoadFromInstance(snapshot, config or {}) :: Folder
end

return Smapshot
