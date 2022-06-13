# License for this file: MIT (expat)
# Copyright 2021-2022, DLR Institute of System Dynamics and Control
# Developer: Martin Otter, DLR-SR
#
# This file is part of module ModiaResult
#
# Overloaded ModiaResult methods for 
# - AbstractDict{String,T}
# - DataFrames
# - Tables

import ModiaResult
import DataFrames
import Tables
import OrderedCollections

# Overloaded methods for AbstractDict{String,T}
ModiaResult.timeSignalName(result::AbstractDict{T1,T2}) where {T1<:AbstractString,T2}               = "time"
ModiaResult.signalNames(   result::AbstractDict{T1,T2}) where {T1<:AbstractString,T2}               = collect(keys(result))
ModiaResult.hasSignal(     result::AbstractDict{T1,T2}, name::String) where {T1<:AbstractString,T2} = haskey(result, name)
ModiaResult.signalValues(  result::AbstractDict{T1,T2}, name::String; unitless=false) where {T1<:AbstractString,T2} = unitless ? ustrip.(result[name]) : result[name]

function ModiaResult.SignalInfo(result::AbstractDict{T1,T2}, name::String)::SignalInfo where {T1<:AbstractString,T2}
    sig     = result[name]
    sigDims = size(sig)
    sigInfo = ""

    if isOneValueSignal(sig)
        kind = ModiaResult.Constant
        if typeof(sig.value) <: Number || typeof(sig.value) <: AbstractArray && eltype(sig.value) <: Number
            sigUnit = unitAsParseableString(sig.value)  
            value = ustrip.(sig.value)
            elementType = typeof(value)
        else
            sigUnit = ""
            value   = sig.value
            elementType = typeof(value)
        end
    else
        if !( BaseType(eltype(sig)) <: Real )
            error("\nSignal \"$name\" has no elements of type Real but has elements of type\n", eltype(sig))
        end
        sigUnit     = unitAsParseableString(sig)
        elementType = eltype(ustrip.(sig))
        value       = missing
        
        if name == timeSignalName(result)
            kind = ModiaResult.Independent
        else
            kind = ModiaResult.Continuous
        end        
    end          

    SignalInfo(kind, elementType, sigDims, sigUnit, sigInfo, value, "", false)
end

# Overloaded methods for OrderedDict{String,T}   # Rest is the same as for AbstractDict
ModiaResult.timeSignalName(result::OrderedCollections.OrderedDict{T1,T2}) where {T1<:AbstractString,T2} = first(result).first


#=
# Overloaded methods for ModiaResult.ResultDict
ModiaResult.rawSignal(       result::ResultDict, name::String) = result.dict[name]
ModiaResult.signalNames(     result::ResultDict)               = collect(keys(result.dict))
ModiaResult.timeSignalName(  result::ResultDict)               = "time"
ModiaResult.hasOneTimeSignal(result::ResultDict)               = result.hasOneTimeSignal
ModiaResult.hasSignal(       result::ResultDict, name::String) = haskey(result.dict, name)
ModiaResult.defaultHeading(  result::ResultDict)               = result.defaultHeading



# Overloaded methods for DataFrames
ModiaResult.timeSignalName(result::DataFrames.DataFrame) = DataFrames.names(result, 1)[1]
ModiaResult.signalNames(   result::DataFrames.DataFrame) = DataFrames.names(result)
ModiaResult.signal(        result::DataFrames.DataFrame, name::AbstractString; unitless=false) = ([result[!,1]], [result[!,name]], name == timeSignalName(result) ? ModiaResult.Independent : ModiaResult.Continuous)
 

 
# Overloaded methods for Tables
function ModiaResult.rawSignal(result, name::AbstractString)
    if Tables.istable(result) && Tables.columnaccess(result)
        return ([Tables.getcolumn(result, 1)], [Tables.getcolumn(result, Symbol(name))], string(Tables.columnnames(result)[1]) == name ? ModiaResult.Independent : ModiaResult.Continuous)
    else
        @error "rawSignal(result, \"$name\") is not supported for typeof(result) = " * string(typeof(result))
    end
end

function ModiaResult.signalNames(result)
    if Tables.istable(result) && Tables.columnaccess(result)
        return string.(Tables.columnnames(result))
    else
        @error "signalNames(result) is not supported for typeof(result) = " * string(typeof(result))
    end
end

function ModiaResult.timeSignalName(result)
    if Tables.istable(result) && Tables.columnaccess(result)
        return string(Tables.columnnames(result)[1])
    else
        @error "timeSignalName(result) is not supported for typeof(result) = " * string(typeof(result))
    end
end

function ModiaResult.hasOneTimeSignal(result)
    if Tables.istable(result) && Tables.columnaccess(result)
        return true
    else
        @error "hasOneTimeSignal(result) is not supported for typeof(result) = " * string(typeof(result))
    end
end
=#