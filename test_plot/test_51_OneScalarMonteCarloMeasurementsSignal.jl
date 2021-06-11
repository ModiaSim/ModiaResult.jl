module test_51_OneScalarMonteCarloMeasurementsSignal

import ModiaResult
include("$(ModiaResult.path)/test/test_51_OneScalarMonteCarloMeasurementsSignal.jl")

ModiaResult.@usingModiaPlot

plot(result, "phi", MonteCarloAsArea=true, heading="Sine(time) with MonteCarloMeasurements")

end