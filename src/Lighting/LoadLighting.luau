local Lighting = game:GetService("Lighting")

local CopyPropertiesFromAttributes = require(script.Parent.Parent.Helper.CopyPropertiesFromAttributes)
return function(lightingInfoHolder: Folder, keepDirty: boolean?)
    CopyPropertiesFromAttributes(lightingInfoHolder, Lighting, keepDirty)

    if keepDirty then
        for _, child in lightingInfoHolder:GetChildren() do
            local exists = Lighting:FindFirstChild(child.Name)
            if exists then
                exists:Destroy()
            end
            child:Clone().Parent = Lighting
        end

        return
    else
        Lighting:ClearAllChildren()
    end

    for _, child in lightingInfoHolder:GetChildren() do
        child:Clone().Parent = Lighting
    end
end
