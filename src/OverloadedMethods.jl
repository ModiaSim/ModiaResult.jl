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
ModiaResult.rawSignal(result::AbstractDict{String,T}, name::String) where {T} = ([result[name]], [result["time"]], "time", 
                                                                                name == "time" ? ModiaResult.TimeSignal : ModiaResult.Continuous)
ModiaResult.names(    result::AbstractDict{String,T}) where {T}               = collect(keys(result))
ModiaResult.hasSignal(result::AbstractDict{String,T}, name::String) where {T} = haskey(result, name)



# Overloaded methods for ModiaResult.ResultDict
ModiaResult.rawSignal(     result::ResultDict, name::String) = begin
                                                                  value = result.dict[name]
                                                                  (value[2], value[1], "time", value[3])
                                                               end
ModiaResult.names(         result::ResultDict)               = collect(keys(result.dict))
ModiaResult.hasSignal(     result::ResultDict, name::String) = haskey(result.dict, name)
ModiaResult.defaultHeading(result::ResultDict)               = result.defaultHeading



# Overloaded methods for DataFrames
ModiaResult.rawSignal(result::DataFrames.DataFrame, name::AbstractString) = 
                      ([result[!,name]], [result[!,1]], DataFrames.names(result, 1)[1], ModiaResult.Continuous)
                      
ModiaResult.names(result::DataFrames.DataFrame) = DataFrames.names(result)


 
# Overloaded methods for Tables
function ModiaResult.rawSignal(result, name::AbstractString)
    if Tables.istable(result) && Tables.columnaccess(result)
        return ([Tables.getcolumn(result, Symbol(name))],
                [Tables.getcolumn(result, 1)],
                 string(Tables.columnnames(result)[1]),
                 ModiaResult.Continuous)
    else
        @error "ModiaResult.rawSignal(result, \"$AbstractString\") is not supported for typeof(result) = " * typeof(result)
    end
end

function ModiaResult.names(result)
    if Tables.istable(result) && Tables.columnaccess(result)
        return string.(Tables.columnnames(result))
    else
        @error "ModiaResult.names(result) is not supported for typeof(result) = " * typeof(result)
    end
end

