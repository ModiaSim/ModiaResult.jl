module test_24_Reuse

using ModiaResult
using Unitful
using DataStructures
ModiaResult.@usingModiaPlot

t = range(0.0, stop=10.0, length=100)

result1 = OrderedDict{String,Any}()

result1["time"] = t*u"s"
result1["phi"]  = sin.(t)u"rad"
result1["w"]    = cos.(t)u"rad/s"

result2 = OrderedDict{String,Any}()
result2["time"] = t*u"s"
result2["phi"]  = 1.2*sin.(t)u"rad"
result2["w"]    = 0.8*cos.(t)u"rad/s"

println("\n... test_24_Reuse:")
ModiaResult.showInfo(result1)
ModiaResult.showInfo(result2)

plot(result1, ("phi", "w"), prefix="Sim 1:", heading="Test reuse")
plot(result2, ("phi", "w"), prefix="Sim 2:", reuse=true)

end