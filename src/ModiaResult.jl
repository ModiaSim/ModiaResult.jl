module ModiaResult

const path = dirname(dirname(@__FILE__)) 

export quantity
export showResultInfo, resultInfo, timeSignalName, signalNames, SignalInfo
export lastSignalValue, signalValues, signalValuesForLinePlots, defaultHeading
export OneValueSignal, ArraySignal, BaseType, unitAsParseableString
export @usingModiaPlot, usePlotPackage, usePreviousPlotPackage, currentPlotPackage
export plot, saveFigure, closeFigure, closeAllFigures, showFigure

include("AbstractResultInterface.jl")
include("NoPlot.jl")
include("SilentNoPlot.jl")
include("UserFunctions.jl")
include("OverloadedMethods.jl")
include("Deprecated.jl")

#include("Utilities.jl")
#include("CompareResults.jl")

end # module
