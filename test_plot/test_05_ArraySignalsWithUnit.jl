module test_05_ArraySignalsWithUnit

import ModiaResult
include("$(ModiaResult.path)/test/test_05_ArraySignalsWithUnit.jl")

ModiaResult.@usingModiaPlot

plot(result, ["Inertia[2,2]", "Inertia[2:3,3]"], heading="Array signals")

end