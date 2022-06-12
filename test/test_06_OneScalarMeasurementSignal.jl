module test_06_OneScalarMeasurementSignal

using ModiaResult
using ModiaResult.OrderedCollections
using ModiaResult.Unitful
using ModiaResult.Measurements
ModiaResult.@usingModiaPlot

t = range(0.0, stop=10.0, length=100)
c = ones(size(t,1))

result = OrderedDict{String,Any}()

result["time"] = t
result["phi"]  = [sin(t[i]) ± 0.1*c[i]  for i in eachindex(t)]

println("\n... test_06_OneScalarMeasurementSignal.jl:")
ModiaResult.showResultInfo(result)

plot(result, "phi", heading="Sine(time) with Measurement")

end