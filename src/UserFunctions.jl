
using  Unitful
import OrderedCollections
import DataFrames
import Measurements
import MonteCarloMeasurements
import Pkg

Unitful.ustrip(v) = v   # Handle cases, such as ustrip( range(0.0, stop=10.0, length=100) )

isinstalled(pkg::String) = any(x -> x.name == pkg && x.is_direct_dep, values(Pkg.dependencies()))

const AvailableModiaPlotPackages = ["GLMakie", "WGLMakie", "CairoMakie", "PyPlot", "NoPlot", "SilentNoPlot"]
const ModiaPlotPackagesStack = String[]


QuantityBaseType(::Type{T})                       where {T}     = T
QuantityBaseType(::Type{Unitful.Quantity{T,D,U}}) where {T,D,U} = T


"""
    BaseType(T)

Return the base type of a type T, according to the following definition:

```julia
QuantityBaseType(::Type{T})                                   where {T}     = T
QuantityBaseType(::Type{Unitful.Quantity{T,D,U}})             where {T,D,U} = T

BaseType(::Type{T})                                           where {T}     = T
BaseType(::Type{Unitful.Quantity{T,D,U}})                     where {T,D,U} = T
BaseType(::Type{Measurements.Measurement{T}})                 where {T}     = QuantityBaseType(T)
BaseType(::Type{MonteCarloMeasurements.Particles{T,N}})       where {T,N}   = QuantityBaseType(T)
BaseType(::Type{MonteCarloMeasurements.StaticParticles{T,N}}) where {T,N}   = QuantityBaseType(T)
BaseType(::Type{Union{Missing,T}})                            where {T}     = BaseType(T)
```

# Examples
```
BaseType(Float32)                       # Float32
BaseType(Measurement{Float64})          # Float64
BaseType(Vector{Measurement{Float64}})  # Float64
```
"""
BaseType(::Type{T})                                           where {T}     = T
BaseType(::Type{Unitful.Quantity{T,D,U}})                     where {T,D,U} = T
BaseType(::Type{Measurements.Measurement{T}})                 where {T}     = QuantityBaseType(T)
BaseType(::Type{MonteCarloMeasurements.Particles{T,N}})       where {T,N}   = QuantityBaseType(T)
BaseType(::Type{MonteCarloMeasurements.StaticParticles{T,N}}) where {T,N}   = QuantityBaseType(T)
BaseType(::Type{Union{Missing,T}})                            where {T}     = BaseType(T)


"""
    quantityType = quantity(numberType, numberUnit::Unitful.FreeUnits)

Return Quantity from numberType and numberUnit, e.g. `quantity(Float64,u"m/s")`

# Example
```julia
using ModiaResult
using Unitful

mutable struct Data{FloatType <: AbstractFloat}
    velocity::quantity(FloatType, u"m/s")
end

v = Data{Float64}(2.0u"mm/s")
@show v  # v = Data{Float64}(0.002 m s^-1)

sig = Vector{Union{Missing,quantity(Float64,u"m/s")}}(missing,3) 
append!(sig, [1.0, 2.0, 3.0]u"m/s")
append!(sig, fill(missing, 2))
@show sig    # [missing, missing, missing, 1.0u"m/s", 2.0u"m/s", 3.0u"m/s", missing, missing]
```
"""
quantity(numberType, numberUnit::Unitful.FreeUnits) = Quantity{numberType, dimension(numberUnit), typeof(numberUnit)}


"""
    v_unit = unitAsParseableString(v::[Number|AbstractArray])::String
    
Returns the unit of `v` as a string that can be parsed with `Unitful.uparse`.

This allows, for example, to store a quantity with units into a JSON File and 
recover it when reading the file. This is not (easily) possible with current
Unitful functionality, because `string(unit(v))` returns a string that cannot be
parse with `uparse`. In Julia this is an unusual behavior because `string(something)` 
typically returns a string representation of something that can be again parsed by Julia.
For more details, see [Unitful issue 412](https://github.com/PainterQubits/Unitful.jl/issues/412).

Most likely, `unitAsParseableString(..)` cannot handle all occuring cases.

# Examples

```julia
import ModiaResult
using  Unitful

s = 2.1u"m/s"
v = [1.0, 2.0, 3.0]u"m/s"

s_unit = ModiaResult.unitAsParseableString(s)  # ::String
v_unit = ModiaResult.unitAsParseableString(v)  # ::String

s_unit2 = uparse(s_unit)  # :: Unitful.FreeUnits{(m, s^-1), ..., nothing}
v_unit2 = uparse(v_unit)  # :: Unitful.FreeUnits{(m, s^-1), ..., nothing}

@show s_unit   # = "m*s^-1"
@show v_unit   # = "m*s^-1"

@show s_unit2  # = "m s^-1"
@show v_unit2  # = "m s^-1"
```
"""
unitAsParseableString(sig)::String                        = ""
unitAsParseableString(sigUnit::Unitful.FreeUnits)::String = replace(repr(sigUnit,context = Pair(:fancy_exponent,false)), " " => "*")
unitAsParseableString(sigValue::Number)::String           = unitAsParseableString(unit(sigValue))
unitAsParseableString(sigArray::AbstractArray)::String    = unitAsParseableString(unit(eltype(sigArray)))


