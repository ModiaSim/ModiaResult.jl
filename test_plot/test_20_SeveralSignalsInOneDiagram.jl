module test_20_SeveralSignalsInOneDiagram

import ModiaResult
include("$(ModiaResult.path)/test/test_20_SeveralSignalsInOneDiagram.jl")

ModiaResult.@usingModiaPlot

plot(result, ("phi", "phi2", "w", "w2"), heading="Several signals in one diagram")

end