module test_01_OneScalarSignal

import ModiaResult
include("$(ModiaResult.path)/test/test_01_OneScalarSignal.jl")

ModiaResult.@usingModiaPlot

plot(result, "phi", heading="sine(time)")

end