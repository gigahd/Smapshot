local Workspace = game:GetService("Workspace")

local ClearChildren = require(script.Parent.Parent.Helper.ClearChildren)
local CopyPropertiesFromAttributes = require(script.Parent.Parent.Helper.Attributes.CopyPropertiesFromAttributes)
local CloneAndParentChildren = require(script.Parent.Parent.Helper.Clones.CloneAndParentChildren)
return function(workspaceSnapshot: Folder, keepDirty: boolean?, consume: boolean?, ignoreOnClear: { Instance }?)

    if not keepDirty then
        -- Terrain and the camera must always survive the clear (ClearAllChildren errors on Terrain).
        local keep = { Workspace.Terrain :: Instance }
        if Workspace.CurrentCamera then
            table.insert(keep, Workspace.CurrentCamera)
        end
        if ignoreOnClear then
            table.move(ignoreOnClear, 1, #ignoreOnClear, #keep + 1, keep)
        end
        ClearChildren(Workspace, keep)
    end

    CopyPropertiesFromAttributes(workspaceSnapshot, Workspace, keepDirty)

    local CameraCFrameValue = workspaceSnapshot:FindFirstChild("CameraCFrame")

    if CameraCFrameValue and CameraCFrameValue:IsA("CFrameValue") then
        Workspace.CurrentCamera.CFrame = CameraCFrameValue.Value
    end

    local children = assert(workspaceSnapshot:FindFirstChild("Children"), `Couldn't find Children in Workspace Snapshot`)
    CloneAndParentChildren(children, Workspace, keepDirty == true, consume)
end
