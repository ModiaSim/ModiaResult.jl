module test_26_TooManyLegends

using ModiaResult
using OrderedCollections
using Unitful 
ModiaResult.@usingModiaPlot

t = range(0.0, stop=10.0, length=100)

result = OrderedDict{String,Any}()

result["time"] = t*u"s"
result["phi"]  = sin.(t)u"rad"
result["phi2"] = 0.5 * sin.(t)u"rad"
result["w"]    = cos.(t)u"rad/s"
result["w2"]   = 0.6 * cos.(t)u"rad/s"
result["r"]    = [[0.4 * cos(t[i]), 
                   0.5 * sin(t[i]), 
                   0.3 * cos(t[i])] for i in eachindex(t)]*u"m"

println("\n... test_26_TooManyLegends:")
ModiaResult.printResultInfo(result)

plot(result, ("phi", "r", "w", "w2"), 
     maxLegend = 5,
     heading   = "Too many legends")

end