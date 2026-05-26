const GetValidAttributeProperties = require(script.Parent.GetValidAttributeProperties)

return function(Holder: Instance, Target: Instance, keepDirty: boolean?)
    const properties = GetValidAttributeProperties(Target.ClassName)
    for _, property in properties do
        const attributeValue = Holder:GetAttribute(property.Name)
        if not keepDirty and attributeValue == nil then
            Target:ResetPropertyToDefault(property.Name)
            continue
        end
        if property.Type.ScriptType ~= typeof(attributeValue) then
            warn(
                `Property {property.Name} has a miss matching type, expected: {property.Type.ScriptType}, but got {typeof(
                    attributeValue
                )}`
            )
            continue
        end
        const success, error = pcall(function()
            (Target :: any)[property.Name] = attributeValue
        end)
        if not success then
            warn(`Failed to set {property.Name} on {Target.Name}, due to: {error}`)
        end
    end
end
