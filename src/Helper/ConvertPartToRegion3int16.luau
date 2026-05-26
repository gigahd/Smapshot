return function(part: BasePart)
    local cf = part.CFrame
    local half = part.Size / 2
    local right = cf.RightVector
    local up = cf.UpVector
    local look = cf.LookVector

    local worldHalf = Vector3.new(
        math.abs(right.X) * half.X + math.abs(up.X) * half.Y + math.abs(look.X) * half.Z,
        math.abs(right.Y) * half.X + math.abs(up.Y) * half.Y + math.abs(look.Y) * half.Z,
        math.abs(right.Z) * half.X + math.abs(up.Z) * half.Y + math.abs(look.Z) * half.Z
    )
    local center = cf.Position
    local min = (center - worldHalf) / 4
    local max = (center + worldHalf) / 4
    return Region3int16.new(
        Vector3int16.new(math.floor(min.X), math.floor(min.Y), math.floor(min.Z)),
        Vector3int16.new(math.ceil(max.X), math.ceil(max.Y), math.ceil(max.Z))
    )
end
