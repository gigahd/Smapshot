local GetValidAttributeProperties = require(script.Parent.GetValidAttributeProperties)
local SetSafeAttribute = require(script.Parent.SetSafeAttribute)

return function(AttributeHolder: Instance, Origin: Instance, saveDefaults: boolean?)
    local properties = GetValidAttributeProperties(Origin.ClassName)
    for _, property in properties do
        --Skip Sandboxed on Services
        if property.Name == "Sandboxed" and Origin.Parent == game then
            continue
        end
        if not saveDefaults and not Origin:IsPropertyModified(property.Name) then
            continue
        end
        SetSafeAttribute(AttributeHolder, property.Name, (Origin :: any)[property.Name])
    end
end
