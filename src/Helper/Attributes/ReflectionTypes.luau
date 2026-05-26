export type ReflectionMemberFilter = {
    --- The security context to use; can be more expansive than the current script's security
    Security: SecurityCapabilities?, -- default: SecurityCapabilities.fromCurrent()
    --- Whether to exclude inherited properties from superclasses
    ExcludeInherited: boolean?, -- default: false
    --- Whether to exclude Studio display information about the properties
    ExcludeDisplay: boolean?, -- default: false
}

export type ReflectionType = {
    --- Internal Representation of the Type
    EngineType: string,
    --- Script Representation of the Type (typeof)
    ScriptType: string,
}

export type Property = {
    --- The name of the property
    Name: string,
    --- The superclass from which the property is inherited, or the class name if not inherited
    Owner: string,
    --- Whether the property is serialized (able to be saved to disk or sent over the network)
    Serialized: boolean,
    --- The type of the property
    Type: ReflectionType,
    --- The content type of the property, if applicable
    ContentType: Enum.AssetType?,
    --- Studio display information
    Display: {
        --- The category under which the property is listed in Studio
        Category: string,
        --- A message indicating that the property is deprecated, if applicable
        DeprecationMessage: string?,
    }?,
    --- The security permissions required to access this property
    Permits: {
        --- The security context required to read this property
        Read: SecurityCapabilities?,
        --- The security context required to read this property while thread-safe
        ReadParallel: SecurityCapabilities?,
        --- The security context required to write to this property
        Write: SecurityCapabilities?,
        --- The security context required to write to this property while thread-safe
        WriteParallel: SecurityCapabilities?,
    },
}

return {}
