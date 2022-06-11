module ModiaResult

const path = dirname(dirname(@__FILE__)) 

export printResultInfo, resultInfo, timeSignalName, signalNames, SignalInfo, VariableKind
export lastSignalValue, signalValues, signalValuesForPlotting, defaultHeading, unitAsParseableString
export usingModiaPlot, usePlotPackage, usePreviousPlotPackage, currentPlotPackage
export plot, saveFigure, closeFigure, closeAllFigures, showFigure

include("ResultViews.jl")
include("AbstractInterface.jl")
include("NoPlot.jl")
include("SilentNoPlot.jl")
#include("Utilities.jl")
include("UserFunctions.jl")
#include("CompareResults.jl")

end # module
