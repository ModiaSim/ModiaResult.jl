# License for this file: MIT (expat)
# Copyright 2020-2022, DLR Institute of System Dynamics and Control
# Developer: Martin Otter, DLR-SR

using Unitful
import OrderedCollections

#=
"""
    @enum ModiaResult.SignalType
    
Defines the type of the signal. Supported values:
- `ModiaResult.Independent`: Independent variable (usually the time signal).
- `ModiaResult.Continuous`: Piece-wise continuous signal (typically linearly interpolated).
- `ModiaResult.Clocked`: Clocked signal
  (values are only defined at the corresponding `Time` signal time instants and have
   no value in between; the latter might be signaled by piece-wise constant 
   dotted lines).   
"""
@enum SignalType Independent=1 Continuous=2 Clocked=3
=#



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

- `ysigType::`[`VariableKind`](@ref): The variable kind of `ysig` (either `ModiaResult.Continuous`
  or `ModiaResult.Clocked`).

If `ysigName` is not valid, or no signal values are available, the function returns
`(nothing, nothing, nothing, nothing, nothing)`, and prints a warning message.
"""
function getPlotSignal(result, ysigName::AbstractString; xsigName=nothing)
    (ysig, ysigLegend, ysigKind) = signalValuesForLinePlots(result, ysigName)
    if isnothing(ysig)
        @goto ERROR
    end
    
    xsigName2 = isnothing(xsigName) ? timeSignalName(result) : xsigName
    (xsig, xsigLegend, xsigKind) = signalValuesForLinePlots(result, xsigName2)
    if isnothing(xsig)
        @goto ERROR
    end    

    # Check x-axis signal
    xsigValue = first(xsig)
    if ndims(xsig) != 1
        @warn "\"$xsigName\" does not characterize a scalar variable as needed for the x-axis."
        @goto ERROR
    elseif !(typeof(xsigValue) <: Real                                   || 
             typeof(xsigValue) <: Measurements.Measurement               ||
             typeof(xsigValue) <: MonteCarloMeasurements.StaticParticles ||
             typeof(xsigValue) <: MonteCarloMeasurements.Particles       )
        @warn "\"$xsigName\" is of type " * string(typeof(xsigValue)) * " which is not supported for the x-axis."
        @goto ERROR        
    end

    if ysigKind == ModiaResult.Constant
        ysigKind = ModiaResult.Continuous
    end
    return (xsig, xsigLegend[1], ysig, ysigLegend, ysigKind)

    @label ERROR
    return (nothing, nothing, nothing, nothing, nothing)
end



"""
    ResultDict(args...; defaultHeading="", hasOneTimeSignal=true)

Return a new ResultDict dictionary (is based on OrderedCollections.OrderedDict).

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

time1 = 0.0 : 0.1  : 2.0
time2 = 2.0 : 0.01 : 3.5
time3 = 3.5 : 0.1  : 7.0

t = collect(time1)
push!(t, collect(time2))
push!(t, collect(time3))

sigA = sin.(time1)u"m"
push!(sigA, cos.(time2)u"m")
puhs!(sigA, sin.(time3)u"m")

sigB = fill(missing, length(t1))
push!(sigB, sin.(time2))
push!(sigB, fill(missing, length(t3)))

sigC = fill(missing, length(t1))
push!(sigC,fill(missing, length(t2)))
push!(sigC, sin.(time3))

result = ModiaResult.ResultDict("time" => t,
                                "sigA" => sigA,
                                "sigB" => sigB,
                                "sigC" => sigC,
                                defaultHeading = "Three test signals")
