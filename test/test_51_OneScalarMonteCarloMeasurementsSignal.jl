module test_51_OneScalarMonteCarloMeasurementsSignal

using ModiaResult
using DataStructures
using Unitful
using MonteCarloMeasurements
ModiaResult.@usingModiaPlot

t = range(0.0, stop=10.0, length=100)
c = ones(size(t,1))

result = OrderedDict{String,Any}()

result["time"] = t*u"s"
result["phi"]  = [sin(t[i]) ± 0.1*c[i]  for i in eachindex(t)]*u"rad"

println("\n... test_51_OneScalarMonteCarloMeasurementsSignal:")
ModiaResult.printResultInfo(result)

plot(result, "phi", MonteCarloAsArea=true, heading="Sine(time) with MonteCarloMeasurements")

end