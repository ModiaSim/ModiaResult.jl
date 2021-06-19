module test_82_AllExportedFunctions

import ModiaResult
ModiaResult.@usingModiaPlot

# Test the Figure operations
println("\n... test test_82_AllExportedFunctions.jl:\n")

t = range(0.0, stop=10.0, length=100)
result = Dict{String,Any}("time" => t, "phi" => sin.(t))
info   = ModiaResult.resultInfo(result)
ModiaResult.printResultInfo(result)

plot(result, "phi", figure=2)

showFigure(2)
saveFigure(2, "test_saveFigure.png")
closeFigure(2)
closeAllFigures()

end