showResultInfo(result)
```
"""
struct ResultDict <: AbstractDict{String,Union{Any,Missing}}
    dict::OrderedCollections.OrderedDict{String,Union{Any,Missing}}
    defaultHeading::String

    ResultDict(args...; defaultHeading="") =
        new(OrderedCollections.OrderedDict{String,Union{Any,Missing}}(args...), defaultHeading)
end

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
   vec = OneValueVector(value,nvalues)
   
Provide a vector view of one value (which might be an array).

# Example

```julia
vec1 = OneValueVector(2.0, 10)   # = Vector{Float64} with length(vec) = 10
vec2 = OneValueVector(true, 4)   # = Vector{Bool} with length(vec) = 4
```
"""
struct OneValueVector{T} <: AbstractVector{T}
    value::T
    nvalues::Int
    OneValueVector{T}(value,nvalues) where {T} = new(value,nvalues)
end
OneValueVector(value,nvalues) = OneValueVector{typeof(value)}(value,nvalues)

Base.getindex(v::OneValueVector, i::Int)  = v.value
Base.size(v::OneValueVector)              = (v.nvalues,)
Base.IndexStyle(::Type{<:OneValueVector}) = IndexLinear()


struct FlattendVector{T} <: AbstractVector{T}
    vectorOfVector::Vector{T}
    ibeg::Int  # start index
    iend::Int  # end index
end

Base.getindex(v::FlattendVector, i::Int)  = view(v.vectorOfVector[i], v.ibeg:v.iend)
Base.size(    v::FlattendVector)          = (length(v.vectorOfVector), )
Base.IndexStyle(::Type{<:FlattendVector}) = IndexLinear()





"""
    signal = SignalView(result,signalIndex,negate)
    
Return a view of signal `result[ti][signalIndex]` where `ti` is the index
of the time instant and `signalIndex` is the index of the variable.
If negate=true, negate the signal values.

```julia
signal[ti] = negate ? -result[ti][signalIndex] : result[ti][signalIndex]
```
"""
struct SignalView{T} <: AbstractVector{T}
    result
    signalIndex::Int
    negate::Bool
    SignalView{T}(result,signalIndex,negate) where {T} = new(result,signalIndex,negate)
end
SignalView(result,signalIndex,negate) = SignalView{typeof(result[1][signalIndex])}(result,signalIndex,negate)

Base.getindex(signal::SignalView, ti::Int) = signal.negate ? -signal.result[ti][signal.signalIndex] : signal.result[ti][signal.signalIndex]
Base.size(    signal::SignalView)          = (length(signal.result),)
Base.IndexStyle(::Type{<:SignalView})      = IndexLinear()



"""
    signal = FlattenedSignalView(result,signalStartIndex,signalSize,negate)

Return a view of flattened signal `result[ti][signalStartIndex:signalEndIndex]` 
where `ti` is the index of the time instant and the signal of size `signalSize` has been
flattened into a vector (`signalEndIndex = signalStartIndex + prod(signalSize) - 1`).
If negate=true, negate the signal values.

```julia
baseSignal = reshape(result[ti][signalStartIndex:signalStartIndex+prod(signalSize)-1], signalSize)
signal[ti] = negate ? -baseSignal : baseSignal
```
"""
struct FlattenedSignalView{T} <: AbstractVector{T}
    result
    signalStartIndex::Int
    signalEndIndex::Int
    signalSize::Tuple
    negate::Bool
    FlattenedSignalView{T}(result,signalStartIndex,signalSize,negate) where {T} = 
        new(result,signalStartIndex,signalStartIndex+prod(signalSize)-1,signalSize,negate)
end
FlattenedSignalView(result,signalStartIndex,signalSize,negate) = FlattenedSignalView{typeof(result[1][signalStartIndex])}(result,signalStartIndex,signalSize,negate)

Base.getindex(signal::FlattenedSignalView, ti::Int) = signal.signalSize == () ?
                                                            (signal.negate ? -signal.result[ti][signal.signalStartIndex]
                                                                           :  signal.result[ti][signal.signalStartIndex]) :
                                                            (signal.negate ? -reshape(signal.result[ti][signal.signalStartIndex:signal.signalEndIndex],signal.signalSize) : 
                                                                              reshape(signal.result[ti][signal.signalStartIndex:signal.signalEndIndex],signal.signalSize))
Base.size(    signal::FlattenedSignalView)          = (length(signal.result),)
Base.IndexStyle(::Type{<:FlattenedSignalView})      = IndexLinear()



#=
"""
    (signal, timeSignal, timeSignalName, signalType, arrayName, 
     arrayIndices, nScalarSignals) = getSignalDetails(result, name)
    
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
function getSignalDetails end


"""
    (x,y,xLegend,yLegend) = plotSignal(result, name)

returns signal `name` of `result` in a form, so that a standard `plot(x,y)` command can be executed. 
In particular this means:

- Units are removed from the signals.
- Signals are returned in compact form (see [`signal`](@ref)).
  If the compact form has more as two dimensions, it is reshaped to a matrix
  (so, `y` is either a vector or a matrix; if `y` is a matrix, every column corresponds to one signal element).
"""
function plotSignal(result, name)
    xName = timeSignalName(result)
    xInfo = signalInfo(result,xName)
    yName = name
    yInfo = signalInfo(result,yName)
    x = signal(result,xName,unitless=true)
    y = signal(result,yName,unitless=true,compact=true)
    if ndims(y) > 2
        ysize = size(y)
        y = reshape(y, (ysize[1], prod(ysize[2:end])))
    end
    return (x,y,xName,yName)
end
=#