# License for this file: MIT (expat)
# Copyright 2021, DLR Institute of System Dynamics and Control
# Developer: Martin Otter, DLR-SR
#
# This file is part of module ModiaResult
#
# Overloaded ModiaResult methods for 
# - AbstractDict{String,T}
# - DataFrames
# - Tables
# - ModiaResult.ResultDict

import ModiaResult
import DataFrames
import Tables
import DataStructures


# Overloaded methods for AbstractDict{String,T}
ModiaResult.rawSignal(       result::AbstractDict{T1,T2}, name::String) where {T1<:AbstractString,T2} = ([result["time"]], [result[name]], 
                                                                                                            name == "time" ? ModiaResult.Independent : ModiaResult.Continuous)
ModiaResult.signalNames(     result::AbstractDict{T1,T2}) where {T1<:AbstractString,T2}               = collect(keys(result))
ModiaResult.timeSignalName(  result::AbstractDict{T1,T2}) where {T1<:AbstractString,T2}               = "time" 
ModiaResult.hasOneTimeSignal(result::AbstractDict{T1,T2}) where {T1<:AbstractString,T2}               = true
ModiaResult.hasSignal(       result::AbstractDict{T1,T2}, name::String) where {T1<:AbstractString,T2} = haskey(result, name)



# Overloaded methods for ModiaResult.ResultDict
ModiaResult.rawSignal(       result::ResultDict, name::String) = result.dict[name]
ModiaResult.signalNames(     result::ResultDict)               = collect(keys(result.dict))
ModiaResult.timeSignalName(  result::ResultDict)               = "time"
ModiaResult.hasOneTimeSignal(result::ResultDict)               = result.hasOneTimeSignal
ModiaResult.hasSignal(       result::ResultDict, name::String) = haskey(result.dict, name)
ModiaResult.defaultHeading(  result::ResultDict)               = result.defaultHeading



# Overloaded methods for DataFrames
ModiaResult.timeSignalName(  result::DataFrames.DataFrame) = DataFrames.names(result, 1)[1]
ModiaResult.hasOneTimeSignal(result::DataFrames.DataFrame) = true
ModiaResult.rawSignal(       result::DataFrames.DataFrame, name::AbstractString) = ([result[!,1]], [result[!,name]], name == timeSignalName(result) ? ModiaResult.Independent : ModiaResult.Continuous)
ModiaResult.signalNames(     result::DataFrames.DataFrame) = DataFrames.names(result)
 

 
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
