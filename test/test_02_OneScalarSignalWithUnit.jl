module test_02_OneScalarSignalWithUnit

using ModiaResult
using Unitful
using DataStructures
ModiaResult.@usingModiaPlot

t = range(0.0, stop=10.0, length=100)

result = OrderedDict{String,Any}()

result["time"] = t*u"s"
result["phi"]  = sin.(t)*u"rad"

println("\n... test_02_OneScalarSignalWithUnit.jl:\n")
ModiaResult.showInfo(result)

plot(result, "phi", heading="Sine(time)")

end