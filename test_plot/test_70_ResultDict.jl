module test_10_ResultDict

import ModiaResult
include("$(ModiaResult.path)/test/test_70_ResultDict.jl")

ModiaResult.@usingModiaPlot

plot(result, ("sigA", "sigB", "sigC"))

end