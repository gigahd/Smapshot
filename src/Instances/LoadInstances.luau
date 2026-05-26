local function TryParent(instance: Instance, fullName: string)
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
    instance:Clone().Parent = parent
    instance:SetAttribute("FullName", nil)
end

return function(folder: Folder)
    for _, instance in folder:GetChildren() do
        local fullName = instance:GetAttribute("FullName")
        if fullName == nil or not (typeof(fullName) == "string") then
            continue
        end
        TryParent(instance, fullName)
    end
end
