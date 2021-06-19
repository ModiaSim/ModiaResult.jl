# Functions

```@meta
CurrentModule = ModiaResult
```

This chapter documents the functions that a user of this package typically utilizes.

The following functions are available when prefixed with `ModiaResult`.
Note, `ModiaResult` does not `export` any symbols
(for example: `import ModiaResult; ModiaResult.usePlotPackage("PyPlot")`).

Some packages, such as [Modia](https://github.com/ModiaSim/Modia.jl), export all
the function names below and then the functions can be directly accessed
(for example: `using Modia; usePlotPackage("PyPlot")`).

| Functions                        | Description                                               |
|:---------------------------------|:----------------------------------------------------------|
| [`@usingModiaPlot`](@ref)        | Expands into `using ModiaPlot_<PlotPackageName>`          |
| [`usePlotPackage`](@ref)         | Define the plot package to be used.                       |
| [`usePreviousPlotPackage`](@ref) | Define the previously defined plot package to be used.    |
| [`currentPlotPackage`](@ref)     | Return name defined with [`usePlotPackage`](@ref)         |
| [`resultInfo`](@ref)             | Return info about the result as [DataFrame](https://github.com/JuliaData/DataFrames.jl) table            |
| [`printResultInfo`](@ref)        | Print info of the result on stdout.                       |
| [`rawSignal`](@ref)              | Return raw signal data given the signal name.             |
| [`getPlotSignal`](@ref)          | Return signal data prepared for a plot package.           |
| [`defaultHeading`](@ref)         | Return default heading of a result.                       |
| [`signalNames`](@ref)            | Return all signal names.                                  |
| [`timeSignalName`](@ref)         | Return the name of the time signal.                       |
| [`hasOneTimeSignal`](@ref)       | Return true if one time signal present.                   |
| [`hasSignal`](@ref)              | Return true if a signal name is known.                    |


The following functions are available after [`@usingModiaPlot`](@ref) has been executed:

```@meta
CurrentModule = ModiaPlot_PyPlot
```

| Functions                                    | Description                                               |
|:---------------------------------------------|:----------------------------------------------------------|
| [`plot`](@ref)                               | Plot simulation results in multiple diagrams/figures.     |
| [`saveFigure`](@ref)                         | Save figure in different formats on file.                 |
| [`closeFigure`](@ref)                        | Close one figure                                          |
| [`closeAllFigures`](@ref)                    | Close all figures                                         |
| [`showFigure`](@ref)                         | Show figure in window (only GLMakie, WGLMakie)            |


```@meta
CurrentModule = ModiaResult
```

The following function is typically only used for testing

| Functions                         | Description                                               |
|:----------------------------------|:----------------------------------------------------------|
| [`ModiaResult.ResultDict`](@ref)  | Return a new instance of a ResultDict dictionary.         |



## Functions of ModiaResult

The following functions are provided by package `ModiaResull`.
Other useful functions are available in the [Abstract Interface](@ref).

```@docs
@usingModiaPlot
usePlotPackage
usePreviousPlotPackage
currentPlotPackage
resultInfo
printResultInfo
getPlotSignal
```

## Functions of Plot Package

The following functions are available after

```julia
ModiaResult.@usingModiaPlot
```

has been executed. The documentation below was generated with `ModiaPlot_PyPlot`.

```@meta
CurrentModule = ModiaPlot_PyPlot
```

```@docs
plot
saveFigure
closeFigure
closeAllFigures
showFigure
```


## Functions for Testing

```@meta
CurrentModule = ModiaResult
```

```@docs
ResultDict
```

