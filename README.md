# ModiaResult

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://modiasim.github.io/ModiaResult.jl/stable/index.html)
[![The MIT License](https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square)](https://github.com/ModiaSim/ModiaResult.jl/blob/master/LICENSE.md)

ModiaResult is part of [ModiaSim](https://modiasim.github.io/docs/). See also the ModiaResult [documentation](https://modiasim.github.io/ModiaResult.jl/stable/index.html).

ModiaResult defines an abstract interface for **simulation results** and provides overloaded methods for:

- Dictionaries,

- [DataFrame](https://github.com/JuliaData/DataFrames.jl) tables, 

- [Tables](https://github.com/JuliaData/Tables.jl) (for example [CSV](https://github.com/JuliaData/CSV.jl)), and

- ModiaResult.ResultDict (special dictionary with all features of the interface). 

Additionally, **operations** on simulation results are provided, especially to produce **line plots** in a **convenient way** based on 

- [GLMakie](https://github.com/JuliaPlots/GLMakie.jl) (interactive plots in an OpenGL window),
- [WGLMakie](https://github.com/JuliaPlots/WGLMakie.jl) (interactive plots in a browser window),
- [CairoMakie](https://github.com/JuliaPlots/CairoMakie.jl) (static plots on file with publication quality),
- [PyPlot](https://github.com/JuliaPy/PyPlot.jl) (plots with Matplotlib from Python) and 
- NoPlot (= all plot calls are ignored; NoPlot is a module in ModiaResult), or
- SilentNoPlot (= NoPlot without messages; SilentNoPlot is a module in ModiaResult).


## Installation

ModiaResult is registered. The accompanying plot packages are currently being registered.
During this phase, the packages are installed as (Julia >= 1.5 is required):

```julia
julia> ]add ModiaResult,
        add https://github.com/ModiaSim/ModiaPlot_GLMakie.jl
        add https://github.com/ModiaSim/ModiaPlot_WGLMakie.jl
        add https://github.com/ModiaSim/ModiaPlot_CairoMakie.jl
        add https://github.com/ModiaSim/ModiaPlot_PyPlot.jl
```

Once all packages are registered, install the packages with:

```julia
julia> ]add ModiaResult
        add ModiaPlot_GLMakie
        add ModiaPlot_WGLMakie
        add ModiaPlot_CairoMakie
        add ModiaPlot_PyPlot
```


## Examples

The following example defines a simple line plot of a sine wave:

```julia
import ModiaResult

# Define plotting software globally
ModiaResult.activate("GLMakie") # or ENV["MODIA_PLOT"] = "GLMakie"

# Define result data structure
t = range(0.0, stop=10.0, length=100)
result = Dict("time" => t, "phi" => sin.(t))

# Generate line plot
ModiaResult.@usingModiaPlot  # = "using ModiaPlot_GLMakie"
plot(result, "phi", heading = "Sine(time)")
```
Executing this code results in the following plot:

![SinePlot](docs/resources/images/sine-plot.png)

A more complex example is shown in the next definition, where the signals have units, are scalars and vectors, have different time axes and are not always defined over the complete time range.
 

```julia
import ModiaResult
using  Unitful

# Define plotting software globally
ModiaResult.activate("PyPlot") # or ENV["MODIA_PLOT"] = "PyPlot"

# Define result data structure
t0 = ([0.0, 15.0], [0.0, 15.0], ModiaResult.TimeSignal)
t1 = 0.0  : 0.1 : 15.0
t2 = 0.0  : 0.1 : 3.0
t3 = 5.0  : 0.3 : 9.5
t4 = 11.0 : 0.1 : 15.0

sigA1 = 0.9*sin.(t2)u"m"
sigA2 =     cos.(t3)u"m"
sigA3 = 1.1*sin.(t4)u"m"
R2    = [[0.4 * cos(t), 0.5 * sin(t), 0.3 * cos(t)] for t in t2]u"m"
R4    = [[0.2 * cos(t), 0.3 * sin(t), 0.2 * cos(t)] for t in t4]u"m"

sigA  = ([t2,t3,t4], [sigA1,sigA2,sigA3 ], ModiaResult.Continuous)
sigB  = ([t1]      , [0.7*sin.(t1)u"m/s"], ModiaResult.Continuous)
sigC  = ([t3]      , [sin.(t3)u"N*m"]    , ModiaResult.Clocked)
r     = ([t2,t4]   , [R2,R4]             , ModiaResult.Continuous)
    
result = ModiaResult.ResultDict("time" => t0, 
                                "sigA" => sigA,
                                "sigB" => sigB,
                                "sigC" => sigC,
                                "r"    => r,
                                defaultHeading = "Segmented signals",
                                hasOneTimeSignal = false) 
                        
# Generate line plots                     
ModiaResult.@usingModiaPlot   # = "using ModiaPlot_PyPlot"
plot(result, [("sigA", "sigB", "sigC"), "r[2:3]"])
```

Executing this code results in the following plot:

![SegmentedSignalsPlot](docs/resources/images/segmented-signals-plot.png)


Many other examples are available at `$(ModiaResult.path)/test/*.jl`.



## Main developer

[Martin Otter](https://rmc.dlr.de/sr/en/staff/martin.otter/),
[DLR - Institute of System Dynamics and Control](https://www.dlr.de/sr/en)

