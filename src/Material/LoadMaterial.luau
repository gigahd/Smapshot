local MaterialService = game:GetService("MaterialService")

local ClearChildren = require(script.Parent.Parent.Helper.ClearChildren)
local CloneAndParentChildren = require(script.Parent.Parent.Helper.Clones.CloneAndParentChildren)
local CopyPropertiesFromAttributes = require(script.Parent.Parent.Helper.Attributes.CopyPropertiesFromAttributes)
return function(materialSnapshot: Folder, keepDirty: boolean?, consume: boolean?, ignoreOnClear: { Instance }?)
    CopyPropertiesFromAttributes(materialSnapshot, MaterialService, keepDirty)

    if not keepDirty then
        ClearChildren(MaterialService, ignoreOnClear)
    end

    CloneAndParentChildren(materialSnapshot, MaterialService, keepDirty == true, consume)
end
