const AssetService = game:GetService("AssetService")
const ServerStorage = game:GetService("ServerStorage")

const ConvertPartToRegion3int16 = require(script.Helper.ConvertPartToRegion3int16)
const LoadInstances = require(script.Instances.LoadInstances)
const SaveInstances = require(script.Instances.SaveInstances)
const LoadLighting = require(script.Lighting.LoadLighting)
const SaveLighting = require(script.Lighting.SaveLighting)
const LoadTerrain = require(script.Terrain.LoadTerrain)
const SaveTerrain = require(script.Terrain.SaveTerrain)
const Map = {}

const idCache: { [number]: Instance } = {}

export type TerrainConfig = {
    slice: (BasePart | Region3int16)?,
}

export type LightingConfig = {
    effectsWhiteList: { string }?,
    effectsBlackList: { string }?,
}

export type InstanceConfig = {
    ignoreParents: boolean?,
}

export type SaveConfig = {
    name: string?,
    saveLocation: Instance?,
    saveDefaults: boolean?,
    terrain: TerrainConfig?,
    instances: { Instance }?,
    instanceConfig: InstanceConfig?,
    lighting: LightingConfig?,
}

const MAX_NAME_COUNT = 1000

local function FindFittingName(export: Folder, parent: Instance): string
    local name = export.Name
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

function Map.Save(config: SaveConfig): Folder
    const export = Instance.new("Folder")

    const terrainConfig = config.terrain
    if terrainConfig then
        const slice = if typeof(terrainConfig.slice) == "Instance" and terrainConfig.slice:IsA("BasePart")
            then ConvertPartToRegion3int16(terrainConfig.slice)
            else terrainConfig.slice
        const result = SaveTerrain(slice, config.saveDefaults)
        result.Parent = export
    end
    const instances = config.instances
    if instances then
        const ignoreParents = config.instanceConfig ~= nil and config.instanceConfig.ignoreParents
        const result = SaveInstances(instances, ignoreParents)
        result.Parent = export
    end
    const lightingConfig = config.lighting
    if lightingConfig then
        const result =
            SaveLighting(lightingConfig.effectsWhiteList, lightingConfig.effectsBlackList, config.saveDefaults)
        result.Parent = export
    end
    if config.name then
        export.Name = config.name
    end
    local location = config.saveLocation
    if location then
        FindFittingName(export, location)
        export.Parent = location
    end
    return export
end

local function LoadFromInstance(toLoad: Instance, keepDirty: boolean?)
    local terrain = toLoad:FindFirstChild("MapTerrain")
    if terrain and terrain:IsA("TerrainRegion") then
        LoadTerrain(terrain, keepDirty)
    end
    local instances = toLoad:FindFirstChild("Instances")
    if instances and instances:IsA("Folder") then
        LoadInstances(instances)
    end
    local lighting = toLoad:FindFirstChild("Lighting")
    if lighting and lighting:IsA("Folder") then
        LoadLighting(lighting, keepDirty)
    end
    return toLoad
end

local function LoadFromAssetId(toLoad: number, keepDirty: boolean?)
    local cached = idCache[toLoad]
    if cached then
        return LoadFromInstance(cached, keepDirty)
    end
    local asset = AssetService:LoadAssetAsync(toLoad)
    local model = asset:GetChildren()[1]
    idCache[toLoad] = model
    return LoadFromInstance(model, keepDirty)
end

function Map.LoadAsync(toLoad: Folder | number, keepDirty: boolean?): Folder
    local type = typeof(toLoad)
    if type == "number" then
        return LoadFromAssetId(toLoad :: number, keepDirty) :: Folder
    elseif type == "Instance" then
        return LoadFromInstance(toLoad :: Instance, keepDirty) :: Folder
    else
        error(`Cannot load from {type}`)
    end
end

return Map
