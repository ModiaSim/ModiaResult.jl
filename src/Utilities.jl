# License for this file: MIT (expat)
# Copyright 2020, DLR Institute of System Dynamics and Control
# Developer: Martin Otter, DLR-SR
#
# This file is part of module ModiaResult
#
# Utility functions that are usually not directly called.

using  Unitful
import DataStructures
import DataFrames
import Measurements
import MonteCarloMeasurements
import Pkg
isinstalled(pkg::String) = any(x -> x.name == pkg && x.is_direct_dep, values(Pkg.dependencies()))

const AvailableModiaPlotPackages = ["GLMakie", "WGLMakie", "CairoMakie", "PyPlot", "NoPlot", "SilentNoPlot"]
const ModiaPlotPackagesStack = String[]


"""
    usePlotPackage(plotPackage::String)
    
Define the ModiaPlot package that shall be used by command `ModiaResult.@usingModiaPlot`.
If a ModiaPlot package is already defined, save it on an internal stack
(can be reactivated with `usePreviousPlotPackage()`.

Possible values for `plotPackage`:
- `"GLMakie"`
- `"WGLMakie"`
- `"CairoMakie"`
- `"PyPlot"`
- `"NoPlot"`
- `"SilentNoPlot"`

# Example

```julia
import ModiaResult

ModiaResult.usePlotPackage("GLMakie")

module MyTest
    ModiaResult.@usingModiaPlot

    t = range(0.0, stop=10.0, length=100)
    result = Dict{String,Any}("time" => t, "phi" => sin.(t))

    plot(result, "phi")  # use GLMakie for the rendering
end
```
"""
function usePlotPackage(plotPackage::String; pushPreviousOnStack=true)::Bool
    success = true
    if plotPackage == "NoPlot" || plotPackage == "SilentNoPlot"
        if  pushPreviousOnStack && haskey(ENV, "MODIA_PLOT")
            push!(ModiaPlotPackagesStack, ENV["MODIA_PLOT"])
        end
        if plotPackage == "NoPlot"
            ENV["MODIA_PLOT"] = "NoPlot"
        else
            ENV["MODIA_PLOT"] = "SilentNoPlot"
        end
    else
        plotPackageName = "ModiaPlot_" * plotPackage
        if plotPackage in AvailableModiaPlotPackages
            # Check that plotPackage is defined in current environment
            if isinstalled(plotPackageName)
                if pushPreviousOnStack && haskey(ENV, "MODIA_PLOT")
                    push!(ModiaPlotPackagesStack, ENV["MODIA_PLOT"])
                end
                ENV["MODIA_PLOT"] = plotPackage
            else
                @warn "... usePlotPackage(\"$plotPackage\"): Call ignored, since package $plotPackageName is not in your current environment"
                success = false
            end
        else
            @warn "\n... usePlotPackage(\"$plotPackage\"): Call ignored, since argument not in $AvailableModiaPlotPackages."
            success = false
        end
    end
    return success
end



"""
    usePreviousPlotPackage()
    
Pop the last saved ModiaPlot package from an internal stack
and call `usePlotPackage(<popped ModiaPlot package>)`.
"""
function usePreviousPlotPackage()::Bool
    if length(ModiaPlotPackagesStack) > 0
        plotPackage = pop!(ModiaPlotPackagesStack)
        success = usePlotPackage(plotPackage, pushPreviousOnStack=false)
    else
        @warn "usePreviousPlotPackage(): Call ignored, because nothing saved."
        success = false
    end
    return success
end


"""
    currentPlotPackage()
    
Return the name of the plot package as a string that was
defined with [`usePlotPackage`](@ref).
For example, the function may return "GLMakie", "PyPlot" or "NoPlot" or
or "", if no PlotPackage is defined.
"""
currentPlotPackage() = haskey(ENV, "MODIA_PLOT") ? ENV["MODIA_PLOT"] : ""



