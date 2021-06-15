# Functions

```@meta
CurrentModule = ModiaPlot_PyPlot
```

This chapter documents the functions that a user of this package typically utilizes.

| Functions                              | Description                                               |
|:---------------------------------------|:----------------------------------------------------------|
| [`ModiaResult.ResultDict`](@ref)       | Return a new instance of a ResultDict dictionary.         |
| [`ModiaResult.activate`](@ref)         | Define the plot package to be used.                       |
| [`ModiaResult.activatePrevious`](@ref) | Activate previous plot package                            |
| [`ModiaResult.activated`](@ref)        | Return name of activated plot package                     |
| [`ModiaResult.@usingModiaPlot`](@ref)  | expands into `using ModiaPlot_<PlotPackageName>`          |
| [`plot`](@ref)                         | Plot simulation results in multiple diagrams/figures.     |
| [`resultInfo`](@ref)                   | Return info about the result as [DataFrame](https://github.com/JuliaData/DataFrames.jl) table            |
| [`showResultInfo`](@ref)               | Print info of the result on stdout.                       |
| [`saveFigure`](@ref)                   | Save figure in different formats on file.                 |
| [`closeFigure`](@ref)                  | Close one figure                                          |
| [`closeAllFigures`](@ref)              | Close all figures                                         |
| [`showFigure`](@ref)                   | Show figure in window (only GLMakie, WGLMakie)            |


## Functions of ModiaResult

```@docs
ModiaResult.ResultDict
ModiaResult.activate
ModiaResult.activatePrevious
ModiaResult.activated
ModiaResult.@usingModiaPlot
```


## Functions exported by plot package

The following functions are available after

```julia
ModiaResult.@usingModiaPlot
```

has been executed. The documentation below was generated with `ModiaPlot_PyPlot`.

```@docs
plot
resultInfo
showResultInfo
saveFigure
closeFigure
closeAllFigures
showFigure
```
