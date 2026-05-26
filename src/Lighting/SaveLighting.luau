local Lighting = game:GetService("Lighting")

local CloneChildrenWithFilter = require(script.Parent.Parent.Helper.Clones.CloneChildrenWithFilter)
local CopyPropertiesIntoAttributes = require(script.Parent.Parent.Helper.Attributes.CopyPropertiesIntoAttributes)

return function(whitelist: { string }?, blacklist: { string }?, saveDefaults: boolean?)
    local lightingSnapshot = Instance.new("Folder")
    lightingSnapshot.Name = "Lighting"
    CopyPropertiesIntoAttributes(lightingSnapshot, Lighting, saveDefaults)

    CloneChildrenWithFilter(Lighting, lightingSnapshot, whitelist, blacklist)
    return lightingSnapshot
end
