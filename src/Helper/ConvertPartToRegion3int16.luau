return function(part: BasePart)
    const cf = part.CFrame
    const half = part.Size / 2
    const right = cf.RightVector
    const up = cf.UpVector
    const look = cf.LookVector
    
    const worldHalf = Vector3.new(
        math.abs(right.X) * half.X + math.abs(up.X) * half.Y + math.abs(look.X) * half.Z,
        math.abs(right.Y) * half.X + math.abs(up.Y) * half.Y + math.abs(look.Y) * half.Z,
        math.abs(right.Z) * half.X + math.abs(up.Z) * half.Y + math.abs(look.Z) * half.Z
    )
    const center = cf.Position
    const min = (center - worldHalf) / 4
    const max = (center + worldHalf) / 4
    return Region3int16.new(
        Vector3int16.new(math.floor(min.X), math.floor(min.Y), math.floor(min.Z)),
        Vector3int16.new(math.ceil(max.X),  math.ceil(max.Y),  math.ceil(max.Z))
    )
end