"""
    sig = OneValueSignal(value,nvalues)
   
Return a view to one value as an array signal.

# Example

```julia
s1 = OneValueSignal(2.0          ,  100)   # size(s1) = (100,)
s2 = OneValueSignal([false, true],  100)   # size(s2) = (100,2)
s3 = OneValueSignal([1 2 3; 4 5 6], 100)   # size(s3) = (200,2,3)
```
"""
struct OneValueSignal{ValueType, ElementType, NDims} <: AbstractArray{ElementType, NDims}
    value::ValueType
    nvalues::Int
    OneValueSignal{ValueType, ElementType, NDims}(value,nvalues) where {ValueType, ElementType, NDims} = new(value,nvalues)
end
OneValueSignal(value,nvalues) = OneValueSignal{typeof(value), eltype(value), typeof(value) <: AbstractArray ? ndims(value)+1 : 1}(value,nvalues)

Base.getindex(s::OneValueSignal, i::Int) = typeof(s.value) <: AbstractArray ? Base.getindex(s.value, div(i-1,s.nvalues)+1) : s.value
Base.size(s::OneValueSignal)             = typeof(s.value) <: AbstractArray ? (s.nvalues, size(s.value)...) : (s.nvalues,)
Base.IndexStyle(::Type{<:OneValueSignal}) = IndexLinear()


"""
    isOneValueSignal(signal)::Bool
    
Return `true`, if `signal::OneValueSignal`, otherwise return false.
"""
isOneValueSignal(s) = false
isOneValueSignal(s::OneValueSignal) = true
    

"""
    usePlotPackage(plotPackage::String)

Define the ModiaPlot package that shall be used by command `ModiaResult.@usingModiaPlot`.
If a ModiaPlot package is already defined, save it on an internal stack
(can be reactivated with `usePreviousPlotPackage()`.

Possible values for `plotPackage`:
- `"PyPlot"`
- `"GLMakie"`
- `"WGLMakie"`
- `"CairoMakie"`
- `"NoPlot"`
- `"SilentNoPlot"`

# Example

```julia
using ModiaResult
usePlotPackage("GLMakie")

module MyTest
    using ModiaResult
    @usingModiaPlot

    t = range(0.0, stop=10.0, length=100)
    result = Dict{String,Any}("time" => t, "phi" => sin.(t))

    plot(result, "phi")  # use GLMakie for the rendering
end
```
"""
function usePlotPackage(plotPackage::String; pushPreviousOnStack=true)::Bool
    success = true
    if plotPackage == "NoPlot" || plotPackage == "SilentNoPlot"
        if  pushPreviousOnStack && haskey(ENV, "MODIA_PLOT")
            push!(ModiaPlotPackagesStack, ENV["MODIA_PLOT"])
        end
        if plotPackage == "NoPlot"
            ENV["MODIA_PLOT"] = "NoPlot"
        else
            ENV["MODIA_PLOT"] = "SilentNoPlot"
        end
    else
        plotPackageName = "ModiaPlot_" * plotPackage
        if plotPackage in AvailableModiaPlotPackages
            # Check that plotPackage is defined in current environment
            if isinstalled(plotPackageName)
                if pushPreviousOnStack && haskey(ENV, "MODIA_PLOT")
                    push!(ModiaPlotPackagesStack, ENV["MODIA_PLOT"])
                end
                ENV["MODIA_PLOT"] = plotPackage
            else
                @warn "... usePlotPackage(\"$plotPackage\"): Call ignored, since package $plotPackageName is not in your current environment"
                success = false
            end
        else
            @warn "\n... usePlotPackage(\"$plotPackage\"): Call ignored, since argument not in $AvailableModiaPlotPackages."
            success = false
        end
    end
    return success
