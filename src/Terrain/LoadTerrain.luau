const Workspace = game:GetService("Workspace")
const CopyPropertiesFromAttributes = require(script.Parent.Parent.Helper.CopyPropertiesFromAttributes)

const Terrain = Workspace.Terrain

local function getRegionCorner(terrain: TerrainRegion)
    const cornerValue = terrain:FindFirstChild("CornerValue")
    if cornerValue and cornerValue:IsA("Vector3Value") then
        return Vector3int16.new(cornerValue.Value.X, cornerValue.Value.Y, cornerValue.Value.Z)
    end
    return Vector3int16.new(
        -math.floor(terrain.SizeInCells.X / 2),
        -math.floor(terrain.SizeInCells.Y / 2),
        -math.floor(terrain.SizeInCells.Z / 2)
    )
end

return function(terrain: TerrainRegion, keepDirty: boolean?)
    const position = getRegionCorner(terrain)
    if not keepDirty then
        Terrain:Clear()
    end
    Terrain:PasteRegion(terrain, position, true)
    CopyPropertiesFromAttributes(terrain, Terrain, keepDirty)
    const MaterialColors = terrain:FindFirstChild("MaterialColors")
    if not MaterialColors then
        return
    end
    for materialName: string, colorValue: Color3 in MaterialColors:GetAttributes() do
        const materialEnum = Enum.Material:FromName(materialName)
        if not materialEnum then
            continue
        end
        Terrain:SetMaterialColor(materialEnum, colorValue)
    end
end
