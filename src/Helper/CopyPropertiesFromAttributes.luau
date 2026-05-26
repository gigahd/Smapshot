local GetValidAttributeProperties = require(script.Parent.GetValidAttributeProperties)

return function(Holder: Instance, Target: Instance, keepDirty: boolean?)
    local properties = GetValidAttributeProperties(Target.ClassName)
    for _, property in properties do
        local attributeValue = Holder:GetAttribute(property.Name)
        
        if attributeValue == nil then
            if not keepDirty then
                pcall(function()
                    Target:ResetPropertyToDefault(property.Name)
                end)
            end
            continue
        end
        if attributeValue and property.Type.ScriptType ~= typeof(attributeValue) then
            warn(
                `Property {property.Name} has a miss matching type, expected: {property.Type.ScriptType}, but got {typeof(
                    attributeValue
                )}`
            )
            continue
        end
        local success, error = pcall(function()
            (Target :: any)[property.Name] = attributeValue
        end)
        if not success then
            warn(`Failed to set {property.Name} on {Target.Name}, due to: {error}`)
        end
    end
end