"""
    @usingModiaPlot()
    
Execute `using XXX`, where `XXX` is the ModiaPlot package that was
activated with `usePlotPackage(plotPackage)`.
"""
macro usingModiaPlot()
    if haskey(ENV, "MODIA_PLOT")
        ModiaPlotPackage = ENV["MODIA_PLOT"]
        if !(ModiaPlotPackage in AvailableModiaPlotPackages)
            @warn "ENV[\"MODIA_PLOT\"] = \"$ModiaPlotPackage\" is not supported!. Using \"NoPlot\"."
            @goto USE_NO_PLOT
        elseif ModiaPlotPackage == "NoPlot"
            @goto USE_NO_PLOT
        elseif ModiaPlotPackage == "SilentNoPlot"
            expr = :( import ModiaResult.SilentNoPlot: plot, showFigure, saveFigure, closeFigure, closeAllFigures )
            return esc( expr )           
        else
            ModiaPlotPackage = Symbol("ModiaPlot_" * ModiaPlotPackage)
            expr = :(using $ModiaPlotPackage)
            println("$expr")            
            return esc( :(using $ModiaPlotPackage) )
        end
        
    else
        @warn "No plot package activated. Using \"NoPlot\"."
        @goto USE_NO_PLOT
    end
    
    @label USE_NO_PLOT
    expr = :( import ModiaResult.NoPlot: plot, showFigure, saveFigure, closeFigure, closeAllFigures )
    println("$expr")
    return esc( expr )
end


const signalTypeToString = ["Independent", "Continuous", "Clocked"]


"""
    resultInfo(result)

Return information about the result as DataFrames.DataFrame object
with columns:

```julia
name::String, unit::String, nTime::String, signalType::String, valueSize::String, eltype::String
```
"""
function resultInfo(result)
    if isnothing(result)
        @info "The call of showInfo(result) is ignored, since the argument is nothing."
        return
    end
    
    resultInfoTable = DataFrames.DataFrame(name=String[], unit=String[], nTime=String[], signalType=String[], valueSize=String[], eltype=String[])

    timeSigName = timeSignalName(result)
    for name in signalNames(result)
        (signalType, nTime, valueSize, elType, sigUnit) = signalInfo(result, name)
        if isnothing(elType)
            sigUnit2    = "???"
            nTime2      = "???"
            signalType2 = "???"
            valueSize2  = "???"
            elType2     = "???"

        else
            sigUnit2    = string(sigUnit)
            nTime2      = name==timeSigName && !hasOneTimeSignal(result) ? "---" : string(nTime)
            signalType2 = signalTypeToString[Int(signalType)]
            valueSize2  = string(valueSize)
            elType2     = string(elType)
        end
            
        push!(resultInfoTable, [name, sigUnit2, nTime2, signalType2, valueSize2, elType2] )
    end 
    
    return resultInfoTable
end



"""
    printResultInfo(result)
    
Print info about result.

# Example
```julia
using ModiaResult
using Unitful
ModiaResult.@usingModiaPlot

t = range(0.0, stop=10.0, length=100)
result = OrderedDict{String,Any}("time"=> t*u"s", "phi" => sin.(t)*u"rad")
printResultInfo(result)

# Gives output:
 # │ name  unit  nTime  signalType  valueSize  eltype  
───┼───────────────────────────────────────────────────
 1 │ time  s     100    Independent ()         Float64
 2 │ phi   rad   100    Continuous  ()         Float64
``` 

"""
function printResultInfo(result)::Nothing
    resultInfoTable = resultInfo(result)
    show(stdout, resultInfoTable, summary=false, rowlabel=Symbol("#"), allcols=true, eltypes=false, truncate=50)   
    println(stdout)    
    return nothing
end



