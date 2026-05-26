local function TryParent(instance: Instance, fullName: string, keepDirty: boolean?)
    local parent: Instance = game
    local path = fullName:split(".")
    -- Last element is just the instance it self
    table.remove(path, #path)
    for i, name in path do
        local next = parent:FindFirstChild(name)
        if next == nil then
            warn(
                `Couldn't place {instance.Name} in it's supposed location {fullName}, closest approach {parent:GetFullName()}`
            )
            return
        end
        parent = next
    end
    local clone = instance:Clone()
    if not keepDirty then
        local exists = parent:FindFirstChild(clone.Name)
        if exists then
            exists:Destroy()
        end
    end
    clone.Parent = parent
    clone:SetAttribute("FullName", nil)
end

return function(folder: Folder, keepDirty: boolean?)
    for _, instance in folder:GetChildren() do
        local fullName = instance:GetAttribute("FullName")
        if fullName == nil or not (typeof(fullName) == "string") then
            continue
        end
        TryParent(instance, fullName, keepDirty)
    end
end
