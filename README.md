# ModiaResult

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://modiasim.github.io/ModiaResult.jl/stable/index.html)
[![The MIT License](https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square)](https://github.com/ModiaSim/ModiaResult.jl/blob/master/LICENSE.md)

ModiaResult is part of [ModiaSim](https://modiasim.github.io/docs/). See also the ModiaResult [documentation](https://modiasim.github.io/ModiaResult.jl/stable/index.html).

ModiaResult defines an abstract interface for **simulation results** with a potentially segmented 
time axis (on different segments of the time axis, different variables might be defined).

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

The ModiaResult package provides an abstract interface to *operate* on such simulation results, for example, 
- to provide the simulation result in a form to allow *signal calculations* (e.g. ``v_{diff} = v_2 - v_1``),
- to provide a *table view* of the signals via [DataFrames.jl](https://github.com/JuliaData/DataFrames.jl), or
- to produce *line plots* in *multiple diagrams* within *multiple windows/figures* in a *convenient way* (see example below).

*Concrete implementations* of the ModiaResult [Abstract Interface](@ref) are provided for:

- [Modia.jl](https://github.com/ModiaSim/Modia.jl) (a modeling and simulation environment)
- [DataFrames.jl](https://github.com/JuliaData/DataFrames.jl) (tabular data; first column is independent variable)
- [Tables.jl](https://github.com/JuliaData/Tables.jl) (abstract interface for tabular data, e.g. [CSV](https://github.com/JuliaData/CSV.jl) tables; first column is independent variable),
- Dictionaries with String keys (if OrderedDict, independent variable is first variable, otherwise independent variable is "time").

*Concrete implementations* of the ModiaResult [Abstract Plot Interface](@ref) are provided for:

- [PyPlot](https://github.com/JuliaPy/PyPlot.jl) (plots with [Matplotlib](https://matplotlib.org/stable/) from Python), 
- [GLMakie](https://github.com/JuliaPlots/GLMakie.jl) (interactive plots in an OpenGL window),
- [WGLMakie](https://github.com/JuliaPlots/WGLMakie.jl) (interactive plots in a browser window),
- [CairoMakie](https://github.com/JuliaPlots/CairoMakie.jl) (static plots on file with publication quality).

Furthermore, there are two dummy modules included in ModiaResult, that are useful when performing tests with runtests.jl, 
in order that no plot package needs to be loaded during the tests:

- NoPlot (= all plot calls are ignored and info messages are instead printed), or
- SilentNoPlot (= NoPlot without messages).

More details:

- [Getting Started](https://modiasim.github.io/ModiaResult.jl/stable/GettingStarted.html)
- [Functions](https://modiasim.github.io/ModiaResult.jl/stable/Functions.html)
- [Abstract Interface](https://modiasim.github.io/ModiaResult.jl/stable/internal/AbstractInterface.html)
- [Abstract Plot Interface](https://modiasim.github.io/ModiaResult.jl/stable/internal/AbstractPlotInterface.html)

## Installation

All packages are registered and are installed with:

```julia
julia> ]add ModiaResult
        add ModiaPlot_PyPlot        # if plotting with PyPlot desired
        add ModiaPlot_GLMakie       # if plotting with GLMakie desired
        add ModiaPlot_WGLMakie      # if plotting with WGLMakie desired
        add ModiaPlot_CairoMakie    # if plotting with CairoMakie desired
```

If you have trouble installing `ModiaPlot_PyPlot`, see [Installation of PyPlot.jl](https://modiasim.github.io/ModiaResult.jl/stable/index.html#Installation-of-PyPlot.jl)
 
 
## Example

Assume that the result data structure is available, then the following commands


```julia
using ModiaResult

# Define plotting software globally
usePlotPackage("PyPlot") # or ENV["MODIA_PLOT"] = "PyPlot"

# Execute "using ModiaPlot_<globally defined plot package>"
@usingModiaPlot   # = "using ModiaPlot_PyPlot"

# Generate line plots                     
plot(result, [("sigA", "sigB", "sigC"), "r[2:3]"])
```

generate the following plot:

![SegmentedSignalsPlot](docs/resources/images/segmented-signals-plot.png)


## Main developer

[Martin Otter](https://rmc.dlr.de/sr/en/staff/martin.otter/),
[DLR - Institute of System Dynamics and Control](https://www.dlr.de/sr/en)

