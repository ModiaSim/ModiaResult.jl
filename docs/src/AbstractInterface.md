# Abstract Interface

```@meta
CurrentModule = ModiaResult
```

This chapter documents the abstract interface to access a result data structure.


| Functions                       | Description                                                |
|:--------------------------------|:-----------------------------------------------------------|
| [`SignalType`](@ref)            | Enumeration defining the supported signal types.           |
| [`rawSignal`](@ref)             | Returns signal data given the signal name (required).      |
| [`names`](@ref)                 | Return all signal names (required).                        |
| [`timeSignalName`](@ref)        | Return the name of the time signal (required).             |
| [`hasOneTimeSignal`](@ref)      | Return true if one time signal present (required).         |
| [`hasSignal`](@ref)             | Inquire whether a signal name is known (optional).         |
| [`defaultHeading`](@ref)        | Return default heading as string (optional).               |


```@docs
SignalType
rawSignal
names
timeSignalName
hasOneTimeSignal
hasSignal
defaultHeading
```
