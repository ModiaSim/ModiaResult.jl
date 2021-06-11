module test_02_OneScalarSignalWithUnit

import ModiaResult
include("$(ModiaResult.path)/test/test_02_OneScalarSignalWithUnit.jl")

ModiaResult.@usingModiaPlot

plot(result, "phi", heading="Sine(time)")

end