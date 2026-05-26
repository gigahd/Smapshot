local CloneAndParent = require(script.Parent.CloneAndParent)
return function(child: Instance, parent: Instance, whitelist: { string }?, blacklist: { string }?)
    if (whitelist and not table.find(whitelist, child.Name)) or (blacklist and table.find(blacklist, child.Name)) then
        return
    end
    CloneAndParent(child, parent, false)
end
