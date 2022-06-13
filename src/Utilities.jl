# License for this file: MIT (expat)
# Copyright 2020, DLR Institute of System Dynamics and Control
# Developer: Martin Otter, DLR-SR
#
# This file is part of module ModiaResult
#
# Utility functions that are usually not directly called.




#=


"""
    (sigType, nTime, sigSize, sigElType, sigUnit, oneSigValue) = signalInfo2(result, name)

Return information about a signal, given the `name` of the signal in `result`.
The difference to `signalInfo(..)` is that additionally the information is returned,
whether the signals consists only of one value.

- `sigType::SignalType`: Ìnterpolation type of signal.

- `nTime::Int`: Number of signal time points.

- `sigSize`: size(signal[1][1])

- `sigElType`: ustrip( eltype(signal[1][1]) ), that is the element type of the signal without unit.

- `sigUnit`: Unit of signal

- `oneSigValue`: = true, at all time instants, the signal has identical values (e.g. if parameter defined with OneValueVector).
                 = false, signal has potentially different values at different time instants (which might be an array

If `name` is defined, but no signal is available (= nothing, missing or zero length),
return `nTime=0` and `nothing` for `sigSize, sigElType, sigUnit, oneSigValue`.
"""
function signalInfo2(result, name::AbstractString)
    (timeSignal, signal, sigType) = rawSignal(result,name)
    if ismissing(signal) || isnothing(signal) || !(typeof(signal) <: AbstractArray) || signalLength(signal) == 0
        hasDimensionMismatch(signal, name, timeSignal, timeSignalName(result))
        return (sigType, 0, nothing, nothing, nothing, nothing)
    end

    oneSigValue = length(signal) == 1 && typeof(signal[1]) <: OneValueVector
    
    value = signal[1][1]
    if value isa Number || value isa AbstractArray
        valueSize = size(value)
        valueUnit = unit(value[1])
    else
        hasDimensionMismatch(signal, name, timeSignal, timeSignalName(result))
        return (sigType, signalLength(timeSignal), nothing, typeof(value), nothing, oneSigValue)
    end

    if typeof(value) <: MonteCarloMeasurements.Particles
        elTypeAsString = string(typeof(ustrip.(value[1])))
        nparticles     = length(value)
        valueElType    = "MonteCarloMeasurements.Particles{" * elTypeAsString * ",$nparticles}"
    elseif typeof(value) <: MonteCarloMeasurements.StaticParticles
        elTypeAsString = string(typeof(ustrip.(value[1])))
        nparticles     = length(value)
        valueElType    = "MonteCarloMeasurements.StaticParticles{" * elTypeAsString * ",$nparticles}"
    else
        valueElType = typeof( ustrip.(value) )
    end
    nTime = signalLength(timeSignal)
    return (sigType, nTime, valueSize, valueElType, valueUnit, oneSigValue)
end


# Default implementation of getSignalDetails
function getSignalDetails(result, name::AbstractString)
    sigPresent = false
    if hasSignal(result, name)
        (timeSig, sig2, sigType) = rawSignal(result, name)
        timeSigName = timeSignalName(result)
        if !( isnothing(sig2) || ismissing(sig2) || signalLength(sig2) == 0 ||
              hasDimensionMismatch(sig2, name, timeSig, timeSigName) )
            sigPresent = true
            value      = sig2[1][1]
            if ndims(value) == 0
                sig            = sig2
                arrayName      = name
                arrayIndices   = ()
                nScalarSignals = 1
            else
                arrayName      = name
                arrayIndices   = Tuple(1:Int(ni) for ni in size(value))
                nScalarSignals = length(value)
                sig = Vector{Matrix{eltype(value)}}(undef, length(sig2))
                for segment = 1:length(sig2)
                    sig[segment] = zeros(eltype(value), length(sig2[segment]), nScalarSignals)
                    siga  = sig[segment]
                    sig2a = sig2[segment]
                    for (i, value_i) in enumerate(sig2a)
                        for j in 1:nScalarSignals
                            siga[i,j] = sig2a[i][j]
                        end
                    end
                end
            end
        end

    else
        # Handle signal arrays, such as a.b.c[3] or a.b.c[2:3, 1:5, 3]
        if name[end] == ']'
            i = findlast('[', name)
            if i >= 2
                arrayName = name[1:i-1]
                indices   = name[i+1:end-1]
                if hasSignal(result, arrayName)
                    (timeSig, sig2, sigType) = rawSignal(result, arrayName)
                    timeSigName = timeSignalName(result)
                    if !( isnothing(sig2) || ismissing(sig2) || signalLength(sig2) == 0 ||
                          hasDimensionMismatch(sig2, arrayName, timeSig, timeSigName) )
                        sigPresent = true
                        value = sig2[1][1]

                        # Determine indices as tuple
                        arrayIndices = eval( Meta.parse( "(" * indices * ",)" ) )

                        # Determine number of signals
                        #nScalarSignals = sum( length(indexRange) for indexRange in arrayIndices )

                        # Extract sub-matrix
                        sig = Vector{Any}(undef,length(sig2))
                        for segment = 1:length(sig2)
                            sig2a = sig2[segment]
                            sig[segment] = [getindex(sig2a[i], arrayIndices...) for i in eachindex(sig2a)]
                        end

                        # Determine number of signals
                        nScalarSignals = length(sig[1][1])

                        # "flatten" array to matrix
                        eltypeValue = eltype(value)
                        if !(eltypeValue <: Number)
                            @warn "eltype($name) = $eltypeValue and this is not <: Number!"
                            return (nothing, nothing, nothing, nothing, name, (), 0)
                        end
                        for segment = 1:length(sig2)
                            sig[segment] = zeros(eltypeValue, length(sig2[segment]), nScalarSignals)
                            siga  = sig[segment]
                            sig2a = sig2[segment]
                            for (i, value_i) in enumerate(sig2a)
                                for j in 1:nScalarSignals
                                    siga[i,j] = sig2a[i][j]
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if sigPresent
        return (sig, timeSig, timeSigName, sigType, arrayName, arrayIndices, nScalarSignals)
    else
        return (nothing, nothing, nothing, nothing, name, (), 0)
    end
