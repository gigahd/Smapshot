local MaterialService = game:GetService("MaterialService")

local CloneAndParentChildren = require(script.Parent.Parent.Helper.Clones.CloneAndParentChildren)
local CopyPropertiesFromAttributes = require(script.Parent.Parent.Helper.Attributes.CopyPropertiesFromAttributes)
return function(materialSnapshot: Folder, keepDirty: boolean?)
    CopyPropertiesFromAttributes(materialSnapshot, MaterialService, keepDirty)

    if keepDirty then
        MaterialService:ClearAllChildren()
    end

    CloneAndParentChildren(materialSnapshot, MaterialService, keepDirty == true)
end
