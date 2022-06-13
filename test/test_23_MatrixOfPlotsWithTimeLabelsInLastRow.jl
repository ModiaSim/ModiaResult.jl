module test_23_MatrixOfPlotsWithTimeLabelsInLastRow

using ModiaResult
using ModiaResult.OrderedCollections
using ModiaResult.Unitful
@usingModiaPlot

t = range(0.0, stop=10.0, length=100)

result = OrderedDict{String,Any}()

result["time"] = t*u"s"
result["phi"]  = sin.(t)u"rad"
result["phi2"] = 0.5 * sin.(t)u"rad"
result["w"]    = cos.(t)u"rad/s"
result["w2"]   = 0.6 * cos.(t)u"rad/s"
result["r"]    = hcat(0.4 * cos.(t), 
                      0.5 * sin.(t), 
                      0.3 * cos.(t))*u"m"

println("\n... test_23_MatrixOfPlotsWithTimeLabelsInLastRow:")
ModiaResult.showResultInfo(result)

plot(result, [ ("phi", "r")        ("phi", "phi2", "w");
               ("w", "w2", "phi2") ("phi", "w")        ], 
               minXaxisTickLabels = true,
               heading="Matrix of plots with time labels in last row")

end