end


"""
    (signal, timeSignal, timeSignalName, signalType, arrayName, arrayIndices, nScalarSignals) =
         getSignalWithWarning(result, name)

Call getSignal(result,name) and print a warning message if `signal == nothing`
"""
function getSignalDetailsWithWarning(result,name::AbstractString)
    (sig, timeSig, timeSigName, sigType, arrayName, arrayIndices, nScalarSignals) = getSignalDetails(result,name)
    if isnothing(sig)
        @warn "\"$name\" is not correct or is not defined or has no values."
    end
    return (sig, timeSig, timeSigName, sigType, arrayName, arrayIndices, nScalarSignals)
end


appendUnit2(name, unit) = unit == "" ? name : string(name, " [", unit, "]")


function appendUnit(name, value)
    if typeof(value) <: MonteCarloMeasurements.StaticParticles ||
       typeof(value) <: MonteCarloMeasurements.Particles
        appendUnit2(name, string(unit(value.particles[1])))
    else
        appendUnit2(name, string(unit(value)))
    end
end


"""
    (xsig, xsigLegend, ysig, ysigLegend, ysigType) = getPlotSignal(result, ysigName; xsigName=nothing)

Given the result data structure `result` and a variable `ysigName::AbstractString` with
or without array range indices (for example `ysigName = "a.b.c[2,3:5]"`) and an optional
variable name `xsigName::AbstractString` for the x-axis, return

- `xsig::Vector{T1<:Real}`: The vector of the x-axis signal without a unit. Segments are concatenated
  and separated by NaN.

- `xsigLegend::AbstractString`: The legend of the x-axis consisting of the x-axis name
  and its unit (if available).

- `ysig::Vector{T2}` or `::Matrix{T2}`: the y-axis signal, either as a vector or as a matrix
  of values without units depending on the given name. For example, if `ysigName = "a.b.c[2,3:5]"`, then
  `ysig` consists of a matrix with three columns corresponding to the variable values of
  `"a.b.c[2,3]", "a.b.c[2,4]", "a.b.c[2,5]"` with the (potential) units are stripped off.
  Segments are concatenated and separated by NaN.

- `ysigLegend::Vector{AbstractString}`: The legend of the y-axis as a vector
  of strings, where `ysigLegend[1]` is the legend for `ysig`, if `ysig` is a vector,
  and `ysigLegend[i]` is the legend for the i-th column of `ysig`, if `ysig` is a matrix.
  For example, if variable `"a.b.c"` has unit `m/s`, then `ysigName = "a.b.c[2,3:5]"` results in
  `ysigLegend = ["a.b.c[2,3] [m/s]", "a.b.c[2,3] [m/s]", "a.b.c[2,5] [m/s]"]`.

- `ysigType::`[`SignalType`](@ref): The signal type of `ysig` (either `ModiaResult.Continuous`
  or `ModiaResult.Clocked`).

If `ysigName` is not valid, or no signal values are available, the function returns
`(nothing, nothing, nothing, nothing, nothing)`, and prints a warning message.
"""
function getPlotSignal(result, ysigName::AbstractString; xsigName=nothing)
    (ysig, xsig, timeSigName, ysigType, ysigArrayName, ysigArrayIndices, nysigScalarSignals) = getSignalDetailsWithWarning(result, ysigName)

    # Check y-axis signal and time signal
    if isnothing(ysig) || isnothing(xsig) || isnothing(timeSigName)  || signalLength(ysig) == 0
        @goto ERROR
    end

    # Get xSigName or check xSigName
    if isnothing(xsigName)
        xsigName = timeSigName
    elseif xsigName != timeSigName
        (xsig, xsigTime, xsigTimeName, xsigType, xsigArrayName, xsigArrayIndices, nxsigScalarSignals) = getSignalDetailsWithWarning(result, xsigName)
        if isnothing(xsig) || isnothing(xsigTime) || isnothing(xsigTimeName) || signalLength(xsig) == 0
            @goto ERROR
        elseif !hasSameSegments(ysig, xsig)
            @warn "\"$xsigName\" (= x-axis) and \"$ysigName\" (= y-axis) have not the same time signal vector."
            @goto ERROR
        end
    end

    # Check x-axis signal
    xsigValue = first(first(xsig))
    if length(xsigValue) != 1
        @warn "\"$xsigName\" does not characterize a scalar variable as needed for the x-axis."
        @goto ERROR
    elseif !( typeof(xsigValue) <: Number )
        @warn "\"$xsigName\" has no Number type values, but values of type " * string(typeof(xsigValue)) * "."
        @goto ERROR
    elseif typeof(xsigValue) <: Measurements.Measurement
        @warn "\"$xsigName\" is a Measurements.Measurement type and this is not (yet) supported for the x-axis."
        @goto ERROR
    elseif typeof(xsigValue) <: MonteCarloMeasurements.StaticParticles
        @warn "\"$xsigName\" is a MonteCarloMeasurements.StaticParticles type and this is not supported for the x-axis."
        @goto ERROR
    elseif typeof(xsigValue) <: MonteCarloMeasurements.Particles
        @warn "\"$xsigName\" is a MonteCarloMeasurements.Particles type and this is not supported for the x-axis."
        @goto ERROR
    end

    # Build xsigLegend
    xsigLegend = appendUnit(xsigName, xsigValue)

    # Get one segment of the y-axis and check it
    ysegment1 = first(ysig)
    if !( typeof(ysegment1) <: AbstractVector || typeof(ysegment1) <: AbstractMatrix )
        @error "Bug in function: typeof of an y-axis segment is neither a vector nor a Matrix, but " * string(typeof(ysegment1))
    elseif !(eltype(ysegment1) <: Number)
        @warn "\"$ysigName\" has no Number values but values of type " * string(eltype(ysegment1))
        @goto ERROR
    end

    # Build ysigLegend
    value = ysegment1[1]
    if ysigArrayIndices == ()
        # ysigName is a scalar variable
        ysigLegend = [appendUnit(ysigName, value)]

    else
        # ysigName is an array variable
        ysigLegend = [ysigArrayName * "[" for i = 1:nysigScalarSignals]
        i = 1
        ySizeLength = Int[]
        for j1 in eachindex(ysigArrayIndices)
            push!(ySizeLength, length(ysigArrayIndices[j1]))
            i = 1
            if j1 == 1
                for j2 in 1:div(nysigScalarSignals, ySizeLength[1])
                    for j3 in ysigArrayIndices[1]
                        ysigLegend[i] *= string(j3)
                        i += 1
                    end
                end
            else
                ncum = prod( ySizeLength[1:j1-1] )
                for j2 in ysigArrayIndices[j1]
                    for j3 = 1:ncum
                        ysigLegend[i] *= "," * string(j2)
                        i += 1
                    end
                end
            end
        end

        for i = 1:nysigScalarSignals
            ysigLegend[i] *= appendUnit("]", ysegment1[1,i])
        end
    end

    #xsig2 = Vector{Any}(undef, length(xsig))
    #ysig2 = Vector{Any}(undef, length(ysig))
    #for i = 1:length(xsig)
    #    xsig2[i] = collect(ustrip.(xsig[i]))
    #    ysig2[i] = collect(ustrip.(ysig[i]))
    #end


    #xsig2 = collect(ustrip.(first(xsig)))
    xsig2 = ustrip.(collect(first(xsig)))    
    ysig2 = collect(ustrip.(first(ysig)))

    if length(xsig) > 1
        xNaN = convert(eltype(xsig2), NaN)
        if ndims(ysig2) == 1
            yNaN = convert(eltype(ysig2), NaN)
        else
            yNaN = fill(convert(eltype(ysig2), NaN), 1, size(ysig2,2))
        end

        for i = 2:length(xsig)
            xsig2 = vcat(xsig2, xNaN, collect((xsig[i])))
            ysig2 = vcat(ysig2, yNaN, collect(ustrip.(ysig[i])))
        end
    end
    return (xsig2, xsigLegend, ysig2, ysigLegend, ysigType)

    @label ERROR
    return (nothing, nothing, nothing, nothing, nothing)
end



"""
    getHeading(result, heading)

Return `heading` if no empty string. Otherwise, return `defaultHeading(result)`.
"""
getHeading(result, heading::AbstractString) = heading != "" ? heading : defaultHeading(result)



"""
    prepend!(prefix, signalLegend)

Add `prefix` string in front of every element of the `signalLegend` string-Vector.
"""
function prepend!(prefix::AbstractString, signalLegend::Vector{AbstractString})
   for i in eachindex(signalLegend)
      signalLegend[i] = prefix*signalLegend[i]
   end
   return signalLegend
end

=#