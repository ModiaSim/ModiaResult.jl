module test_03_OneVectorSignalWithUnit

using ModiaResult
using ModiaResult.Unitful
using ModiaResult.OrderedCollections
ModiaResult.@usingModiaPlot

t = range(0.0, stop=10.0, length=100)

result = OrderedDict{String,Any}()

result["time"] = t*u"s"
result["r"]    = [[0.4 * cos(t[i]), 
                   0.5 * sin(t[i]), 
                   0.3 * cos(t[i])] for i in eachindex(t)]*u"m"

println("\n... test_03_OneVectorSignalWithUnit.jl:")
ModiaResult.printResultInfo(result)

plot(result, ["r", "r[2]", "r[2:3]"], heading="Plot vector signals")

end