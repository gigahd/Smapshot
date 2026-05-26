local ReflectionService = game:GetService("ReflectionService")

local AttributeList = require(script.Parent.AttributeList)
local ReflectionTypes = require(script.Parent.ReflectionTypes)
export type Property = ReflectionTypes.Property

local classCache: { [string]: { Property } } = {}

local function TypeIsValidAttributeType(scriptType)
    return (AttributeList :: any)[scriptType]
end

return function(class: string): { Property }
    do
        local cached = classCache[class]
        if cached then
            return cached
        end
    end

    local properties: { Property } = {}
    for _, property: Property in ReflectionService:GetPropertiesOfClass(class) do
        local Permits = property.Permits
        if
            (property.Display and property.Display.DeprecationMessage) --Property is deprecated
            or not ((Permits.Read or Permits.ReadParallel) and (Permits.Write or Permits.WriteParallel)) -- Property is not Read- and Writeable
            or not property.Type
            or not property.Type.ScriptType
            or not TypeIsValidAttributeType(property.Type.ScriptType)
        then
            continue
        end

        table.insert(properties, property)
    end
    classCache[class] = properties
    table.freeze(properties)
    return properties
end
