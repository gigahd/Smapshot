local Workspace = game:GetService("Workspace")

local CopyPropertiesIntoAttributes = require(script.Parent.Parent.Helper.CopyPropertiesIntoAttributes)
local SetSafeAttribute = require(script.Parent.Parent.Helper.SetSafeAttribute)

local Terrain = Workspace.Terrain

local function GetMaterialColorSafe(material: Enum.Material): (boolean, Color3)
    return pcall(function(): Color3
        return Terrain:GetMaterialColor(material)
    end)
end

return function(slice: Region3int16?, saveDefaults: boolean?): TerrainRegion
    print(slice)
    local terrainRegion = Terrain:CopyRegion(if slice then slice else Terrain.MaxExtents)
    terrainRegion.Name = "MapTerrain"
    if slice then
        local value = Instance.new("Vector3Value")
        value.Value = Vector3.new(slice.Min.X, slice.Min.Y, slice.Min.Z)
        value.Name = "CornerValue"
        value.Parent = terrainRegion
    end
    CopyPropertiesIntoAttributes(terrainRegion, Terrain, saveDefaults)

    local materialColors: Folder = Instance.new("Folder")
    materialColors.Name = "MaterialColors"
    materialColors.Parent = terrainRegion

    for _, material: Enum.Material in Enum.Material:GetEnumItems() do
        local success: boolean, color: Color3 = GetMaterialColorSafe(material)
        if not success then
            continue
        end
        SetSafeAttribute(materialColors, material.Name, color)
    end

    return terrainRegion
end
