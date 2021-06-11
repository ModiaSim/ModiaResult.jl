module test_21_VectorOfPlots

import ModiaResult
include("$(ModiaResult.path)/test/test_21_VectorOfPlots.jl")

ModiaResult.@usingModiaPlot

plot(result, ["phi2", ("w",), ("phi", "phi2", "w", "w2")], heading="Vector of plots")

end