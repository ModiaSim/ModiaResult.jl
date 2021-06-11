module test_04_ConstantSignalsWithUnit

import ModiaResult
include("$(ModiaResult.path)/test/test_04_ConstantSignalsWithUnit.jl")

ModiaResult.@usingModiaPlot

plot(result, ["phi_max", "i_max", "open", "Inertia[2,2]", "Inertia[1,2:3]", "Inertia"], heading="Constants")

end