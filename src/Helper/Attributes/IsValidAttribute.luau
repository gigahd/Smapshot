local AttributeList = require(script.Parent.AttributeList)
export type ValidAttributeTypes =
    | string | number | boolean | UDim
    | UDim2 | Vector2 | Vector3 | CFrame
    | Color3 | BrickColor | ColorSequence 
    | NumberSequence | NumberRange | Rect | Font


return function(value: ValidAttributeTypes): boolean
    return (AttributeList :: any)[typeof(value)] == true
end
