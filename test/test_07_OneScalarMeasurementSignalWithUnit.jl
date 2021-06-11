using ModiaResult
using DataStructures
using Unitful
using Measurements

t = range(0.0, stop=10.0, length=100)
c = ones(size(t,1))

result = OrderedDict{String,Any}()

result["time"] = t*u"s"
result["phi"]  = [sin(t[i]) ± 0.1*c[i]  for i in eachindex(t)]*u"rad"

println("\n... test_07_OneScalarMeasurementSignalWithUnit:")
ModiaResult.showInfo(result)
