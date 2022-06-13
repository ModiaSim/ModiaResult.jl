module test_07_OneScalarMeasurementSignalWithUnit

using ModiaResult
using ModiaResult.OrderedCollections
using ModiaResult.Unitful
using ModiaResult.Measurements
@usingModiaPlot

t = range(0.0, stop=10.0, length=100)
c = ones(size(t,1))

result = OrderedDict{String,Any}()

result["time"] = t*u"s"
result["phi"]  = [sin(t[i]) ± 0.1*c[i]  for i in eachindex(t)]*u"rad"

println("\n... test_07_OneScalarMeasurementSignalWithUnit:")
ModiaResult.showResultInfo(result)

plot(result, "phi", heading="Sine(time) with Measurement")

end
