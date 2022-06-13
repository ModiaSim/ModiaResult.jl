module test_25_SeveralFigures

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

println("\n... test_25_SeveralFigures:")
ModiaResult.showResultInfo(result)

plot(result, ("phi", "r")       , heading="First figure" , figure=1)
plot(result, ["w", "w2", "r[2]"], heading="Second figure", figure=2)
plot(result, "r"                , heading="Third figure" , figure=3)

end
