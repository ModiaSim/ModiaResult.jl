# License for this file: MIT (expat)
# Copyright 2021, DLR Institute of System Dynamics and Control (DLR-SR)
# Developer: Martin Otter, DLR-SR
#
# This file is part of module ModiaResult
#
# The following functions must be defined by the package that generates a result:
#     rawSignal(result, name)
#     names(result)
#     timeSignalName(result)
#     hasOneTimeSignal(result)
#
# The following functions can be defined by the package that generates a result
# (below is a default implementation):
#     hasSignal(result, name)
#     defaultHeading(result)
#
# The following functions should be defined by the used plot package
#     plot(result, names::AbstractString; kwargs...) = plot(result, [names]        ; kwargs...) 
#     plot(result, names::Symbol        ; kwargs...) = plot(result, [string(names)]; kwargs...)
#     plot(result, names::Tuple         ; kwargs...) = plot(result, [names]        ; kwargs...) 
#     plot(result, names::AbstractVector; kwargs...) = plot(result, reshape(names, length(names), 1); kwargs...)
#     plot(result, names::AbstractMatrix; heading::AbstractString="", grid::Bool=true, xAxis="time", 
#          figure::Int=1, prefix::AbstractString="", reuse::Bool=false, maxLegend::Integer=10, 
#          minXaxisTickLabels::Bool=false, MonteCarloAsArea=false)
#     showFigure(figure::Int)
#     saveFigure(figure, file; kwargs...)
#     closeFigure(figure)
#     closeAllFigure()



"""
    @enum ModiaResult.SignalType
    
Defines the type of the signal. Supported values:

- `ModiaResult.TimeSignal`: Time signal (= independent variable).

- `ModiaResult.Continuous`: Piece-wise continuous signal (typically linearly interpolated).

- `ModiaResult.Clocked`: Clocked signal
  (values are only defined at the corresponding `Time` signal time instants and have
   no value in between; the latter might be signaled by piece-wise constant 
   dotted lines).   
"""
@enum SignalType TimeSignal=1 Continuous=2 Clocked=3
 


"""
    (timeSignal, signal, signalType) = ModiaResult.rawSignal(result, name)
    
Returns 

- the result time series `signal::Vector{AbstractVector}}` of `name::AbstractString`
  (an element of `signal[i][j]` is either a Real number (`<: Real`) or an
   array of Real numbers (`eltype(signal[i][j]) <: Real`),
 
- the corresponding `timeSignal::Vector{Vector{Real}}` of the independent variable,

- the information `signalType::SignalType` that defines how the signal shall be 
  interpolated. 

Note, an error shall be raised, if `name` is not known.

Result signals consist of one or more **segments**. `signal[i][j]` is the value of 
the signal at time instant `timeSignal[i][j]` in result segment `i`.
`timeSignal[i][:]` must have monotonically increasing values.

If the signal is a constant with value `value`, return
`([[value, value]], [[t_min, t_max]], timeSignalName, Continuous)`.

If the signal is the time signal, return 
`(timeSignal, timeSignal, timeSignalName, TimeSignal)`. 
The `timeSignal` might be a dummy vector consisting of the first and last time point
in the result (if different timeSignals are present for different signals or
if the signal is constant).

`signal` and `timeSignal` may have units from package `Unitful`.
"""
function rawSignal end


"""
    ModiaResult.names(result)
    
Return a string vector of the signal names that are present in result.
"""
function names end


"""
    ModiaResult.timeSignalName(result)
    
Return the name of the time signal (default: "time").
"""
function timeSignalName end



"""
    ModiaResult.hasOneTimeSignal(result)
    
Return true if `result` has one time signal.
Return false, if `result` has two or more time signals.
"""
function hasOneTimeSignal end



"""
    ModiaResult.hasSignal(result, name)
    
Returns `true` if signal `name::AbstractString` is available in `result`.
"""
function hasSignal(result, name::AbstractString)    
    hasName = true
    try
        sigInfo = rawSignal(result,name)
    catch
        hasName = false
    end
    return hasName
end



"""
    ModiaResult.defaultHeading(result)
    
Return default heading of result as a string 
(can be used as default heading for a plot).
"""
defaultHeading(result) = ""

