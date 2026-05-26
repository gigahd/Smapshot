local Workspace = game:GetService("Workspace")

local CloneWithFilter = require(script.Parent.Parent.Helper.Clones.CloneWithFilter)
local CopyPropertiesIntoAttributes = require(script.Parent.Parent.Helper.Attributes.CopyPropertiesIntoAttributes)
return function(whitelist: { string }?, blacklist: { string }?, saveCameraCFrame: boolean?, saveDefaults: boolean?)
    local workspaceSnapshot = Instance.new("Folder")
    workspaceSnapshot.Name = "Workspace"
    CopyPropertiesIntoAttributes(workspaceSnapshot, Workspace, saveDefaults)
    
    local WorkspaceChildren = Instance.new("Folder")
    WorkspaceChildren.Name = "Children"
    WorkspaceChildren.Parent = workspaceSnapshot

    for _, child in Workspace:GetChildren() do
        if child:IsA("Terrain") then
            continue
        end
        if child == Workspace.CurrentCamera then
            if saveCameraCFrame then
                local cameraCFrameValue = Instance.new("CFrameValue")
                cameraCFrameValue.Name = "CameraCFrame"
                cameraCFrameValue.Value = Workspace.CurrentCamera.CFrame
                cameraCFrameValue.Parent = workspaceSnapshot
            end
            continue
        end
        CloneWithFilter(child, WorkspaceChildren, whitelist, blacklist)
    end
    return workspaceSnapshot
end
