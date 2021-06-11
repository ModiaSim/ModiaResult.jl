using ModiaResult
using DataStructures
using Unitful

t  = range(0.0, stop=10.0, length=100)
t2 = range(0.0, stop=10.0, length=110)

result = OrderedDict{String,Any}()

result["time"] = t*u"s"
result["phi"]  = sin.(t)u"rad"
result["phi2"] = 0.5 * sin.(t)u"rad"
result["w"]    = cos.(t)u"rad/s"
result["w2"]   = 0.6 * cos.(t)u"rad/s"
result["r"]    = [[0.4 * cos(t[i]), 
                   0.5 * sin(t[i]), 
                   0.3 * cos(t[i])] for i in eachindex(t)]*u"m"

result["nothingSignal"]   = nothing
result["emptySignal"]     = Float64[]
result["wrongSizeSignal"] = sin.(t2)u"rad"

println("\n... test_40_Warnings")
ModiaResult.showInfo(result)
