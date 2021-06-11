module test_23_MatrixOfPlotsWithTimeLabelsInLastRow

import ModiaResult
include("$(ModiaResult.path)/test/test_23_MatrixOfPlotsWithTimeLabelsInLastRow.jl")

ModiaResult.@usingModiaPlot

plot(result, [ ("phi", "r")        ("phi", "phi2", "w");
               ("w", "w2", "phi2") ("phi", "w")        ], 
               minXaxisTickLabels = true,
               heading="Matrix of plots with time labels in last row")

end