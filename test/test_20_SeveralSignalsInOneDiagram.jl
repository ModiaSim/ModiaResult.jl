module test_20_SeveralSignalsInOneDiagram

using ModiaResult
using ModiaResult.Unitful
using ModiaResult.OrderedCollections
ModiaResult.@usingModiaPlot

t = range(0.0, stop=10.0, length=100)

result = OrderedDict{String,Any}()

result["time"] = t*u"s"
result["phi"]  = sin.(t)u"rad"
result["phi2"] = 0.5 * sin.(t)u"rad"
result["w"]    = cos.(t)u"rad/s"
result["w2"]   = 0.6 * cos.(t)u"rad/s"
result["A"]    = ModiaResult.OneValueVector(0.6, length(t))

println("\n... test_20_SeveralSignalsInOneDiagram:")
ModiaResult.printResultInfo(result)

plot(result, ("phi", "phi2", "w", "w2", "A"), heading="Several signals in one diagram")

end
