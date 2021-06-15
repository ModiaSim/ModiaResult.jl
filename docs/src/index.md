# ModiaResult Documentation

Package [ModiaResult](https://github.com/ModiaSim/ModiaResult.jl) defines 
an abstract interface for **simulation results** and provides overloaded methods for:

- Dictionaries with String keys,

- [DataFrame](https://github.com/JuliaData/DataFrames.jl) tables, 

- [Tables](https://github.com/JuliaData/Tables.jl) (for example [CSV](https://github.com/JuliaData/CSV.jl)), and

- ModiaResult.ResultDict (special dictionary with all features of the interface). 

Additionally, **operations** on simulation results are provided, especially to produce **line plots**
in a **convenient way** based on 

- [GLMakie](https://github.com/JuliaPlots/GLMakie.jl) (interactive plots in an OpenGL window),
- [WGLMakie](https://github.com/JuliaPlots/WGLMakie.jl) (interactive plots in a browser window),
- [CairoMakie](https://github.com/JuliaPlots/CairoMakie.jl) (static plots on file with publication quality),
- [PyPlot](https://github.com/JuliaPy/PyPlot.jl) (plots with Matplotlib from Python), 
- NoPlot (= all plot calls are ignored; NoPlot is a module in ModiaResult), or
- SilentNoPlot (= NoPlot without messages; SilentNoPlot is a module in ModiaResult).

More details:

- [Getting Started](GettingStarted.html)
- [Functions](Functions.html)
- [Abstract Interface](AbstractInterface.html)
- [Internal](Internal.html)


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
# Exit Juila

# Start a new Julia session
]add PyPlot
using PyPlot
t = [0,1,2,3,4]
plot(t,2*t)
```

If the above does not work, or you want to use another Python distribution,
you might utilize the following approach.

1. Install a Python 3.x distribution that contains Matplotlib.\
   Recommended: [Anaconda distribution](https://www.anaconda.com/download/).\
   Advantage: very robust;\
   Disadvantage: > 3 GByte memory needed;\
   `ModiaPlot_PyPlot` is based on the Python 3.x version of Matplotlib where some keywords
   are different to the Python 2.x version.\
   On **Windows 10**, either provide a `julia_start.bat` file with the following content
   (and add `<path-to-julia-installation>\bin` to the path environment variable):
   ```
   call <path-to-Anaconda3>\Anaconda3\Scripts\activate.bat
   julia
   ```
   and always start julia by calling `julia_start`,\
   or you could add the following directories to the path environment variable:
   ```
   <path-to-Anaconda3>\Anaconda3
   <path-to-Anaconda3>\Anaconda3\Library\mingw-w64\bin
   <path-to-Anaconda3>\Anaconda3\Library\usr\bin
   <path-to-Anaconda3>\Anaconda3\Library\bin
   <path-to-Anaconda3>\Anaconda3\Scripts
   <path-to-Anaconda3>\Anaconda3\bin
   <path-to-Anaconda3>\Anaconda3\condabin
   ```
   and start julia by calling `julia`
  

2. Include the path to the Python executable in your startup file\
   (`<path-to-user>/.julia/config/startup.jl`):\
    `ENV["PYTHON"] = "<path-above-Anaconda3>/Anaconda3/python.exe"`.

3. Start Julia, give the command `ENV["PYTHON"]` in the REPL, and check whether the path
   is correct (if you made a typo in the startup file, Julia might use another
   Python executable and PyPlot might crash Julia).

4. If you have used a different Python installation before, execute the command
   `]build PyCall` (or `using Pkg; Pkg.build("PyCall")`, exit Julia and start Julia again.

5. Install PyPlot via `]add PyPlot` (or `using Pkg; Pkg.add("PyPlot")`)



## Release Notes

### Version 0.1.0

- Initial version (based on the result plotting developed for [ModiaMath](https://github.com/ModiaSim/ModiaMath.jl)).

## Main developer

[Martin Otter](https://rmc.dlr.de/sr/en/staff/martin.otter/),
[DLR - Institute of System Dynamics and Control](https://www.dlr.de/sr/en)

