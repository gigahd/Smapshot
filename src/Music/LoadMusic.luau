local SoundService = game:GetService("SoundService")

local ClearChildren = require(script.Parent.Parent.Helper.ClearChildren)
local CloneAndParentChildren = require(script.Parent.Parent.Helper.Clones.CloneAndParentChildren)
local CopyPropertiesFromAttributes = require(script.Parent.Parent.Helper.Attributes.CopyPropertiesFromAttributes)
return function(musicSnapshot: Folder, keepDirty: boolean?, consume: boolean?, ignoreOnClear: { Instance }?)
    CopyPropertiesFromAttributes(musicSnapshot, SoundService, keepDirty)

    if not keepDirty then
        ClearChildren(SoundService, ignoreOnClear)
    end

    CloneAndParentChildren(musicSnapshot, SoundService, keepDirty == true, consume)
end
