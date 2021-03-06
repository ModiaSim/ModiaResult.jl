module test_01_OneScalarSignal

using ModiaResult
using ModiaResult.OrderedCollections
ModiaResult.@usingModiaPlot

t = range(0.0, stop=10.0, length=100)

result = OrderedDict{String,Any}()

result["time"] = t
result["phi"]  = sin.(t)

println("\n... test_01_OneScalarSignal.jl:\n")
ModiaResult.printResultInfo(result)

plot(result, "phi", heading="sine(time)")

end