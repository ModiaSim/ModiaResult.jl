# Abstract Result Interface

```@meta
CurrentModule = ModiaResult
```

This chapter documents the *abstract result interface* for which an implementation has to be provided,
in order that the [Functions](@ref) of the ModiaResult package can be used.

Functions that are marked as *required*, need to be defined for a new result data structure.
Functions that are marked as *optional* have a default implementation, but can be defined for 
a new result data structure.

| Result functions          | Description                                                   |
|:--------------------------|:--------------------------------------------------------------|
| [`timeSignalName`](@ref)  | Return signal name of the independent variable (*required*).  |
| [`signalNames`](@ref)     | Return all signal names (*required*).                         |
| [`SignalInfo`](@ref)      | Return info about a signal (*required*).                      |
| [`signalValues`](@ref)    | Return values of one signal as an array (*required*).         |
| [`lastSignalValue`](@ref) | Return last (non-missing) value of one signal (*optional*)    |
| [`hasSignal`](@ref)       | Return true if a signal name is known (*optional*).           |
| [`defaultHeading`](@ref)  | Return default heading of result data structure (*optional*). |


*Concrete implementations* of theses functions are provided for:

- [Modia.jl](https://github.com/ModiaSim/Modia.jl) (a modeling and simulation environment)
- [DataFrames.jl](https://github.com/JuliaData/DataFrames.jl) (tabular data; first column is independent variable)
- [Tables.jl](https://github.com/JuliaData/Tables.jl) (abstract interface for tabular data, e.g. [CSV](https://github.com/JuliaData/CSV.jl) tables; first column is independent variable),
- AbstractDict dictionaries with String keys (if OrderedDict, independent variable is first variable, otherwise independent variable is "time").
