const Lighting = game:GetService("Lighting")

const CopyPropertiesFromAttributes = require(script.Parent.Parent.Helper.CopyPropertiesFromAttributes)
return function(lightingInfoHolder: Folder, keepDirty: boolean?)
    CopyPropertiesFromAttributes(lightingInfoHolder, Lighting, keepDirty)

    if keepDirty then
        for _, child in lightingInfoHolder:GetChildren() do
            const exists = Lighting:FindFirstChild(child.Name)
            if exists then
                exists:Destroy()
            end
            child.Parent = Lighting
        end

        return
    else
        Lighting:ClearAllChildren()
    end

    for _, child in lightingInfoHolder:GetChildren() do
        child.Parent = Lighting
    end
end
