module test_05_ArraySignalsWithUnit

using ModiaResult
using Unitful
using DataStructures
ModiaResult.@usingModiaPlot

t = range(0.0, stop=1.0, length=100)

result = OrderedDict{String,Any}()

Ibase  = [1.1  1.2  1.3;
          2.1  2.2  2.3;
          3.1  3.2  3.3]u"kg*m^2"

result["time"]     = t*u"s"
result["Inertia"]  = [Ibase*t[i] for i in eachindex(t)]

println("\n... test_05_ArraySignalsWithUnit:")
ModiaResult.printResultInfo(result)

plot(result, ["Inertia[2,2]", "Inertia[2:3,3]"], heading="Array signals")

end