"""
    ResultDict(args...; defaultHeading="", hasOneTimeSignal=true)
    
Return a new ResultDict dictionary (is based on DataStructures.OrderedDict).

- A key of the dictionary is a String. Key `"time"` characterizes the
  independent variable.

- A value of the dictionary is a tuple `(timeSignal, signal, signalType)`
  where `timeSignal::Vector{AbstractVector}`,
  `signal::Vector{AbstractVector}` and
  `signalType::ModiaResult.SignalType.
  `signal[i][j]` is the signalValue at time instant `timeSignal[i][j]` in segment `i`.

# Example

```julia
using ModiaResult

time0 = [0.0, 7.0]
t     = ([time0], [time0], ModiaResult.Independent)

time1 = 0.0 : 0.1  : 2.0
time2 = 3.0 : 0.01 : 3.5
time3 = 5.0 : 0.1  : 7.0
sigA1 = sin.(time1)u"m"
sigA2 = cos.(time2)u"m"
sigA3 = sin.(time3)u"m"
sigA  = ([time1, time2, time3], 
         [sigA1, sigA2, sigA3 ], 
         ModiaResult.SignalType)
sigB  = ([time2], [sin.(time2)], ModiaResult.SignalType)
sigC  = ([time3], [sin.(time3)], ModiaResult.Clocked)    
    
result = ModiaResult.ResultDict("time" => t, 
                                "sigA" => sigA,
                                "sigB" => sigB,
                                "sigC" => sigC,
                                defaultHeading = "Three test signals",
                                hasOneTimeSignal = false)
showInfo(result)
```
"""
struct ResultDict    <: AbstractDict{String,Tuple{Any,Any,SignalType}}
    dict::DataStructures.OrderedDict{String,Tuple{Any,Any,SignalType}}
    defaultHeading::String
    hasOneTimeSignal::Bool
    
    ResultDict(args...; defaultHeading="", hasOneTimeSignal=true) = 
        new(DataStructures.OrderedDict{String,Tuple{Any,Any,SignalType}}(args...),
            defaultHeading, hasOneTimeSignal)
end


        #new(DataStructures.OrderedDict{String,Tuple{Vector{AbstractVector},
        #                                            Vector{AbstractVector},
        #                                            ModiaResult.SignalType}}(args...),
                                                    
# Overload AbstractDict methods
Base.haskey(result::ResultDict, key) = Base.haskey(result.dict, key)

Base.get(result::ResultDict, key, default)     = Base.get(result.dict, key, default)
Base.get(f::Function, result::ResultDict, key) = Base.get(f, result.dict, key)

Base.get!(result::ResultDict, key, default)     = Base.get!(result.dict, key, default)
Base.get!(f::Function, result::ResultDict, key) = Base.get!(f, result.dict, key)

Base.getkey(result::ResultDict, key, default) = Base.getkey(result.dict, key, default)

Base.delete!(result::ResultDict, key) = Base.delete!(result.dict, key)

Base.keys(result::ResultDict) = Base.keys(result.dict)

Base.pop!(result::ResultDict, key)          = Base.pop!(result.dict, key)
Base.pop!(result::ResultDict, key, default) = Base.pop!(result.dict, key, default)

Base.setindex!(result::ResultDict, value, key...) = Base.setindex!(result.dict, value, key...)

Base.values(result::ResultDict) = Base.values(result.dict)




"""
    signalLength(signal)
    
Return the total number of values of `signal::Vector{AbstractVector}`.
If signal[i] is nothing or missing, a length of zero is returned.
"""
function signalLength(signal::AbstractVector) 
    for s in signal
        if ismissing(s) || isnothing(s)
            return 0
        end
    end
    return sum( length(s) for s in signal )
end

   

"""
    hasSameSegments(signal1, signal2)
    
Return true, if the lengths of the segments in `signal1` and in `signal2` are the same.
"""
function hasSameSegments(signal1::Vector{AbstractVector}, signal2::Vector{AbstractVector})
    if length(signal1) != length(signal2)
        return false
    end

    for i = 1:length(signal1)
        if length(signal1[i]) != length(signal2[i])
            return false
        end
    end
    
    return true
end
      

