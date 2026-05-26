local CloneWithFilter = require(script.Parent.CloneWithFilter)
return function(origin: Instance, parent: Instance, whitelist: { string }?, blacklist: { string }?)
    for _, child in origin:GetChildren() do
        CloneWithFilter(child, parent, whitelist, blacklist)
    end
end
