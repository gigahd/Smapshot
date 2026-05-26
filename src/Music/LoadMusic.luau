local SoundService = game:GetService("SoundService")

local CloneAndParentChildren = require(script.Parent.Parent.Helper.Clones.CloneAndParentChildren)
local CopyPropertiesFromAttributes = require(script.Parent.Parent.Helper.Attributes.CopyPropertiesFromAttributes)
return function(musicSnapshot: Folder, keepDirty: boolean?, consume: boolean?)
    CopyPropertiesFromAttributes(musicSnapshot, SoundService, keepDirty)

    if not keepDirty then
        SoundService:ClearAllChildren()
    end

    CloneAndParentChildren(musicSnapshot, SoundService, keepDirty == true, consume)
end
