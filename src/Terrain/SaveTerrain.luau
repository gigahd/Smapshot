const Workspace = game:GetService("Workspace")

const CopyPropertiesIntoAttributes = require(script.Parent.Parent.Helper.CopyPropertiesIntoAttributes)
const SetSafeAttribute = require(script.Parent.Parent.Helper.SetSafeAttribute)

const Terrain = Workspace.Terrain

const function GetMaterialColorSafe(material: Enum.Material): (boolean, Color3)
    return pcall(function(): Color3
        return Terrain:GetMaterialColor(material)
    end)
end

return function(slice: Region3int16?, saveDefaults: boolean?): TerrainRegion
    print(slice)
    const terrainRegion = Terrain:CopyRegion(if slice then slice else Terrain.MaxExtents)
    terrainRegion.Name = "MapTerrain"
    if slice then
        local value = Instance.new("Vector3Value")
        value.Value = Vector3.new(slice.Min.X, slice.Min.Y, slice.Min.Z)
        value.Name = "CornerValue"
        value.Parent = terrainRegion
    end
    CopyPropertiesIntoAttributes(terrainRegion, Terrain, saveDefaults)

    const materialColors: Folder = Instance.new("Folder")
    materialColors.Name = "MaterialColors"
    materialColors.Parent = terrainRegion

    for _, material: Enum.Material in Enum.Material:GetEnumItems() do
        const success: boolean, color: Color3 = GetMaterialColorSafe(material)
        if not success then
            continue
        end
        SetSafeAttribute(materialColors, material.Name, color)
    end

    return terrainRegion
end
