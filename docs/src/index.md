# ModiaResult Documentation

```@meta
CurrentModule = ModiaResult
```

Package [ModiaResult](https://github.com/ModiaSim/ModiaResult.jl) defines 
an abstract interface for **simulation results** with a potentially segmented 
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
- to produce *line plots* in *multiple diagrams* within *multiple windows/figurs* in a *convenient way* (see example below).

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


## Example

Assume that the result data structure is available, then the following commands


```julia
import ModiaResult

# Define plotting software globally
ModiaResult.activate("PyPlot") # or ENV["MODIA_PLOT"] = "PyPlot"

# Execute "using ModiaPlot_<globally defined plot package>"
ModiaResult.@usingModiaPlot   # = "using ModiaPlot_PyPlot"

# Generate line plots                     
plot(result, [("sigA", "sigB", "sigC"), "r[2:3]"])
```

generate the following plot:

![SegmentedSignalsPlot](../resources/images/segmented-signals-plot.png)


## Installation

All packages are registered and are installed with:

```julia
julia> ]add ModiaResult
        add ModiaPlot_PyPlot        # if plotting with PyPlot desired
        add ModiaPlot_GLMakie       # if plotting with GLMakie desired
        add ModiaPlot_WGLMakie      # if plotting with WGLMakie desired
        add ModiaPlot_CairoMakie    # if plotting with CairoMakie desired
```

If you have trouble installing `ModiaPlot_PyPlot`, see 
[Installation of PyPlot.jl](https://modiasim.github.io/ModiaResult.jl/stable/index.html#Installation-of-PyPlot.jl)


## Installation of PyPlot.jl

`ModiaPlot_PyPlot.jl` uses `PyPlot.jl` which in turn uses Python. 
Therefore a Python installation is needed. Installation 
might give problems in some cases. Here are some hints what to do
(you may also consult the documentation of [PyPlot.jl](https://github.com/JuliaPy/PyPlot.jl)).

Before installing `ModiaPlot_PyPlot.jl` make sure that `PyPlot.jl` is working:

```julia
]add PyPlot
using PyPlot
t = [0,1,2,3,4]
plot(t,2*t)
```

If the commands above give a plot window. Everything is fine.

If you get errors or no plot window appears or Julia crashes, 
try to first install a standard Python installation from Julia:

```julia
# Start a new Julia session
ENV["PYTHON"] = ""    # Let Julia install Python
]build PyCall
exit()   # Exit Juila

# Start a new Julia session
]add PyPlot
using PyPlot
t = [0,1,2,3,4]
plot(t,2*t)
```

If the above does not work, or you want to use another Python distribution,
install a [Python 3.x distribution](https://wiki.python.org/moin/PythonDistributions) that contains Matplotlib,
set `ENV["PYTHON"] = "<path-above-python-installation>/python.exe"` and follow the steps above.
Note, `ModiaPlot_PyPlot` is based on the Python 3.x version of Matplotlib where some keywords
are different to the Python 2.x version.


## Release Notes

### Version 0.5.0-dev

- 


**Non-backwards compatible changes**

- A result data structure has only one time axis (previously, a result datastructure could have several time axes).
  Therefore, function `hasOneTimeSignal` makes no sense anymore and is removed.
  



### Version 0.4.3

- Internal bug fixed.


### Version 0.4.2

- `showResultInfo(..)` and `resultInfo(..)` improved
  (signals with one value defined with ModiaResult.OneValueVector are specially marked,
  for example parameters).


### Version 0.4.1

- Update of Manifest.toml file


### Version 0.4.0

- Require Julia 1.7
- Upgrade Manifest.toml to version 2.0
- Update Project.toml/Manifest.toml


### Version 0.3.10

- Packages used in test models, prefixed with `ModiaResult.` to avoid missing package errors.


### Version 0.3.9

- Wrong link in README.md corrected
- makie.jl: Adapted to newer Makie version (update!(..) no longer known and needed).
- Issue with ustrip fixed.
- Broken test_52_MonteCarloMeasurementsWithDistributions.jl reactivated
- Manifest.toml updated. 

### Version 0.3.8

- Better handling if some input arguments are `nothing`.
- Bug corrected when accessing a vector element, such as `mvec[2]`.
- Documentation slightly improved.


### Version 0.3.7

- Replaced Point2f0 by Makie_Point2f that needs to be defined according to the newest Makie version.


### Version 0.3.6

- Adapt to MonteCarloMeasurements, version >= 1.0 (e.g. pmean(..) instead of mean(..))
- Remove test_71_Tables_Rotational_First.jl from runtests.jl, because "using CSV" 
  (in order that CSV.jl does not have to be added to the Project.toml file)


### Version 0.3.5

- Project.toml: Added version 1 of MonteCarloMeasurements.


### Version 0.3.4

- Project.toml: Added older versions to DataFrames, in order to reduce conflicts.

### Version 0.3.3

- ModiaResult/test/Project.toml: DataStructures replaced by OrderedCollections.


### Version 0.3.2

- DataStructures replaced by OrderedCollections.
- Version numbers of used packages updated.


### Version 0.3.1

- Two new views on results added (SignalView and FlattenedSignalView).


### Version 0.3

- Major clean-up of the function interfaces. This version is not backwards compatible to previous versions.


### Version 0.2.2

- Overloaded AstractDicts generalized from `AbstractDict{String,T} where {T}` to\
  `AbstractDict{T1,T2} where {T1<:AbstractString,T2}`.

- Bug fixed.



### Version 0.2.1

- Bug fixed: `<: Vector` changed to `<: AbstractVector`


### Version 0.2.0

- Abstract Interface slightly redesigned (therefore 0.2.0 is not backwards compatible to 0.1.0).

- Modules NoPlot and SilentNoPlot added as sub-modules of ModiaResult. These modules are
  activated if plot package "NoPlot" or "SilentNoPlot" are selected.

- Content of directory src_plot moved into src. Afterwards src_plot was removed.

- Directory test_plot merged into test (and then removed).
  

### Version 0.1.0

- Initial version (based on the result plotting developed for [ModiaMath](https://github.com/ModiaSim/ModiaMath.jl)).

## Main developer

[Martin Otter](https://rmc.dlr.de/sr/en/staff/martin.otter/),
[DLR - Institute of System Dynamics and Control](https://www.dlr.de/sr/en)

