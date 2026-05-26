return function(instances: { Instance }, ignoreParents: boolean?)
    local Instances = Instance.new("Folder")
    Instances.Name = "Instances"

    for _, instance in instances do
        local clone = instance:Clone()
        clone.Parent = Instances
        if ignoreParents then
            continue
        end
        local fullName = instance:GetFullName()
        --Only copy it if it actually is living inside of game. Otherwise we would have no idea where to put it in the first place
        if instance:IsDescendantOf(game) then
            clone:SetAttribute("FullName", fullName)
        end
    end
    return Instances
end