"""
    hasDimensionMismatch(signal, timeSignal, timeSignalName)
    
Print a warning message if signalLength(signal) != signalLength(timeSignal)
and return true. Otherwise, return false
"""
function hasDimensionMismatch(signal, signalName, timeSignal, timeSignalName::AbstractString)
    if signalLength(signal) != signalLength(timeSignal)
        lensignal = signalLength(signal)
        lentime   = signalLength(timeSignal)
        @warn "signalLength of \"$signalName\" = $lensignal but signalLength of \"$timeSignalName\" = $lentime" 
        return true
    end
    return false
end


    
"""
    (sigType, nTime, sigSize, sigElType, sigUnit) = signalInfo(result, name)

Return information about a signal, given the `name` of the signal in `result`:

- `sigType::SignalType`: Ìnterpolation type of signal.

- `nTime::Int`: Number of signal time points.

- `sigSize`: size(signal[1][1])

- `sigElType`: ustrip( eltype(signal[1][1]) ), that is the element type of the signal without unit.

- `sigUnit`: Unit of signal 

If `name` is defined, but no signal is available (= nothing, missing or zero length),
return `nTime=0` and `nothing` for `sigSize, sigElType, sigUnit`.
"""
function signalInfo(result, name::AbstractString)
    (timeSignal, signal, sigType) = rawSignal(result,name)
    if ismissing(signal) || isnothing(signal) || signalLength(signal) == 0 || 
       hasDimensionMismatch(signal, name, timeSignal, timeSignalName(result))
        return (sigType, 0, nothing, nothing, nothing)       
    end

    value     = signal[1][1]
    valueSize = size(value)
    valueUnit = unit(value[1])

    if typeof(value) <: MonteCarloMeasurements.Particles
        elTypeAsString = string(typeof(ustrip.(value[1])))
        nparticles     = length(value)
        valueElType    = "MonteCarloMeasurements.Particles{" * elTypeAsString * ",$nparticles}"
    elseif typeof(value) <: MonteCarloMeasurements.StaticParticles
        elTypeAsString = string(typeof(ustrip.(value[1])))
        nparticles     = length(value)        
        valueElType    = "MonteCarloMeasurements.StaticParticles{" * elTypeAsString * ",$nparticles}"    
    else
        valueElType = typeof( ustrip.(value) ) 
    end
    nTime = signalLength(timeSignal)
    return (sigType, nTime, valueSize, valueElType, valueUnit)
end



