local Lighting = game:GetService("Lighting")

local CloneAndParentChildren = require(script.Parent.Parent.Helper.Clones.CloneAndParentChildren)
local CopyPropertiesFromAttributes = require(script.Parent.Parent.Helper.Attributes.CopyPropertiesFromAttributes)
return function(lightingSnapshot: Folder, keepDirty: boolean?, consume: boolean?)
    CopyPropertiesFromAttributes(lightingSnapshot, Lighting, keepDirty)

    if keepDirty then
        Lighting:ClearAllChildren()
    end

    CloneAndParentChildren(lightingSnapshot, Lighting, keepDirty == true, consume)
end
