module test_25_SeveralFigures

import ModiaResult
include("$(ModiaResult.path)/test/test_25_SeveralFigures.jl")

ModiaResult.@usingModiaPlot

plot(result, ("phi", "r")       , heading="First figure" , figure=1)
plot(result, ["w", "w2", "r[2]"], heading="Second figure", figure=2)
plot(result, "r"                , heading="Third figure" , figure=3)

end