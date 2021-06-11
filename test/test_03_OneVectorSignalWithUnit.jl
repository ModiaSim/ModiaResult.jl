using ModiaResult
using Unitful
using DataStructures

t = range(0.0, stop=10.0, length=100)

result = OrderedDict{String,Any}()

result["time"] = t*u"s"
result["r"]    = [[0.4 * cos(t[i]), 
                   0.5 * sin(t[i]), 
                   0.3 * cos(t[i])] for i in eachindex(t)]*u"m"

println("\n... test_03_OneVectorSignalWithUnit.jl:")
ModiaResult.showInfo(result)
