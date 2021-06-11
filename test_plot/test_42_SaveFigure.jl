module test_42_SaveFigure

import ModiaResult
ModiaResult.@usingModiaPlot

println("\n... test test_42_SaveFigure.jl:\n")

t = range(0.0, stop=10.0, length=100)
result = Dict{String,Any}("time" => t, "phi" => sin.(t))
info   = resultInfo(result)
showResultInfo(result)

plot(result, "phi", figure=2)
saveFigure(2, "test_saveFigure2.png")


end