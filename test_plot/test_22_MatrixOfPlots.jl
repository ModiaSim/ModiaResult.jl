module test_22_MatrixOfPlots

import ModiaResult
include("$(ModiaResult.path)/test/test_22_MatrixOfPlots.jl")

ModiaResult.@usingModiaPlot

plot(result, [ ("phi", "r")        ("phi", "phi2", "w");
               ("w", "w2", "phi2") "w"                 ], heading="Matrix of plots")

end