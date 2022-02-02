module test_04_ConstantSignalsWithUnit

using ModiaResult
using ModiaResult.Unitful
using ModiaResult.OrderedCollections
ModiaResult.@usingModiaPlot

inertia = [1.1  1.2  1.3;
           2.1  2.2  2.3;
           3.1  3.2  3.3]u"kg*m^2"
                              
result = OrderedDict{String,Any}()

result["time"]     = [0.0, 1.0]*u"s"
result["phi_max"]  = [1.1f0, 1.1f0]*u"rad"
result["i_max"]    = [2, 2]
result["open"]     = [true , true]
result["Inertia"]  = [inertia, inertia]

println("\n... test_04_ConstantSignalsWithUnit.jl:")
ModiaResult.printResultInfo(result)

plot(result, ["phi_max", "i_max", "open", "Inertia[2,2]", "Inertia[1,2:3]", "Inertia"], heading="Constants")

end