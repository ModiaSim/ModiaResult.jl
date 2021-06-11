module test_26_TooManyLegends

import ModiaResult
include("$(ModiaResult.path)/test/test_26_TooManyLegends.jl")

ModiaResult.@usingModiaPlot

plot(result, ("phi", "r", "w", "w2"), 
     maxLegend = 5,
     heading   = "Too many legends")

end