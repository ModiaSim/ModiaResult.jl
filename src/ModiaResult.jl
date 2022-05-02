module ModiaResult

const path = dirname(dirname(@__FILE__)) 

include("ResultViews.jl")
include("AbstractInterface.jl")
include("NoPlot.jl")
include("SilentNoPlot.jl")
include("Utilities.jl")
include("OverloadedMethods.jl")
#include("CompareResults.jl")

end # module
