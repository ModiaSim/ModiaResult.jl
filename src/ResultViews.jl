using Unitful

    
"""
   vec = OneValueVector(value,nvalues)
   
Provide a vector view of one value.

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



