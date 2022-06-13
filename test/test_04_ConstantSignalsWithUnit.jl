module test_04_ConstantSignalsWithUnit

using ModiaResult
using ModiaResult.Unitful
using ModiaResult.OrderedCollections
@usingModiaPlot

inertia = [1.1  1.2  1.3;
           2.1  2.2  2.3;
           3.1  3.2  3.3]u"kg*m^2"
                              
result = OrderedDict{String,Any}()

result["time"]     = [0.0, 1.0]*u"s"
result["phi_max"]  = OneValueSignal(1.1f0*u"rad", 2)
result["i_max"]    = OneValueSignal(2, 2)
result["open"]     = OneValueSignal(true, 2)
result["Inertia"]  = OneValueSignal(inertia, 2)

println("\n... test_04_ConstantSignalsWithUnit.jl:")
ModiaResult.showResultInfo(result)

plot(result, ["phi_max", "i_max", "open", "Inertia[2,2]", "Inertia[1,2:3]", "Inertia"], heading="Constants")

end