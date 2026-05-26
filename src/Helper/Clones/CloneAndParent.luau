return function(child: Instance, parent: Instance, replaceExisting: boolean)
    if replaceExisting then
        local existing = parent:FindFirstChild(child.Name)
        if existing then
            existing:Destroy()
        end
    end
    local clone = child:Clone()
    clone.Parent = parent
    return clone
end
