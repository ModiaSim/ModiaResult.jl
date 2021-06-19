module ModiaResult

const path = dirname(dirname(@__FILE__)) 

include("AbstractInterface.jl")
include("NoPlot.jl")
include("SilentNoPlot.jl")
include("Utilities.jl")
include("OverloadedMethods.jl")
#include("CompareResults.jl")
include("ResultViews.jl")

end # module
