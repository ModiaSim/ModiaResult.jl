# Abstract Interface

```@meta
CurrentModule = ModiaResult
```

This chapter documents the abstract interface to access a result data structure.


| Functions                       | Description                                                 |
|:--------------------------------|:------------------------------------------------------------|
| [`SignalType`](@ref)            | Predefined enumeration defining the supported signal types. |
| [`rawSignal`](@ref)             | Return raw signal data given the signal name (required).    |
| [`signalNames`](@ref)           | Return all signal names (required).                         |
| [`timeSignalName`](@ref)        | Return the name of the time signal (required).              |
| [`hasOneTimeSignal`](@ref)      | Return true if one time signal present (required).          |
| [`hasSignal`](@ref)             | Return true if signal name is known (optional).             |
| [`defaultHeading`](@ref)        | Return default heading as string (optional).                |


The following figure sketches the signal definition:

![SignalDefinition](../resources/images/signal-definition.png)

Other signal types can be mapped to this basic signal type by introducing views 
on special structs.


## Predefined enumeration

```@docs
SignalType
```


## Required functions

The following functions must be defined for a new result data structure:

```@docs
rawSignal
signalNames
timeSignalName
hasOneTimeSignal
```


## Optional functions

The following functions can be defined for a new result data structure.
If they are not defined, a default implementation is used:

```@docs
hasSignal
defaultHeading
```
