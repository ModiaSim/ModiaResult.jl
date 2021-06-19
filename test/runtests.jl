module Runtests

# Run all tests with SilentNoPlot (so not plots)

import ModiaResult
using Test

@testset "Test ModiaResult/test" begin
    ModiaResult.usePlotPackage("SilentNoPlot")
    include("include_all.jl")
    ModiaResult.usePreviousPlotPackage()
end

end