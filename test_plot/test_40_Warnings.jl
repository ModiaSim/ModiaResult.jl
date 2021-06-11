module test_40_Warnings

import ModiaResult
include("$(ModiaResult.path)/test/test_40_Warnings.jl")

ModiaResult.@usingModiaPlot

println("... Next plots should give warnings:")

plot(result, ("phi", "r", "signalNotDefined"), heading="Plot with warning 1" , figure=1)
plot(result, ("signalNotDefined",
              "nothingSignal",
              "emptySignal",
              "wrongSizeSignal"), 
              heading="Plot with warning 2" , figure=2)
end