end



"""
    usePreviousPlotPackage()

Pop the last saved ModiaPlot package from an internal stack
and call `usePlotPackage(<popped ModiaPlot package>)`.
"""
function usePreviousPlotPackage()::Bool
    if length(ModiaPlotPackagesStack) > 0
        plotPackage = pop!(ModiaPlotPackagesStack)
        success = usePlotPackage(plotPackage, pushPreviousOnStack=false)
    else
        @warn "usePreviousPlotPackage(): Call ignored, because nothing saved."
        success = false
    end
    return success
end


"""
    currentPlotPackage()

Return the name of the plot package as a string that was
defined with [`usePlotPackage`](@ref).
For example, the function may return "GLMakie", "PyPlot" or "NoPlot" or
or "", if no PlotPackage is defined.
"""
currentPlotPackage() = haskey(ENV, "MODIA_PLOT") ? ENV["MODIA_PLOT"] : ""



"""
    @usingModiaPlot()

Execute `using XXX`, where `XXX` is the ModiaPlot package that was
activated with `usePlotPackage(plotPackage)`.
"""
macro usingModiaPlot()
    if haskey(ENV, "MODIA_PLOT")
        ModiaPlotPackage = ENV["MODIA_PLOT"]
        if !(ModiaPlotPackage in AvailableModiaPlotPackages)
            @warn "ENV[\"MODIA_PLOT\"] = \"$ModiaPlotPackage\" is not supported!. Using \"NoPlot\"."
            @goto USE_NO_PLOT
        elseif ModiaPlotPackage == "NoPlot"
            @goto USE_NO_PLOT
        elseif ModiaPlotPackage == "SilentNoPlot"
            expr = :( import ModiaResult.SilentNoPlot: plot, showFigure, saveFigure, closeFigure, closeAllFigures )
            return esc( expr )
        else
            ModiaPlotPackage = Symbol("ModiaPlot_" * ModiaPlotPackage)
            expr = :(using $ModiaPlotPackage)
            println("$expr")
            return esc( :(using $ModiaPlotPackage) )
        end

    else
        @warn "No plot package activated. Using \"NoPlot\"."
        @goto USE_NO_PLOT
    end

    @label USE_NO_PLOT
    expr = :( import ModiaResult.NoPlot: plot, showFigure, saveFigure, closeFigure, closeAllFigures )
    println("$expr")
    return esc( expr )
end


"""
    resultInfo(result; sorted=true)

Return information about the result as DataFrames.DataFrame object
(see [`showResultInfo`](@ref))
"""
function resultInfo(result; sorted=true)
    if isnothing(result)
        @info "The call of resultInfo(result) is ignored, since the argument is nothing."
        return
    end

    name2   = String[]
    unit2   = String[]
    dims2   = String[]
    eltype2 = String[]
    kind2   = String[]
    
    timeSigName = timeSignalName(result)
    tSig        = signalValues(result, timeSigName, unitless=true)
    sigNames    = signalNames(result)
    if sorted
        sigNames = sort(sigNames)
    end
    
    for name in sigNames
        sigInfo = SignalInfo(result, name)
        kind = sigInfo.kind
        
        if kind == Independent
            pushfirst!(name2, name)
            pushfirst!(unit2, sigInfo.unit)
            pushfirst!(dims2, string(sigInfo.dims))
            pushfirst!(eltype2, string(sigInfo.elementType))
            pushfirst!(kind2, "Independent (= [$(tSig[1]) .. $(tSig[end])])")
        else
            elementType         = sigInfo.elementType
            elementTypeAsString = string(elementType)
            #if !(elementType <: Number)
                i = findlast('.' , elementTypeAsString)
                if !isnothing(i) && i < length(elementTypeAsString)
                    elementTypeAsString = elementTypeAsString[i+1:end]
                end
            #end
            push!(name2, name)
            push!(unit2, sigInfo.unit)
            push!(dims2, string(sigInfo.dims))
            push!(eltype2, elementTypeAsString)
        
            if kind == Constant
                if eltype(sigInfo.value) <: Number
                    push!(kind2, "Constant (= $(sigInfo.value))")
                elseif typeof(sigInfo.value) <: AbstractString
                    push!(kind2, "Constant (= \"$(sigInfo.value)\")")                    
                else
                    push!(kind2, "Constant")
                end
            elseif kind == Eliminated
                push!(kind2, "Eliminated (= " * (sigInfo.aliasNegate ? "-" : "") * sigInfo.aliasName * ")")               
            elseif kind == Clocked
                push!(kind2, "Clocked signal")
            else
                push!(kind2, "")
            end
        end
    end

    resultInfoTable = DataFrames.DataFrame(name=name2, unit=unit2, size=dims2, eltype=eltype2, kind=kind2)

    return resultInfoTable
