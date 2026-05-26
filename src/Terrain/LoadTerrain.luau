local Workspace = game:GetService("Workspace")
local CopyPropertiesFromAttributes = require(script.Parent.Parent.Helper.Attributes.CopyPropertiesFromAttributes)

local Terrain = Workspace.Terrain

local function getRegionCorner(terrainSnapshot: TerrainRegion)
    local cornerValue = terrainSnapshot:FindFirstChild("CornerValue")
    if cornerValue and cornerValue:IsA("Vector3Value") then
        return Vector3int16.new(cornerValue.Value.X, cornerValue.Value.Y, cornerValue.Value.Z)
    end
    return Vector3int16.new(
        -math.floor(terrainSnapshot.SizeInCells.X / 2),
        -math.floor(terrainSnapshot.SizeInCells.Y / 2),
        -math.floor(terrainSnapshot.SizeInCells.Z / 2)
    )
end

return function(terrain: TerrainRegion, keepDirty: boolean?)
    local position = getRegionCorner(terrain)
    if not keepDirty then
        Terrain:Clear()
    end
    Terrain:PasteRegion(terrain, position, true)
    CopyPropertiesFromAttributes(terrain, Terrain, keepDirty)
    local MaterialColors = terrain:FindFirstChild("MaterialColors")
    if not MaterialColors then
        return
    end
    for materialName: string, colorValue: Color3 in MaterialColors:GetAttributes() do
        local materialEnum = Enum.Material:FromName(materialName)
        if not materialEnum then
            continue
        end
        Terrain:SetMaterialColor(materialEnum, colorValue :: Color3)
    end
end
