local Workspace = game:GetService("Workspace")

local CopyPropertiesIntoAttributes = require(script.Parent.Parent.Helper.CopyPropertiesIntoAttributes)
return function(saveCameraCFrame: boolean?, saveDefaults: boolean?)
    local WorkspaceHolder = Instance.new("Folder")
    WorkspaceHolder.Name = "Workspace"
    CopyPropertiesIntoAttributes(WorkspaceHolder, Workspace, saveDefaults)
    local WorkspaceChildren = Instance.new("Folder")
    WorkspaceChildren.Name = "Children"
    WorkspaceChildren.Parent = WorkspaceHolder

    for _, child in Workspace:GetChildren() do
        if child:IsA("Terrain") then
            continue
        end
        if child == Workspace.CurrentCamera then
            if saveCameraCFrame then
                local cameraCFrameValue = Instance.new("CFrameValue")
                cameraCFrameValue.Name = "CameraCFrame"
                cameraCFrameValue.Value = Workspace.CurrentCamera.CFrame
                cameraCFrameValue.Parent = WorkspaceHolder
            end
            continue
        end
        child:Clone().Parent = WorkspaceChildren
    end
    return WorkspaceHolder
end
