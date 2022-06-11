
using  Unitful
import OrderedCollections
import DataFrames
import Measurements
import MonteCarloMeasurements
import Pkg


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
unitAsParseableString(sigUnit::Unitful.FreeUnits)::String = replace(repr(sigUnit,context = Pair(:fancy_exponent,false)), " " => "*")
unitAsParseableString(sigValue::Number)::String           = unitAsParseableString(unit(sigValue))
unitAsParseableString(sigArray::AbstractArray)::String    = unitAsParseableString(unit(eltype(sigArray)))



isinstalled(pkg::String) = any(x -> x.name == pkg && x.is_direct_dep, values(Pkg.dependencies()))

const AvailableModiaPlotPackages = ["GLMakie", "WGLMakie", "CairoMakie", "PyPlot", "NoPlot", "SilentNoPlot"]
const ModiaPlotPackagesStack = String[]


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
import ModiaResult

ModiaResult.usePlotPackage("GLMakie")

module MyTest
    ModiaResult.@usingModiaPlot

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

Return information about the result as DataFrames.DataFrame object with columns:

```julia
name::String, unit::String, varSize::String, valType::String, "info::String"
```
"""
function resultInfo(result; sorted=true)
    if isnothing(result)
        @info "The call of resultInfo(result) is ignored, since the argument is nothing."
        return
    end

    name2     = String[]
    unit2     = String[]
    varSize2  = String[]
    varType2  = String[]
    info2     = String[]
    
    timeSigName = timeSignalName(result)
    tSig        = signal(result, timeSigName)
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
            pushfirst!(varSize2, size(sigInfo.VariableType))
            pushfirst!(varType2, eltype(sigInfo.VariableType))
            pushfirst!(info2, "len=$(length(tSig)), [$(tSig[1]) .. $(tSig[end])]")
        else
            push!(name2, name)
            push!(unit2, sigInfo.unit)
            push!(varSize2, size(sigInfo.VariableType))
            push!(varType2, eltype(sigInfo.VariableType))
        
            if kind == Constant
                push!(info2, "Constant (value = " * sigInfo.value * ")")
            elseif kind == Segmented
                push!(info2, "Segmented")
            elseif kind == Eliminated
                push!(info2, "= " * (sigInfo.aliasNegate ? "-" : "") * sigInfo.aliasName)
            else
                push!(info2, "")
            end
        end
    end

    resultInfoTable = DataFrames.DataFrame(name=name2, unit=unit2, varSize=varSize2, varType=varType2,info=info2)

    return resultInfoTable
end


"""
    printResultInfo(result)

Print info about result.

# Example
```julia
using ModiaResult
using Unitful
ModiaResult.@usingModiaPlot

t = range(0.0, stop=10.0, length=100)
result = OrderedDict{String,Any}("time"=> t*u"s", 
                                 "phi" => sin.(t)*u"rad", 
                                 "A"   => OneValueVector(2.0, length(t)))
printResultInfo(result)

# Gives output:
 # │ name  unit  nTime  signalType  valueSize  eltype
───┼───────────────────────────────────────────────────
 1 │ time  s     100    Independent ()         Float64
 2 │ phi   rad   100    Continuous  ()         Float64
 3 | A           100*   Continuous  ()         Float64
 *: Signal stored as ModiaResult.OneValueVector
```
"""
function printResultInfo(result)::Nothing
    resultInfoTable = resultInfo(result)

    show(stdout, resultInfoTable, summary=false, rowlabel=Symbol("#"), allcols=true, eltypes=false, truncate=50)
    println(stdout)

    return nothing
end


"""
    (sig, sigLegend) = signalValuesForPlotting(result, name)

Given the result data structure `result` and a variable `name::AbstractString` with
or without array range indices (for example `name = "a.b.c[2,3:5]"`) 
return the values `sig::[Vector|Matrix]` of `name` without units prepared for a plot package,
including legend `sigLegend::Vector{String}`. T
If `name` is not valid, or no signal values are available, the function returns
`(nothing, nothing)`, and prints a warning message.

# Return arguments

- `sig::Vector{T2}` or `::Matrix{T2}`:
  For example, if `name = "a.b.c[2,3:5]"`, then
  `sig` consists of a matrix with three columns corresponding to the variable values of
  `"a.b.c[2,3]", "a.b.c[2,4]", "a.b.c[2,5]"` with the (potential) units are stripped off.
  `missing` values in the signal are replaced by `NaN`. If `NaN` needs to be used,
  the return value is converted to Float64, if the signal type has no `NaN` definition
  (as for example Integer).
  Segments are concatenated and separated by NaN.

- `sigLegend::Vector{AbstractString}`: The legend of the y-axis as a vector
  of strings, where `sigLegend[1]` is the legend for `sig`, if `sig` is a vector,
  and `sigLegend[i]` is the legend for the i-th column of `sig`, if `sig` is a matrix.
  For example, if variable `"a.b.c"` has unit `m/s`, then `sigName = "a.b.c[2,3:5]"` results in
  `sigLegend = ["a.b.c[2,3] [m/s]", "a.b.c[2,3] [m/s]", "a.b.c[2,5] [m/s]"]`.
"""
function signalValuesForPlotting(result, name::AbstractString)
    return (nothing,nothing)
end