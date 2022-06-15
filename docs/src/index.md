# ModiaResult Documentation

```@meta
CurrentModule = ModiaResult
```

Package [ModiaResult](https://github.com/ModiaSim/ModiaResult.jl) defines
an [Abstract Result Interface](@ref) and an [Abstract Line Plot Interface](@ref)  
together with concrete implementations of these interfaces. 
Furthermore, useful functionality is provided on top of these interfaces, 
for example line plots (see [Functions](@ref)).

A *result* consists of a set of *signals*. A *signal* is identified by its `name::String`
(e.g. `"robot.joint1.angle"`) and is a representation of the values of a variable ``v_j`` as a (partial) function ``v_j(t)``
of the independent, monotonically increasing variable ``t``. Typically, the independent variable ``t`` is called `"time"`.

- The (only) *independent variable* ``t`` of a result is represented as a set of values ``t_i`` that are stored in a vector `t::Vector{<:Real}`.
  
- A *dependent variable* ``v`` of a result is represented as a set of values ``v(t_i) = v_i`` and is stored as array `v::AbstractArray{T,N}`.
  `v[i,j,k,...]` is element `j,k,...` of variable ``v`` at ``t_i``.\
  If an element is *not defined*, it has a value of **`missing`** at the corresponding time instants. 
  
Example of a result data structure, together with the *attributes* that can be associated with a signal:

```julia
name        unit      size      eltype                  kind                          info
────────────────────────────────────────────────────────────────────────────────────────────────
time        s         (208,)    Float64                 Independent (= [0.0 .. 7.0])
load.f      N         (208, 3)  Vector{Float64}         Constant (= [1.0, 2.0, 3.0])
load.phi    rad       (208,)    Float64                                 
load.r_abs  m         (208, 3)  Float64                
load.w      rad*s^-1  (208,)    Union{Missing,Float64}                                    
motor.J     kg*m^2    (208,)    Float64                 Constant (= 1.2)
motor.b               (208,)    Bool                   
motor.data            (208,)    MotorStruct             Constant
motor.phi   rad       (208,)    Float64                 
motor.w_m   rad/s     (208,)    Union{Missing,Float64}                                Clocked
reference             (208,)    String                  Constant (= "reference.txt")
```

The *logical view* of a signal is always an *array*. Consequently, all meaningful array operations can be directly
performed on signals, for example `diff = result["load.phi"] - result["motor.phi"]`. The following signal kinds are supported:
- *Continuous*: Piecewise continuous signal `s::AbstractArray{<:Number,N}` that is linearly interpolated in ``t``.
- *Clocked*: Signal `s::AbstractArray{<:Any,N}` that is not interpolated.
- *Constant*: Signal `s::AbstractArray{<:Any,N}` that has the same value at all ``t`` (compactly stored).
- *Eliminated*: Signal is an alias or negative alias of another signal.
Attributes *unit*, *size*, *eltype* are part of the array type (*unit* via [Unitful.jl](https://github.com/PainterQubits/Unitful.jl)). 
The other attributes are stored with special array types: 
[`ContinuousSignal`](@ref), [`ClockedSignal`](@ref), [`ConstantSignal`](@ref), [`EliminatedSignal`](@ref).

*Concrete implementations* of the ModiaResult [Abstract Result Interface](@ref) are provided for:

- [`ResultTable`](@ref) (included in ModiaResult.jl).
- [Modia.jl](https://github.com/ModiaSim/Modia.jl) (a modeling and simulation environment)
- [DataFrames.jl](https://github.com/JuliaData/DataFrames.jl)
  (tabular data; first column is independent variable; *only vector signals*))
- [Tables.jl](https://github.com/JuliaData/Tables.jl)
  (abstract tables, e.g. [CSV](https://github.com/JuliaData/CSV.jl) tables;
  first column is independent variable; *only vector signals*).

*Concrete implementations* of the ModiaResult [Abstract Line Plot Interface](@ref) are provided for:

- [PyPlot](https://github.com/JuliaPy/PyPlot.jl) (plots with [Matplotlib](https://matplotlib.org/stable/) from Python), 
- [GLMakie](https://github.com/JuliaPlots/GLMakie.jl) (interactive plots in an OpenGL window),
- [WGLMakie](https://github.com/JuliaPlots/WGLMakie.jl) (interactive plots in a browser window),
- [CairoMakie](https://github.com/JuliaPlots/CairoMakie.jl) (static plots on file with publication quality).

Furthermore, there are two dummy implementations included in ModiaResult, that are useful when performing tests with runtests.jl, 
in order that no plot package needs to be loaded during the tests:

- NoPlot (= all plot calls are ignored and info messages are instead printed), or
- SilentNoPlot (= NoPlot without messages).


## Example

```julia
# Define Plot Package in startup.jl. Here: ENV["MODIA_PLOT"] = "PyPlot"
# Or change definition in Julia session. Here: usePlotPackage("PyPlot")

include("$(ModiaResult.path)/examples/result3.jl")   # construct a ResultTable result
@usingModiaPlot                                      # activate plot package
plot(result, [("sigA", "sigB", "sigC"), "r[2:3]"])   # generate line plots
```

Generates the following plot:

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

