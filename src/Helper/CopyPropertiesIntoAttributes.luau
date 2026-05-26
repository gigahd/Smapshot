const GetValidAttributeProperties = require(script.Parent.GetValidAttributeProperties)
const SetSafeAttribute = require(script.Parent.SetSafeAttribute)

return function(AttributeHolder: Instance, Origin: Instance, saveDefaults: boolean?)
    const properties = GetValidAttributeProperties(Origin.ClassName)
    for _, property in properties do
        if not saveDefaults and not Origin:IsPropertyModified(property.Name) then
            continue
        end
        SetSafeAttribute(AttributeHolder, property.Name, (Origin :: any)[property.Name])
    end
end
