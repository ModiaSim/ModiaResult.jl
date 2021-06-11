module test_12_ResultDictWithMatrixOfPlots

import ModiaResult
include("$(ModiaResult.path)/test/test_72_ResultDictWithMatrixOfPlots.jl")

ModiaResult.@usingModiaPlot

plot(result, [("sigA", "sigB", "sigC"), "r[2:3]"])

end