end


"""
    showResultInfo(result)

Print info about result.

# Example

```julia
resultInfo(testResult)

 # │ name         unit    size         eltype       info
───┼──────────────────────────────────────────────────────────────────────────────────
 1 │ time         s       (100,)       Float64      Independent (= [0.0 .. 10.0])
 2 │ b                    (100,)       Bool
 3 │ dummyStruct          (100,)       DummyStruct  Constant
 4 │ inertia      kg*m^2  (100, 2, 3)  Int64        Constant (= [11 12 13; 21 22 23])
 5 │ m            kg      (100,)       Float64      Constant (= 1.0)
 6 │ phi          rad     (100,)       Float64
 7 │ r            m       (100, 2)     Float64      Constant (= [1.0, 2.0])
```
"""
function showResultInfo(result)::Nothing
    resultInfoTable = resultInfo(result)

    show(stdout, resultInfoTable, summary=false, rowlabel=Symbol("#"), allcols=true, eltypes=false, truncate=50)
    println(stdout)

    return nothing
end


const TypesForPlotting = [Float64, Float32, Int]

nameWithUnit(name::String, unit::String) = unit == "" ? name : string(name, " [", unit, "]")


"""
    (sig, legend, kind) = signalValuesForLinePlots(result, name)

Given the result data structure `result` and a variable `name::AbstractString` with
or without array range indices (for example `name = "a.b.c[2,3:5]"`) 
return the values `sig::Union{AbstractVector,AbstractMatrix}` of `name` without units prepared for a plot package,
including `legend::Vector{String}` and `kind::ModiaResult.VariableKind`.

If `name` is not valid, or no signal values are available, or the signal values
are not suited for plotting (and cannot be converted to Float64), a warning message
is printed and `(nothing, nothing, nothing)` is returned.

# Return arguments

- `sig::AbstractVector` or `::AbstractMatrix`:
  For example, if `name = "a.b.c[2,3:5]"`, then
  `sig` consists of a matrix with three columns corresponding to the variable values of
  `"a.b.c[2,3]", "a.b.c[2,4]", "a.b.c[2,5]"` with the (potential) units are stripped off.
  `missing` values in the signal are replaced by `NaN`. If necessary, 
  the signal is converted to `Float64`.

- `legend::Vector{AbstractString}`: The legend of the signal as a vector
  of strings, where `legend[1]` is the legend for `sig`, if `sig` is a vector,
  and `legend[i]` is the legend for the i-th column of `sig`, if `sig` is a matrix.
  For example, if variable `"a.b.c"` has unit `m/s`, then `sigName = "a.b.c[2,3:5]"` results in
  `legend = ["a.b.c[2,3] [m/s]", "a.b.c[2,3] [m/s]", "a.b.c[2,5] [m/s]"]`.
  
- `kind::`[`ModiaResult.VariableKind`](@ref): The variable kind (independent, constant, continuous, ...).
"""
function signalValuesForLinePlots(result, name::String)
    sigPresent = false
    negate     = false
    
    if hasSignal(result,name)
        # name is a signal name without range  
        sigInfo = SignalInfo(result,name)  
        sigKind = sigInfo.kind
        if sigKind == ModiaResult.Eliminated
            sigInfo = SignalInfo(result,sigInfo.aliasName)
            negate  = sigInfo.aliasNegate
            sigKind = sigInfo.kind            
        end
        sig     = signalValues(result,name; unitless=true)
        dims    = size(sig)
        if dims[1] > 0
            sigPresent = true    
            if length(dims) > 2
                # Reshape to a matrix
                sig = reshape(sig, dims[1], prod(dims[i] for i=2:length(dims)))
            end      
            
            # Collect information for legend
            arrayName = name  
            sigUnit   = sigInfo.unit             
            if length(dims) == 1
                arrayIndices   = ()
                nScalarSignals = 1        
            else
                varDims = dims[2:end]
                arrayIndices   = Tuple(1:Int(ni) for ni in varDims)
                nScalarSignals = prod(i for i in varDims)
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
                    sigInfo = SignalInfo(result,arrayName)
                    sigKind = sigInfo.kind
                    if sigKind == ModiaResult.Eliminated
                        sigInfo = SignalInfo(result,sigInfo.aliasName)
                        negate  = sigInfo.aliasNegate
                        sigKind = sigInfo.kind
                    end                    
                    sig  = signalValues(result,arrayName; unitless=true)
                    dims = size(sig)
 
                    if dims[1] > 0 
                        sigPresent = true
                        
                        # Determine indices as tuple
                        arrayIndices = ()
                        try
                            arrayIndices = eval( Meta.parse( "(" * indices * ",)" ) )
                        catch
                            @goto ERROR
                        end

                        # Extract sub-array and collect info for legend
                        sig     = getindex(sig, (:, arrayIndices...)...)
                        sigUnit = sigInfo.unit                         
                        dims    = size(sig)
                        nScalarSignals = length(dims) == 1 ? 1 : prod(i for i in dims[2:end])
                        if length(dims) > 2
                            # Reshape to a matrix
                            sig  = reshape(sig, dims[1], nScalarSignals)
                        end   
                    end
                end
            end
        end
    end
    if !sigPresent
        @goto ERROR
    end
    
    # Check that sig can be plotted or convert it, so that it can be plotted
    sigElType = sigInfo.elementType
    if sigElType in TypesForPlotting ||
       (sigElType <: Measurements.Measurement && BaseType(sigElType) in TypesForPlotting) ||
       (sigElType <: MonteCarloMeasurements.AbstractParticles && BaseType(sigElType) in TypesForPlotting)
        # Signal can be plotted - do nothing
    
    elseif sigElType <: Bool
        # Transform to Int
        sig2 = Array{Int, ndims(sig)}(undef, size(sig))       
        for i = 1:length(sig)
            sig2[i] = convert(Int, sig[i])
        end
        sig2 = sig
    
    elseif isa(missing, sigElType) || isa(nothing, sigElType)
        # sig contains missing or nothing - try to remove and if necessary convert to Float64
        canBePlottedWithoutConversion = false
        for T in TypesForPlotting
            if isa(T(0), sigElType)
                canBePlottedWithoutConversion = true
                break
            end
        end
        
        if canBePlottedWithoutConversion
            # Remove missing and nothing
            sigNaN = convert(sigElType, NaN)
            for i = 1:length(sig)
                if ismissing(sig[i]) || isnothing(sig[i])
                    sig[i] = sigNaN
                end
            end

        else
            # Convert to Float64 if possible and remove missing and nothing
            sig2 = similar(sig, element_type=Float64)            
            try
                for i = 1:length(sig)
                    sig2[i] = ismissing(sig[i]) || isnothing(sig[i]) ? NaN : convert(Float64, sig[i])
                end
            catch
                # Cannot be plotted
                @warn "Signal \"$name\" is ignored, because its element type = $sigElType\nand therefore its values cannot be plotted."
                return (nothing,nothing,nothing)
            end
            sig = sig2
        end

    else
        # Convert to Float64 if possible 
        sig2 = Array{Float64, ndims(sig)}(undef, size(sig))       
        try
            for i = 1:length(sig)
                sig2[i] = convert(Float64, sig[i])
            end
        catch
            # Cannot be plotted
            @warn "Signal \"$name\" is ignored, because its element type = $sigElType\nand therefore its values cannot be plotted."
            return (nothing,nothing,nothing)
        end
        sig = sig2
    end

    # Build legend
    if arrayIndices == ()
        # sig is a scalar variable
        legend = String[nameWithUnit(name, sigUnit)]

    else
        # sig is an array variable
        legend = [arrayName * "[" for i = 1:nScalarSignals]
        i = 1
        sizeLength = Int[]
        for j1 in eachindex(arrayIndices)
            push!(sizeLength, length(arrayIndices[j1]))
            i = 1
            if j1 == 1
                for j2 in 1:div(nScalarSignals, sizeLength[1])
                    for j3 in arrayIndices[1]
                        legend[i] *= string(j3)
                        i += 1
                    end
                end
            else
                ncum = prod( sizeLength[1:j1-1] )
                for j2 in arrayIndices[j1]
                    for j3 = 1:ncum
                        legend[i] *= "," * string(j2)
                        i += 1
                    end
                end
            end
        end

        for i = 1:nScalarSignals
            legend[i] *= nameWithUnit("]", sigUnit)
        end
    end 

    if negate
        sig = -sig
    end
    
    return (collect(sig), legend, sigKind)
    
    @label ERROR
    @warn "\"$name\" is ignored, because it is not defined or is not correct or has no values."
    return (nothing,nothing,nothing)
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
