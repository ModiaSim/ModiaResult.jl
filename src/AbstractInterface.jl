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
    @enum VariableKind Constant Invariant Segmented Eliminated

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
    info = SignalInfo(result, name)

Return information about signal `name` of `result`. 

| Returned info:          | Description                                                                      |
|:------------------------|:---------------------------------------------------------------------------------|
| `info.kind`             | Kind of variable (see `@enum `[`VariableKind`](@ref))                            |
| `info.elementType`      | Element type of signal (without unit)                                            |
| `info.dims`             | Dimensions of signal                                                             |
| `info.unit`             | Unit of signal as string which is parseable with `Unitful.uparse` or `""`        |
| `info.value`            | Value, if info.kind = ModiaResult.Constant (otherwise `missing`)                 |
| `info.aliasName`        | Alias name, if info.kind = ModiaResult.Eliminated (otherwise `""`)               |
| `info.aliasNegate`      | = true, if alias values must be negated (if info.kind = ModiaResult.Eliminated)  |

Note, `info.aliasName` and `info.aliasNegate` is only supported by [Modia.jl](https://github.com/ModiaSim/Modia.jl).
"""
struct SignalInfo
    kind::VariableKind
    elementType
    dims::Dims
    unit::String
    
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