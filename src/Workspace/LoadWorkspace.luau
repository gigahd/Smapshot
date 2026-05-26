local Workspace = game:GetService("Workspace")

local CopyPropertiesFromAttributes = require(script.Parent.Parent.Helper.Attributes.CopyPropertiesFromAttributes)
local CloneAndParentChildren = require(script.Parent.Parent.Helper.Clones.CloneAndParentChildren)
return function(workspaceSnapshot: Folder, keepDirty: boolean?)
    
    if not keepDirty then
        --Clear children manually since CLearAllChildren will always error due to terrain
        for _, child in Workspace:GetChildren() do
            --Skip those two
            if child:IsA("Terrain") or child == Workspace.CurrentCamera then
                continue
            end
            child:Destroy()
        end
    end

    CopyPropertiesFromAttributes(workspaceSnapshot, Workspace, keepDirty)

    local CameraCFrameValue = workspaceSnapshot:FindFirstChild("CameraCFrame")

    if CameraCFrameValue and CameraCFrameValue:IsA("CFrameValue") then
        Workspace.CurrentCamera.CFrame = CameraCFrameValue.Value
    end

    local children = assert(workspaceSnapshot:FindFirstChild("Children"), `Couldn't find Children in Workspace Snapshot`)
    CloneAndParentChildren(children, Workspace, keepDirty == true)
end
