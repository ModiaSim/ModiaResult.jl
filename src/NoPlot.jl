# License for this file: MIT (expat)
# Copyright 2021, DLR Institute of System Dynamics and Control

module NoPlot

import ModiaResult
include("plot.jl")

plot(result, names::AbstractMatrix; heading::AbstractString="", grid::Bool=true, xAxis="time", 
     figure::Int=1, prefix::AbstractString="", reuse::Bool=false, maxLegend::Integer=10, 
     minXaxisTickLabels::Bool=false, MonteCarloAsArea=false) =  
        println("... plot(..): Call is ignored, because of ModiaResult.activate(\"NoPlot\").")
     
showFigure(figure::Int)  = println("... showFigure($figure): Call is ignored, because of ModiaResult.activate(\"NoPlot\").")
closeFigure(figure::Int) = println("... closeFigure($figure): Call is ignored, because of ModiaResult.activate(\"NoPlot\").")
saveFigure(figure::Int, fileName::AbstractString) = println("... saveFigure($figure,\"$fileName\"): Call is ignored, because of ModiaResult.activate(\"NoPlot\").")

"""
    closeAllFigures()

Close all figures.
"""
closeAllFigures() = println("... closeAllFigures(): Call is ignored, because of ModiaResult.activate(\"NoPlot\").")

end