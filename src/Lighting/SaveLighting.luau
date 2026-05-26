local Lighting = game:GetService("Lighting")

local CopyPropertiesIntoAttributes = require(script.Parent.Parent.Helper.CopyPropertiesIntoAttributes)

return function(whitelist: { string }?, blacklist: { string }?, saveDefaults: boolean?)
    local LightingPropertiesHolder = Instance.new("Folder")
    LightingPropertiesHolder.Name = "Lighting"
    CopyPropertiesIntoAttributes(LightingPropertiesHolder, Lighting, saveDefaults)
    --Just quick fail save because Sandboxed cannot be set even though permissions allow it? Idk man
    LightingPropertiesHolder:SetAttribute("Sandboxed", nil)
    for _, child in Lighting:GetChildren() do
        if
            (whitelist and not table.find(whitelist, child.Name)) or (blacklist and table.find(blacklist, child.Name))
        then
            continue
        end
        child:Clone().Parent = LightingPropertiesHolder
    end
    return LightingPropertiesHolder
end
