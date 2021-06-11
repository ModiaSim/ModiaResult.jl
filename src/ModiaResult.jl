module ModiaResult

const path = dirname(dirname(@__FILE__)) 

include("AbstractInterface.jl")
include("Utilities.jl")
include("OverloadedMethods.jl")
#include("CompareResults.jl")

end # module
