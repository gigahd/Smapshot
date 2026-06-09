-- Destroys every child of `parent` except those listed in `ignore`.
-- Falls back to the faster `ClearAllChildren` when there is nothing to keep.
return function(parent: Instance, ignore: { Instance }?)
    if not ignore or #ignore == 0 then
        parent:ClearAllChildren()
        return
    end

    local keep: { [Instance]: true } = {}
    for _, instance in ignore do
        keep[instance] = true
    end

    -- GetChildren returns a snapshot array, so destroying while iterating it is safe.
    for _, child in parent:GetChildren() do
        if not keep[child] then
            child:Destroy()
        end
    end
end
