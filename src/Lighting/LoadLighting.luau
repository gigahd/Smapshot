local Lighting = game:GetService("Lighting")

local ClearChildren = require(script.Parent.Parent.Helper.ClearChildren)
local CloneAndParentChildren = require(script.Parent.Parent.Helper.Clones.CloneAndParentChildren)
local CopyPropertiesFromAttributes = require(script.Parent.Parent.Helper.Attributes.CopyPropertiesFromAttributes)
return function(lightingSnapshot: Folder, keepDirty: boolean?, consume: boolean?, ignoreOnClear: { Instance }?)
    CopyPropertiesFromAttributes(lightingSnapshot, Lighting, keepDirty)

    if not keepDirty then
        ClearChildren(Lighting, ignoreOnClear)
    end

    CloneAndParentChildren(lightingSnapshot, Lighting, keepDirty == true, consume)
end
