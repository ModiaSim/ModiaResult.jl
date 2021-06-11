module test_03_OneVectorSignalWithUnit

import ModiaResult
include("$(ModiaResult.path)/test/test_03_OneVectorSignalWithUnit.jl")

ModiaResult.@usingModiaPlot

plot(result, ["r", "r[2]", "r[2:3]"], heading="Plot vector signals")

end