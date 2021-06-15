module test_20_SeveralSignalsInOneDiagram

using ModiaResult
using Unitful
using DataStructures
ModiaResult.@usingModiaPlot

t = range(0.0, stop=10.0, length=100)

result = OrderedDict{String,Any}()

result["time"] = t*u"s"
result["phi"]  = sin.(t)u"rad"
result["phi2"] = 0.5 * sin.(t)u"rad"
result["w"]    = cos.(t)u"rad/s"
result["w2"]   = 0.6 * cos.(t)u"rad/s"

println("\n... test_20_SeveralSignalsInOneDiagram:")
ModiaResult.showInfo(result)

plot(result, ("phi", "phi2", "w", "w2"), heading="Several signals in one diagram")

end
