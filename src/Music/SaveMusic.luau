local SoundService = game:GetService("SoundService")

local CloneChildrenWithFilter = require(script.Parent.Parent.Helper.Clones.CloneChildrenWithFilter)
local CopyPropertiesIntoAttributes = require(script.Parent.Parent.Helper.Attributes.CopyPropertiesIntoAttributes)
return function(whitelist: { string }?, blacklist: { string }?, saveDefaults: boolean?)
    local musicSnapshot = Instance.new("Folder")
    musicSnapshot.Name = "Music"
    CopyPropertiesIntoAttributes(musicSnapshot, SoundService, saveDefaults)

    CloneChildrenWithFilter(SoundService, musicSnapshot, whitelist, blacklist)
    return musicSnapshot
end
