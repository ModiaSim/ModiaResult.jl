module test_05_ArraySignalsWithUnit

using ModiaResult
using ModiaResult.Unitful
using ModiaResult.OrderedCollections
@usingModiaPlot

t = range(0.0, stop=1.0, length=100)

result = OrderedDict{String,Any}()

Ibase  = [1.1  1.2  1.3;
          2.1  2.2  2.3;
          3.1  3.2  3.3]
Iarray = Array{Float64,3}(undef,length(t),3,3)
for i = 1:length(t), j = 1:3, k=1:3
    Iarray[i,j,k] = Ibase[j,k]*t[i]
end
        
result["time"]     = t*u"s"
result["Inertia"]  = Iarray*u"kg*m^2"

println("\n... test_05_ArraySignalsWithUnit:")
ModiaResult.showResultInfo(result)

plot(result, ["Inertia[2,2]", "Inertia[2:3,3]", "Inertia[2:3,2:3]"], heading="Array signals")

end
