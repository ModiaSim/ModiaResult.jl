using Unitful

    
"""
   OneValueVector{T}(value,nvalues) < AbstractVector{T}
   
Return a vector with identical elements 
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
