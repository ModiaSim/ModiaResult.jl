module test_06_OneScalarMeasurementSignal

import ModiaResult
include("$(ModiaResult.path)/test/test_06_OneScalarMeasurementSignal.jl")

ModiaResult.@usingModiaPlot

plot(result, "phi", heading="Sine(time) with Measurement")

end