return function(instances: { Instance }, ignoreParents: boolean?)
    const Instances = Instance.new("Folder")
    Instances.Name = "Instances"

    for _, instance in instances do
        const clone = instance:Clone()
        clone.Parent = Instances
        if ignoreParents then
            continue
        end
        const fullName = instance:GetFullName()
        --Only copy it if it actually is living inside of game. Otherwise we would have no idea where to put it in the first place
        if instance:IsDescendantOf(game) then
            clone:SetAttribute("FullName", fullName)
        end
    end
    return Instances
end
