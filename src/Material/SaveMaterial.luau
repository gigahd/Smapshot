local MaterialService = game:GetService("MaterialService")

local CloneWithFilter = require(script.Parent.Parent.Helper.Clones.CloneWithFilter)
local CopyPropertiesIntoAttributes = require(script.Parent.Parent.Helper.Attributes.CopyPropertiesIntoAttributes)
return function(materialFilter: { Enum.Material }?, whitelist: { string }?, blacklist: { string }?, saveDefaults: boolean?)
    local materialsSnapshot = Instance.new("Folder")
    materialsSnapshot.Name = "Material"
    CopyPropertiesIntoAttributes(materialsSnapshot, MaterialService, saveDefaults)

    for _, child in MaterialService:GetChildren() do
        if materialFilter and not table.find(materialFilter, (child :: MaterialVariant).BaseMaterial) then
            continue
        end
        CloneWithFilter(child, materialsSnapshot, whitelist, blacklist)
    end
    return materialsSnapshot
end
