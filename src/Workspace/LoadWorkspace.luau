local Workspace = game:GetService("Workspace")
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
    local CameraCFrameValue = workspaceSnapshot:FindFirstChild("CameraCFrame")
    if CameraCFrameValue and CameraCFrameValue:IsA("CFrameValue") then
        Workspace.CurrentCamera.CFrame = CameraCFrameValue.Value
    end
    local children = assert(workspaceSnapshot:FindFirstChild("Children"), `Couldn't find Children in Workspace Snapshot`)
    for _, child in children:GetChildren() do
        local clone = child:Clone()
        clone.Parent = Workspace
    end
end
