# License for this file: MIT (expat)
# Copyright 2021, DLR Institute of System Dynamics and Control

module SilentNoPlot

import ModiaResult
include("../src_plot/plot.jl")

plot(result, names::AbstractMatrix; heading::AbstractString="", grid::Bool=true, xAxis="time", 
     figure::Int=1, prefix::AbstractString="", reuse::Bool=false, maxLegend::Integer=10, 
     minXaxisTickLabels::Bool=false, MonteCarloAsArea=false) = nothing
showFigure(figure::Int)  = nothing
closeFigure(figure::Int) = nothing
closeAllFigures()        = nothing
saveFigure(figure::Int, fileName::AbstractString) = nothing

end