module test_12_ResultDictWithMatrixOfPlotsb

import ModiaResult
include("$(ModiaResult.path)/test/test_72_ResultDictWithMatrixOfPlotsb.jl")

ModiaResult.@usingModiaPlot

plot(result, [("sigA", "sigB", "sigC"), "r[2:3]"])

end