local CloneAndParent = require(script.Parent.CloneAndParent)
return function(origin: Instance, parent: Instance, replaceExisting: boolean)
    for _, child in origin:GetChildren() do
        CloneAndParent(child, parent, replaceExisting)
    end
end
