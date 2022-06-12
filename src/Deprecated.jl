# License for this file: MIT (expat)
# Copyright 2020-2022, DLR Institute of System Dynamics and Control
# Developer: Martin Otter, DLR-SR

using Unitful
import OrderedCollections


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



