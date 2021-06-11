module test_52_MonteCarloMeasurementsWithDistributions

import ModiaResult
include("$(ModiaResult.path)/test/test_52_MonteCarloMeasurementsWithDistributions.jl")

ModiaResult.@usingModiaPlot

plot(result, ["phi1", "phi2", "phi3"], figure=1,
     heading="Sine(time) with MonteCarloParticles/StaticParticles (plot area)")
     
plot(result, ["phi1", "phi2", "phi3"], figure=2,
     heading="Sine(time) with MonteCarloParticles/StaticParticles (plot all runs)")

end