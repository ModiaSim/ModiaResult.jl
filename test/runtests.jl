module Runtests

# Run all tests with SilentNoPlot (so not plots)

import ModiaResult
using Test

ModiaResult.activate("SilentNoPlot")

@testset "Test ModiaResult/test" begin
    include("include_all.jl")
end

ModiaResult.activatePrevious()

end