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
ModiaResult.rawSignal(     result::AbstractDict{String,T}, name::String) where {T} = ([result["time"]], [result[name]], 
                                                                                name == "time" ? ModiaResult.TimeSignal : ModiaResult.Continuous)
ModiaResult.names(           result::AbstractDict{String,T}) where {T}               = collect(keys(result))
ModiaResult.timeSignalName(  result::AbstractDict{String,T}) where {T}               = "time" 
ModiaResult.hasOneTimeSignal(result::AbstractDict{String,T}) where {T}               = true
ModiaResult.hasSignal(       result::AbstractDict{String,T}, name::String) where {T} = haskey(result, name)



# Overloaded methods for ModiaResult.ResultDict
ModiaResult.rawSignal(       result::ResultDict, name::String) = result.dict[name]
ModiaResult.names(           result::ResultDict)               = collect(keys(result.dict))
ModiaResult.timeSignalName(  result::ResultDict)               = "time"
ModiaResult.hasOneTimeSignal(result::ResultDict)               = result.hasOneTimeSignal
ModiaResult.hasSignal(       result::ResultDict, name::String) = haskey(result.dict, name)
ModiaResult.defaultHeading(  result::ResultDict)               = result.defaultHeading



# Overloaded methods for DataFrames
ModiaResult.rawSignal(       result::DataFrames.DataFrame, name::AbstractString) = ([result[!,1]], [result[!,name]], ModiaResult.Continuous)
ModiaResult.names(           result::DataFrames.DataFrame) = DataFrames.names(result)
ModiaResult.timeSignalName(  result::DataFrames.DataFrame) = DataFrames.names(result, 1)[1]
ModiaResult.hasOneTimeSignal(result::DataFrames.DataFrame) = true
 

 
# Overloaded methods for Tables
function ModiaResult.rawSignal(result, name::AbstractString)
    if Tables.istable(result) && Tables.columnaccess(result)
        return ([Tables.getcolumn(result, 1)], [Tables.getcolumn(result, Symbol(name))], ModiaResult.Continuous)
    else
        @error "ModiaResult.rawSignal(result, \"$name\") is not supported for typeof(result) = " * typeof(result)
    end
end

function ModiaResult.names(result)
    if Tables.istable(result) && Tables.columnaccess(result)
        return string.(Tables.columnnames(result))
    else
        @error "ModiaResult.names(result) is not supported for typeof(result) = " * typeof(result)
    end
end

function ModiaResult.timeSignalName(result)
    if Tables.istable(result) && Tables.columnaccess(result)
        return string(Tables.columnnames(result)[1])
    else
        @error "ModiaResult.timeSignalName(result) is not supported for typeof(result) = " * typeof(result)
    end
end

function ModiaResult.hasOneTimeSignal(result)
    if Tables.istable(result) && Tables.columnaccess(result)
        return true
    else
        @error "ModiaResult.hasOneTimeSignal(result) is not supported for typeof(result) = " * typeof(result)
    end
end
