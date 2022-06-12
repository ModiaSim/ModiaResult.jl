module ModiaResult

const path = dirname(dirname(@__FILE__)) 

export quantity
export showResultInfo, resultInfo, timeSignalName, signalNames, SignalInfo
export lastSignalValue, signalValues, signalValuesForPlotting, defaultHeading
export OneValueSignal, BaseType, unitAsParseableString
export usingModiaPlot, usePlotPackage, usePreviousPlotPackage, currentPlotPackage
export plot, saveFigure, closeFigure, closeAllFigures, showFigure

include("Deprecated.jl")
include("AbstractInterface.jl")
include("NoPlot.jl")
include("SilentNoPlot.jl")
include("UserFunctions.jl")
include("OverloadedMethods.jl")

#include("Utilities.jl")
#include("CompareResults.jl")

end # module
