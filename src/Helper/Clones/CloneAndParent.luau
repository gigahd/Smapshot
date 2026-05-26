return function(child: Instance, parent: Instance, replaceExisting: boolean, consume: boolean?)
    if replaceExisting then
        local existing = parent:FindFirstChild(child.Name)
        if existing and existing ~= child then
            existing:Destroy()
        end
    end
    if consume then
        child.Parent = parent
        return child
    end
    local clone = child:Clone()
    clone.Parent = parent
    return clone
end