"""
    (signal, timeSignal, timeSignalName, signalType, arrayName, arrayIndices, nScalarSignals) = getSignalDetails(result, name)
    
Return the signal defined by `name::AbstractString` as
`signal::Vector{Matrix{<:Real}}`.
`name` may include an array range, such as "a.b.c[2:3,5]".
In this case `arrayName` is the name without the array indices,
such as `"a.b.c"`, `arrayIndices` is a tuple with the array indices,
such as `(2:3, 5)` and `nScalarSignals` is the number of scalar
signals, such as `3` if arrayIndices = `(2:3, 5)`. 
Otherwise `arrayName = name, arrayIndices=(), nScalarSignals=1`.

In case the signal is not known or `name` cannot be interpreted,
`(nothing, nothing, nothing, nothing, name, (), 0)` is returned.

It is required that the value of the signal at a time instant 
has either `typeof(value) <: Real` or
`typeof(value) = AbstractArray{Real, N}`.
The following `Real` types are currently supported:

1. `convert(Float64, eltype(value)` is supported
   (for example Float32, Float64, DoubleFloat, Rational, Int32, Int64, Bool).
  
2. Measurements.Measurement{<Type of (1)>}.

3. MonteCarloMeasurements.StaticParticles{<Type of (1)>}.

4. MonteCarloMeasurements.Particles{<Type of (1)>}.
"""
function getSignalDetails(result, name::AbstractString)
    sigPresent = false
    if hasSignal(result, name)
        (timeSig, sig2, sigType) = rawSignal(result, name)
        timeSigName = timeSignalName(result)
        if !( isnothing(sig2) || ismissing(sig2) || signalLength(sig2) == 0 || 
              hasDimensionMismatch(sig2, name, timeSig, timeSigName) )
            sigPresent = true
            value      = sig2[1][1]
            if ndims(value) == 0
                sig            = sig2
                arrayName      = name
                arrayIndices   = ()
                nScalarSignals = 1 
            else
                arrayName      = name     
                arrayIndices   = Tuple(1:Int(ni) for ni in size(value)) 
                nScalarSignals = length(value) 
                sig = Vector{Matrix{eltype(value)}}(undef, length(sig2))
                for segment = 1:length(sig2)      
                    sig[segment] = zeros(eltype(value), length(sig2[segment]), nScalarSignals)
                    siga  = sig[segment]
                    sig2a = sig2[segment]
                    for (i, value_i) in enumerate(sig2a)
                        for j in 1:nScalarSignals
                            siga[i,j] = sig2a[i][j]
                        end
                    end
                end
            end          
        end
        
    else
        # Handle signal arrays, such as a.b.c[3] or a.b.c[2:3, 1:5, 3]
        if name[end] == ']'      
            i = findlast('[', name)
            if i >= 2
                arrayName = name[1:i-1]
                indices   = name[i+1:end-1]                 
                if hasSignal(result, arrayName)
                    (timeSig, sig2, sigType) = rawSignal(result, arrayName)
                    timeSigName = timeSignalName(result)
                    if !( isnothing(sig2) || ismissing(sig2) || signalLength(sig2) == 0 || 
                          hasDimensionMismatch(sig2, arrayName, timeSig, timeSigName) )
                        sigPresent = true
                        value = sig2[1][1]
                        
                        # Determine indices as tuple
                        arrayIndices = eval( Meta.parse( "(" * indices * ",)" ) )       
                        
                        # Determine number of signals
                        #nScalarSignals = sum( length(indexRange) for indexRange in arrayIndices )
                        
                        # Extract sub-matrix
                        sig = Vector{Any}(undef,length(sig2))
                        for segment = 1:length(sig2)
                            sig2a = sig2[segment]
                            sig[segment] = [getindex(sig2a[i], arrayIndices...) for i in eachindex(sig2a)]
                        end
                        
                        # Determine number of signals
                        nScalarSignals = length(sig[1][1])     
                        
                        # "flatten" array to matrix
                        for segment = 1:length(sig2)      
                            sig[segment] = zeros(eltype(value), length(sig2[segment]), nScalarSignals)
                            siga  = sig[segment]
                            sig2a = sig2[segment]
                            for (i, value_i) in enumerate(sig2a)
                                for j in 1:nScalarSignals
                                    siga[i,j] = sig2a[i][j]
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if sigPresent
        return (sig, timeSig, timeSigName, sigType, arrayName, arrayIndices, nScalarSignals)
    else
        return (nothing, nothing, nothing, nothing, name, (), 0)
    end
end


"""
    (signal, timeSignal, timeSignalName, signalType, arrayName, arrayIndices, nScalarSignals) = 
         getSignalWithWarning(result, name)
    
Call getSignal(result,name) and print a warning message if `signal == nothing`
"""
function getSignalDetailsWithWarning(result,name::AbstractString)
    (sig, timeSig, timeSigName, sigType, arrayName, arrayIndices, nScalarSignals) = getSignalDetails(result,name)
    if isnothing(sig)
        @warn "\"$name\" is not correct or is not defined or has no values."
    end
    return (sig, timeSig, timeSigName, sigType, arrayName, arrayIndices, nScalarSignals)
end


appendUnit2(name, unit) = unit == "" ? name : string(name, " [", unit, "]")


function appendUnit(name, value)
    if typeof(value) <: MonteCarloMeasurements.StaticParticles ||
       typeof(value) <: MonteCarloMeasurements.Particles
        appendUnit2(name, string(unit(value.particles[1])))
    else
        appendUnit2(name, string(unit(value)))
    end
