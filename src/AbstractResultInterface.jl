# License for this file: MIT (expat)
# Copyright 2021-2022, DLR Institute of System Dynamics and Control (DLR-SR)
# Developer: Martin Otter, DLR-SR
#
# This file is part of module ModiaResult

"""
    timeSignalName(result)
    
Return the name of the independent variable (typically: "time").
"""
function timeSignalName end


"""
    signalNames(result)
    
Return a string vector of the signal names that are present in result.
"""
function signalNames end


"""
    @enum VariableKind Independent Constant Continuous Clocked Eliminated

Kind of variables:

| ResultKind value        | Description                                                                      |
|:------------------------|:---------------------------------------------------------------------------------|
| ModiaResult.Independent | Independent variable (usually "time")                                            |
| ModiaResult.Constant    | Variable is constant                                                             |
| ModiaResult.Continuous  | Variable is piecewise continuous                                                 |
| ModiaResult.Clocked     | Variable is clocked (only defined when a clock ticks, otherwise value = missing) |
| ModiaResult.Eliminated  | Variable is eliminated and is an alias or negative alias of another variable     |
"""
@enum VariableKind Independent Constant Continuous Clocked Eliminated


"""
    sigInfo = SignalInfo(result, name)

Return information about signal `name` of `result`. 

| Returned info:        | Description                                                                      |
|:----------------------|:---------------------------------------------------------------------------------|
| `sigInfo.kind`        | Kind of variable (see `@enum `[`VariableKind`](@ref))                            |
| `sigInfo.elementType` | Element type of signal without unit, i.e. `eltype(ustrip.(sig))`; e.g. `Float64` |
| `sigInfo.dims`        | Dimensions of signal, e.g., `(100,2,3)`                                          |
| `sigInfo.unit`        | Unit of signal parseable with `Unitful.uparse` or `""`; e.g. `"kg*m*s^2"`        |
| `sigInfo.info`        | Short description text or `""`; e.g. `"Position vector"`                         |
| `sigInfo.value`       | Value, if info.kind = ModiaResult.Constant (otherwise `missing`)                 |
| `sigInfo.aliasName`   | Alias name, if info.kind = ModiaResult.Eliminated (otherwise `""`)               |
| `sigInfo.aliasNegate` | = true, if alias values must be negated (if info.kind = ModiaResult.Eliminated)  |
"""
struct SignalInfo
    kind::VariableKind
    elementType
    dims::Dims
    unit::String
    info::String
    
    # If kind = Constant
    value::Union{Any,Missing}  # If kind is not Constant: value=missing
    
    # If kind = Eliminated
    aliasName::String          # If kind is not Eliminated: aliasName="", aliasNegate=false
    aliasNegate::Bool    
end 


"""
    s = signalValues(result, name; unitless=false)
    
returns the values of signal `name` from `result` as an array s such that `s[i,...]` is the
value of the signal at time instant `i`. 
If `s` is not defined at `i`, its value is `missing`.


# Examples

- If the variable is a scalar, then `s[i]` is the signal at time instant i.
  If the signal is not defined at `i` then `s[i] = missing`.
  
- If the variable is a (2,3) matrix, `s[i,1:2,1:3]` is the signal at time instant i.
  If the signal is not defined at `i` then `s[i,1:2,1:3] = fill(missing,2,3)`.

- If the variable is a (2,3) matrix (size(s) = (nt,2,3)) and at time instant i it is
  a (1,2) matrix, then `s[i,1:2,1:3] = [v11 v12 missing; missing, missing, missing]
   another

If unitless=true, `s` is without a unit, otherwise `s` is with a unit (if a unit was defined).
"""
function signalValues end


# ----------- Functions that have a default implementation ----------------------------------------


"""
    lastSignalValue(result, name; unitless=false)
    
Returns last value of the signal that is not `missing`. 
If signal is not defined or has no values `missing` is returned.
"""
function lastSignalValue end


"""
    hasSignal(result, name)
    
Returns `true` if signal `name` is available in `result`.
"""
function hasSignal(result, name)::Bool  
    hasName = true
    try
        info = signalInfo(result,name)
    catch
        hasName = false
    end
    return hasName
end


"""
    defaultHeading(result)
    
Return default heading of result as a string 
(can be used as default heading for a plot).
"""
defaultHeading(result) = ""
