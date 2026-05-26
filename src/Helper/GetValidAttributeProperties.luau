local ReflectionService = game:GetService("ReflectionService")

local ReflectionTypes = require(script.Parent.ReflectionTypes)
export type Property = ReflectionTypes.Property

local classCache: { [string]: { Property } } = {}

-- See https://create.roblox.com/docs/studio/properties#instance-attributes for more infos
local validTypesList: { [string]: boolean } = {
    ["string"] = true,
    ["number"] = true,
    ["boolean"] = true,
    ["UDim"] = true,
    ["UDim2"] = true,
    ["BrickColor"] = true,
    ["Color3"] = true,
    ["Vector2"] = true,
    ["Vector3"] = true,
    ["CFrame"] = true,
    ["NumberSequence"] = true,
    ["ColorSequence"] = true,
    ["NumberRange"] = true,
    ["Rect"] = true,
    ["Font"] = true,
}

local function TypeIsValidAttributeType(scriptType: string)
    return validTypesList[scriptType]
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