end


"""
    (xsig, xsigLegend, ysig, ysigLegend, ysigType) = getPlotSignal(result, ysigName; xsigName=nothing)

Given the result data structure `result` and a variable `ysigName::AbstractString` with
or without array range indices (for example `ysigName = "a.b.c[2,3:5]"`) and an optional
variable name `xsigName::AbstractString` for the x-axis, return 

- `xsig::Vector{T1<:Real}`: The vector of the x-axis signal without a unit. Segments are concatenated 
  and separated by NaN.

- `xsigLegend::AbstractString`: The legend of the x-axis consisting of the x-axis name
  and its unit (if available).

- `ysig::Vector{T2}` or `::Matrix{T2}`: the y-axis signal, either as a vector or as a matrix
  of values without units depending on the given name. For example, if `ysigName = "a.b.c[2,3:5]"`, then
  `ysig` consists of a matrix with three columns corresponding to the variable values of
  `"a.b.c[2,3]", "a.b.c[2,4]", "a.b.c[2,5]"` with the (potential) units are stripped off.
  Segments are concatenated and separated by NaN.

- `ysigLegend::Vector{AbstractString}`: The legend of the y-axis as a vector
  of strings, where `ysigLegend[1]` is the legend for `ysig`, if `ysig` is a vector,
  and `ysigLegend[i]` is the legend for the i-th column of `ysig`, if `ysig` is a matrix.
  For example, if variable `"a.b.c"` has unit `m/s`, then `ysigName = "a.b.c[2,3:5]"` results in
  `ysigLegend = ["a.b.c[2,3] [m/s]", "a.b.c[2,3] [m/s]", "a.b.c[2,5] [m/s]"]`.

- `ysigType::`[`SignalType`](@ref): The signal type of `ysig` (either `ModiaResult.Continuous`
  or `ModiaResult.Clocked`).
  
If `ysigName` is not valid, or no signal values are available, the function returns 
`(nothing, nothing, nothing, nothing, nothing)`, and prints a warning message.
"""      
function getPlotSignal(result, ysigName::AbstractString; xsigName=nothing)
    (ysig, xsig, timeSigName, ysigType, ysigArrayName, ysigArrayIndices, nysigScalarSignals) = getSignalDetailsWithWarning(result, ysigName)
       
    # Check y-axis signal and time signal
    if isnothing(ysig) || isnothing(xsig) || isnothing(timeSigName)  || signalLength(ysig) == 0
        @goto ERROR   
    end    

    # Get xSigName or check xSigName
    if isnothing(xsigName)
        xsigName = timeSigName
    elseif xsigName != timeSigName
        (xsig, xsigTime, xsigTimeName, xsigType, xsigArrayName, xsigArrayIndices, nxsigScalarSignals) = getSignalDetailsWithWarning(result, xsigName)
        if isnothing(xsig) || isnothing(xsigTime) || isnothing(xsigTimeName) || signalLength(xsig) == 0
            @goto ERROR
        elseif !hasSameSegments(ysig, xsig)
            @warn "\"$xsigName\" (= x-axis) and \"$ysigName\" (= y-axis) have not the same time signal vector."
            @goto ERROR                
        end
    end 
    
    # Check x-axis signal
    xsigValue = first(first(xsig))
    if length(xsigValue) != 1
        @warn "\"$xsigName\" does not characterize a scalar variable as needed for the x-axis."
        @goto ERROR
    elseif !( typeof(xsigValue) <: Number )    
        @warn "\"$xsigName\" has no Number type values, but values of type " * string(typeof(xsigValue)) * "."        
        @goto ERROR    
    elseif typeof(xsigValue) <: Measurements.Measurement
        @warn "\"$xsigName\" is a Measurements.Measurement type and this is not (yet) supported for the x-axis."
        @goto ERROR    
    elseif typeof(xsigValue) <: MonteCarloMeasurements.StaticParticles
        @warn "\"$xsigName\" is a MonteCarloMeasurements.StaticParticles type and this is not supported for the x-axis."
        @goto ERROR  
    elseif typeof(xsigValue) <: MonteCarloMeasurements.Particles
        @warn "\"$xsigName\" is a MonteCarloMeasurements.Particles type and this is not supported for the x-axis."
        @goto ERROR  
    end    
    
    # Build xsigLegend
    xsigLegend = appendUnit(xsigName, xsigValue)

    # Get one segment of the y-axis and check it
    ysegment1 = first(ysig)
    if !( typeof(ysegment1) <: AbstractVector || typeof(ysegment1) <: AbstractMatrix )
        @error "Bug in function: typeof of an y-axis segment is neither a vector nor a Matrix, but " * string(typeof(ysegment1)) 
    elseif !(eltype(ysegment1) <: Number)
        @warn "\"$ysigName\" has no Number values but values of type " * string(eltype(ysegment1))
        @goto ERROR    
    end

    # Build ysigLegend
    value = ysegment1[1]
    if ysigArrayIndices == ()
        # ysigName is a scalar variable
        ysigLegend = [appendUnit(ysigName, value)]        
        
    else
        # ysigName is an array variable
        ysigLegend = [ysigArrayName * "[" for i = 1:nysigScalarSignals]
        i = 1
        ySizeLength = Int[]        
        for j1 in eachindex(ysigArrayIndices)
            push!(ySizeLength, length(ysigArrayIndices[j1]))
            i = 1
            if j1 == 1
                for j2 in 1:div(nysigScalarSignals, ySizeLength[1])
                    for j3 in ysigArrayIndices[1]
                        ysigLegend[i] *= string(j3)
                        i += 1
                    end
                end
            else
                ncum = prod( ySizeLength[1:j1-1] )
                for j2 in ysigArrayIndices[j1]
                    for j3 = 1:ncum
                        ysigLegend[i] *= "," * string(j2)                       
                        i += 1
                    end
                end
            end
        end

        for i = 1:nysigScalarSignals
            ysigLegend[i] *= appendUnit("]", ysegment1[1,i])
        end
    end
           
    #xsig2 = Vector{Any}(undef, length(xsig))
    #ysig2 = Vector{Any}(undef, length(ysig))
    #for i = 1:length(xsig)
    #    xsig2[i] = collect(ustrip.(xsig[i]))
    #    ysig2[i] = collect(ustrip.(ysig[i]))
    #end
    
    xsig2 = collect(ustrip.(first(xsig)))
    ysig2 = collect(ustrip.(first(ysig)))
    if length(xsig) > 1
        xNaN = convert(eltype(xsig2), NaN)
        if ndims(ysig2) == 1
            yNaN = convert(eltype(ysig2), NaN)               
        else
            yNaN = fill(convert(eltype(ysig2), NaN), 1, size(ysig2,2))
        end
           
        for i = 2:length(xsig)
            xsig2 = vcat(xsig2, xNaN, collect(ustrip.(xsig[i])))
            ysig2 = vcat(ysig2, yNaN, collect(ustrip.(ysig[i])))
        end
    end
            
    return (xsig2, xsigLegend, ysig2, ysigLegend, ysigType)
    
    @label ERROR
    return (nothing, nothing, nothing, nothing, nothing)
end



"""
    getHeading(result, heading)
    
Return `heading` if no empty string. Otherwise, return `defaultHeading(result)`.
"""
getHeading(result, heading::AbstractString) = heading != "" ? heading : defaultHeading(result)



"""
    prepend!(prefix, signalLegend)
    
Add `prefix` string in front of every element of the `signalLegend` string-Vector.
"""
function prepend!(prefix::AbstractString, signalLegend::Vector{AbstractString})
   for i in eachindex(signalLegend)
      signalLegend[i] = prefix*signalLegend[i]
   end
   return signalLegend
end

