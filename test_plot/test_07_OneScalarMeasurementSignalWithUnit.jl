module test_07_OneScalarMeasurementSignalWithUnit

import ModiaResult
include("$(ModiaResult.path)/test/test_07_OneScalarMeasurementSignalWithUnit.jl")

ModiaResult.@usingModiaPlot

plot(result, "phi", heading="Sine(time) with Measurement")

end