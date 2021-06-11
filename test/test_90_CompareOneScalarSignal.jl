using ModiaResult
using DataStructures
using DataFrames

t1 = range(0.0, stop=10.0, length=100)
t2 = deepcopy(t1)
t3 = range(0.0 , stop=10.0 , length=112)
t4 = range(-0.1, stop=10.1, length=111)

result1 = OrderedDict{String,Any}()
result2 = DataFrame()
result3 = DataFrame()
result4 = DataFrame()

result1["time"]   = t1
result1["phi"]    = sin.(t1)

result2."time"    = t2
result2."phi"     = sin.(t2)

result3[!,"time"] = t3
result3[!,"phi"]  = sin.(t3)

result4."time"    = t4
result4."phi"     = sin.(t4.+0.01)


# Check makeSameTimeAxis
(result1b, result2b, sameTimeRange1) = ModiaResult.makeSameTimeAxis(result1, result2, select=["phi", "w"])
println("sameTimeRange1 = ", sameTimeRange1)

(result1c, result3b, sameTimeRange3) = ModiaResult.makeSameTimeAxis(result1, result3)
println("sameTimeRange3 = ", sameTimeRange3)

(result1d, result4b, sameTimeRange4) = ModiaResult.makeSameTimeAxis(result1, result4)
println("sameTimeRange4 = ", sameTimeRange4)

# check compareResults
(success2, diff2, diff_names2, max_error2, within_tolerance2) = ModiaResult.compareResults(result1, result2)
println("success2 = $success2, max_error2 = $max_error2, within_tolerance2 = $within_tolerance2")

(success3, diff3, diff_names3, max_error3, within_tolerance3) = ModiaResult.compareResults(result1, result3)
println("success3 = $success3, max_error3 = $max_error3, within_tolerance3 = $within_tolerance3")

(success4, diff4, diff_names4, max_error4, within_tolerance4) = ModiaResult.compareResults(result1, result4)
println("success4 = $success4, max_error4 = $max_error4, within_tolerance4 = $within_tolerance4")
