# Functions

This chapter documents the functions that a user of this package typically utilizes.

A simulation *result* consists of a set of result *signals*. A result *signal* is identified by its `name::String`
(e.g. `"robot.joint1.angle"`). It provides an approximation of a piecewise continuous variable ``v = v(t)`` which is a (partial) function
of the independent, monotonically increasing variable ``t``. Typically, the independent variable ``t`` is called `"time"`.
The approximation consists of the values of variable ``v`` at particular time instants, ``v_i = v(t_i)``
together with the information how to interpolate between these time instants. If a variable is *not defined*
in some phase, it has a value of `missing` at the corresponding time instants.

A value ``v_{ji}(t_i)`` of a variable ``v_j`` at time instant ``t_i`` is represented as `vj[i]` and is 
typically a sub-type of *Real* or of *AbstractArray* with an element type of *Real*
(e.g. a (2,3) array variable ``v_a`` at time instant ``t_i`` is represented as `va[i,1:2,1:3]`).
A simulation result can also hold constants (parameters), that have the same value at all time instants. 
Constants are compactly stored as  [`OneValueSignal`](@ref) and can be of any Julia type (e.g. `v = "data.txt"`).
If a variable is *not defined* in some phase, it has a value of `missing` at the corresponding time instants. 
Optionally, a unit (via [`Unitful.jl`](https://github.com/PainterQubits/Unitful.jl)) can be associated with a 
variable ``v`` (so the same unit for all elements, if the variable is an array).


## Results

```@meta
CurrentModule = ModiaResult
```

The functions below are provided to operate on a result data structure, especially:

- [Modia.jl](https://github.com/ModiaSim/Modia.jl) (a modeling and simulation environment),
- [DataFrames.jl](https://github.com/JuliaData/DataFrames.jl) (tabular data; first column is independent variable)
- [Tables.jl](https://github.com/JuliaData/Tables.jl) (abstract interface for tabular data, e.g. [CSV](https://github.com/JuliaData/CSV.jl) tables; first column is independent variable),
- AbstractDict dictionaries with String keys (if OrderedDict, independent variable is first variable, otherwise independent variable is "time").

!!! note
    [ModiaResult.jl](https://github.com/ModiaSim/ModiaResult.jl) exports all symbols with exception of VariableKind.\
    [Modia.jl](https://github.com/ModiaSim/Modia.jl) reexports all symbols and uses as *result* argument `instantiatedModel`.

| Result functions                   | Description                                                                                    |
|:-----------------------------------|:-----------------------------------------------------------------------------------------------|
| [`showResultInfo`](@ref)           | Print info of the result on stdout.                                                            |
| [`resultInfo`](@ref)               | Return info about the result as [DataFrame](https://github.com/JuliaData/DataFrames.jl) table. |
| [`hasSignal`](@ref)                | Return true if a signal name is known in a result                                              |
| [`timeSignalName`](@ref)           | Return signal name of the independent variable of a result                                     |
| [`signalNames`](@ref)              | Return all signal names (including independent variable) of a result                           |
| [`SignalInfo`](@ref)               | Return info about a signal.                                                                    |
| [`ModiaResult.VariableKind`](@ref) | `@enum` used in [`SignalInfo`](@ref)                                                           |
| [`signalValues`](@ref)             | Return values of one signal as an array (**potentially with** `missing` values).               |
| [`signalValuesForLinePlots`](@ref) | Return values of one signal prepared for a plot package, including signal legend               |
|                                    | (return `Vector` or `Matrix` with potentially `NaN` but **no** `missing` values).              |
| [`lastSignalValue`](@ref)          | Return last value of one signal (useful e.g. for @test)                                        |
| [`defaultHeading`](@ref)           | Return default heading of result data structure (e.g. for a plot window).                      |
| [`quantity`](@ref)                 | Return Quantity from numberType and numberUnit, e.g. `quantity(Float64,u"m/s")`.               |
| [`OneValueSignal`](@ref)           | Return a view to one value as an array signal, e.g. `OneValueSignal("data.txt",100)`           |


```@docs
showResultInfo
resultInfo
hasSignal
timeSignalName
signalNames
SignalInfo
VariableKind
signalValues
signalValuesForLinePlots
lastSignalValue
defaultHeading
quantity
OneValueSignal
```


## Plot Package

```@meta
CurrentModule = ModiaResult
```

The plot package `XXX` to be used can be defined by:

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

Typically, runtests.jl is defined as:

```julia
using ModiaResult
usePlotPackage("SilentNoPlot") # Define Plot Package (previously defined one is put on a stack)
include("include_all.jl")      # Include all tests that use a plot package
usePreviousPlotPackage()       # Use previously defined Plot package
```

The following functions are provided to define/inquire the current plot package.

!!! note
    [ModiaResult.jl](https://github.com/ModiaSim/ModiaResult.jl) exports all symbols.\
    [Modia.jl](https://github.com/ModiaSim/Modia.jl) reexports all symbols.
    
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


## Line Plots

```@meta
CurrentModule = ModiaPlot_PyPlot
```

The functions below are used to *plot* one or more result signals in one or more *diagrams*
within one or more *windows* (figures), and *save* a window (figure) in various *formats* on file
(e.g. png, pdf). The functions below are available after

```julia
using ModiaResult   # Make Symbols available
@usingModiaPlot     # Define used Plot package (expands e.g., into: using ModiaPlot_PyPlot)
``` 

or

```
using Modia
@usingModiaPlot
```

have been executed. The documentation has been generated with [ModiaPlot_PyPlotResult.jl](https://github.com/ModiaSim/ModiaPlot_PyPlot.jl).

!!! note
    [ModiaResult.jl](https://github.com/ModiaSim/ModiaResult.jl) exports all symbols.\
    [Modia.jl](https://github.com/ModiaSim/Modia.jl) reexports all symbols and uses as *result* argument `instantiatedModel`.

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
