# Functions

This chapter documents the functions that a user of this package typically utilizes.


## Results

```@meta
CurrentModule = ModiaResult
```

The functions below are provided to operate on a result data structures, especially:

- [Modia.jl](https://github.com/ModiaSim/Modia.jl) (a modeling and simulation environment),
- [DataFrames.jl](https://github.com/JuliaData/DataFrames.jl) (tabular data; first column is independent variable)
- [Tables.jl](https://github.com/JuliaData/Tables.jl) (abstract interface for tabular data, e.g. [CSV](https://github.com/JuliaData/CSV.jl) tables; first column is independent variable),
- AbstractDict dictionaries with String keys (if OrderedDict, independent variable is first variable, otherwise independent variable is "time").


!!! note
    [ModiaResult.jl](https://github.com/ModiaSim/ModiaResult.jl) does **not** export any symbols.\
    [Modia.jl](https://github.com/ModiaSim/Modia.jl) exports all the symbols and uses as
    *result* argument `instantiatedModel` (= returned from `@Modia.instantiatedModel(model, ...)`).

| Functions                         | Description                                                                                    |
|:----------------------------------|:-----------------------------------------------------------------------------------------------|
| [`printResultInfo`](@ref)         | Print info of the result on stdout.                                                            |
| [`resultInfo`](@ref)              | Return info about the result as [DataFrame](https://github.com/JuliaData/DataFrames.jl) table. |
| [`hasSignal`](@ref)               | Return true if a signal name is known.                                                         |
| [`timeSignalName`](@ref)          | Return signal name of the independent variable.                                                |
| [`signalNames`](@ref)             | Return all signal names (including independent variable).                                      |
| [`SignalInfo`](@ref)              | Return info about a signal.                                                                    |
| [`VariableKind`](@ref)            | `@enum` used in [`SignalInfo`](@ref)                                                           |
| [`lastSignalValue`](@ref)         | Return last (non-missing) value of one signal (useful e.g. for @test)                          |
| [`signalValues`](@ref)            | Return values of one signal as an array (**potentially with** `missing` values).               |
| [`signalValuesForPlotting`](@ref) | Return values of one signal prepared for a plot package, including signal legend               |
|                                   | (return `Vector` or `Matrix` with potentially `NaN` but **no** `missing` values).              |
| [`defaultHeading`](@ref)          | Return default heading of result data structure (e.g. for a plot window).                      |
| [`unitAsParseableString`](@ref)   | Return the unit of a number or array as a string that is parseable with `Unitful.uparse`.      |


```@docs
printResultInfo
resultInfo
hasSignal
timeSignalName
signalNames
SignalInfo
VariableKind
lastSignalValue
signalValues
signalValuesForPlotting
defaultHeading
unitAsParseableString
```


## Plot Package

```@meta
CurrentModule = ModiaResult
```

The plot package `XXX` to be used can be defined by (provided the corresponding package `ModiaPlot_XXX.jl` is installed):

- `ENV["MODIA_PLOT"] = XXX` (e.g. in startup.jl file: `ENV["MODIA_PLOT"] = "PyPlot"`), or
- by calling [`usePlotPackage`](@ref)(XXX) (e.g. `usePlotPackage("PyPlot")`).

Supported values for `XXX`:

- `"PyPlot"` ([PyPlot](https://github.com/JuliaPy/PyPlot.jl) plots with Matplotlib from Python), 
- `"GLMakie"` ([GLMakie](https://github.com/JuliaPlots/GLMakie.jl) provides interactive plots in an OpenGL window),
- `"WGLMakie"` ([WGLMakie](https://github.com/JuliaPlots/WGLMakie.jl) provides interactive plots in a browser window),
- `"CairoMakie"` ([CairoMakie](https://github.com/JuliaPlots/CairoMakie.jl) provides static plots on file with publication quality).

Furthermore, there are two dummy modules included in ModiaResult, that are useful when performing tests with runtests.jl, 
in order that no plot package needs to be loaded during the tests:

- `"NoPlot"` (= all `plot(..)` calls are ignored and info messages are instead printed), or
- `"SilentNoPlot"` (= NoPlot without messages).

Typically, runtests.jl is define as:

```julia
import ModiaResult
ModiaResult.usePlotPackage("SilentNoPlot")
include("include_all.jl")                    # Include all tests that use a plot package
ModiaResult.usePreviousPlotPackage()
```

The following functions are provided to define/inquire the current plot package.

!!! note
    [ModiaResult.jl](https://github.com/ModiaSim/ModiaResult.jl) does **not** export any symbols.\
    [Modia.jl](https://github.com/ModiaSim/Modia.jl) exports all the symbols.
    
| Functions                        | Description                                               |
|:---------------------------------|:----------------------------------------------------------|
| [`@usingModiaPlot`](@ref)        | Expands into `using ModiaPlot_<PlotPackageName>`          |
| [`usePlotPackage`](@ref)         | Define the plot package to be used.                       |
| [`usePreviousPlotPackage`](@ref) | Define the previously defined plot package to be used.    |
| [`currentPlotPackage`](@ref)     | Return name defined with [`usePlotPackage`](@ref)         |

```@docs
@usingModiaPlot
usePlotPackage
usePreviousPlotPackage
currentPlotPackage
```


## Plotting

```@meta
CurrentModule = ModiaPlot_PyPlot
```

The following functions are available after

```julia
import ModiaResult
ModiaResult.@usingModiaPlot
``` 

or

```
using Modia
@usingModiaPlot
```

have been executed. The documentation below was generated with ModiaPlot_PyPlot.

!!! note
    [ModiaResult.jl](https://github.com/ModiaSim/ModiaResult.jl) does **not** export any symbols.\
    [Modia.jl](https://github.com/ModiaSim/Modia.jl) exports all the symbols and uses as
    *result* argument `instantiatedModel` (= returned from `@Modia.instantiatedModel(model, ...)`).

| Functions                                    | Description                                               |
|:---------------------------------------------|:----------------------------------------------------------|
| [`plot`](@ref)                               | Plot simulation results in multiple diagrams/figures.     |
| [`saveFigure`](@ref)                         | Save figure in different formats on file.                 |
| [`closeFigure`](@ref)                        | Close one figure                                          |
| [`closeAllFigures`](@ref)                    | Close all figures                                         |
| [`showFigure`](@ref)                         | Show figure in window (only GLMakie, WGLMakie)            |


```@docs
plot
saveFigure
closeFigure
closeAllFigures
showFigure
```
