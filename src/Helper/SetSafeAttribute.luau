return function(instance: Instance, name: string, value: any)
    local success, error = pcall(function()
        instance:SetAttribute(name, value)
    end)
    if not success then
        warn(`Tried saving {name}, but {typeof(value)} is not a valid Attribute type`)
    end
end
