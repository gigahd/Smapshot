local CloneAndParent = require(script.Parent.Parent.Helper.Clones.CloneAndParent)
return function(instances: { Instance }, ignoreParents: boolean?)
    local instanceSnapshot = Instance.new("Folder")
    instanceSnapshot.Name = "Instances"

    for _, instance in instances do
        local clone = CloneAndParent(instance, instanceSnapshot, false)
        if ignoreParents then
            continue
        end
        local fullName = instance:GetFullName()
        --Only copy it if it actually is living inside of game. Otherwise we would have no idea where to put it in the first place
        if instance:IsDescendantOf(game) then
            clone:SetAttribute("FullName", fullName)
        end
    end
    return instanceSnapshot
end
